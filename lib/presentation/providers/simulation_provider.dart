import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/biophysical_state.dart';
import '../../domain/models/soil_profile.dart';
import '../../domain/models/soil_layer.dart';
import '../../domain/models/plant.dart';
import '../../domain/actions/simulation_actions.dart';
import '../../domain/models/scenario.dart';
import '../../domain/solvers/simulation_isolate.dart';
import '../../domain/solvers/scoring_solver.dart';
import '../../domain/solvers/simulation_engine.dart';
import '../../domain/solvers/particle_physics_isolate.dart';

import 'event_log_provider.dart';
import 'simulation_session_provider.dart';

part 'simulation_provider.g.dart';

@Riverpod(keepAlive: true)
class Simulation extends _$Simulation {
  static const _storage = FlutterSecureStorage(aOptions: AndroidOptions());
  static const _stateKey = 'last_biophysical_state';

  late SimulationIsolateManager _isolateManager;
  late ParticlePhysicsIsolateManager particleIsolate;
  StreamSubscription<BiophysicalState>? _stateSubscription;
  double _particleMinX = -7400;
  double _particleMaxX = 8600;
  double _particleWorldHeight = 1000;
  double _particleSurfaceY = 450;

  int _tickCount = 0;
  // Timeline for scrubbing (entries must have `history: []` to avoid nesting).
  final List<BiophysicalState> _history = [];

  BiophysicalState _stripHistory(BiophysicalState s) =>
      s.copyWith(history: const []);

  @override
  BiophysicalState build() {
    _isolateManager = SimulationIsolateManager();
    particleIsolate = ParticlePhysicsIsolateManager();
    _initIsolate();
    particleIsolate.init();

    ref.onDispose(() {
      _stateSubscription?.cancel();
      _isolateManager.dispose();
      particleIsolate.dispose();
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
    final defaultPlant = Plant(
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

    final defaultState = BiophysicalState(
      profile: defaultProfile,
      plants: [defaultPlant.copyWith(baseX: 0.5)],
      timeElapsed: 0,
      precipitation: 0.0,
      airTemperature: 293.15,
      relativeHumidity: 0.5,
      atmCO2: 0.017,
      autoWeather: false,
      timeScale: 1.0,
      hasCoverCrop: false,
      isRunning: false,
      history: [],
    );

    final defaultEntry = _stripHistory(defaultState);
    _history
      ..clear()
      ..add(defaultEntry);

    return defaultEntry.copyWith(history: List.unmodifiable(_history));
  }

  Future<void> _initIsolate() async {
    await _isolateManager.init();
    _stateSubscription = _isolateManager.stateStream.listen((newState) {
      // While scrubbing, freeze the background simulation result from affecting display
      final session = ref.read(simulationSessionProvider);
      if (session.isScrubbing) return;

      BiophysicalState processedState = newState;
      bool eventApplied = false;

      // Cultivation Event Triggers
      if (state.currentScenario != null) {
        for (final event in state.currentScenario!.cultivationPlan) {
          if (processedState.timeElapsed >= event.executionTime && 
              state.timeElapsed < event.executionTime) {
            processedState = _applyEvent(processedState, event);
            eventApplied = true;
          }
        }
      }

      if (eventApplied) {
        _isolateManager.updateState(processedState, processedState.precipitation);
      }

      final dt = 600.0 * processedState.timeScale;
      final newScore = ScoringSolver.solve(processedState, dt);

      // Merge Simulation truth with UI truth to prevent race conditions
      final entry = _mergeSimulationState(processedState, state).copyWith(
        score: newScore,
      );
      
      _history.add(_stripHistory(entry));
      if (_history.length > 500) {
        _history.removeAt(0);
      }

      state = entry.copyWith(history: List.unmodifiable(_history));
      
      _tickCount++;
      if (_tickCount >= 50) {
        _tickCount = 0;
        _saveState();
      }
    });
  }

  /// Merges background simulation results with current Control state.
  /// Preserves user overrides from [localState] while taking biophysical results from [remoteState].
  BiophysicalState _mergeSimulationState(BiophysicalState remoteState, BiophysicalState localState) {
    return remoteState.copyWith(
      // Preserve Control State (Main thread is source of truth)
      isRunning: localState.isRunning,
      timeScale: localState.timeScale,
      autoWeather: localState.autoWeather,
      hasCoverCrop: localState.hasCoverCrop,
      solarRadiationOverride: localState.solarRadiationOverride,
      
      // Atmospheric inputs: Take from isolate ONLY if autoWeather is on
      airTemperature: localState.autoWeather ? remoteState.airTemperature : localState.airTemperature,
      relativeHumidity: localState.autoWeather ? remoteState.relativeHumidity : localState.relativeHumidity,
      precipitation: localState.autoWeather ? remoteState.precipitation : localState.precipitation,
      atmCO2: localState.autoWeather ? remoteState.atmCO2 : localState.atmCO2,

      // Preserve Scenario (Isolate shouldn't change scenario structure)
      currentScenario: localState.currentScenario,
    );
  }

  void _syncIsolate() {
    if (state.isRunning) {
      _isolateManager.updateState(_stripHistory(state), state.precipitation);
    }
  }

  void start() {
    state = state.copyWith(isRunning: true);
    _isolateManager.updateState(_stripHistory(state), state.precipitation);
    _isolateManager.start();
    particleIsolate.start(
      _particleMinX,
      _particleMaxX,
      _particleWorldHeight,
      _particleSurfaceY,
    );
  }

  void stop() {
    state = state.copyWith(isRunning: false);
    _isolateManager.stop();
    particleIsolate.stop();
    _saveState();
  }

  void setSpeed(double speed) {
    state = state.copyWith(timeScale: speed);
    _syncIsolate();
  }

  void setPrecipitation(double p) {
    state = state.copyWith(precipitation: p);
    _syncIsolate();
  }

  void toggleAutoWeather() {
    state = SimulationActions.updateWeather(
      state,
      state.airTemperature,
      state.relativeHumidity,
    ).copyWith(autoWeather: !state.autoWeather);
    _syncIsolate();
  }

  void applyCoverCrop() {
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
    state = SimulationActions.triggerHeatWave(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent('Heat wave!', state.timeElapsed);
    _syncIsolate();
  }

  void triggerFlashFlood() {
    state = SimulationActions.triggerFlashFlood(state);
    ref
        .read(eventLogProvider.notifier)
        .addEvent('Flash flood!', state.timeElapsed);
    _syncIsolate();
  }

  void updateWeather(double temperature, double humidity) {
    state = SimulationActions.updateWeather(state, temperature, humidity);
    _syncIsolate();
  }

  void updateNutrient(String layerId, String symbol, double value) {
    state = SimulationActions.applyNutrients(state, layerId, symbol, value);
    _syncIsolate();
  }
  
  void updateSolarRadiation(double value) {
    state = state.copyWith(solarRadiationOverride: value);
    _syncIsolate();
  }

  void updatePAR(double value) {
    state = state.copyWith(solarRadiationOverride: value / 2.1);
    _syncIsolate();
  }

  void updateAtmosphere({double? temperature, double? humidity, double? precipitation, double? co2}) {
    state = state.copyWith(
      airTemperature: temperature ?? state.airTemperature,
      relativeHumidity: humidity ?? state.relativeHumidity,
      precipitation: precipitation ?? state.precipitation,
      atmCO2: co2 ?? state.atmCO2,
    );
    _syncIsolate();
  }

  bool applyTillage() {
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

    state = state.copyWith(plants: updatedPlants);
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
      if (state.profile.layers[i].potassiumContent != newLayers[i].potassiumContent) {
        changed = true;
        break;
      }
    }

    if (changed) {
      state = state.copyWith(profile: state.profile.copyWith(layers: newLayers));
      _syncIsolate();
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
            if (l.labileCarbon >= amount) return l.copyWith(labileCarbon: l.labileCarbon - amount);
            break;
          case 'nitrate':
            if (l.nitrateContent >= amount) return l.copyWith(nitrateContent: l.nitrateContent - amount);
            break;
          case 'ammonium':
            if (l.ammoniumContent >= amount) return l.copyWith(ammoniumContent: l.ammoniumContent - amount);
            break;
        }
      }
      return l;
    }).toList();

    state = state.copyWith(profile: state.profile.copyWith(layers: newLayers));
    _syncIsolate();
    return true;
  }

  /// Consumes a small amount of gas from the soil pool.
  /// Used by visual bubble emitters to maintain mass conservation.
  bool consumeGas(String layerId, String gasSymbol, double amount) {
    final List<SoilLayer> newLayers = state.profile.layers.map<SoilLayer>((l) {
      if (l.id == layerId) {
        switch (gasSymbol) {
          case 'CO2':
            if (l.co2Content >= amount) return l.copyWith(co2Content: l.co2Content - amount);
            break;
          case 'CH4':
            if (l.methaneContent >= amount) return l.copyWith(methaneContent: l.methaneContent - amount);
            break;
          case 'N2O':
            if (l.nitrousOxideContent >= amount) return l.copyWith(nitrousOxideContent: l.nitrousOxideContent - amount);
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
      state = state.copyWith(profile: state.profile.copyWith(layers: newLayers));
      _syncIsolate();
      return true;
    }
    return false;
  }


  Future<void> _saveState() async {
    try {
      final jsonStr = jsonEncode(state.toJson());
      await _storage.write(key: _stateKey, value: jsonStr);
    } catch (e) {
      debugPrint('Error saving state: $e');
    }
  }

  Future<bool> hasSavedState() async {
    final hasSecure = await _storage.containsKey(key: _stateKey);
    if (hasSecure) return true;

    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_stateKey) || _history.isNotEmpty;
  }

  Future<bool> loadLastState() async {
    String? jsonStr = await _storage.read(key: _stateKey);

    // Migration logic from SharedPreferences to FlutterSecureStorage
    if (jsonStr == null) {
      final prefs = await SharedPreferences.getInstance();
      jsonStr = prefs.getString(_stateKey);
      if (jsonStr != null) {
        await _storage.write(key: _stateKey, value: jsonStr);
        await prefs.remove(_stateKey);
      }
    }

    if (jsonStr != null) {
      try {
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        final loadedState = BiophysicalState.fromJson(jsonMap);
        if (_history.isEmpty) {
          _history.add(_stripHistory(loadedState));
        }
        state = loadedState.copyWith(history: List.unmodifiable(_history));
        _syncIsolate();
        return true;
      } catch (e) {
        debugPrint('Error loading saved state: $e');
      }
    }
    if (_history.isNotEmpty) {
      state = _history.last.copyWith(history: List.unmodifiable(_history));
      return true;
    }
    return false;
  }

  void startScrubbing() {
    stop(); // Pause simulation while scrubbing
    ref.read(simulationSessionProvider.notifier).setScrubbing(true);
    if (_history.isNotEmpty) {
      ref.read(simulationSessionProvider.notifier).setViewTime(_history.last.timeElapsed);
    }
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
    state = state.copyWith(
      currentScenario: scenario,
      profile: scenario.initialProfile,
    );
    _syncIsolate();
  }

  Future<void> preCalculateTimeline(int days) async {
    ref.read(simulationSessionProvider.notifier).setScrubbing(true);
    state = state.copyWith(isRunning: false);
    _isolateManager.stop();
    particleIsolate.stop();

    // Use a compute task to run fast simulation
    final computedHistory = await compute(_preCalculateTimelineTask, (state, days));
    _history.clear();
    _history.addAll(computedHistory);

    if (_history.isNotEmpty) {
      state = _history.first.copyWith(
        history: List.unmodifiable(_history),
      );
      ref.read(simulationSessionProvider.notifier).setViewTime(_history.first.timeElapsed);
    }
  }

  void configureParticleDomain(double minX, double maxX, double height, double surfaceY) {
    _particleMinX = minX;
    _particleMaxX = maxX;
    _particleWorldHeight = height;
    _particleSurfaceY = surfaceY;
    if (state.isRunning) {
      particleIsolate.start(
        _particleMinX,
        _particleMaxX,
        _particleWorldHeight,
        _particleSurfaceY,
      );
    }
  }
}

@Riverpod(keepAlive: true)
BiophysicalState displayedSimulationState(Ref ref) {
  final simState = ref.watch(simulationProvider);
  final session = ref.watch(simulationSessionProvider);
  
  if (session.isScrubbing) {
    final history = simState.history;
    if (history.isEmpty) return simState;
    final index = history.indexWhere((s) => s.timeElapsed >= session.viewTime);
    if (index == -1) return history.last;
    if (index == 0) return history.first;
    final before = history[index - 1];
    final after = history[index];
    if ((session.viewTime - before.timeElapsed).abs() <
        (after.timeElapsed - session.viewTime).abs()) {
      return before;
    }
    return after;
  }
  return simState;
}

List<BiophysicalState> _preCalculateTimelineTask((BiophysicalState, int) args) {
  final initialState = args.$1;
  final days = args.$2;
  final List<BiophysicalState> history = [];
  BiophysicalState currentState = initialState;
  
  const double dt = 3600.0; // 1 hour steps
  final totalTicks = (days * 24).toInt();
  
  for (int i = 0; i < totalTicks; i++) {
    // 1. Check cultivation events
    if (currentState.currentScenario != null) {
      for (final event in currentState.currentScenario!.cultivationPlan) {
        if (event.executionTime >= currentState.timeElapsed && 
            event.executionTime < currentState.timeElapsed + dt) {
          currentState = _applyEvent(currentState, event);
        }
      }
    }
    
    // 2. Advance simulation
    currentState = SimulationEngine.tick(currentState, dt);
    
    // 3. Save snapshot (every 6 hours)
    if (i % 6 == 0) {
      history.add(currentState.copyWith(history: []));
    }
  }
  return history;
}

BiophysicalState _applyEvent(BiophysicalState state, CultivationEvent event) {
  switch (event.type) {
    case 'till':
      return SimulationActions.applyTillage(state);
    case 'fertilize':
      if (event.layerId != null) {
        // Use extraData for nutrient symbol if present, default to 'N'
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

