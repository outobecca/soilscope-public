import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../core/debug_log.dart';
import '../../domain/models/biophysical_state.dart';
import '../../domain/models/default_simulation_profile.dart';
import '../../domain/models/soil_profile.dart';
import '../../domain/models/soil_layer.dart';
import '../../domain/models/scenario.dart';
import '../../domain/solvers/particle_physics_isolate.dart';
import '../../domain/services/simulation_interventions.dart';
import '../../domain/services/simulation_persistence.dart';
import '../../domain/services/simulation_resource_exchange.dart';
import '../../domain/services/simulation_runtime.dart';
import '../../domain/services/simulation_timeline.dart';
import '../../domain/services/simulation_tick_processor.dart';
import '../../domain/services/timeline_precalculation.dart';

import 'event_log_provider.dart';
import 'simulation_session_provider.dart';
import 'ui_state_provider.dart';

part 'simulation_provider.g.dart';

/// Whether the run has a timeline to open. The starting snapshot is enough:
/// history mode can show the run's origin immediately, and the scrub range
/// grows as soon as the engine records a second snapshot.
bool hasTimelineHistory(List<BiophysicalState> history) => history.isNotEmpty;

/// Whether history contains a range that can actually be scrubbed. A single
/// snapshot is a valid timeline view but has no range to move through yet.
bool hasTimelineRange(List<BiophysicalState> history) =>
    history.length > 1 && history.last.timeElapsed > history.first.timeElapsed;

/// Owns the simulation's Riverpod-facing concerns: engine lifecycle, tick
/// merging, session persistence, timeline entry points and the public
/// intervention facades.
///
/// The transition rules live in [SimulationInterventions], snapshot storage in
/// [SimulationTimeline], tick reconciliation in [SimulationTickProcessor],
/// isolate and particle lifecycle in [SimulationRuntime], and the saved-session
/// envelope in [SimulationPersistence]. This notifier coordinates them; it does
/// not reimplement them.
@Riverpod(keepAlive: true)
class Simulation extends _$Simulation {
  final SimulationPersistence _persistence = SimulationPersistence();

  late SimulationRuntime _runtime;
  late SimulationTickProcessor _tickProcessor;

  /// Shared particle runtime; Flame components send their particle commands
  /// through this manager.
  ParticlePhysicsIsolateManager get particleIsolate => _runtime.particles;

  int _tickCount = 0;

  /// Fields the UI owns when an engine tick is merged into the session.
  /// The companion test asserts that every state field is classified here or
  /// in [kSimulationEngineFields], so new fields cannot silently drift.
  static const Set<String> uiFields = {
    'isRunning',
    'timeScale',
    'autoWeather',
    'hasCoverCrop',
    'solarRadiationOverride',
    'airTemperature',
    'relativeHumidity',
    'precipitation',
    'atmCO2',
    'currentScenario',
  };

  /// Fields the simulation engine owns during a tick.
  static const Set<String> engineFields = {
    'profile',
    'plants',
    'timeElapsed',
    'soilEvaporation',
    'isInitializing',
    'history',
    'score',
    'mycorrhizaState',
  };

  /// Snapshots for scrubbing; owned by [SimulationTimeline].
  final SimulationTimeline _timeline = SimulationTimeline();

  /// User-triggered interventions. The provider supplies state access, event
  /// logging and engine sync; the transition rules live in the service.
  late final SimulationInterventions _interventions = SimulationInterventions(
    readState: () => state,
    apply: (next) {
      state = next;
      _syncIsolate();
    },
    log: (message, time) =>
        ref.read(eventLogProvider.notifier).addEvent(message, time),
    leaveHistoryMode: _leaveHistoryMode,
    selectedLayerId: () => ref.read(simulationSessionProvider).selectedLayerId,
    isDisposed: () => _disposed,
  );

  /// Particle-driven pool changes. Deferred writes keep collision callbacks
  /// out of the frame and out of a disposed provider.
  late final SimulationResourceExchange _resources = SimulationResourceExchange(
    readState: () => state,
    apply: (next) => state = next,
    sync: _syncIsolate,
    defer: (action) => Future.microtask(() {
      if (!_disposed) action();
    }),
  );

  bool _disposed = false;
  BiophysicalState? _pendingState;

  @override
  BiophysicalState build() {
    debugLog('[SimulationProvider] build called');
    // Reset lifecycle flags on rebuild — critical for correctness.
    // Without this, a provider rebuild creates new isolate managers
    // but skips their init (because _isInitialized was still true)
    // and drops all state updates (because _disposed was still true).
    _disposed = false;
    _pendingState = null;

    _runtime = SimulationRuntime();
    _tickProcessor = SimulationTickProcessor(history: _timeline.entries);
    _initializeRuntime();

    ref.onDispose(() {
      _disposed = true;
      _runtime.dispose();
    });

    final defaultProfile = defaultSoilProfile();
    final defaultState = _initialState(defaultProfile, isInitializing: true);

    final defaultEntry = SimulationTimeline.strip(defaultState);
    _timeline.clearAndAdd(defaultEntry);

    return defaultEntry.copyWith(history: _timeline.view);
  }

  /// Builds a clean state for [profile] at t=0 with a single seedling.
  ///
  /// Used for the default profile on first launch and whenever a scenario is
  /// loaded, so a new scenario never inherits the previous run's clock, plants
  /// or history.
  BiophysicalState _initialState(
    SoilProfile profile, {
    Scenario? scenario,
    bool isInitializing = false,
    double timeScale = 1.0,
  }) {
    return BiophysicalState(
      profile: profile,
      plants: [seedPlant().copyWith(baseX: 0.5)],
      timeElapsed: 0,
      precipitation: 0.0,
      airTemperature: 293.15,
      relativeHumidity: 0.5,
      atmCO2: 0.017,
      autoWeather: false,
      timeScale: timeScale,
      hasCoverCrop: false,
      isRunning: false,
      isInitializing: isInitializing,
      history: const [],
      currentScenario: scenario,
    );
  }

  /// Retries a failed engine start without restarting the app.
  void retryInitialization() {
    if (_disposed || !ref.mounted || state.isInitializing) return;
    ref.read(engineFailureProvider.notifier).setFailed(false);
    state = state.copyWith(isInitializing: true);
    _initializeRuntime();
  }

  void _failInitialization() {
    if (_disposed || !ref.mounted) return;
    ref.read(engineFailureProvider.notifier).setFailed(true);
    // Never leave the app stuck on the splash if the isolate cannot start.
    state = state.copyWith(isInitializing: false);
    ref
        .read(eventLogProvider.notifier)
        .addEvent('Simulation engine failed to start.', state.timeElapsed);
  }

  Future<void> _initializeRuntime() async {
    await _runtime.initialize(
      readState: () => state,
      isScrubbing: () => ref.read(simulationSessionProvider).isScrubbing,
      onTick: _handleEngineTick,
      onFailure: _failInitialization,
      onReady: _handleRuntimeReady,
    );
  }

  void _handleRuntimeReady() {
    if (_disposed || !ref.mounted) return;
    ref.read(engineFailureProvider.notifier).setFailed(false);
    state = state.copyWith(isInitializing: false);
    debugLog('[SimulationProvider] runtime ready');
  }

  void _handleEngineTick(BiophysicalState engineState) {
    if (_disposed || !ref.mounted) return;

    final result = _tickProcessor.process(
      engineState: engineState,
      uiState: state,
    );
    if (result.eventApplied) {
      _runtime.updateEngineState(result.eventState);
    }
    if (result.snapshotAdded) {
      _timeline.refresh();
    }

    _pendingState = result.entry;
    Future.microtask(() {
      if (!_disposed && _pendingState != null) {
        state = _pendingState!.copyWith(history: _timeline.view);
        _pendingState = null;
      }
    });

    _tickCount++;
    if (_tickCount >= 50) {
      _tickCount = 0;
      _saveState();
    }
  }

  void _syncIsolate() => _runtime.sync(state);

  /// Leaving history mode makes every displayed surface follow the live engine
  /// again. Used before starting a run or applying an edit from a control that
  /// was showing a historical snapshot.
  void _leaveHistoryMode() {
    final session = ref.read(simulationSessionProvider);
    if (session.isScrubbing) {
      ref.read(simulationSessionProvider.notifier).setScrubbing(false);
    }
  }

  void start() {
    // Starting the run while the timeline is open must leave history mode;
    // otherwise the displayed snapshot would stay frozen while the engine
    // advances underneath it.
    _leaveHistoryMode();
    debugLog(
      '[SimulationProvider] start() called: isRunning=${state.isRunning}, isInitializing=${state.isInitializing}',
    );
    if (state.isRunning || state.isInitializing) {
      debugLog(
        '[SimulationProvider] start() ABORTED: already running or initializing',
      );
      return;
    }

    state = state.copyWith(isRunning: true);
    debugLog('[SimulationProvider] start() state updated: isRunning=true');

    _syncIsolate(); // Ensure isolate has the latest state before starting
    debugLog('[SimulationProvider] start() isolate synced');

    _runtime.start();
    debugLog(
      '[SimulationProvider] start() SUCCESS: all isolate managers started',
    );
  }

  void stop() {
    state = state.copyWith(isRunning: false);
    _runtime.stop();
    _saveState();
  }

  /// Stops without touching a provider that is already being torn down.
  /// Used by route disposal, which can run after the provider scope closes.
  void stopIfMounted() {
    if (!ref.mounted) return;
    stop();
  }

  void setSpeed(double speed) => _interventions.setSpeed(speed);

  void setPrecipitation(double p) => _interventions.setPrecipitation(p);

  void toggleAutoWeather() => _interventions.toggleAutoWeather();

  /// Sets the auto-weather mode explicitly so a control shown from a historical
  /// snapshot can apply the state the user actually saw.
  void setAutoWeather(bool enabled) => _interventions.setAutoWeather(enabled);

  void applyCoverCrop() => _interventions.applyCoverCrop();

  /// Sets the cover-crop state explicitly for controls that may be showing a
  /// historical snapshot rather than the live engine.
  void setCoverCrop(bool planted) => _interventions.setCoverCrop(planted);

  void applyNutrients(Map<String, double> pendingNutrients) =>
      _interventions.applyNutrients(pendingNutrients);

  void triggerHeatWave() => _interventions.triggerHeatWave();

  void triggerFlashFlood() => _interventions.triggerFlashFlood();

  void updateWeather(double temperature, double humidity) =>
      _interventions.updateWeather(temperature, humidity);

  void updateNutrient(String layerId, String symbol, double value) =>
      _interventions.updateNutrient(layerId, symbol, value);

  void updateSolarRadiation(double value) =>
      _interventions.updateSolarRadiation(value);

  void updatePAR(double value) => _interventions.updatePAR(value);

  void updateAtmosphere({
    double? temperature,
    double? humidity,
    double? precipitation,
    double? co2,
  }) => _interventions.updateAtmosphere(
    temperature: temperature,
    humidity: humidity,
    precipitation: precipitation,
    co2: co2,
  );

  bool applyTillage() => _interventions.applyTillage();

  void applyIrrigation({double amountMm = 10.0}) =>
      _interventions.applyIrrigation(amountMm: amountMm);

  void applyOrganicMatter() => _interventions.applyOrganicMatter();

  void applyDrainage() => _interventions.applyDrainage();

  /// Applies a one-tap fertilizer dose to the selected layer, falling back to
  /// the topsoil when the user has not selected a layer.
  void applyQuickNutrient(String symbol, {double amount = 20.0}) =>
      _interventions.applyQuickNutrient(symbol, amount: amount);

  /// Functional update pattern for soil layers.
  /// Decouples the UI from the internal structure of the SoilLayer.
  void updateLayer(String layerId, SoilLayer Function(SoilLayer) transform) =>
      _interventions.updateLayer(layerId, transform);

  /// Convenience wrapper for updating a single soil layer parameter by string
  /// name.
  void updateLayerParameter(String layerId, String param, double value) =>
      _interventions.updateLayerParameter(layerId, param, value);

  /// Particle-layer resource exchange. The provider owns state and engine
  /// sync; [SimulationResourceExchange] owns the pool arithmetic.
  void absorbNutrient(String plantId, String symbol, double amount) =>
      _resources.absorbNutrient(plantId, symbol, amount);

  bool consumePotassium(String layerId, double amount) =>
      _resources.consumePotassium(layerId, amount);

  bool consumeResource(String layerId, String resourceType, double amount) =>
      _resources.consumeResource(layerId, resourceType, amount);

  bool consumeGas(String layerId, String gasSymbol, double amount) =>
      _resources.consumeGas(layerId, gasSymbol, amount);

  Future<void> _saveState() => _persistence.save(state);

  Future<bool> hasSavedState() => _persistence.hasSavedState(
    // A run that has started but has not reached the periodic save yet.
    // A pristine provider only has the default entry, not a session.
    hasLiveRun: _timeline.length > 1,
  );

  Future<bool> loadLastState() async {
    final loadedState = await _persistence.load();
    if (loadedState != null) {
      _timeline.clearAndAdd(SimulationTimeline.strip(loadedState));
      state = loadedState.copyWith(history: _timeline.view);
      _syncIsolate();
      return true;
    }
    if (_timeline.length > 1) {
      state = _timeline.last.copyWith(history: _timeline.view);
      return true;
    }
    return false;
  }

  void startScrubbing() {
    // The starting snapshot is enough to enter the timeline view. There is no
    // range to scrub until a second snapshot exists, but the view itself is
    // available from launch and can show where the run began.
    if (_timeline.isEmpty) return;
    stop(); // Pause simulation while scrubbing
    ref.read(simulationSessionProvider.notifier).setScrubbing(true);
    ref
        .read(simulationSessionProvider.notifier)
        .setViewTime(_timeline.last.timeElapsed);
  }

  void stopScrubbing() {
    ref.read(simulationSessionProvider.notifier).setScrubbing(false);
  }

  void scrubTo(double time) {
    ref.read(simulationSessionProvider.notifier).setViewTime(time);
  }

  Scenario exportCurrentState(String title, String desc) {
    return Scenario(
      id: "exported_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      description: desc,
      initialProfile: state.profile,
      weatherData: {},
      objectives: [],
    );
  }

  void loadScenario(Scenario scenario) {
    // Stop the current run first so the isolate cannot push frames from the
    // previous scenario into the fresh one.
    _runtime.stop();

    final initial = SimulationTimeline.strip(
      _initialState(
        scenario.initialProfile,
        scenario: scenario,
        timeScale: state.timeScale,
      ),
    );

    _timeline.clearAndAdd(initial);

    state = initial.copyWith(history: _timeline.view, isInitializing: false);

    // Selection, microscope and inspection state belong to the run being
    // replaced. Leaving them behind makes a new scenario open with a stale
    // layer card and a paused canvas.
    ref.read(uIStateProvider.notifier).resetInspection();
    ref.read(simulationSessionProvider.notifier).resetForScenario();

    _syncIsolate();
    _saveState();
  }

  /// Pre-computes a timeline for [days] simulated days.
  ///
  /// The work runs in day-sized chunks so the caller can render progress and
  /// the UI can breathe between chunks. This matters on web, where [compute]
  /// executes on the main thread.
  Future<bool> preCalculateTimeline(
    int days, {
    void Function(double progress)? onProgress,
    bool Function()? shouldCancel,
  }) async {
    // 180 days of hourly ticks is already minutes on a phone; the builder
    // slider uses the same ceiling.
    final totalDays = days.clamp(1, 180).toInt();
    ref.read(simulationSessionProvider.notifier).setScrubbing(true);
    state = state.copyWith(isRunning: false);
    _runtime.stop();

    final startState = SimulationTimeline.strip(state);
    final computedHistory = <BiophysicalState>[startState];
    var cursor = startState;
    var processedDays = 0;
    final chunkDays = (totalDays / 20).ceil().clamp(1, totalDays).toInt();

    onProgress?.call(0);
    while (processedDays < totalDays) {
      if (shouldCancel?.call() ?? false) {
        ref.read(simulationSessionProvider.notifier).setScrubbing(false);
        return false;
      }

      final remaining = totalDays - processedDays;
      final daysThisChunk = chunkDays < remaining ? chunkDays : remaining;

      final (nextState, chunkHistory) = await compute(
        preCalculateTimelineTask,
        (cursor, daysThisChunk),
      );

      cursor = nextState;
      computedHistory.addAll(chunkHistory);
      processedDays += daysThisChunk;
      onProgress?.call(processedDays / totalDays);

      // Yield so a progress indicator can repaint between chunks.
      await Future<void>.delayed(Duration.zero);
    }

    _timeline.clearAndAddAll(computedHistory);

    state = computedHistory.first.copyWith(
      history: _timeline.view,
      isInitializing: false,
    );
    ref
        .read(simulationSessionProvider.notifier)
        .setViewTime(computedHistory.first.timeElapsed);
    ref.read(simulationSessionProvider.notifier).setScrubbing(false);

    return true;
  }

  void configureParticleDomain(
    double minX,
    double maxX,
    double height,
    double surfaceY,
  ) {
    _runtime.configureParticleDomain(
      minX,
      maxX,
      height,
      surfaceY,
      isRunning: state.isRunning,
    );
  }
}

/// True when the engine failed to initialize and the user can retry.
class EngineFailureNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setFailed(bool value) => state = value;
}

final engineFailureProvider = NotifierProvider<EngineFailureNotifier, bool>(
  EngineFailureNotifier.new,
);

@Riverpod(keepAlive: true)
BiophysicalState displayedSimulationState(Ref ref) {
  final simState = ref.watch(simulationProvider);
  final session = ref.watch(simulationSessionProvider);

  if (session.isScrubbing) {
    final history = simState.history;
    if (history.isEmpty) return simState;
    final index = nearestHistorySnapshotIndex(history, session.viewTime);
    // Keep the run's timeline on the displayed snapshot. Report and validation
    // widgets need the full run history even while the visible values come
    // from a historical snapshot; the stored timeline entries stay stripped.
    return history[index].copyWith(history: history);
  }
  return simState;
}

/// Index of the history snapshot nearest to [time]. History is sorted by time.
/// A tie selects the later snapshot, matching the displayed-state fallback.
int nearestHistorySnapshotIndex(List<BiophysicalState> history, double time) {
  if (history.isEmpty) return -1;
  final index = _lowerBound(history, time);
  if (index >= history.length) return history.length - 1;
  if (index == 0) return 0;
  final before = history[index - 1];
  final after = history[index];
  return (time - before.timeElapsed).abs() < (after.timeElapsed - time).abs()
      ? index - 1
      : index;
}

/// First index whose snapshot is at or after [time]; history is sorted.
int _lowerBound(List<BiophysicalState> history, double time) {
  var low = 0;
  var high = history.length;
  while (low < high) {
    final mid = low + ((high - low) >> 1);
    if (history[mid].timeElapsed < time) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }
  return low;
}
