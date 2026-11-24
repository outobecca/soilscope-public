import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../../core/simulation_constants.dart';
import '../../core/biophysics_utils.dart';
import '../../core/model_config.dart';

/// Microbial Enzyme Kinetics Solver
///
/// Implements Michaelis-Menten enzyme kinetics for key soil processes:
/// - Urease: NH4+ release from urea/organic N
/// - Phosphatase: P release from organic P compounds
/// - Cellulase/β-glucosidase: C release from cellulose/plant residues
/// - Protease: N release from proteins
///
/// Scientific basis:
/// - Michaelis-Menten: v = Vmax × [S] / (Km + [S])
/// - pH optimum curves for each enzyme
/// - Temperature response (Q10 and Arrhenius)
/// - Substrate inhibition at high concentrations
///
/// References:
/// - Schimel & Weintraub (2003): The implications of exoenzyme activity on microbial C and N limitation
/// - Burns et al. (2013): Soil enzymes in a changing environment
/// - German et al. (2011): Optimization of hydrolytic and oxidative enzyme methods
class MicrobialEnzymesSolver {
  // ============ ENZYME PARAMETERS ============

  // --- UREASE ---
  // Catalyzes: Urea → 2NH4+ + CO2
  // Optimal pH: 6.5-7.0
  /// Vmax for urease [mg N kg⁻¹ h⁻¹]
  static double get vmaxUrease => ModelConfig.of('microbialEnzymes.vmaxUrease');

  /// Km for urease [mg N kg⁻¹] (substrate affinity)
  static double get kmUrease => ModelConfig.of('microbialEnzymes.kmUrease');

  /// Optimal pH for urease activity
  static double get phOptUrease =>
      ModelConfig.of('microbialEnzymes.phOptUrease');

  /// pH sensitivity parameter
  static double get phSensUrease =>
      ModelConfig.of('microbialEnzymes.phSensUrease');

  // --- PHOSPHATASE (Acid + Alkaline) ---
  // Catalyzes: Organic-P → PO4³⁻
  // Acid phosphatase optimal pH: 5.0-6.0
  // Alkaline phosphatase optimal pH: 8.0-9.0
  /// Vmax for phosphatase [mg P kg⁻¹ h⁻¹]
  static double get vmaxPhosphatase =>
      ModelConfig.of('microbialEnzymes.vmaxPhosphatase');

  /// Km for phosphatase [mg P kg⁻¹]
  static double get kmPhosphatase =>
      ModelConfig.of('microbialEnzymes.kmPhosphatase');

  /// Optimal pH for acid phosphatase
  static double get phOptAcidPhos =>
      ModelConfig.of('microbialEnzymes.phOptAcidPhos');

  /// Optimal pH for alkaline phosphatase
  static double get phOptAlkPhos =>
      ModelConfig.of('microbialEnzymes.phOptAlkPhos');

  // --- β-GLUCOSIDASE / CELLULASE ---
  // Catalyzes: Cellulose → Glucose → CO2
  // Optimal pH: 5.0-6.0
  /// Vmax for cellulase [mg C kg⁻¹ h⁻¹]
  static double get vmaxCellulase =>
      ModelConfig.of('microbialEnzymes.vmaxCellulase');

  /// Km for cellulase [mg C kg⁻¹]
  static double get kmCellulase =>
      ModelConfig.of('microbialEnzymes.kmCellulase');

  /// Optimal pH for cellulase
  static double get phOptCellulase =>
      ModelConfig.of('microbialEnzymes.phOptCellulase');

  /// pH sensitivity for cellulase
  static double get phSensCellulase =>
      ModelConfig.of('microbialEnzymes.phSensCellulase');

  // --- PROTEASE ---
  // Catalyzes: Proteins → Amino acids → NH4+
  // Optimal pH: 7.0-8.0
  /// Vmax for protease [mg N kg⁻¹ h⁻¹]
  static double get vmaxProtease =>
      ModelConfig.of('microbialEnzymes.vmaxProtease');

  /// Km for protease [mg N kg⁻¹]
  static double get kmProtease => ModelConfig.of('microbialEnzymes.kmProtease');

  /// Optimal pH for protease
  static double get phOptProtease =>
      ModelConfig.of('microbialEnzymes.phOptProtease');

  // --- GENERAL PARAMETERS ---
  /// Reference temperature [K]
  static double get tRef => ModelConfig.of('microbialEnzymes.tRef'); // 20°C
  /// Q10 for enzyme activity
  static double get q10Enzyme => ModelConfig.of('microbialEnzymes.q10Enzyme');

  /// Activation energy for Arrhenius [J mol⁻¹]
  static double get activationEnergy =>
      ModelConfig.of('microbialEnzymes.activationEnergy');

  /// Gas constant [J mol⁻¹ K⁻¹]
  static double get gasConstant => ModelConfig.of('gasConstant');

  /// Substrate inhibition constant (Ki/Km ratio)
  static double get substrateInhibitionRatio =>
      ModelConfig.of('microbialEnzymes.substrateInhibitionRatio');

  /// Runs enzyme-mediated transformations for the soil profile
  static SoilProfile solve(SoilProfile profile, double dt) {
    // Convert dt from seconds to hours for enzyme rates
    final double dtHours = dt / 3600.0;

    final updatedLayers = List<SoilLayer>.from(profile.layers);

    for (int i = 0; i < updatedLayers.length; i++) {
      updatedLayers[i] = _solveLayerEnzymes(updatedLayers[i], dtHours);
    }

    return profile.copyWith(layers: updatedLayers);
  }

  static SoilLayer _solveLayerEnzymes(SoilLayer layer, double dtHours) {
    // Environmental modifiers
    final double fTemp = _temperatureResponse(layer.temperature);
    final double fMoisture = _moistureResponse(
      layer.waterContent,
      layer.porosity,
    );
    final double fRedox = _redoxResponse(layer.redoxPotential);

    // --- RHIZOSPHERE PRIMING EFFECT ---
    // Labile C (exudates) stimulates enzyme production
    final double vMaxPriming = ModelConfig.of('microbialEnzymes.vMaxPriming');
    final double kmPriming = ModelConfig.of('microbialEnzymes.kmPriming');
    final double basePrimingFactor =
        vMaxPriming * layer.labileCarbon / (kmPriming + layer.labileCarbon);

    // Hotspot-driven priming (additional boost from biological "hubs")
    // This represents the concentrated enzymatic activity at root-microbe interfaces
    double hotspotBoost = 0.0;
    for (final h in layer.hotspots) {
      // Hotspots provide a localized boost to the enzyme pool
      hotspotBoost += h.intensity * 0.4;
    }

    final double totalPrimingFactor = (basePrimingFactor + hotspotBoost).clamp(
      0.0,
      5.0,
    );

    // Enzyme pool scales with microbial biomass and is boosted by priming
    final double enzymePool =
        (layer.microbialBiomass / 100.0) * (1.0 + totalPrimingFactor);

    // C/N constraint for net N mineralization
    // Mineralization peaks when C/N < 20, and drops towards 0 as C/N approaches 30.
    double nMinFactor = 1.0;
    if (layer.cnRatio > 20.0) {
      nMinFactor = math.max(0.0, 1.0 - (layer.cnRatio - 20.0) / 10.0);
    }

    // ============ UREASE ============
    final ureaseResult = _calculateUreaseActivity(
      layer.organicNitrogen,
      layer.ph,
      fTemp,
      fMoisture,
      enzymePool * nMinFactor,
      dtHours,
    );

    // ============ PHOSPHATASE ============
    final double organicP = layer.particulateOrganicMatter * 0.001;
    final phosphataseResult = _calculatePhosphataseActivity(
      organicP,
      layer.ph,
      fTemp,
      fMoisture,
      enzymePool,
      dtHours,
    );

    // ============ CELLULASE / β-GLUCOSIDASE ============
    final cellulaseResult = _calculateCellulaseActivity(
      layer.particulateOrganicMatter,
      layer.ph,
      fTemp,
      fMoisture,
      fRedox,
      enzymePool,
      dtHours,
    );

    // ============ PROTEASE ============
    final proteaseResult = _calculateProteaseActivity(
      layer.organicNitrogen,
      layer.ph,
      fTemp,
      fMoisture,
      enzymePool * nMinFactor,
      dtHours,
    );

    // ============ MICROBIAL TURNOVER (Moved from AggregationSolver) ============
    final double dtSeconds = dtHours * 3600.0;
    final double deathRate = SimulationConstants.microbialDeathRate;

    // Death scales with temperature and biomass
    final double microbialDeath =
        layer.microbialBiomass * deathRate * fTemp * dtSeconds;

    // MAOM Stabilization (necromass capture by minerals)
    // Task 3/6: Moved to AggregationSolver to act as Single Source of Truth for Stable Carbon.
    // Enzymes solver now only handles the generation of POM (necromass detritus).

    // ============ UPDATE POOLS ============
    // NH4+ gains from urease and protease
    final double nh4Gain =
        ureaseResult.nh4Produced + proteaseResult.nh4Produced;

    // PO4 gains from phosphatase
    final double po4Gain = phosphataseResult.po4Produced;

    // Organic N losses
    final double orgNLoss =
        ureaseResult.substrateConsumed + proteaseResult.substrateConsumed;

    // POM losses from cellulase (C mineralization)
    final double pomLoss = cellulaseResult.substrateConsumed;

    // Microbial biomass gains from C assimilation (CUE ~ 0.35)
    // and losses from death
    final double cueEnzyme = ModelConfig.of('microbialEnzymes.cueEnzyme');
    final double biomassGain =
        cellulaseResult.substrateConsumed * cueEnzyme * 0.1;

    final double newMicrobialBiomass =
        (layer.microbialBiomass + biomassGain - microbialDeath).clamp(
          1.0,
          1000.0,
        );

    // Carbon pool sync (POM vs Labile)
    // All death now goes to POM; AggregationSolver will later "promote" some of this to MAOM.
    final double newPom =
        (layer.particulateOrganicMatter - pomLoss + microbialDeath).clamp(
          0.0,
          1000.0,
        );

    return layer.copyWith(
      ammoniumContent: (layer.ammoniumContent + nh4Gain).clamp(0.0, 500.0),
      phosphateContent: (layer.phosphateContent + po4Gain).clamp(0.0, 1000.0),
      organicNitrogen: (layer.organicNitrogen - orgNLoss).clamp(0.0, 10000.0),
      particulateOrganicMatter: newPom,
      labileCarbon: newPom, // Maintain sync between POM and Labile C
      organicCarbon: newPom + layer.mineralAssociatedOrganicMatter,
      microbialBiomass: newMicrobialBiomass,
    );
  }

  // ============ ENZYME ACTIVITY CALCULATIONS ============

  /// Michaelis-Menten with substrate inhibition
  /// v = Vmax × [S] / (Km + [S] + [S]²/Ki)
  static double _michaelisWithInhibition(
    double substrate,
    double vmax,
    double km,
    double kiRatio,
  ) {
    if (substrate <= 0) return 0.0;

    final double ki = km * kiRatio;
    final double denominator = km + substrate + (substrate * substrate) / ki;
    return vmax * substrate / denominator;
  }

  /// pH response function (Gaussian-like)
  /// f(pH) = exp(-((pH - pHopt)² / (2σ²)))
  static double _phResponse(double ph, double phOpt, double sensitivity) {
    final double deviation = ph - phOpt;
    double response = math.exp(
      -(deviation * deviation) / (2.0 * sensitivity * sensitivity),
    );
    // Sharp penalty below pH 5.0 (acidic conditions severely limit microbial action)
    if (ph < 5.0) {
      response *= math.exp(-2.0 * (5.0 - ph));
    }
    return response;
  }

  /// Temperature response (Q10 with denaturation at high T)
  static double _temperatureResponse(double tempK) {
    // Q10 component — delegated to centralized BiophysicsUtils (DRY)
    final double q10Factor = BiophysicsUtils.q10Factor(
      tempK,
      q10: q10Enzyme,
      tRef: tRef,
    );

    // High temperature denaturation (proteins denature above ~50°C)
    double denaturationFactor = 1.0;
    if (tempK > 318.15) {
      // Above 45°C
      denaturationFactor = math.exp(-(tempK - 318.15) / 10.0);
    }

    // Low temperature limitation
    double lowTempFactor = 1.0;
    if (tempK < 278.15) {
      // Below 5°C
      lowTempFactor = (tempK - 268.15) / 10.0; // Linear ramp from -5°C
      lowTempFactor = lowTempFactor.clamp(0.0, 1.0);
    }

    return (q10Factor * denaturationFactor * lowTempFactor).clamp(0.0, 5.0);
  }

  /// Moisture response — delegated to centralized BiophysicsUtils (DRY).
  /// Optimal at ~60% WFPS, identical piecewise-linear curve.
  static double _moistureResponse(double waterContent, double porosity) {
    return BiophysicsUtils.moistureActivityFactor(waterContent, porosity);
  }

  /// Redox response (aerobic enzymes inhibited under anaerobic conditions)
  static double _redoxResponse(double eh) {
    if (eh > 300.0) return 1.0; // Fully aerobic
    if (eh < 0.0) return 0.2; // Anaerobic (only anaerobic enzymes active)
    return 0.2 + 0.8 * (eh / 300.0); // Linear transition
  }

  // ============ SPECIFIC ENZYME CALCULATIONS ============

  /// Urease activity: Organic N → NH4+
  static ({double nh4Produced, double substrateConsumed})
  _calculateUreaseActivity(
    double organicN,
    double ph,
    double fTemp,
    double fMoisture,
    double enzymePool,
    double dtHours,
  ) {
    final double fPh = _phResponse(ph, phOptUrease, phSensUrease);
    final double effectiveVmax =
        vmaxUrease * fTemp * fMoisture * fPh * enzymePool;

    final double rate = _michaelisWithInhibition(
      organicN,
      effectiveVmax,
      kmUrease,
      substrateInhibitionRatio,
    );

    final double consumed = (rate * dtHours).clamp(
      0.0,
      organicN * 0.1,
    ); // Max 10% per step

    return (nh4Produced: consumed, substrateConsumed: consumed);
  }

  /// Phosphatase activity: Organic P → PO4
  /// Includes both acid and alkaline phosphatase
  static ({double po4Produced, double substrateConsumed})
  _calculatePhosphataseActivity(
    double organicP,
    double ph,
    double fTemp,
    double fMoisture,
    double enzymePool,
    double dtHours,
  ) {
    // Acid phosphatase dominates at low pH
    final double fPhAcid = _phResponse(ph, phOptAcidPhos, 1.5);
    // Alkaline phosphatase dominates at high pH
    final double fPhAlk = _phResponse(ph, phOptAlkPhos, 1.5);

    // Combined activity (both can be present)
    final double combinedPhFactor = math.max(fPhAcid, fPhAlk);

    final double effectiveVmax =
        vmaxPhosphatase * fTemp * fMoisture * combinedPhFactor * enzymePool;

    final double rate = _michaelisWithInhibition(
      organicP,
      effectiveVmax,
      kmPhosphatase,
      substrateInhibitionRatio,
    );

    final double consumed = (rate * dtHours).clamp(0.0, organicP * 0.1);

    return (po4Produced: consumed, substrateConsumed: consumed);
  }

  /// Cellulase/β-glucosidase activity: POM (cellulose) → CO2 + microbial C
  static ({double co2Produced, double substrateConsumed})
  _calculateCellulaseActivity(
    double pom,
    double ph,
    double fTemp,
    double fMoisture,
    double fRedox,
    double enzymePool,
    double dtHours,
  ) {
    final double fPh = _phResponse(ph, phOptCellulase, phSensCellulase);

    // Cellulase is primarily aerobic
    final double effectiveVmax =
        vmaxCellulase * fTemp * fMoisture * fPh * fRedox * enzymePool;

    final double rate = _michaelisWithInhibition(
      pom,
      effectiveVmax,
      kmCellulase,
      substrateInhibitionRatio,
    );

    final double consumed = (rate * dtHours).clamp(
      0.0,
      pom * 0.05,
    ); // Max 5% per step

    // ~60% of C goes to CO2 (1 - CUE)
    final double co2 = consumed * 0.6;

    return (co2Produced: co2, substrateConsumed: consumed);
  }

  /// Protease activity: Protein-N → Amino acids → NH4+
  static ({double nh4Produced, double substrateConsumed})
  _calculateProteaseActivity(
    double organicN,
    double ph,
    double fTemp,
    double fMoisture,
    double enzymePool,
    double dtHours,
  ) {
    final double fPh = _phResponse(ph, phOptProtease, 1.5);
    final double effectiveVmax =
        vmaxProtease * fTemp * fMoisture * fPh * enzymePool;

    // Protease acts on protein fraction of organic N (~30%)
    final double proteinN = organicN * 0.3;

    final double rate = _michaelisWithInhibition(
      proteinN,
      effectiveVmax,
      kmProtease,
      substrateInhibitionRatio,
    );

    final double consumed = (rate * dtHours).clamp(0.0, proteinN * 0.1);

    return (nh4Produced: consumed, substrateConsumed: consumed);
  }
}
