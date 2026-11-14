import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../core/debug_log.dart';
import '../../domain/models/biophysical_state.dart';
import '../../domain/models/soil_profile.dart';
import '../../domain/models/soil_layer.dart';
import '../../domain/models/plant.dart';
import '../../domain/actions/simulation_actions.dart';
import '../../domain/models/scenario.dart';
import '../../domain/solvers/particle_physics_isolate.dart';
import '../../domain/services/simulation_persistence.dart';
import '../../domain/services/simulation_runtime.dart';
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
    history.length > 1 &&
    history.last.timeElapsed > history.first.timeElapsed;

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
  // Timeline for scrubbing (entries must have `history: []` to avoid nesting).
  final List<BiophysicalState> _history = [];

  /// Immutable view handed to widgets, rebuilt only when _history changes.
  List<BiophysicalState> _historyView = const [];

  void _rebuildHistoryView() {
    _historyView = List.unmodifiable(_history);
  }

  BiophysicalState _stripHistory(BiophysicalState s) =>
      s.copyWith(history: const []);

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
    _tickProcessor = SimulationTickProcessor(history: _history);
    _initializeRuntime();

    ref.onDispose(() {
      _disposed = true;
      _runtime.dispose();
    });

    final defaultProfile = SoilProfile(
      id: "default",
      name: "Default Profile",
      layers: [
        SoilLayer(
          id: "A1",
          depth: 0.0,
          thickness: 0.2,
          kSat: 1e-6,
          porosity: 0.45,
          thetaR: 0.05,
          vgAlpha: 2.0,
          vgN: 1.4,
          vgL: 0.5,
          bulkDensity: 1400.0,
          waterContent: 0.25,
          temperature: 293.15,
          heatCapacity: 800.0,
          ph: 6.5,
          ec: 0.2,
          redoxPotential: 500.0,
          nitrateContent: 15.0,
          ammoniumContent: 5.0,
          phosphateContent: 10.0,
          potassiumContent: 25.0,
          microbialBiomass: 40.0,
          epsContent: 2.0,
          fungalHyphaeDensity: 0.1,
          necromass: 1.0,
          organicCarbon: 25.5,
          particulateOrganicMatter: 0.5,
          mineralAssociatedOrganicMatter: 25.0,
          labileCarbon: 0.5,
          stableCarbon: 25.0,
          nitrogenContent: 0.2,
        ),
        SoilLayer(
          id: "B1",
          depth: 0.2,
          thickness: 0.4,
          kSat: 5e-7,
          porosity: 0.4,
          thetaR: 0.06,
          vgAlpha: 1.5,
          vgN: 1.3,
          vgL: 0.5,
          bulkDensity: 1600.0,
          waterContent: 0.3,
          temperature: 290.15,
          heatCapacity: 850.0,
          ph: 7.0,
          ec: 0.1,
          redoxPotential: 400.0,
          nitrateContent: 5.0,
          ammoniumContent: 2.0,
          phosphateContent: 5.0,
          potassiumContent: 15.0,
          microbialBiomass: 15.0,
          epsContent: 0.5,
          fungalHyphaeDensity: 0.05,
          necromass: 0.2,
          organicCarbon: 10.1,
          particulateOrganicMatter: 0.1,
          mineralAssociatedOrganicMatter: 10.0,
          labileCarbon: 0.1,
          stableCarbon: 10.0,
          nitrogenContent: 0.1,
        ),
        SoilLayer(
          id: "C1",
          depth: 0.6,
          thickness: 0.4,
          kSat: 1e-7,
          porosity: 0.35,
          thetaR: 0.08,
          vgAlpha: 1.0,
          vgN: 1.2,
          vgL: 0.5,
          bulkDensity: 1800.0,
          waterContent: 0.32,
          temperature: 288.15,
          heatCapacity: 900.0,
          ph: 7.5,
          ec: 0.1,
          redoxPotential: 350.0,
          nitrateContent: 1.0,
          ammoniumContent: 1.0,
          phosphateContent: 2.0,
          potassiumContent: 10.0,
          microbialBiomass: 5.0,
          epsContent: 0.0,
          fungalHyphaeDensity: 0.0,
          necromass: 0.05,
          organicCarbon: 5.02,
          particulateOrganicMatter: 0.02,
          mineralAssociatedOrganicMatter: 5.0,
          labileCarbon: 0.02,
          stableCarbon: 5.0,
          nitrogenContent: 0.05,
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.0,
    );
    final defaultState = _initialState(defaultProfile, isInitializing: true);

    final defaultEntry = _stripHistory(defaultState);
    _history
      ..clear()
      ..add(defaultEntry);
    _rebuildHistoryView();

    return defaultEntry.copyWith(history: _historyView);
  }

  Plant _seedPlant() {
    return Plant(
      id: "plant_1",
      species: "Wheat",
      age: 1.0,
      height: 0.1,
      lai: 0.1,
      turgorPressure: 0.8,
      rootSystem: [
        const RootNode(x: 0.5, z: 0, radius: 0.002, isTip: false),
        const RootNode(
          x: 0.5,
          z: 0.05,
          radius: 0.0018,
          isTip: false,
          parentIndex: 0,
        ),
        const RootNode(
          x: 0.5,
          z: 0.12,
          radius: 0.0015,
          isTip: true,
          parentIndex: 1,
        ),
      ],
      nitrogenUptake: 0.0,
      waterUptake: 0.0,
      totalBiomass: 150.0,
      rootBiomass: 60.0,
    );
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
      plants: [_seedPlant().copyWith(baseX: 0.5)],
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
      _rebuildHistoryView();
    }

    _pendingState = result.entry;
    Future.microtask(() {
      if (!_disposed && _pendingState != null) {
        state = _pendingState!.copyWith(history: _historyView);
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

  void setSpeed(double speed) {
    state = state.copyWith(timeScale: speed);
    _syncIsolate();
  }

  void setPrecipitation(double p) {
    _leaveHistoryMode();
    state = state.copyWith(precipitation: p);
    _syncIsolate();
  }

  void toggleAutoWeather() {
    _leaveHistoryMode();
    state = SimulationActions.updateWeather(
      state,
      state.airTemperature,
      state.relativeHumidity,
    ).copyWith(autoWeather: !state.autoWeather);
    _syncIsolate();
  }

  /// Sets the auto-weather mode explicitly so a control shown from a historical
  /// snapshot can apply the state the user actually saw.
  void setAutoWeather(bool enabled) {
    _leaveHistoryMode();
    state = SimulationActions.updateWeather(
      state,
      state.airTemperature,
      state.relativeHumidity,
    ).copyWith(autoWeather: enabled);
    _syncIsolate();
  }

  void applyCoverCrop() {
    _leaveHistoryMode();
    state = SimulationActions.toggleCoverCrop(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent(
          'Cover crop ${state.hasCoverCrop ? "planted" : "removed"}.',
          state.timeElapsed,
        );
    _syncIsolate();
  }

  /// Sets the cover-crop state explicitly for controls that may be showing a
  /// historical snapshot rather than the live engine.
  void setCoverCrop(bool planted) {
    _leaveHistoryMode();
    if (state.hasCoverCrop == planted) return;
    state = SimulationActions.toggleCoverCrop(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent(
          'Cover crop ${state.hasCoverCrop ? "planted" : "removed"}.',
          state.timeElapsed,
        );
    _syncIsolate();
  }

  void applyNutrients(Map<String, double> pendingNutrients) {
    _leaveHistoryMode();
    final session = ref.read(simulationSessionProvider);
    if (session.selectedLayerId == null) return;

    BiophysicalState newState = state;
    pendingNutrients.forEach((symbol, amount) {
      newState = SimulationActions.applyNutrients(
        newState,
        session.selectedLayerId!,
        symbol,
        amount,
      );
    });
    state = newState;
    _syncIsolate();
  }

  void triggerHeatWave() {
    _leaveHistoryMode();
    state = SimulationActions.triggerHeatWave(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent('Heat wave!', state.timeElapsed);
    _syncIsolate();
  }

  void triggerFlashFlood() {
    _leaveHistoryMode();
    state = SimulationActions.triggerFlashFlood(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent('Flash flood!', state.timeElapsed);
    _syncIsolate();
  }

  void updateWeather(double temperature, double humidity) {
    _leaveHistoryMode();
    state = SimulationActions.updateWeather(state, temperature, humidity);
    _syncIsolate();
  }

  void updateNutrient(String layerId, String symbol, double value) {
    _leaveHistoryMode();
    state = SimulationActions.applyNutrients(state, layerId, symbol, value);
    _syncIsolate();
  }

  void updateSolarRadiation(double value) {
    _leaveHistoryMode();
    state = state.copyWith(solarRadiationOverride: value);
    _syncIsolate();
  }

  void updatePAR(double value) {
    _leaveHistoryMode();
    state = state.copyWith(solarRadiationOverride: value / 2.1);
    _syncIsolate();
  }

  void updateAtmosphere({
    double? temperature,
    double? humidity,
    double? precipitation,
    double? co2,
  }) {
    _leaveHistoryMode();
    state = state.copyWith(
      airTemperature: temperature ?? state.airTemperature,
      relativeHumidity: humidity ?? state.relativeHumidity,
      precipitation: precipitation ?? state.precipitation,
      atmCO2: co2 ?? state.atmCO2,
    );
    _syncIsolate();
  }

  bool applyTillage() {
    _leaveHistoryMode();
    state = SimulationActions.applyTillage(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent('Soil tilled.', state.timeElapsed);
    _syncIsolate();
    return true;
  }

  /// Functional update pattern for soil layers.
  /// Decouples the UI from the internal structure of the SoilLayer.
  void updateLayer(String layerId, SoilLayer Function(SoilLayer) transform) {
    final List<SoilLayer> newLayers = state.profile.layers.map<SoilLayer>((l) {
      if (l.id == layerId) {
        return transform(l);
      }
      return l;
    }).toList();

    if (_disposed) return;
    _leaveHistoryMode();
    // Apply synchronously so a dragged slider never lags a frame behind.
    state = state.copyWith(profile: state.profile.copyWith(layers: newLayers));
    _syncIsolate();
  }

  /// Convenience wrapper for updating a single soil layer parameter by string name.
  void updateLayerParameter(String layerId, String param, double value) {
    updateLayer(layerId, (l) {
      switch (param) {
        case 'kSat':
          return l.copyWith(kSat: value);
        case 'vgAlpha':
          return l.copyWith(vgAlpha: value);
        case 'vgN':
          return l.copyWith(vgN: value);
        case 'sandFraction':
          return l.copyWith(sandFraction: value);
        case 'siltFraction':
          return l.copyWith(siltFraction: value);
        case 'clayFraction':
          return l.copyWith(clayFraction: value);
        case 'organicCarbon':
          return l.copyWith(organicCarbon: value);
        case 'bulkDensity':
          return l.copyWith(bulkDensity: value);
        case 'porosity':
          return l.copyWith(porosity: value);
        case 'nitrateContent':
          return l.copyWith(nitrateContent: value);
        case 'phosphateContent':
          return l.copyWith(phosphateContent: value);
        case 'potassiumContent':
          return l.copyWith(potassiumContent: value);
        default:
          return l;
      }
    });
  }

  /// Updates plant state by absorbing a nutrient amount.
  /// Triggered by Flame collision events between roots and nutrient particles.
  void absorbNutrient(String plantId, String symbol, double amount) {
    final List<Plant> updatedPlants = state.plants.map((p) {
      if (p.id == plantId) {
        switch (symbol) {
          case 'Ca':
            return p.copyWith(calciumUptake: p.calciumUptake + amount);
          case 'Mg':
            return p.copyWith(magnesiumUptake: p.magnesiumUptake + amount);
          case 'N':
            return p.copyWith(nitrogenUptake: p.nitrogenUptake + amount);
          case 'P':
            return p.copyWith(phosphorusUptake: p.phosphorusUptake + amount);
          default:
            return p;
        }
      }
      return p;
    }).toList();

    Future.microtask(() {
      if (!_disposed) state = state.copyWith(plants: updatedPlants);
    });
  }

  /// Consumes potassium from the soil pool (e.g., when spawning particles).
  bool consumePotassium(String layerId, double amount) {
    final List<SoilLayer> newLayers = state.profile.layers.map<SoilLayer>((l) {
      if (l.id == layerId && l.potassiumContent >= amount) {
        return l.copyWith(potassiumContent: l.potassiumContent - amount);
      }
      return l;
    }).toList();

    bool changed = false;
    for (int i = 0; i < state.profile.layers.length; i++) {
      if (state.profile.layers[i].potassiumContent !=
          newLayers[i].potassiumContent) {
        changed = true;
        break;
      }
    }

    if (changed) {
      Future.microtask(() {
        if (!_disposed) {
          state = state.copyWith(
            profile: state.profile.copyWith(layers: newLayers),
          );
          _syncIsolate();
        }
      });
      return true;
    }
    return false;
  }

  /// Generic resource consumption for visual synchronization.
  bool consumeResource(String layerId, String resourceType, double amount) {
    final List<SoilLayer> newLayers = state.profile.layers.map<SoilLayer>((l) {
      if (l.id == layerId) {
        switch (resourceType) {
          case 'labileCarbon':
            if (l.labileCarbon >= amount) {
              return l.copyWith(labileCarbon: l.labileCarbon - amount);
            }
            break;
          case 'nitrate':
            if (l.nitrateContent >= amount) {
              return l.copyWith(nitrateContent: l.nitrateContent - amount);
            }
            break;
          case 'ammonium':
            if (l.ammoniumContent >= amount) {
              return l.copyWith(ammoniumContent: l.ammoniumContent - amount);
            }
            break;
        }
      }
      return l;
    }).toList();

    Future.microtask(() {
      if (!_disposed) {
        state = state.copyWith(
          profile: state.profile.copyWith(layers: newLayers),
        );
        _syncIsolate();
      }
    });
    return true;
  }

  /// Consumes a small amount of gas from the soil pool.
  /// Used by visual bubble emitters to maintain mass conservation.
  bool consumeGas(String layerId, String gasSymbol, double amount) {
    final List<SoilLayer> newLayers = state.profile.layers.map<SoilLayer>((l) {
      if (l.id == layerId) {
        switch (gasSymbol) {
          case 'CO2':
            if (l.co2Content >= amount) {
              return l.copyWith(co2Content: l.co2Content - amount);
            }
            break;
          case 'CH4':
            if (l.methaneContent >= amount) {
              return l.copyWith(methaneContent: l.methaneContent - amount);
            }
            break;
          case 'N2O':
            if (l.nitrousOxideContent >= amount) {
              return l.copyWith(
                nitrousOxideContent: l.nitrousOxideContent - amount,
              );
            }
            break;
          case 'O2':
            // Oxygen actually increases when bubbles diffuse in
            return l.copyWith(oxygenContent: l.oxygenContent + amount);
        }
      }
      return l;
    }).toList();

    bool changed = false;
    for (int i = 0; i < state.profile.layers.length; i++) {
      final oldL = state.profile.layers[i];
      final newL = newLayers[i];
      if (oldL.co2Content != newL.co2Content ||
          oldL.methaneContent != newL.methaneContent ||
          oldL.nitrousOxideContent != newL.nitrousOxideContent ||
          oldL.oxygenContent != newL.oxygenContent) {
        changed = true;
        break;
      }
    }

    if (changed) {
      Future.microtask(() {
        if (!_disposed) {
          state = state.copyWith(
            profile: state.profile.copyWith(layers: newLayers),
          );
          _syncIsolate();
        }
      });
      return true;
    }
    return false;
  }

  Future<void> _saveState() => _persistence.save(state);

  Future<bool> hasSavedState() => _persistence.hasSavedState(
    // A run that has started but has not reached the periodic save yet.
    // A pristine provider only has the default entry, not a session.
    hasLiveRun: _history.length > 1,
  );

  Future<bool> loadLastState() async {
    final loadedState = await _persistence.load();
    if (loadedState != null) {
      _history
        ..clear()
        ..add(_stripHistory(loadedState));
      _rebuildHistoryView();
      state = loadedState.copyWith(history: _historyView);
      _syncIsolate();
      return true;
    }
    if (_history.length > 1) {
      state = _history.last.copyWith(history: _historyView);
      return true;
    }
    return false;
  }

  void startScrubbing() {
    // The starting snapshot is enough to enter the timeline view. There is no
    // range to scrub until a second snapshot exists, but the view itself is
    // available from launch and can show where the run began.
    if (_history.isEmpty) return;
    stop(); // Pause simulation while scrubbing
    ref.read(simulationSessionProvider.notifier).setScrubbing(true);
    ref
        .read(simulationSessionProvider.notifier)
        .setViewTime(_history.last.timeElapsed);
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

    final initial = _stripHistory(
      _initialState(
        scenario.initialProfile,
        scenario: scenario,
        timeScale: state.timeScale,
      ),
    );

    _history
      ..clear()
      ..add(initial);
    _rebuildHistoryView();

    state = initial.copyWith(history: _historyView, isInitializing: false);

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

    final startState = _stripHistory(state);
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

    _history
      ..clear()
      ..addAll(computedHistory);
    _rebuildHistoryView();

    state = computedHistory.first.copyWith(
      history: _historyView,
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
    // from a historical snapshot; the actual _history entries stay stripped.
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
