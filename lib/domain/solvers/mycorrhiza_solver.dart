import 'dart:math' as math;
import '../models/soil_layer.dart';
import '../models/soil_profile.dart';
import '../models/plant.dart';
import '../../core/simulation_constants.dart';
import '../../core/biophysics_utils.dart';

/// Mycorrhiza Symbiosis Solver
///
/// Models the mutualistic relationship between plant roots and mycorrhizal fungi:
/// - Arbuscular Mycorrhiza (AM) - most common, exchanges P for C
/// - Ectomycorrhiza (ECM) - common in trees, also N exchange
///
/// Key processes:
/// - Carbon transfer: Plant → Fungus (4-20% of photosynthate)
/// - Nutrient transfer: Fungus → Plant (P, N, micronutrients)
/// - Hyphal network expansion: Extends effective root zone 10-100x
/// - Water uptake enhancement: Hyphae access smaller pores
///
/// Scientific basis:
/// - Smith & Read (2008): Mycorrhizal Symbiosis
/// - Bever et al. (2010): Preferential allocation and carbon transfer
/// - Fellbaum et al. (2012): Carbon and nitrogen allocation
///
/// Integration with CPlantBox/CoupModel principles for C/N/P exchange
class MycorrhizaSolver {
  // ============ MYCORRHIZAL PARAMETERS ============

  /// Maximum carbon transfer to fungus as fraction of daily photosynthate
  /// Source: Smith & Read (2008) - typically 4-20%
  static const double maxCarbonTransferFraction = 0.15;

  /// Hyphal extension rate [m day⁻¹]
  /// Source: Typical AM fungi
  static const double hyphalGrowthRate = SimulationConstants.hyphalGrowthRate;

  /// Maximum hyphal density [m hyphae m⁻³ soil]
  static const double maxHyphalDensity = 100.0;

  /// Hyphal turnover rate [day⁻¹]
  /// Hyphae live 5-7 days on average
  static const double hyphalTurnover = 0.15;

  /// P uptake efficiency of hyphae relative to roots [dimensionless]
  /// Hyphae can access P in smaller pores
  static const double pUptakeEfficiency = 3.0;

  /// N uptake efficiency of hyphae [dimensionless]
  /// Less efficient than P but still significant
  static const double nUptakeEfficiency = 1.5;

  /// Colonization rate constant [day⁻¹]
  /// Rate at which fungi colonize new root tips
  static const double colonizationRate = 0.1;

  /// Maximum root colonization [fraction]
  static const double maxColonization = 0.8;

  /// Carbon cost per unit P transferred [g C / mg P]
  /// Based on stoichiometric exchange ratios
  static const double cCostPerP = 100.0;

  /// Carbon cost per unit N transferred [g C / mg N]
  static const double cCostPerN = 50.0;

  /// Minimum soil temperature for mycorrhizal activity [K]
  static const double minTempActivity = 278.15; // 5°C

  /// Optimal temperature for mycorrhizal activity [K]
  static const double optTempActivity = 298.15; // 25°C

  /// Solves mycorrhizal dynamics for one time step
  static ({SoilProfile profile, Plant plant, MycorrhizaState mycorrhizaState})
  solve(
    SoilProfile profile,
    Plant plant,
    MycorrhizaState previousState,
    double dt, {
    double dailyPhotosynthate = 0.0, // g C day⁻¹ from Farquhar model
  }) {
    // Convert dt to days for mycorrhiza kinetics
    final double dtDays = dt / 86400.0;

    // Environmental factors
    final double fTemp = _temperatureResponse(profile.layers.first.temperature);
    final double fMoisture = _moistureResponse(
      profile.layers.first.waterContent,
      profile.layers.first.porosity,
    );

    // 1. Root colonization dynamics
    final double colonization = _updateColonization(
      previousState.rootColonization,
      plant,
      fTemp,
      fMoisture,
      dtDays,
    );

    // 2. Hyphal network growth
    final hyphalResult = _updateHyphalNetwork(
      profile,
      plant,
      previousState,
      colonization,
      fTemp,
      fMoisture,
      dtDays,
    );

    // 3. Carbon allocation from plant to fungus
    final double carbonToFungus = _calculateCarbonTransfer(
      plant,
      colonization,
      hyphalResult.totalHyphalLength,
      dailyPhotosynthate,
      dtDays,
    );

    // 4. Nutrient transfer from fungus to plant
    final nutrientResult = _calculateNutrientTransfer(
      profile,
      hyphalResult.layerHyphalDensities,
      colonization,
      carbonToFungus,
      fTemp,
      dtDays,
    );

    // 5. Update soil nutrient pools (depletion by hyphae)
    final updatedProfile = _updateSoilNutrients(
      hyphalResult.profile, // Use the profile returned by _updateHyphalNetwork which has updated disturbance
      nutrientResult.pUptakeByLayer,
      nutrientResult.nUptakeByLayer,
    );

    // 6. Update plant nutrient status
    final updatedPlant = _updatePlantNutrients(
      plant,
      nutrientResult.totalPTransfer,
      nutrientResult.totalNTransfer,
    );

    // 7. Create new mycorrhiza state
    final newState = MycorrhizaState(
      rootColonization: colonization,
      totalHyphalLength: hyphalResult.totalHyphalLength,
      layerHyphalDensities: hyphalResult.layerHyphalDensities,
      carbonTransferredToday: carbonToFungus,
      pTransferredToday: nutrientResult.totalPTransfer,
      nTransferredToday: nutrientResult.totalNTransfer,
      fungalBiomass:
          previousState.fungalBiomass +
          carbonToFungus * 0.3 -
          previousState.fungalBiomass * hyphalTurnover * dtDays,
    );

    return (
      profile: updatedProfile,
      plant: updatedPlant,
      mycorrhizaState: newState,
    );
  }

  // ============ HELPER FUNCTIONS ============

  /// Temperature response function (optimum around 25°C)
  static double _temperatureResponse(double tempK) {
    if (tempK < minTempActivity) return 0.0;
    if (tempK > 313.15) return 0.1; // Above 40°C, minimal activity

    // Gaussian around optimum
    final double deviation = tempK - optTempActivity;
    return math.exp(-(deviation * deviation) / 200.0);
  }

  /// Moisture response (optimal at moderate moisture)
  static double _moistureResponse(double waterContent, double porosity) {
    return BiophysicsUtils.moistureActivityFactor(waterContent, porosity);
  }

  /// Updates root colonization level
  static double _updateColonization(
    double currentColonization,
    Plant plant,
    double fTemp,
    double fMoisture,
    double dtDays,
  ) {
    // Colonization increases based on root growth and environmental conditions
    final double rootGrowthFactor = (plant.rootBiomass / 1000.0).clamp(
      0.1,
      2.0,
    );
    final double colonizationIncrease =
        colonizationRate *
        (maxColonization - currentColonization) *
        rootGrowthFactor *
        fTemp *
        fMoisture *
        dtDays;

    // Natural decline (roots die, fungi die)
    final double colonizationDecline = currentColonization * 0.01 * dtDays;

    return (currentColonization + colonizationIncrease - colonizationDecline)
        .clamp(0.0, maxColonization);
  }

  /// Updates extramatrical hyphal network and handles cultivation disturbance
  static ({double totalHyphalLength, List<double> layerHyphalDensities, SoilProfile profile})
  _updateHyphalNetwork(
    SoilProfile profile,
    Plant plant,
    MycorrhizaState previousState,
    double colonization,
    double fTemp,
    double fMoisture,
    double dtDays,
  ) {
    final layerDensities = List<double>.filled(profile.layers.length, 0.0);
    double totalLength = 0.0;
    final updatedLayers = List<SoilLayer>.from(profile.layers);

    for (int i = 0; i < profile.layers.length; i++) {
      final layer = profile.layers[i];
      
      // Update Cultivation Disturbance State
      double currentDisturbance = layer.cultivationDisturbance;
      if (layer.isCultivated) {
        // Fast mechanical breaking
        currentDisturbance = (currentDisturbance + dtDays * 10.0).clamp(0.0, 1.0);
      } else if (currentDisturbance > 0.0) {
        // Gradual recovery if conditions are favorable
        if (fTemp > 0.1 && fMoisture > 0.1) {
            currentDisturbance = (currentDisturbance - dtDays * 0.05).clamp(0.0, 1.0);
        }
      }
      
      updatedLayers[i] = layer.copyWith(cultivationDisturbance: currentDisturbance);

      // Count roots in this layer
      final rootsInLayer = plant.rootSystem
          .where(
            (n) => n.z >= layer.depth && n.z <= layer.depth + layer.thickness,
          )
          .length;

      if (rootsInLayer > 0) {
        // Hyphal growth from colonized roots
        final double previousDensity =
            i < previousState.layerHyphalDensities.length
            ? previousState.layerHyphalDensities[i]
            : 0.0;

        // Growth proportional to colonization, roots, and available C
        final double growth =
            hyphalGrowthRate *
            colonization *
            rootsInLayer *
            fTemp *
            fMoisture *
            dtDays;

        // Turnover is massively increased by cultivation disturbance
        // Isaac (1992): Tillage disrupts the extraradical mycelial network
        final double disturbanceDecay = previousDensity * currentDisturbance * 5.0 * dtDays;
        final double turnover = (previousDensity * hyphalTurnover * dtDays) + disturbanceDecay;

        // New density (limited by soil pore space)
        final double maxInLayer =
            maxHyphalDensity * (1.0 - layer.clayFraction * 0.5) * (1.0 - currentDisturbance * 0.9);
        layerDensities[i] = (previousDensity + growth - turnover).clamp(
          0.0,
          maxInLayer,
        );

        totalLength += layerDensities[i] * layer.thickness;
      }
    }

    return (
      totalHyphalLength: totalLength,
      layerHyphalDensities: layerDensities,
      profile: profile.copyWith(layers: updatedLayers),
    );
  }

  /// Calculates carbon transfer from plant to fungus
  static double _calculateCarbonTransfer(
    Plant plant,
    double colonization,
    double hyphalLength,
    double dailyPhotosynthate,
    double dtDays,
  ) {
    // Carbon transfer depends on colonization level and hyphal demand
    final double demandFactor = (hyphalLength / 10.0).clamp(0.1, 1.0);

    // Photosynthate available for transfer
    final double availableC = dailyPhotosynthate > 0
        ? dailyPhotosynthate
        : plant.totalBiomass * 0.001; // Estimate if not provided

    // Transfer scaled by colonization and capped by max fraction
    return availableC *
        colonization *
        demandFactor *
        maxCarbonTransferFraction *
        dtDays;
  }

  /// Calculates nutrient transfer from fungus to plant
  static ({
    double totalPTransfer,
    double totalNTransfer,
    List<double> pUptakeByLayer,
    List<double> nUptakeByLayer,
  })
  _calculateNutrientTransfer(
    SoilProfile profile,
    List<double> hyphalDensities,
    double colonization,
    double carbonAvailable,
    double fTemp,
    double dtDays,
  ) {
    final pUptake = List<double>.filled(profile.layers.length, 0.0);
    final nUptake = List<double>.filled(profile.layers.length, 0.0);
    double totalP = 0.0;
    double totalN = 0.0;

    for (int i = 0; i < profile.layers.length; i++) {
      if (i < hyphalDensities.length && hyphalDensities[i] > 0) {
        final layer = profile.layers[i];

        // P uptake enhanced by hyphal exploration
        // Hyphae can access sorbed P more effectively
        final double pAvailable =
            layer.phosphateContent * 0.1; // Labile fraction
        final double pUptakeRate =
            pAvailable *
            hyphalDensities[i] *
            pUptakeEfficiency *
            1e-4 *
            fTemp *
            dtDays;
        pUptake[i] = pUptakeRate.clamp(
          0.0,
          pAvailable * 0.1,
        ); // Max 10% per step

        // N uptake (primarily ammonium for AM fungi)
        final double nAvailable = layer.ammoniumContent * 0.2;
        final double nUptakeRate =
            nAvailable *
            hyphalDensities[i] *
            nUptakeEfficiency *
            1e-4 *
            fTemp *
            dtDays;
        nUptake[i] = nUptakeRate.clamp(0.0, nAvailable * 0.1);

        totalP += pUptake[i];
        totalN += nUptake[i];
      }
    }

    // Transfer to plant is limited by available carbon "payment"
    final double maxPFromC = carbonAvailable / cCostPerP;
    final double maxNFromC = carbonAvailable / cCostPerN;

    // Scale if uptake exceeds what can be "purchased"
    if (totalP > maxPFromC) {
      final scale = maxPFromC / totalP;
      for (int i = 0; i < pUptake.length; i++) {
        pUptake[i] *= scale;
      }
      totalP = maxPFromC;
    }
    if (totalN > maxNFromC) {
      final scale = maxNFromC / totalN;
      for (int i = 0; i < nUptake.length; i++) {
        nUptake[i] *= scale;
      }
      totalN = maxNFromC;
    }

    return (
      totalPTransfer: totalP * colonization, // Transfer scaled by colonization
      totalNTransfer: totalN * colonization,
      pUptakeByLayer: pUptake,
      nUptakeByLayer: nUptake,
    );
  }

  /// Updates soil nutrient pools after mycorrhizal uptake
  static SoilProfile _updateSoilNutrients(
    SoilProfile profile,
    List<double> pUptake,
    List<double> nUptake,
  ) {
    final updatedLayers = List<SoilLayer>.from(profile.layers);

    for (int i = 0; i < updatedLayers.length; i++) {
      if (i < pUptake.length) {
        updatedLayers[i] = updatedLayers[i].copyWith(
          phosphateContent: (updatedLayers[i].phosphateContent - pUptake[i])
              .clamp(0.0, 1000.0),
          ammoniumContent: (updatedLayers[i].ammoniumContent - nUptake[i])
              .clamp(0.0, 500.0),
        );
      }
    }

    return profile.copyWith(layers: updatedLayers);
  }

  /// Updates plant nutrient uptake with mycorrhizal contribution
  static Plant _updatePlantNutrients(
    Plant plant,
    double pTransfer,
    double nTransfer,
  ) {
    // Mycorrhizal P and N are added to plant's nutrient status
    // This enhances the plant's nutrient uptake calculated elsewhere
    return plant.copyWith(
      nitrogenUptake: plant.nitrogenUptake + nTransfer,
      phosphorusUptake: plant.phosphorusUptake + pTransfer,
    );
  }
}

/// State container for mycorrhizal symbiosis
class MycorrhizaState {
  /// Fraction of root length colonized by mycorrhizae [0-1]
  final double rootColonization;

  /// Total extramatrical hyphal length [m]
  final double totalHyphalLength;

  /// Hyphal density in each soil layer [m m⁻³]
  final List<double> layerHyphalDensities;

  /// Carbon transferred from plant to fungus today [g C]
  final double carbonTransferredToday;

  /// Phosphorus transferred from fungus to plant today [mg P]
  final double pTransferredToday;

  /// Nitrogen transferred from fungus to plant today [mg N]
  final double nTransferredToday;

  /// Total fungal biomass [g C]
  final double fungalBiomass;

  const MycorrhizaState({
    this.rootColonization = 0.0,
    this.totalHyphalLength = 0.0,
    this.layerHyphalDensities = const [],
    this.carbonTransferredToday = 0.0,
    this.pTransferredToday = 0.0,
    this.nTransferredToday = 0.0,
    this.fungalBiomass = 0.0,
  });

  MycorrhizaState copyWith({
    double? rootColonization,
    double? totalHyphalLength,
    List<double>? layerHyphalDensities,
    double? carbonTransferredToday,
    double? pTransferredToday,
    double? nTransferredToday,
    double? fungalBiomass,
  }) {
    return MycorrhizaState(
      rootColonization: rootColonization ?? this.rootColonization,
      totalHyphalLength: totalHyphalLength ?? this.totalHyphalLength,
      layerHyphalDensities: layerHyphalDensities ?? this.layerHyphalDensities,
      carbonTransferredToday: carbonTransferredToday ?? this.carbonTransferredToday,
      pTransferredToday: pTransferredToday ?? this.pTransferredToday,
      nTransferredToday: nTransferredToday ?? this.nTransferredToday,
      fungalBiomass: fungalBiomass ?? this.fungalBiomass,
    );
  }

  /// Creates initial state for a new simulation
  factory MycorrhizaState.initial(int numLayers) {
    return MycorrhizaState(
      layerHyphalDensities: List<double>.filled(numLayers, 0.0),
    );
  }

  /// Benefit ratio: nutrients received / carbon given
  double get benefitRatio {
    if (carbonTransferredToday <= 0) return 0.0;
    return (pTransferredToday + nTransferredToday) / carbonTransferredToday;
  }
}

