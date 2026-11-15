import '../models/biophysical_state.dart';
import '../models/plant.dart';
import '../models/soil_layer.dart';

/// Applies resource changes driven by the particle layer.
///
/// Flame collision and emitter callbacks run on the main thread and write
/// asynchronously so a frame cannot be blocked by a state rebuild. The
/// provider owns the state and the engine; this class owns the pool arithmetic
/// and the deferred-write rule.
class SimulationResourceExchange {
  SimulationResourceExchange({
    required this.readState,
    required this.apply,
    required this.sync,
    required this.defer,
  });

  final BiophysicalState Function() readState;

  /// Writes state without synchronising the engine.
  final void Function(BiophysicalState state) apply;

  final void Function() sync;

  /// Runs [action] after the current frame, unless the provider is disposed.
  final void Function(void Function() action) defer;

  /// Updates plant state by absorbing a nutrient amount.
  /// Triggered by Flame collision events between roots and nutrient particles.
  void absorbNutrient(String plantId, String symbol, double amount) {
    final List<Plant> updatedPlants = readState().plants.map((plant) {
      if (plant.id == plantId) {
        switch (symbol) {
          case 'Ca':
            return plant.copyWith(calciumUptake: plant.calciumUptake + amount);
          case 'Mg':
            return plant.copyWith(
              magnesiumUptake: plant.magnesiumUptake + amount,
            );
          case 'N':
            return plant.copyWith(
              nitrogenUptake: plant.nitrogenUptake + amount,
            );
          case 'P':
            return plant.copyWith(
              phosphorusUptake: plant.phosphorusUptake + amount,
            );
          default:
            return plant;
        }
      }
      return plant;
    }).toList();

    defer(() {
      apply(readState().copyWith(plants: updatedPlants));
    });
  }

  /// Consumes potassium from the soil pool (e.g., when spawning particles).
  bool consumePotassium(String layerId, double amount) {
    final current = readState();
    final List<SoilLayer> newLayers = current.profile.layers.map<SoilLayer>((
      layer,
    ) {
      if (layer.id == layerId && layer.potassiumContent >= amount) {
        return layer.copyWith(
          potassiumContent: layer.potassiumContent - amount,
        );
      }
      return layer;
    }).toList();

    var changed = false;
    for (int i = 0; i < current.profile.layers.length; i++) {
      if (current.profile.layers[i].potassiumContent !=
          newLayers[i].potassiumContent) {
        changed = true;
        break;
      }
    }

    if (changed) {
      defer(() {
        final state = readState();
        apply(
          state.copyWith(profile: state.profile.copyWith(layers: newLayers)),
        );
        sync();
      });
      return true;
    }
    return false;
  }

  /// Generic resource consumption for visual synchronization.
  bool consumeResource(String layerId, String resourceType, double amount) {
    final current = readState();
    final newLayers = current.profile.layers.map<SoilLayer>((layer) {
      if (layer.id == layerId) {
        switch (resourceType) {
          case 'labileCarbon':
            if (layer.labileCarbon >= amount) {
              return layer.copyWith(labileCarbon: layer.labileCarbon - amount);
            }
            break;
          case 'nitrate':
            if (layer.nitrateContent >= amount) {
              return layer.copyWith(
                nitrateContent: layer.nitrateContent - amount,
              );
            }
            break;
          case 'ammonium':
            if (layer.ammoniumContent >= amount) {
              return layer.copyWith(
                ammoniumContent: layer.ammoniumContent - amount,
              );
            }
            break;
        }
      }
      return layer;
    }).toList();

    defer(() {
      final state = readState();
      apply(state.copyWith(profile: state.profile.copyWith(layers: newLayers)));
      sync();
    });
    return true;
  }

  /// Consumes a small amount of gas from the soil pool.
  /// Used by visual bubble emitters to maintain mass conservation.
  bool consumeGas(String layerId, String gasSymbol, double amount) {
    final current = readState();
    final newLayers = current.profile.layers.map<SoilLayer>((layer) {
      if (layer.id == layerId) {
        switch (gasSymbol) {
          case 'CO2':
            if (layer.co2Content >= amount) {
              return layer.copyWith(co2Content: layer.co2Content - amount);
            }
            break;
          case 'CH4':
            if (layer.methaneContent >= amount) {
              return layer.copyWith(
                methaneContent: layer.methaneContent - amount,
              );
            }
            break;
          case 'N2O':
            if (layer.nitrousOxideContent >= amount) {
              return layer.copyWith(
                nitrousOxideContent: layer.nitrousOxideContent - amount,
              );
            }
            break;
          case 'O2':
            // Oxygen actually increases when bubbles diffuse in
            return layer.copyWith(oxygenContent: layer.oxygenContent + amount);
        }
      }
      return layer;
    }).toList();

    var changed = false;
    for (int i = 0; i < current.profile.layers.length; i++) {
      final oldLayer = current.profile.layers[i];
      final newLayer = newLayers[i];
      if (oldLayer.co2Content != newLayer.co2Content ||
          oldLayer.methaneContent != newLayer.methaneContent ||
          oldLayer.nitrousOxideContent != newLayer.nitrousOxideContent ||
          oldLayer.oxygenContent != newLayer.oxygenContent) {
        changed = true;
        break;
      }
    }

    if (changed) {
      defer(() {
        final state = readState();
        apply(
          state.copyWith(profile: state.profile.copyWith(layers: newLayers)),
        );
        sync();
      });
      return true;
    }
    return false;
  }
}
