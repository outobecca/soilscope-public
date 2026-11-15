import 'dart:math' as math;
import '../models/biophysical_state.dart';
import '../models/soil_layer.dart';

/// Pure logic for simulation actions (tillage, fertilization, weather, etc.)
/// These functions are pure and return a new state, making them easy to test.
class SimulationActions {
  /// Applies Tillage (Muokkaus) to the soil.
  /// Affects top layers by reducing bulk density, increasing porosity and aggregate stability.
  /// Also oxygenates the soil but may lead to carbon loss.
  static BiophysicalState applyTillage(BiophysicalState state) {
    final layers = List<SoilLayer>.from(state.profile.layers);

    // Typically tillage affects top 20-30cm (top 1-2 layers)
    for (int i = 0; i < math.min(2, layers.length); i++) {
      final l = layers[i];

      // Tillage effects:
      // 1. Aeration (Oxygen increase)
      // 2. Porosity increase (temporary)
      // 3. Bulk density decrease
      // 4. Aggregate stability decrease (long term)

      layers[i] = l.copyWith(
        oxygenContent: math.min(10.0, l.oxygenContent * 1.5),
        porosity: (l.porosity * 1.1).clamp(0.3, 0.6),
        bulkDensity: l.bulkDensity * 0.9,
        aggregateStability: math.max(0.1, l.aggregateStability * 0.95),
        redoxPotential: math.min(600.0, l.redoxPotential + 50.0),
      );
    }

    var updatedState = state.copyWith(
      profile: state.profile.copyWith(layers: layers),
    );

    // Isaac (1992): Tillage disrupts the extraradical mycelial network
    if (state.mycorrhizaState != null) {
      final ms = state.mycorrhizaState!;
      final updatedDensities = List<double>.from(ms.layerHyphalDensities);

      // Disrupt hyphae in the top affected layers
      for (int i = 0; i < math.min(2, updatedDensities.length); i++) {
        updatedDensities[i] *= 0.2; // 80% reduction
      }

      updatedState = updatedState.copyWith(
        mycorrhizaState: ms.copyWith(
          rootColonization: ms.rootColonization * 0.2,
          layerHyphalDensities: updatedDensities,
          totalHyphalLength:
              ms.totalHyphalLength * 0.3, // Significant reduction
        ),
      );
    }

    return updatedState;
  }

  /// Applies irrigation water to the topsoil.
  ///
  /// [amountMm] is the water depth applied in millimetres. The corresponding
  /// volumetric water-content increase is derived from the top layer's
  /// thickness, so a 10 mm irrigation means the same physical input regardless
  /// of how the profile is discretized.
  static BiophysicalState applyIrrigation(
    BiophysicalState state, {
    double amountMm = 10.0,
  }) {
    if (state.profile.layers.isEmpty || !amountMm.isFinite || amountMm <= 0) {
      return state;
    }

    final layers = List<SoilLayer>.from(state.profile.layers);
    final top = layers.first;
    final thicknessMm = math.max(1.0, top.thickness * 1000.0);
    final deltaTheta = (amountMm / thicknessMm).clamp(0.0, 0.25);
    final nextWater = math.min(
      top.porosity * 0.98,
      top.waterContent + deltaTheta,
    );

    layers[0] = top.copyWith(
      previousWaterContent: top.waterContent,
      waterContent: nextWater,
    );
    return state.copyWith(profile: state.profile.copyWith(layers: layers));
  }

  /// Adds an organic amendment to the topsoil.
  ///
  /// This is the quick-action equivalent of incorporating compost or crop
  /// residue: particulate and labile carbon feed the microbial pool, and
  /// aggregate stability and microbial biomass get an immediate boost while
  /// the slower solver response develops.
  static BiophysicalState applyOrganicMatter(BiophysicalState state) {
    if (state.profile.layers.isEmpty) return state;

    final layers = List<SoilLayer>.from(state.profile.layers);
    final top = layers.first;
    layers[0] = top.copyWith(
      labileCarbon: top.labileCarbon + 5.0,
      particulateOrganicMatter: top.particulateOrganicMatter + 5.0,
      organicCarbon: top.organicCarbon + 5.0,
      microbialBiomass: top.microbialBiomass + 10.0,
      aggregateStability: math.min(1.0, top.aggregateStability + 0.05),
    );
    return state.copyWith(profile: state.profile.copyWith(layers: layers));
  }

  /// Removes excess water from the upper profile and re-aerates it.
  ///
  /// This models a drainage intervention, not evaporation: it lowers the
  /// water content toward residual water, restores some pore oxygen, and
  /// raises redox potential in the drained layers.
  static BiophysicalState applyDrainage(BiophysicalState state) {
    if (state.profile.layers.isEmpty) return state;

    final layers = List<SoilLayer>.from(state.profile.layers);
    for (int i = 0; i < math.min(2, layers.length); i++) {
      final l = layers[i];
      layers[i] = l.copyWith(
        waterContent: math.max(l.thetaR, l.waterContent - 0.03),
        oxygenContent: math.min(10.0, l.oxygenContent + 1.0),
        redoxPotential: math.min(600.0, l.redoxPotential + 75.0),
      );
    }
    return state.copyWith(profile: state.profile.copyWith(layers: layers));
  }

  /// Applies Fertilizers (Lannoitus) to a specific layer.
  static BiophysicalState applyNutrients(
    BiophysicalState state,
    String layerId,
    String symbol,
    double amount,
  ) {
    final layers = List<SoilLayer>.from(state.profile.layers);
    final index = layers.indexWhere((l) => l.id == layerId);

    if (index != -1) {
      final l = layers[index];
      switch (symbol) {
        case 'N':
          layers[index] = l.copyWith(nitrateContent: l.nitrateContent + amount);
          break;
        case 'P':
          layers[index] = l.copyWith(
            phosphateContent: l.phosphateContent + amount,
          );
          break;
        case 'K':
          layers[index] = l.copyWith(
            potassiumContent: l.potassiumContent + amount,
          );
          break;
        case 'Ca':
          layers[index] = l.copyWith(
            solutionCalcium: l.solutionCalcium + amount,
          );
          break;
        case 'Mg':
          layers[index] = l.copyWith(
            solutionMagnesium: l.solutionMagnesium + amount,
          );
          break;
        case 'C-lab':
          layers[index] = l.copyWith(
            labileCarbon: l.labileCarbon + amount,
            organicCarbon: l.organicCarbon + amount,
          );
          break;
        case 'C-sta':
          layers[index] = l.copyWith(
            stableCarbon: l.stableCarbon + amount,
            organicCarbon: l.organicCarbon + amount,
          );
          break;
      }
    }

    return state.copyWith(profile: state.profile.copyWith(layers: layers));
  }

  /// Updates Weather (Sää) and recalculates dependent variables.
  static BiophysicalState updateWeather(
    BiophysicalState state,
    double temperature,
    double humidity,
  ) {
    return state.copyWith(
      airTemperature: temperature,
      relativeHumidity: humidity,
    );
  }

  /// Triggers a Heat Wave event.
  static BiophysicalState triggerHeatWave(BiophysicalState state) {
    return state.copyWith(
      airTemperature: state.airTemperature + 10.0,
      relativeHumidity: math.max(0.1, state.relativeHumidity - 0.2),
      precipitation: 0.0,
    );
  }

  /// Triggers a Flash Flood event.
  static BiophysicalState triggerFlashFlood(BiophysicalState state) {
    return state.copyWith(
      precipitation: 0.005, // Heavy rain
      relativeHumidity: 0.95,
    );
  }

  /// Applies Cover Crop (Kerääjäkasvi).
  static BiophysicalState toggleCoverCrop(BiophysicalState state) {
    final newState = state.copyWith(hasCoverCrop: !state.hasCoverCrop);

    // Cover crops protect soil and provide carbon inputs
    if (newState.hasCoverCrop) {
      final layers = List<SoilLayer>.from(newState.profile.layers);
      for (int i = 0; i < layers.length; i++) {
        final l = layers[i];
        final isTopLayer = i == 0;

        layers[i] = l.copyWith(
          aggregateStability: math.min(1.0, l.aggregateStability * 1.05),
          // Living roots and residues increase microbial and organic pools
          microbialBiomass: isTopLayer
              ? l.microbialBiomass + 2.0
              : l.microbialBiomass + 0.5,
          particulateOrganicMatter: isTopLayer
              ? l.particulateOrganicMatter + 0.1
              : l.particulateOrganicMatter,
        );
      }
      return newState.copyWith(
        profile: newState.profile.copyWith(layers: layers),
      );
    }

    return newState;
  }
}
