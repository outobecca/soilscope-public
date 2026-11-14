import 'package:flutter/foundation.dart';

import '../../core/debug_log.dart';
import '../actions/simulation_actions.dart';
import '../models/biophysical_state.dart';
import '../models/scenario.dart';

/// One engine tick after scenario events, UI-owned overrides and history have
/// been reconciled.
class SimulationTickResult {
  const SimulationTickResult({
    required this.entry,
    required this.eventState,
    required this.eventApplied,
    required this.snapshotAdded,
  });

  /// State after scenario events but before UI-owned overrides are merged.
  /// This is what must be sent back to the engine on an event tick.
  final BiophysicalState eventState;
  final BiophysicalState entry;
  final bool eventApplied;
  final bool snapshotAdded;
}

/// Reconciles the engine's tick with the controls the UI owns.
///
/// The engine owns biophysics, the main thread owns the session controls.
/// Keeping this out of the notifier makes the merge rule testable and stops the
/// provider from growing a second simulation loop.
class SimulationTickProcessor {
  SimulationTickProcessor({
    required this.history,
    this.snapshotIntervalSeconds = 600.0,
    this.maxSnapshots = 500,
  });

  /// Timeline entries; each entry has an empty `history` to avoid nesting.
  final List<BiophysicalState> history;
  final double snapshotIntervalSeconds;
  final int maxSnapshots;

  SimulationTickResult process({
    required BiophysicalState engineState,
    required BiophysicalState uiState,
  }) {
    var processedState = engineState.copyWith(isInitializing: false);
    var eventApplied = false;

    final scenario = uiState.currentScenario;
    if (scenario != null) {
      for (final event in scenario.cultivationPlan) {
        if (processedState.timeElapsed >= event.executionTime &&
            uiState.timeElapsed < event.executionTime) {
          if (kDebugMode) {
            debugLog(
              '[SimulationTickProcessor] Applying event: '
              '${event.type} at ${event.executionTime}',
            );
          }
          processedState = applyCultivationEvent(processedState, event);
          eventApplied = true;
        }
      }
    }

    final entry = mergeSimulationState(processedState, uiState);
    final lastSnapshotTime = history.isEmpty
        ? double.negativeInfinity
        : history.last.timeElapsed;
    var snapshotAdded = false;

    if (history.length <= 1 ||
        entry.timeElapsed - lastSnapshotTime >= snapshotIntervalSeconds) {
      history.add(entry.copyWith(history: const []));
      if (history.length > maxSnapshots) {
        history.removeAt(0);
      }
      snapshotAdded = true;
    }

    return SimulationTickResult(
      entry: entry,
      eventState: processedState,
      eventApplied: eventApplied,
      snapshotAdded: snapshotAdded,
    );
  }
}

/// Merges background simulation results with current control state.
///
/// Preserves user overrides from [localState] while taking biophysical results
/// from [remoteState].
BiophysicalState mergeSimulationState(
  BiophysicalState remoteState,
  BiophysicalState localState,
) {
  return remoteState.copyWith(
    isInitializing: false,
    isRunning: localState.isRunning,
    timeScale: localState.timeScale,
    autoWeather: localState.autoWeather,
    hasCoverCrop: localState.hasCoverCrop,
    solarRadiationOverride: localState.solarRadiationOverride,

    // Atmospheric inputs: take the engine's values only while auto weather is
    // on; otherwise the sliders are the source of truth.
    airTemperature: localState.autoWeather
        ? remoteState.airTemperature
        : localState.airTemperature,
    relativeHumidity: localState.autoWeather
        ? remoteState.relativeHumidity
        : localState.relativeHumidity,
    precipitation: localState.autoWeather
        ? remoteState.precipitation
        : localState.precipitation,
    atmCO2: localState.autoWeather ? remoteState.atmCO2 : localState.atmCO2,

    // The isolate must not change the scenario structure.
    currentScenario: localState.currentScenario,
  );
}

/// Applies one scenario cultivation event to the state.
BiophysicalState applyCultivationEvent(
  BiophysicalState state,
  CultivationEvent event,
) {
  switch (event.type) {
    case 'till':
      return SimulationActions.applyTillage(state);
    case 'fertilize':
      if (event.layerId != null) {
        final symbol = event.extraData ?? 'N';
        return SimulationActions.applyNutrients(
          state,
          event.layerId!,
          symbol,
          event.amount,
        );
      }
      return state;
    case 'water':
      return state.copyWith(precipitation: event.amount);
    default:
      return state;
  }
}
