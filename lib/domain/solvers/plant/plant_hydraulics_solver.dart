import 'dart:math' as math;
import '../../models/plant.dart';
import '../../models/soil_profile.dart';
import '../../../core/biophysics_utils.dart';

/// Logic for plant water relations: VPD, transpiration, turgor pressure, and SPAC coupling.
///
/// Scientific basis:
/// - Jarvis (2011): Compensatory water uptake and stress functions
/// - Tardieu & Simonneau (1998): ABA-mediated stomatal response
/// - Sperry et al. (2017): Hydraulic limitation and plant water transport
class PlantHydraulicsSolver {
  // ============ PHYSICAL CONSTANTS ============

  /// Maximum stomatal conductance [mol H2O m⁻² s⁻¹]
  /// Source: Typical C3 crop value (Medlyn et al., 2011)
  static const double gsMax = 0.4;

  /// Maximum transpiration rate [m³ H2O m⁻² leaf s⁻¹]
  static const double maxTranspirationRate = 1.0e-8;

  /// Osmotic potential at full turgor [MPa]
  /// Source: Typical crop mesophyll (Hsiao, 1973)
  static const double psiOsmotic = -0.8;

  /// Root hydraulic conductance per unit root length [m³ MPa⁻¹ m⁻¹ s⁻¹]
  /// Source: Steudle (2000) - root radial conductivity
  static const double rootLp = 5.0e-8;

  /// Stem xylem conductance [m³ MPa⁻¹ s⁻¹]
  /// Source: Typical herbaceous plant
  static const double xylemKs = 2.0e-6;

  /// Plant water capacitance [m³ MPa⁻¹]
  /// Source: Nobel (2009) - tissue elasticity
  static const double plantCapacitance = 1.0e-5;

  /// Critical leaf water potential for stomatal closure [MPa]
  /// Source: Tardieu & Simonneau (1998)
  static const double psiLeafCrit = -1.5;

  /// Leaf water potential at 50% stomatal closure [MPa]
  static const double psi50 = -1.0;

  /// Sensitivity parameter for stomatal response to VPD [kPa⁻¹]
  /// Source: Medlyn et al. (2011) optimal stomatal model
  static const double vpdSensitivity = 0.5;

  // ============ CORE CALCULATIONS ============

  /// Calculates Vapor Pressure Deficit (VPD) based on air temperature.
  /// Uses Tetens equation for saturation vapor pressure.
  ///
  /// Reference: Tetens (1930), Murray (1967)
  static double calculateVPD(
    double airTemperature, {
    double relativeHumidity = 0.5,
  }) {
    final double tCelsius = airTemperature - 273.15;
    // Tetens equation via centralized BiophysicsUtils (DRY)
    final double eSat = BiophysicsUtils.getSaturationVaporPressureCelsius(tCelsius);
    return eSat * (1.0 - relativeHumidity);
  }

  /// Calculates potential transpiration based on LAI and VPD.
  /// This represents atmospheric demand without soil water limitation.
  static double calculatePotentialTranspiration(Plant plant, double vpd) {
    return maxTranspirationRate * plant.lai * (vpd / 1.0).clamp(0.1, 5.0);
  }

  /// Calculates soil water potential for a single layer using van Genuchten model.
  ///
  /// Reference: van Genuchten (1980)
  /// Returns ψ in MPa (negative values indicate drier soil)
  static double calculateLayerPsi(
    double waterContent,
    double thetaR,
    double porosity,
    double vgAlpha,
    double vgN,
  ) {
    // BiophysicsUtils.thetaToPsi returns pressure head ψ [m] when α is in [1/m]
    // (as in SoilLayer.vgAlpha and BiophysicsUtils.getVGParams).
    final double psiHeadM = BiophysicsUtils.thetaToPsi(
      waterContent,
      thetaR,
      porosity,
      vgAlpha,
      vgN,
    );

    // Convert pressure head [m H2O] to water potential [MPa].
    // ψ(MPa) = ρ g h / 1e6, with ρ≈1000 kg/m³ and g≈9.80665 m/s².
    const double mH2OToMPa = 1000.0 * 9.80665 / 1e6; // 0.00980665 MPa per m
    return (psiHeadM * mH2OToMPa).clamp(-10.0, 0.0);
  }

  /// Calculates average soil water potential weighted by root density.
  /// Implements compensatory uptake: roots in wetter zones compensate for dry zones.
  ///
  /// Reference: Jarvis (2011) - Simple physics-based models of compensatory plant water uptake
  static double calculateAverageSoilPsi(
    SoilProfile profile,
    List<double> layerWeights,
    double totalRootWeight,
  ) {
    if (totalRootWeight <= 0) return -1.5;

    double sumPsi = 0.0;
    double sumWeight = 0.0;

    for (int i = 0; i < profile.layers.length; i++) {
      if (layerWeights[i] > 0) {
        final l = profile.layers[i];
        // Use van Genuchten for accurate ψ calculation
        final psi = calculateLayerPsi(
          l.waterContent,
          l.thetaR,
          l.porosity,
          l.vgAlpha,
          l.vgN,
        );

        // Compensatory weighting: wetter layers contribute more
        // f_comp = exp(-ψ/ψ_ref) where ψ_ref = -0.5 MPa
        final double compensatoryFactor = math.exp(psi / 0.5);
        final double effectiveWeight = layerWeights[i] * compensatoryFactor;

        sumPsi += psi * effectiveWeight;
        sumWeight += effectiveWeight;
      }
    }

    return sumWeight > 0 ? sumPsi / sumWeight : -1.5;
  }

  /// Calculates stomatal conductance reduction due to leaf water potential.
  /// Implements a sigmoidal response function.
  ///
  /// Reference: Tardieu & Simonneau (1998) - Stomatal control by ABA
  /// Returns factor [0, 1] where 1 = fully open, 0 = fully closed
  static double calculateStomatalStressFactor(double psiLeaf) {
    if (psiLeaf >= 0) return 1.0;
    if (psiLeaf <= psiLeafCrit) return 0.05; // Minimum conductance (cuticular)

    // Sigmoidal response: f = 1 / (1 + (ψ/ψ₅₀)^n)
    // n = 3 gives reasonable steepness
    final double ratio = psiLeaf / psi50;
    return 1.0 / (1.0 + math.pow(ratio.abs(), 3.0));
  }

  /// Calculates stomatal conductance reduction due to VPD (feedforward response).
  /// High VPD causes partial stomatal closure to prevent excessive water loss.
  ///
  /// Reference: Medlyn et al. (2011) - Optimal stomatal model
  /// Returns factor [0.2, 1.0]
  static double calculateVPDStressFactor(double vpd) {
    // f_vpd = 1 / (1 + vpd * sensitivity)
    // Ensures minimum conductance at very high VPD
    return (1.0 / (1.0 + vpd * vpdSensitivity)).clamp(0.2, 1.0);
  }

  /// Calculates actual transpiration considering soil water stress and VPD.
  /// This is the key SPAC integration function.
  ///
  /// T_actual = T_potential × f_stomatal(ψ_leaf) × f_vpd(VPD)
  ///
  /// Reference:
  /// - Jarvis (2011): Compensatory uptake
  /// - Sperry et al. (2017): Hydraulic limitation
  static ({double transpiration, double psiLeaf, double gs})
  calculateActualTranspiration(
    Plant plant,
    SoilProfile profile,
    List<double> layerWeights,
    double totalRootWeight,
    double vpd,
    double previousPsiLeaf,
    double dt,
  ) {
    // 1. Calculate soil-root interface potential
    final double psiSoil = calculateAverageSoilPsi(
      profile,
      layerWeights,
      totalRootWeight,
    );

    // 2. Calculate potential transpiration (atmospheric demand)
    final double potentialTrans = calculatePotentialTranspiration(plant, vpd);

    // 3. Calculate root system hydraulic conductance
    // K_root = Lp × total_root_length (simplified as root biomass proxy)
    final double rootConductance =
        rootLp * (plant.rootBiomass / 1000.0).clamp(0.01, 100.0);

    // 4. Iteratively solve for leaf water potential
    // At steady state: T = K_soil-leaf × (ψ_soil - ψ_leaf)
    // But we also need: T = gs × VPD × f(ψ_leaf)
    // Use Newton-Raphson or simple iteration

    double psiLeaf = previousPsiLeaf;
    for (int iter = 0; iter < 5; iter++) {
      // Stomatal and VPD stress factors
      final double fStomatal = calculateStomatalStressFactor(psiLeaf);
      final double fVPD = calculateVPDStressFactor(vpd);

      // Transpiration demand at current stomatal state
      // (We keep demand tied to potentialTrans for this simplified SPAC coupling.)
      final double transDemand = potentialTrans * fStomatal * fVPD;

      // Supply-limited transpiration (Ohm's law analogy)
      // T_supply = K × (ψ_soil - ψ_leaf)
      final double totalConductance =
          (rootConductance * xylemKs) / (rootConductance + xylemKs + 1e-12);
      final double transSupply =
          totalConductance * (psiSoil - psiLeaf).clamp(0.0, 10.0);

      // Actual transpiration is minimum of demand and supply
      final double actualTrans = math.min(transDemand, transSupply);

      // Update leaf water potential based on transpiration
      // ψ_leaf = ψ_soil - T / K
      final double newPsiLeaf =
          psiSoil - actualTrans / (totalConductance + 1e-12);

      // Damped update for stability
      psiLeaf = psiLeaf + 0.5 * (newPsiLeaf - psiLeaf);
    }

    // 5. Apply capacitance effect (time lag)
    // dψ/dt = (ψ_target - ψ_current) / τ
    // τ = C / K (time constant)
    final double timeConstant = plantCapacitance / (rootConductance + 1e-12);
    final double relaxationFactor = 1.0 - math.exp(-dt / (timeConstant + 1.0));
    final double finalPsiLeaf =
        previousPsiLeaf + (psiLeaf - previousPsiLeaf) * relaxationFactor;

    // 6. Final transpiration calculation with updated psiLeaf
    final double fStomatalFinal = calculateStomatalStressFactor(finalPsiLeaf);
    final double fVPDFinal = calculateVPDStressFactor(vpd);
    final double gsFinal = gsMax * fStomatalFinal * fVPDFinal;
    final double actualTransFinal = potentialTrans * fStomatalFinal * fVPDFinal;

    return (
      transpiration: actualTransFinal,
      psiLeaf: finalPsiLeaf,
      gs: gsFinal,
    );
  }

  /// Calculates turgor pressure based on leaf and osmotic potentials.
  /// Turgor = ψ_pressure = ψ_leaf - ψ_osmotic
  ///
  /// Reference: Hsiao (1973) - Plant responses to water stress
  static double calculateTurgor(double psiLeaf) {
    // Turgor pressure P = ψ_total - ψ_osmotic
    // When ψ_total approaches ψ_osmotic, turgor → 0 (wilting point)
    return (psiLeaf - psiOsmotic).clamp(0.0, 1.2);
  }

  /// Calculates water stress index [0-1] where 0 = no stress, 1 = severe stress.
  /// Useful for UI visualization and plant growth reduction.
  static double calculateWaterStressIndex(double psiLeaf) {
    if (psiLeaf >= -0.3) return 0.0; // No stress
    if (psiLeaf <= psiLeafCrit) return 1.0; // Maximum stress

    // Linear interpolation between thresholds
    return ((-0.3 - psiLeaf) / (-0.3 - psiLeafCrit)).clamp(0.0, 1.0);
  }

  /// Calculates relative water content (RWC) from leaf water potential.
  /// Useful for visualization of plant water status.
  ///
  /// Reference: Pressure-volume curve relationships
  static double calculateRWC(double psiLeaf) {
    // Simplified P-V relationship: RWC ≈ 1 - |ψ_leaf| × 0.3
    // At ψ = 0: RWC = 1.0 (fully turgid)
    // At ψ = -1.5: RWC ≈ 0.55 (wilting)
    return (1.0 + psiLeaf * 0.3).clamp(0.3, 1.0);
  }
}
