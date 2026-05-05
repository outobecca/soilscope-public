import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../../domain/models/soil_layer.dart';

/// Mixin to provide standard, unified access to the simulation state and time.
/// Eliminates the need for multiple null-guards in Flame components.
mixin SimulationStateMixin on HasGameReference<SoilScopeGame> {
  /// The current state of the biophysical simulation.
  BiophysicalState? get simState => game.simulationState;

  /// Checks if the simulation is currently active and advancing.
  bool get isSimRunning => simState?.isRunning ?? false;

  /// Direct access to the topmost soil layer (e.g., for weather boundary checks).
  SoilLayer? get topLayer => simState?.profile.layers.firstOrNull;

  /// The continuous visual time used by animations [seconds].
  double get simTime => game.currentTime();
}
