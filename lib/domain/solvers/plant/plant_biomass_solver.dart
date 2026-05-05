import 'dart:math' as math;
import '../../models/plant.dart';
import '../../../core/biophysics_utils.dart';
import '../../../core/simulation_constants.dart';

/// Plant Biomass Solver with Farquhar-von Caemmerer-Berry (FvCB) Photosynthesis Model
///
/// Scientific basis:
/// - Farquhar et al. (1980): A biochemical model of photosynthetic CO2 assimilation
/// - von Caemmerer & Farquhar (1981): Some relationships between CO2 exchange
/// - Medlyn et al. (2002): Temperature response of parameters
///
/// The FvCB model calculates net CO2 assimilation (An) as:
/// An = min(Ac, Aj) - Rd
/// where:
/// - Ac = Rubisco-limited assimilation rate
/// - Aj = RuBP regeneration (light)-limited assimilation rate
/// - Rd = Day respiration
class PlantBiomassSolver {
  // ============ GROWTH PARAMETERS ============
  static const double phi = 0.5; // Extensibility coefficient [MPa⁻¹ s⁻¹]
  static const double yieldThreshold = 0.2; // Turgor threshold for growth [MPa]
  static const double maxHeight = 1.2; // Maximum plant height [m]
  static const double maxLai = 6.0; // Maximum LAI

  // ============ FARQUHAR MODEL PARAMETERS ============
  // Reference values at 25°C (298.15 K)

  /// Maximum carboxylation rate at 25°C [µmol CO2 m⁻² s⁻¹]
  /// Source: Typical C3 crop (Wullschleger, 1993)
  static const double vcmax25 = 80.0;

  /// Maximum electron transport rate at 25°C [µmol e⁻ m⁻² s⁻¹]
  /// Typically Jmax/Vcmax ≈ 1.67 (Wullschleger, 1993)
  static const double jmax25 = 130.0;

  /// Day respiration at 25°C [µmol CO2 m⁻² s⁻¹]
  /// Typically ~1-2% of Vcmax
  static const double rd25 = 1.5;

  /// Michaelis constant for CO2 at 25°C [µmol mol⁻¹ or µbar]
  static const double kc25 = 404.0;

  /// Michaelis constant for O2 at 25°C [mmol mol⁻¹ or mbar]
  static const double ko25 = 278.0;

  /// CO2 compensation point at 25°C (no Rd) [µmol mol⁻¹]
  static const double gammastar25 = 42.75;

  /// Atmospheric O2 concentration [mmol mol⁻¹]
  static const double oi = 210.0;

  /// Curvature factor for light response
  static const double theta = 0.7;

  /// Quantum yield of electron transport [mol e⁻ mol⁻¹ photons]
  static const double alpha = 0.3;

  // ============ TEMPERATURE RESPONSE PARAMETERS ============
  // Activation energies [J mol⁻¹] from Medlyn et al. (2002)
  static const double haVcmax = 65330.0;
  static const double haJmax = 43900.0;
  static const double haRd = 46390.0;
  static const double haKc = 79430.0;
  static const double haKo = 36380.0;
  static const double haGammastar = 37830.0;

  // Deactivation parameters for Jmax (peaked response)
  static const double hdJmax = 200000.0; // [J mol⁻¹]
  static const double dsJmax = 650.0; // [J mol⁻¹ K⁻¹]

  /// Gas constant [J mol⁻¹ K⁻¹]
  static const double gasR = 8.314;

  /// Reference temperature [K]
  static const double tRef = 298.15;

  /// Calculates actual growth rate based on turgor, nutrients, toxicity and maturity.
  static double calculateGrowthRate(
    Plant plant,
    double turgor,
    double nStressFactor,
    double toxicityFactor,
    double co2Factor,
  ) {
    final double baseGrowthRate =
        phi * (turgor - yieldThreshold).clamp(0.0, 1.0);
    final double maturityFactor = (1.0 - plant.height / maxHeight).clamp(
      0.0,
      1.0,
    );

    return baseGrowthRate *
        nStressFactor *
        toxicityFactor *
        maturityFactor *
        co2Factor *
        5.0e-7;
  }

  /// Calculates biomass changes using Farquhar photosynthesis model.
  ///
  /// Parameters:
  /// - plant: Current plant state
  /// - actualGrowthRate: Growth limitation from turgor/nutrients
  /// - co2Concentration: Atmospheric CO2 [mol m⁻³] (0.017 ≈ 415 ppm)
  /// - tCelsius: Leaf temperature [°C]
  /// - par: Photosynthetically active radiation [µmol m⁻² s⁻¹]
  /// - stomatalConductance: gs [mol m⁻² s⁻¹]
  /// - dt: Time step [s]
  static (double total, double root) calculateBiomass(
    Plant plant,
    double actualGrowthRate,
    double co2Factor,
    double tCelsius,
    double dt, {
    double co2Concentration = SimulationConstants.atmCO2Default, // mol/m³
    double par = 500.0, // µmol m⁻² s⁻¹ (typical daytime average)
  }) {
    // Convert temperature to Kelvin
    final double tK = tCelsius + 273.15;

    // Get temperature-adjusted parameters
    final double vcmax = _temperatureResponseSimple(vcmax25, haVcmax, tK);
    final double jmax = _temperatureResponsePeaked(
      jmax25,
      haJmax,
      hdJmax,
      dsJmax,
      tK,
    );
    final double rd = _temperatureResponseSimple(rd25, haRd, tK);
    final double kc = _temperatureResponseSimple(kc25, haKc, tK);
    final double ko = _temperatureResponseSimple(ko25, haKo, tK);
    final double gammastar = _temperatureResponseSimple(
      gammastar25,
      haGammastar,
      tK,
    );

    // Convert CO2 concentration to µmol mol⁻¹ (ppm)
    // 0.017 mol/m³ at STP ≈ 415 ppm
    final double ca =
        co2Concentration * 1000000.0 / 41.0; // Approximate conversion

    // Estimate internal CO2 (Ci) from stomatal conductance
    // Ci/Ca ratio typically 0.7-0.8 for C3 plants under normal conditions
    // Lower when stressed (stomata close)
    final double ciCaRatio =
        0.7 + 0.1 * (plant.stomatalConductance / 0.4).clamp(0.0, 1.0);
    final double ci = ca * ciCaRatio;

    // Calculate Rubisco-limited assimilation (Ac)
    // Ac = Vcmax * (Ci - Γ*) / (Ci + Kc * (1 + Oi/Ko))
    final double ac = vcmax * (ci - gammastar) / (ci + kc * (1.0 + oi / ko));

    // Calculate electron transport rate (J)
    // Using non-rectangular hyperbola
    final double j = _calculateJ(par, jmax);

    // Calculate RuBP regeneration-limited assimilation (Aj)
    // Aj = J * (Ci - Γ*) / (4 * Ci + 8 * Γ*)
    final double aj = j * (ci - gammastar) / (4.0 * ci + 8.0 * gammastar);

    // Net assimilation is minimum of Ac and Aj, minus respiration
    // An = min(Ac, Aj) - Rd
    final double an = math.min(ac, aj) - rd;

    // Apply stress factors (water stress already in stomatal conductance)
    // Growth rate factor reduces assimilation partitioning to growth
    final double effectiveAn = an * (actualGrowthRate * 1e6).clamp(0.1, 1.0);

    // Convert An [µmol CO2 m⁻² s⁻¹] to biomass [mg]
    // 1 µmol CO2 = 12 µg C = 12e-3 mg C
    // Assume ~45% C in dry matter, so 1 mg C ≈ 2.2 mg dry matter
    // Scale by LAI for canopy-level assimilation
    final double assimilationRate = effectiveAn.clamp(
      0.0,
      50.0,
    ); // µmol m⁻² s⁻¹
    final double carbonGain =
        assimilationRate * 12e-3 * 2.2 * plant.lai * dt; // mg dry matter

    // Maintenance respiration (Q10 = 2, ref 20°C = 293.15 K)
    final double q10Resp = BiophysicsUtils.q10Factor(tK);
    final double maintenanceResp =
        plant.totalBiomass * 0.002 * (dt / 86400.0) * q10Resp;

    // Net biomass change
    final double netGain = carbonGain - maintenanceResp;

    // Partition to roots vs shoots
    // Root fraction increases under stress
    final double stressFactor = (1.0 - plant.waterStressIndex).clamp(0.3, 1.0);
    final double rootAllocation =
        0.25 + 0.15 * (1.0 - stressFactor); // 25-40% to roots

    final double newTotalBiomass = (plant.totalBiomass + netGain).clamp(
      10.0,
      1e9,
    );
    final double newRootBiomass = (plant.rootBiomass + netGain * rootAllocation)
        .clamp(5.0, 1e8);

    return (newTotalBiomass, newRootBiomass);
  }

  /// Arrhenius temperature response (simple form without deactivation)
  /// f(T) = f(25) * exp(Ha * (T - Tref) / (Tref * R * T))
  static double _temperatureResponseSimple(
    double param25,
    double ha,
    double tK,
  ) {
    final double exponent = ha * (tK - tRef) / (tRef * gasR * tK);
    return param25 * math.exp(exponent);
  }

  /// Peaked temperature response (with high-temperature deactivation)
  /// Used for Jmax which decreases at very high temperatures
  static double _temperatureResponsePeaked(
    double param25,
    double ha,
    double hd,
    double ds,
    double tK,
  ) {
    final double numerator = ha * (tK - tRef) / (tRef * gasR * tK);
    final double denominator1 =
        1.0 + math.exp((ds * tRef - hd) / (gasR * tRef));
    final double denominator2 = 1.0 + math.exp((ds * tK - hd) / (gasR * tK));

    return param25 * math.exp(numerator) * denominator1 / denominator2;
  }

  /// Calculate electron transport rate using non-rectangular hyperbola
  /// θ*J² - (αI + Jmax)*J + α*I*Jmax = 0
  static double _calculateJ(double par, double jmax) {
    // Absorbed PAR (assuming 85% absorptance)
    final double i = par * 0.85;

    // Coefficients of quadratic: θ*J² - (αI + Jmax)*J + α*I*Jmax = 0
    final double a = theta;
    final double b = -(alpha * i + jmax);
    final double c = alpha * i * jmax;

    // Solve quadratic (take smaller root)
    final double discriminant = b * b - 4.0 * a * c;
    if (discriminant < 0) return jmax * 0.5; // Fallback

    final double j = (-b - math.sqrt(discriminant)) / (2.0 * a);
    return j.clamp(0.0, jmax);
  }
}

