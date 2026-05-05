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

    var updatedState = state.copyWith(profile: state.profile.copyWith(layers: layers));

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
          totalHyphalLength: ms.totalHyphalLength * 0.3, // Significant reduction
        ),
      );
    }

    return updatedState;
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
          microbialBiomass: isTopLayer ? l.microbialBiomass + 2.0 : l.microbialBiomass + 0.5,
          particulateOrganicMatter: isTopLayer ? l.particulateOrganicMatter + 0.1 : l.particulateOrganicMatter,
        );
      }
      return newState.copyWith(
        profile: newState.profile.copyWith(layers: layers),
      );
    }

    return newState;
  }
}
