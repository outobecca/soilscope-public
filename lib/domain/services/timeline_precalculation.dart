import '../models/biophysical_state.dart';
import '../solvers/simulation_engine.dart';
import 'simulation_tick_processor.dart';

/// One pre-calculation chunk. Runs through `compute`, so it stays top-level.
///
/// [args] is the starting state and the number of simulated days in this
/// chunk. Returns the final state and the six-hourly snapshots for scrubbing.
(BiophysicalState, List<BiophysicalState>) preCalculateTimelineTask(
  (BiophysicalState, int) args,
) {
  final initialState = args.$1;
  final days = args.$2;
  final List<BiophysicalState> history = [];
  BiophysicalState currentState = initialState;

  const double dt = 3600.0; // 1 hour steps
  final totalTicks = (days * 24).toInt();

  for (int i = 0; i < totalTicks; i++) {
    if (currentState.currentScenario != null) {
      for (final event in currentState.currentScenario!.cultivationPlan) {
        if (event.executionTime >= currentState.timeElapsed &&
            event.executionTime < currentState.timeElapsed + dt) {
          currentState = applyCultivationEvent(currentState, event);
        }
      }
    }

    currentState = SimulationEngine.tick(currentState, dt);

    if (i % 6 == 0) {
      history.add(currentState.copyWith(history: []));
    }
  }
  return (currentState, history);
}
