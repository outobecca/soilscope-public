import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, compute;
import '../models/biophysical_state.dart';
import '../models/soil_layer.dart';
import '../models/plant.dart';
import '../models/sustainability_score.dart';
import 'simulation_engine.dart';
import '../../core/biophysics_utils.dart';
import '../../core/simulation_constants.dart';

/// Commands sent to the simulation isolate
abstract class SimulationCommand {}

class StartCommand extends SimulationCommand {}

class StopCommand extends SimulationCommand {}

class UpdateStateCommand extends SimulationCommand {
  final BiophysicalState state;
  final double precipitation;
  UpdateStateCommand(this.state, this.precipitation);
}

/// Sanitizes state to prevent NaN/Infinity from crashing the UI.
/// Now handles the entire plant collection in the SPAC continuum.
BiophysicalState _sanitizeState(BiophysicalState state) {
  bool stateClean = true;
  final layers = List<SoilLayer>.from(state.profile.layers);
  for (int i = 0; i < layers.length; i++) {
    var l = layers[i];
    if (l.temperature.isNaN ||
        l.waterContent.isNaN ||
        l.ph.isNaN ||
        l.ec.isNaN ||
        l.oxygenContent.isNaN) {
      stateClean = false;
      layers[i] = l.copyWith(
        temperature: l.temperature.isNaN ? 293.15 : l.temperature,
        waterContent: l.waterContent.isNaN ? l.porosity * 0.5 : l.waterContent,
        ph: l.ph.isNaN ? 7.0 : l.ph,
        ec: l.ec.isNaN ? 0.5 : l.ec,
        oxygenContent: l.oxygenContent.isNaN ? BiophysicsUtils.atmO2Saturation : l.oxygenContent,
      );
    }
  }

  final List<Plant> nextPlants = [];
  for (final plant in state.plants) {
    if (plant.height.isNaN || plant.lai.isNaN || plant.turgorPressure.isNaN) {
      stateClean = false;
      nextPlants.add(
        plant.copyWith(
          height: plant.height.isNaN ? 0.1 : plant.height,
          lai: plant.lai.isNaN ? 0.1 : plant.lai,
          turgorPressure: plant.turgorPressure.isNaN ? 0.8 : plant.turgorPressure,
        ),
      );
    } else {
      nextPlants.add(plant);
    }
  }

  if (state.mycorrhizaState != null) {
    final ms = state.mycorrhizaState!;
    if (ms.rootColonization.isNaN || ms.totalHyphalLength.isNaN || ms.fungalBiomass.isNaN) {
      stateClean = false;
      state = state.copyWith(
        mycorrhizaState: ms.copyWith(
          rootColonization: ms.rootColonization.isNaN ? 0.0 : ms.rootColonization,
          totalHyphalLength: ms.totalHyphalLength.isNaN ? 0.0 : ms.totalHyphalLength,
          fungalBiomass: ms.fungalBiomass.isNaN ? 0.0 : ms.fungalBiomass,
        ),
      );
    }
  }

  if (state.score.totalSoilHealth.isNaN) {
    stateClean = false;
    state = state.copyWith(score: const SustainabilityScore());
  }

  if (!stateClean) {
    return state.copyWith(
      profile: state.profile.copyWith(layers: layers),
      plants: nextPlants,
    );
  }
  return state;
}

/// Wrapper for web compute tick
BiophysicalState _webTickWrapper((BiophysicalState, double, double) args) {
  final nextState = SimulationEngine.tick(args.$1, args.$2, precipitation: args.$3);
  return _sanitizeState(nextState);
}

/// The entry point for the simulation isolate
void simulationIsolateEntry(SendPort mainSendPort) {
  final childReceivePort = ReceivePort();
  mainSendPort.send(childReceivePort.sendPort);

  BiophysicalState? currentState;
  bool isRunning = false;
  double precipitation = 0.0;
  Timer? timer;

  childReceivePort.listen((message) {
    try {
      if (message is StartCommand) {
        isRunning = true;
        timer?.cancel();
        timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
          if (currentState != null && isRunning) {
            final dt = SimulationConstants.baseTickDelta * currentState!.timeScale;
            final nextState = SimulationEngine.tick(
              currentState!,
              dt,
              precipitation: precipitation,
            );
            currentState = _sanitizeState(nextState);
            mainSendPort.send(currentState);
          }
        });
      } else if (message is StopCommand) {
        isRunning = false;
        timer?.cancel();
      } else if (message is UpdateStateCommand) {
        currentState = message.state;
        precipitation = message.precipitation;
      }
    } catch (e) {
      debugPrint('SimulationIsolate Error: $e');
    }
  });
}

/// Helper class to manage the simulation isolate from the main thread
class SimulationIsolateManager {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _childSendPort;
  final List<SimulationCommand> _pendingCommands = [];

  // Web fallback properties
  Timer? _webTimer;
  BiophysicalState? _currentState;
  double _precipitation = 0.0;
  bool _isWebRunning = false;

  final StreamController<BiophysicalState> _stateController =
      StreamController<BiophysicalState>.broadcast();
  Stream<BiophysicalState> get stateStream => _stateController.stream;
  bool _initialized = false;

  Future<void> init() async {
    if (kIsWeb || _initialized) {
      if (kIsWeb) debugPrint('SimulationIsolateManager: Running in Web Mode (Main Thread)');
      return;
    }
    _initialized = true;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(simulationIsolateEntry, _receivePort!.sendPort);

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _childSendPort = message;
        for (final cmd in _pendingCommands) {
          _childSendPort?.send(cmd);
        }
        _pendingCommands.clear();
      } else if (message is BiophysicalState) {
        if (!_stateController.isClosed) {
          _stateController.add(message);
        }
      }
    });
  }

  void _sendCommand(SimulationCommand cmd) {
    if (kIsWeb) {
      _processWebCommand(cmd);
      return;
    }

    if (_childSendPort != null) {
      _childSendPort?.send(cmd);
    } else {
      _pendingCommands.add(cmd);
    }
  }

  void _runWebLoop() async {
    while (_isWebRunning) {
      if (_currentState != null) {
        final dt = SimulationConstants.baseTickDelta * _currentState!.timeScale;
        try {
          final nextState = await compute(_webTickWrapper, (_currentState!, dt, _precipitation));
          _currentState = nextState;
          if (!_stateController.isClosed) {
            _stateController.add(_currentState!);
          }
        } catch (e) {
          debugPrint('Error in web simulation tick: $e');
          await Future.delayed(Duration.zero);
          final nextState = SimulationEngine.tick(_currentState!, dt, precipitation: _precipitation);
          _currentState = _sanitizeState(nextState);
          Future.microtask(() {
            if (!_stateController.isClosed) {
              _stateController.add(_currentState!);
            }
          });
        }
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _processWebCommand(SimulationCommand cmd) {
    if (cmd is StartCommand) {
      if (!_isWebRunning) {
        _isWebRunning = true;
        _runWebLoop();
      }
    } else if (cmd is StopCommand) {
      _isWebRunning = false;
    } else if (cmd is UpdateStateCommand) {
      _currentState = cmd.state;
      _precipitation = cmd.precipitation;
    }
  }

  void start() {
    _sendCommand(StartCommand());
  }

  void stop() {
    _sendCommand(StopCommand());
  }

  void updateState(BiophysicalState state, double precipitation) {
    _sendCommand(UpdateStateCommand(state, precipitation));
  }

  void dispose() {
    stop();
    _isolate?.kill();
    _webTimer?.cancel();
    _receivePort?.close();
    _stateController.close();
  }
}
