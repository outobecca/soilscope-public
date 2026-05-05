import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../../core/periodic_table.dart';
import '../../core/biophysics_utils.dart';

/// Chemistry Solver: pH dynamics, redox chemistry, and ion exchange.
///
/// Scientific basis:
/// - Nernst equation for redox potential calculations
/// - Terminal Electron Acceptor (TEA) sequence for anaerobic processes
/// - Langmuir isotherm for phosphate sorption
/// - Gapon equation for cation exchange
///
/// References:
/// - Stumm & Morgan (1996): Aquatic Chemistry
/// - Reddy & DeLaune (2008): Biogeochemistry of Wetlands
/// - Sposito (2008): The Chemistry of Soils
class ChemistrySolver {
  // ============ REDOX CONSTANTS ============
  // pe values at pH 7 (standard conditions)
  // pe = Eh(mV) / 59.2 at 25°C

  /// O2/H2O redox couple pe° (aerobic respiration)
  static const double peO2 = 13.75;

  /// NO3-/N2 redox couple pe° (denitrification)
  static const double peNO3 = 12.65;

  /// MnO2/Mn2+ redox couple pe° (manganese reduction)
  static const double peMnO2 = 8.5;

  /// Fe(OH)3/Fe2+ redox couple pe° (iron reduction)
  static const double peFeOH3 = -0.1; // At pH 7

  /// SO4/H2S redox couple pe° (sulfate reduction)
  static const double peSO4 = -3.5;

  /// CO2/CH4 redox couple pe° (methanogenesis)
  static const double peCH4 = -4.0;

  // Eh thresholds (mV) for TEA transitions (Theoretical at pH 7)
  static const double ehAerobic = 750.0; // O2 dominant
  static const double ehNitrate = 650.0; // NO3- reduction starts
  static const double ehManganese = 400.0; // Mn(IV) reduction starts
  static const double ehIron = 50.0; // Fe(III) reduction starts
  static const double ehSulfate = -150.0; // SO4 reduction starts
  static const double ehMethane = -220.0; // Methanogenesis dominant

  /// Solves chemical equilibria, pH dynamics, and redox status with sub-stepping for stability
  static SoilProfile solve(SoilProfile profile, double dt) {
    const double maxSubStep = 600.0;
    int steps = (dt / maxSubStep).ceil().clamp(1, 100);
    double actualDt = dt / steps;

    SoilProfile currentProfile = profile;
    for (int s = 0; s < steps; s++) {
      currentProfile = _solveStep(currentProfile, actualDt);
    }
    return currentProfile;
  }

  static SoilProfile _solveStep(SoilProfile profile, double dt) {
    final updatedLayers = List<SoilLayer>.from(profile.layers);

    for (int i = 0; i < updatedLayers.length; i++) {
      updatedLayers[i] = _solveLayerChemistry(updatedLayers[i], dt);
    }

    return profile.copyWith(layers: updatedLayers);
  }

  static SoilLayer _solveLayerChemistry(SoilLayer layer, double dt) {
    // 0. Temperature Sensitivity (Q10 Rule)
    // Rate doubles every 10 degrees from base 20°C (293.15 K)
    final double q10 = BiophysicsUtils.q10Factor(layer.temperature);

    // ============ 1. REDOX CHEMISTRY (TEA Sequence) ============
    // Calculate redox potential using Nernst-based TEA ladder
    final redoxResult = _calculateRedoxState(layer, dt, q10);

    // ============ 2. PHOSPHATE DYNAMICS ============
    // P mobilization depends on redox state (Fe reduction releases P)
    final phosphateResult = _calculatePhosphateDynamics(
      layer,
      redoxResult.eh,
      redoxResult.fe2Plus,
      dt,
      q10,
    );

    // ============ 3. CATION EXCHANGE (Gapon) ============
    final cationResult = _calculateCationExchange(layer, dt, q10);

    // ============ 4. pH EMERGENCE ============
    final newPh = _calculatePH(
      layer,
      cationResult.baseSaturation,
      redoxResult.eh,
      dt,
      q10,
    );

    // ============ 5. ELECTRICAL CONDUCTIVITY ============
    final newEc = _calculateEC(layer, phosphateResult.pSol, cationResult.kSol);

    return layer.copyWith(
      redoxPotential: redoxResult.eh,
      ph: newPh,
      phosphateContent: phosphateResult.pSol,
      sorbedPhosphate: phosphateResult.pSorbed,
      potassiumContent: cationResult.kSol,
      exchangeablePotassium: cationResult.kEx,
      exchangeableAluminium: cationResult.alEx,
      ec: newEc,
      // New fields for redox-sensitive species
      // These would need to be added to SoilLayer model
    );
  }

  // ============ REDOX STATE CALCULATION ============

  /// Calculates redox potential (Eh) using Terminal Electron Acceptor sequence.
  /// Implements the "redox ladder" where different electron acceptors are consumed
  /// in order of decreasing energy yield: O2 → NO3- → Mn(IV) → Fe(III) → SO4 → CO2
  ///
  /// Reference: Stumm & Morgan (1996), Reddy & DeLaune (2008)
  static ({double eh, double pe, String dominantTEA, double fe2Plus})
  _calculateRedoxState(SoilLayer layer, double dt, double q10) {
    // Current O2 content determines aerobic/anaerobic boundary
    final double o2Fraction = (layer.oxygenContent / BiophysicsUtils.atmO2Saturation).clamp(1e-6, 1.0);

    double pe;
    String dominantTEA;
    double fe2Plus = 0.0; // Ferrous iron concentration

    if (layer.oxygenContent > 0.5) {
      // AEROBIC: O2 is the terminal electron acceptor
      // pe = pe°(O2) - (1/n) * log([red]/[ox]) -> pe = peO2 + 0.25 * log10([O2])
      dominantTEA = 'O2';
      pe = peO2 + 0.25 * math.log(o2Fraction) / math.ln10;
    } else if (layer.nitrateContent > 1.0) {
      // SUBOXIC: NO3- reduction (denitrification)
      // pe = pe°(NO3) + 0.2 * log10([NO3-])
      dominantTEA = 'NO3-';
      final double no3Fraction = (layer.nitrateContent / 50.0).clamp(1e-6, 1.0);
      pe = peNO3 + 0.2 * math.log(no3Fraction) / math.ln10;
    } else {
      // ANAEROBIC: O2 and NO3 depleted, sequential TEA reduction
      final double afp = (layer.porosity - layer.waterContent).clamp(0.0, 1.0);
      final double waterloggingFactor = 1.0 - (afp / 0.05).clamp(0.0, 1.0);

      if (waterloggingFactor < 0.5) {
        // Moderate anaerobic: Mn reduction
        dominantTEA = 'MnO2';
        pe = peMnO2 - 3.0 * waterloggingFactor;
      } else if (waterloggingFactor < 0.8) {
        // Strong anaerobic: Fe(III) reduction
        dominantTEA = 'Fe(III)';
        pe = peFeOH3 - 2.0 * (waterloggingFactor - 0.5);

        // Calculate Fe2+ accumulation
        final double feReductionRate = 1e-6 * q10 * waterloggingFactor;
        fe2Plus = feReductionRate * dt; // Accumulates over time
      } else {
        // Severe anaerobic: Sulfate reduction or methanogenesis
        if (layer.ec > 2.0) {
          dominantTEA = 'SO4';
          pe = peSO4;
        } else {
          dominantTEA = 'CH4';
          pe = peCH4;
        }
      }
    }

    // Convert pe to Eh (mV)
    // Eh = pe × 59.16 mV at 25°C
    final double tempFactor = layer.temperature / 298.15;
    double eh = pe * 59.16 * tempFactor;
    eh = eh.clamp(-300.0, 850.0);

    return (eh: eh, pe: pe, dominantTEA: dominantTEA, fe2Plus: fe2Plus);
  }

  // ============ PHOSPHATE DYNAMICS ============

  /// Calculates phosphate sorption/desorption with redox coupling.
  /// Fe(III) reduction under anaerobic conditions releases sorbed P.
  ///
  /// Reference:
  /// - Langmuir isotherm for sorption
  /// - Reddy & DeLaune (2008) for redox-P coupling
  static ({double pSol, double pSorbed}) _calculatePhosphateDynamics(
    SoilLayer layer,
    double eh,
    double fe2Plus,
    double dt,
    double q10,
  ) {
    // pH-dependent fixation
    // Al/Fe fixation strong at low pH, Ca fixation at high pH
    double alFeFixation = math.exp(-2.0 * (layer.ph - 4.0)).clamp(0.0, 5.0);
    double caFixation = math.exp(2.0 * (layer.ph - 8.5)).clamp(0.0, 5.0);
    double phFactor = 1.0 + alFeFixation + caFixation;

    // REDOX COUPLING: Fe reduction releases P
    // Under low Eh, Fe(III)-P complexes dissolve
    double redoxReleaseFactor = 1.0;
    double feReleasedP = 0.0;
    if (eh < ehIron) {
      // P release increases as Eh drops below Fe threshold
      final double reductionIntensity = (ehIron - eh) / (ehIron - ehSulfate);
      redoxReleaseFactor = 1.0 - 0.7 * reductionIntensity.clamp(0.0, 1.0);

      // Direct release from Fe2+ accumulation
      // Each mol Fe2+ releases ~0.1 mol P (simplified stoichiometry)
      feReleasedP = fe2Plus * 0.1 * 31.0; // mg/kg P
    }

    // Effective Langmuir parameters
    const double qMaxP = 300.0; // mg/kg maximum capacity
    final double kLP = 0.15 * phFactor * redoxReleaseFactor;
    final double kSorptionP = 1.2e-5 * q10;

    final double totalP = layer.phosphateContent + layer.sorbedPhosphate;

    // Solve Langmuir quadratic for equilibrium PSol
    final double bP = 1.0 + kLP * qMaxP - kLP * totalP;
    final double discriminantP = bP * bP + 4 * kLP * totalP;
    double targetPSol = 0.0;
    if (discriminantP >= 0) {
      targetPSol = (-bP + math.sqrt(discriminantP)) / (2 * kLP);
    }

    // Add redox-released P
    targetPSol += feReleasedP;

    final double deltaPSol =
        (targetPSol - layer.phosphateContent) *
        (1.0 - math.exp(-kSorptionP * dt));
    double newPSol = (layer.phosphateContent + deltaPSol).clamp(0.0, 1000.0);
    double newPSorbed = (totalP - newPSol).clamp(0.0, 3000.0);

    return (pSol: newPSol, pSorbed: newPSorbed);
  }

  // ============ CATION EXCHANGE ============

  /// Calculates competitive cation exchange using simplified Gapon equation.
  /// K+/Ca2+ exchange on clay surfaces.
  ///
  /// Reference: Sposito (2008)
  static ({double kSol, double kEx, double alEx, double baseSaturation})
  _calculateCationExchange(SoilLayer layer, double dt, double q10) {
    const double kGK = 0.5; // Gapon constant for K/Ca exchange
    final double kSorptionCations = 2.0e-4 * q10;

    final double kMass = PeriodicTable.getElement('K').atomicMass;
    final double caMass = PeriodicTable.getElement('Ca').atomicMass;
    final double mgMass = PeriodicTable.getElement('Mg').atomicMass;

    final double totalK = layer.potassiumContent + layer.exchangeablePotassium;

    // Solution divalent molarity (mol/L)
    final double solDivalentMolar =
        (layer.solutionCalcium / caMass + layer.solutionMagnesium / mgMass) /
        1000.0;
    final double denominator = math.sqrt(math.max(1e-6, solDivalentMolar));

    final double kSolMolar = (layer.potassiumContent / kMass) / 1000.0;

    // Target Potassium saturation on CEC (%)
    double targetKExPercentage = (kGK * kSolMolar / denominator).clamp(
      0.0,
      0.25,
    );

    // targetKEx in mg/kg
    double targetKExMgKg = targetKExPercentage * layer.cec * kMass * 10.0;

    final double deltaKEx =
        (targetKExMgKg - layer.exchangeablePotassium) *
        (1.0 - math.exp(-kSorptionCations * dt));
    double newKEx = (layer.exchangeablePotassium + deltaKEx).clamp(0.0, 5000.0);
    double newKSol = (totalK - newKEx).clamp(0.0, 1000.0);

    // Base saturation calculation
    final double exKcmol = newKEx / (kMass * 10.0);
    final double exCacmol = layer.exchangeableCalcium / (caMass * 5.0);
    final double exMgcmol = layer.exchangeableMagnesium / (mgMass * 5.0);

    double baseSaturation = (exKcmol + exCacmol + exMgcmol) / layer.cec;
    baseSaturation = baseSaturation.clamp(0.0, 1.0);

    final double acidSat = 1.0 - baseSaturation;
    double newExAl = acidSat * layer.cec * 90.0; // cmol to mg/kg Al

    return (
      kSol: newKSol,
      kEx: newKEx,
      alEx: newExAl,
      baseSaturation: baseSaturation,
    );
  }

  // ============ pH CALCULATION ============

  /// Calculates soil pH based on:
  /// - Base saturation (dominant control)
  /// - CO2 dissolution (carbonic acid effect)
  /// - Redox state (proton consumption/production)
  ///
  /// Reference: Sposito (2008), McBride (1994)
  static double _calculatePH(
    SoilLayer layer,
    double baseSaturation,
    double eh,
    double dt,
    double q10,
  ) {
    // Base pH from base saturation (empirical relationship)
    double targetPh = 4.0 + 3.5 * baseSaturation;

    // CO2 effect (carbonic acid)
    // High CO2 from respiration acidifies soil solution
    if (layer.co2Content > 0.01) {
      final double co2Shift =
          0.5 * math.log(layer.co2Content / 0.02) / math.ln10;
      targetPh -= co2Shift;
    }

    // Redox effect on pH
    // Fe(III) reduction consumes H+: Fe(OH)3 + 3H+ + e- → Fe2+ + 3H2O
    // This raises pH in anaerobic conditions
    if (eh < ehIron) {
      final double reductionIntensity = (ehIron - eh) / 300.0;
      targetPh += 0.5 * reductionIntensity.clamp(0.0, 1.0);
    }

    // Nitrification effect (acidifying)
    // NH4+ + 2O2 → NO3- + 2H+ + H2O
    // Only in aerobic conditions
    if (eh >= ehAerobic && layer.ammoniumContent > 5.0) {
      targetPh -= 0.1 * (layer.ammoniumContent / 50.0).clamp(0.0, 0.5);
    }

    // pH kinetics (approaches target)
    final double newPh =
        layer.ph + (targetPh - layer.ph) * (1.0 - math.exp(-2e-5 * q10 * dt));

    return newPh.clamp(3.5, 9.0);
  }

  // ============ ELECTRICAL CONDUCTIVITY ============

  /// Calculates EC from total dissolved ions.
  static double _calculateEC(SoilLayer layer, double pSol, double kSol) {
    final theta = layer.waterContent.clamp(0.01, 1.0);
    final rho = layer.bulkDensity;
    
    double totalMeqL = 0;
    
    // Anions
    totalMeqL += (layer.nitrateContent * rho) / (62.0 * theta * 1000.0); // NO3-
    totalMeqL += (pSol * rho) / (97.0 * theta * 1000.0); // H2PO4-
    
    // Cations
    totalMeqL += (layer.ammoniumContent * rho) / (18.0 * theta * 1000.0); // NH4+
    totalMeqL += (kSol * rho) / (39.1 * theta * 1000.0); // K+
    totalMeqL += (layer.solutionCalcium * rho) / (20.05 * theta * 1000.0); // Ca2+
    totalMeqL += (layer.solutionMagnesium * rho) / (12.15 * theta * 1000.0); // Mg2+
    
    // Add contribution from other trace elements (average eq weight ~35)
    for (final val in layer.traceElements.values) {
       totalMeqL += (val * rho) / (35.0 * theta * 1000.0);
    }
    
    // Base salinity factor related to clay content (intrinsic salts)
    final salinityBase = layer.clayFraction * 1.5;
    
    return (totalMeqL * 0.1) + (salinityBase * 0.05);
  }
}
