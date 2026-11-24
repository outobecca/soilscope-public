/// Runtime source of truth for the tunable parameters used by the solvers.
///
/// The defaults reproduce the model before this class existed. The app loads
/// an optional override file at startup (`ModelConfigRepository`); tests and
/// tuning tools can call [applyOverrides] directly. Values must stay finite
/// and keys must be known, so a typo cannot silently change a run.
class ModelConfig {
  const ModelConfig._();

  /// Defaults for all tunable model inputs. Rendering and layout constants
  /// deliberately stay in `SimulationConstants`.
  static const Map<String, double> defaults = {
    // Integration and plot-independent model defaults.
    'baseTickDelta': 2.0,
    'maxSubStep': 600.0,
    'maxSubStepsPerTick': 50,
    'nitrateMax': 1000.0,
    'ammoniumMax': 500.0,
    'phosphateMax': 1000.0,
    'potassiumMax': 1000.0,
    'organicMatterMax': 2000.0,
    'immobilizationCnThreshold': 25.0,
    'microbialCnTarget': 15.0,
    'gasConstant': 8.314,
    'atmCO2Default': 0.017,
    'co2HalfSat': 0.005,
    'stefanBoltzmann': 5.67e-8,
    'soilEmissivity': 0.95,
    'airEmissivity': 0.75,
    'solarConstantPeak': 800.0,
    'energySubStep': 60.0,
    'baseAirTemperature': 293.15,
    'hyphalGrowthRate': 0.005,
    'initialRootRadius': 0.025,
    'rootGrowthStep': 0.005,
    'rootBranchStep': 0.004,
    'maxRootsPerPlant': 350,
    'rootEnergyCostFactor': 120.0,
    'nitrogenHalfSat': 15.0,
    'maintenanceRespirationFraction': 0.002,
    'epsProdBase': 1.0e-6,
    'epsDecayBase': 5.0e-7,
    'fungiGrowthBase': 1.0e-7,
    'fungiDeathBase': 2.0e-7,
    'pomMinRate': 1.0e-8,
    'microbialDeathRate': 5.0e-8,
    'maomStabRate': 0.4,
    'ksatChangeRate': 1.0e-8,
    'evapBaseRate': 1.0e-8,
    'thetaMinBuffer': 0.001,
    // Solver kinetics and physiology.
    'plantBiomass.phi': 0.5,
    'plantBiomass.yieldThreshold': 0.2,
    'plantBiomass.maxHeight': 1.2,
    'plantBiomass.maxLai': 6.0,
    'plantBiomass.vcmax25': 80.0,
    'plantBiomass.jmax25': 130.0,
    'plantBiomass.rd25': 1.5,
    'plantBiomass.kc25': 404.0,
    'plantBiomass.ko25': 278.0,
    'plantBiomass.gammastar25': 42.75,
    'plantBiomass.oi': 210.0,
    'plantBiomass.theta': 0.7,
    'plantBiomass.alpha': 0.3,
    'plantBiomass.haVcmax': 65330.0,
    'plantBiomass.haJmax': 43900.0,
    'plantBiomass.haRd': 46390.0,
    'plantBiomass.haKc': 79430.0,
    'plantBiomass.haKo': 36380.0,
    'plantBiomass.haGammastar': 37830.0,
    'plantBiomass.hdJmax': 200000.0,
    'plantBiomass.dsJmax': 650.0,
    'plantBiomass.tRef': 298.15,
    'plantHydraulics.gsMax': 0.4,
    'plantHydraulics.maxTranspirationRate': 1.0e-8,
    'plantHydraulics.psiOsmotic': -0.8,
    'plantHydraulics.rootLp': 5.0e-8,
    'plantHydraulics.xylemKs': 2.0e-6,
    'plantHydraulics.plantCapacitance': 1.0e-5,
    'plantHydraulics.psiLeafCrit': -1.5,
    'plantHydraulics.psi50': -1.0,
    'plantHydraulics.vpdSensitivity': 0.5,
    'plantNutrientUptake.targetVm': -0.14,
    'plantNutrientUptake.faraday': 96485.3,
    'mycorrhiza.maxCarbonTransferFraction': 0.15,
    'mycorrhiza.maxHyphalDensity': 100.0,
    'mycorrhiza.hyphalTurnover': 0.15,
    'mycorrhiza.pUptakeEfficiency': 3.0,
    'mycorrhiza.nUptakeEfficiency': 1.5,
    'mycorrhiza.colonizationRate': 0.1,
    'mycorrhiza.maxColonization': 0.8,
    'mycorrhiza.cCostPerP': 100.0,
    'mycorrhiza.cCostPerN': 50.0,
    'mycorrhiza.minTempActivity': 278.15,
    'mycorrhiza.optTempActivity': 298.15,
    'chemistry.peO2': 13.75,
    'chemistry.peNO3': 12.65,
    'chemistry.peMnO2': 8.5,
    'chemistry.peFeOH3': -0.1,
    'chemistry.peSO4': -3.5,
    'chemistry.peCH4': -4.0,
    'chemistry.ehAerobic': 750.0,
    'chemistry.ehNitrate': 650.0,
    'chemistry.ehManganese': 400.0,
    'chemistry.ehIron': 50.0,
    'chemistry.ehSulfate': -150.0,
    'chemistry.ehMethane': -220.0,
    'gas.d0O2': 2.0e-5,
    'gas.d0CO2': 1.6e-5,
    'aggregation.q10': 2.0,
    'aggregation.tRef': 293.15,
    'microbialEnzymes.vmaxUrease': 50.0,
    'microbialEnzymes.kmUrease': 20.0,
    'microbialEnzymes.phOptUrease': 6.8,
    'microbialEnzymes.phSensUrease': 1.5,
    'microbialEnzymes.vmaxPhosphatase': 30.0,
    'microbialEnzymes.kmPhosphatase': 15.0,
    'microbialEnzymes.phOptAcidPhos': 5.5,
    'microbialEnzymes.phOptAlkPhos': 8.5,
    'microbialEnzymes.vmaxCellulase': 100.0,
    'microbialEnzymes.kmCellulase': 50.0,
    'microbialEnzymes.phOptCellulase': 5.5,
    'microbialEnzymes.phSensCellulase': 1.2,
    'microbialEnzymes.vmaxProtease': 40.0,
    'microbialEnzymes.kmProtease': 25.0,
    'microbialEnzymes.phOptProtease': 7.5,
    'microbialEnzymes.tRef': 293.15,
    'microbialEnzymes.q10Enzyme': 2.0,
    'microbialEnzymes.activationEnergy': 50000.0,
    'microbialEnzymes.substrateInhibitionRatio': 5.0,
    'nitrogenCycle.microbialTargetCN': 10.0,
    'nitrogenCycle.cue': 0.4,
    'microbialEnzymes.vMaxPriming': 2.0,
    'microbialEnzymes.kmPriming': 50.0,
    'microbialEnzymes.cueEnzyme': 0.35,
    'chemistry.qMaxP': 300.0,
    'chemistry.kGK': 0.5,
    'nutrient.dLNitrate': 1.9e-9,
    'nutrient.dLAmmonium': 1.5e-9,
    'nutrient.dLPotassium': 1.8e-9,
    'nutrient.dLPhosphate': 0.8e-9,
    'nitrogenCycle.kImm': 2.0e-5,
    'nitrogenCycle.kNit': 1.0e-6,
    'nitrogenCycle.kDenit': 5.0e-6,
    'nitrogenCycle.kBNF': 1.0e-8,
    'gas.dzSurf': 0.01,
    'gas.kMic': 1.0e-8,
    'gas.kRoot': 5.0e-10,
    'plant.maxSubStep': 1800.0,
    'plant.exudationFraction': 0.15,
    'plantNutrientUptake.baseEff': 0.05,
    'plantNutrientUptake.kmP': 5.0,
    'plantNutrientUptake.phCell': 7.2,
    'plantNutrientUptake.km': 10.0,
    'rootArchitecture.maxDevRadians': 0.2617993877991494,
    'hydrology.maxSteps': 2000.0,
  };

  static Map<String, double> _active = defaults;

  /// The currently active values, including any configuration overrides.
  static Map<String, double> get values => _active;

  /// Reads one active parameter. Throws when [key] is unknown, which
  /// keeps a stale solver key from silently reading a default.
  static double of(String key) =>
      _active[key] ?? (throw StateError('Unknown model parameter: $key'));

  /// Replaces the active set with [defaults] plus [overrides].
  static void applyOverrides(Map<String, double> overrides) {
    for (final entry in overrides.entries) {
      if (!defaults.containsKey(entry.key)) {
        throw ArgumentError.value(
          entry.key,
          'overrides',
          'Unknown model parameter',
        );
      }
      if (!entry.value.isFinite) {
        throw ArgumentError('Model parameter ${entry.key} is not finite');
      }
    }
    _active = Map.unmodifiable({...defaults, ...overrides});
  }

  /// Restores the built-in defaults, discarding configuration overrides.
  static void reset() => _active = defaults;
}
