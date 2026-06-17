import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../../core/simulation_constants.dart';
import 'particle_physics_solver.dart';

/// Commands for the particle isolate
abstract class ParticleCommand {}

class StartParticles extends ParticleCommand {
  final double minX;
  final double maxX;
  final double height;
  final double surfaceY;
  StartParticles(this.minX, this.maxX, this.height, this.surfaceY);
}

class StopParticles extends ParticleCommand {}

class UpdateEnvironment extends ParticleCommand {
  final double temperature;
  final List<List<double>> hotspots; // [[x, y, type], ...]
  final double friction;
  final bool isAnaerobic;
  final double waterFlux;
  final double cnRatio;
  final List<double>? visibleRect;
  final double windDrift;
  final double windNoise;
  final double flowBoost;

  UpdateEnvironment(
    this.temperature,
    this.hotspots, {
    this.friction = 1.0,
    this.isAnaerobic = false,
    this.waterFlux = 0.0,
    this.cnRatio = 10.0,
    this.visibleRect,
    this.windDrift = 10.0,
    this.windNoise = 15.0,
    this.flowBoost = 1.0,
  });
}

class AddParticles extends ParticleCommand {
  final List<List<double>> newParticles; // Data-listat
  AddParticles(this.newParticles);
}

class SetParticles extends ParticleCommand {
  final List<List<double>> particles;
  SetParticles(this.particles);
}

class RemoveParticles extends ParticleCommand {
  final int count;
  final int typeIndex;
  RemoveParticles(this.count, this.typeIndex);
}

/// The entry point for the particle physics isolate
void particleIsolateEntry(SendPort mainSendPort) {
  final childReceivePort = ReceivePort();
  mainSendPort.send(childReceivePort.sendPort);

  List<Particle> particles = [];
  bool isRunning = false;
  double minX = -7400;
  double maxX = 8600;
  double worldHeight = 1000;
  double surfaceY = 450;
  double currentTemperature = 293.15;
  List<({double x, double y, int type})> currentHotspots = [];
  double currentFriction = 1.0;
  bool currentIsAnaerobic = false;
  double currentWaterFlux = 0.0;
  double currentCnRatio = 10.0;
  List<double>? currentVisibleRect;
  double currentWindDrift = 10.0;
  double currentWindNoise = 15.0;
  double currentFlowBoost = 1.0;

  Timer? timer;
  Stopwatch stopwatch = Stopwatch();

  void sendSnapshot() {
    final buffer = Float32List(particles.length * 10);
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final offset = i * 10;
      
      buffer[offset] = p.id.toDouble();
      buffer[offset + 1] = p.x;
      buffer[offset + 2] = p.y;
      buffer[offset + 3] = p.vx;
      buffer[offset + 4] = p.vy;
      buffer[offset + 5] = p.type.index.toDouble();
      buffer[offset + 6] = p.calculateVisualState();
      buffer[offset + 7] = p.x0;
      buffer[offset + 8] = p.y0;
      buffer[offset + 9] = p.t;
    }
    mainSendPort.send(
      TransferableTypedData.fromList([buffer.buffer.asInt8List()]),
    );
  }

  childReceivePort.listen((message) {
    if (message is StartParticles) {
      isRunning = true;
      minX = message.minX;
      maxX = message.maxX;
      worldHeight = message.height;
      surfaceY = message.surfaceY;

      stopwatch.start();
      timer?.cancel();
      timer = Timer.periodic(
        const Duration(milliseconds: SimulationConstants.physicsTickMs),
        (t) {
          if (!isRunning) return;

          final dt = SimulationConstants.physicsTickMs / 1000.0;
          final time = stopwatch.elapsedMilliseconds / 1000.0;

          ParticlePhysicsSolver.updateParticles(
            particles,
            dt,
            time,
            minX,
            maxX,
            worldHeight,
            surfaceY,
            temperatureK: currentTemperature,
            hotspots: currentHotspots,
            friction: currentFriction,
            isAnaerobic: currentIsAnaerobic,
            waterFlux: currentWaterFlux,
            cnRatio: currentCnRatio,
            visibleRect: currentVisibleRect,
            windDrift: currentWindDrift,
            windNoise: currentWindNoise,
            flowBoost: currentFlowBoost,
          );

          // Remove dead particles
          particles.removeWhere((p) => p.life <= 0);
          sendSnapshot();
        },
      );
    } else if (message is StopParticles) {
      isRunning = false;
      timer?.cancel();
      stopwatch.stop();
    } else if (message is UpdateEnvironment) {
      currentTemperature = message.temperature;
      currentHotspots = message.hotspots
          .map((h) => (x: h[0], y: h[1], type: h[2].toInt()))
          .toList();
      currentFriction = message.friction;
      currentIsAnaerobic = message.isAnaerobic;
      currentWaterFlux = message.waterFlux;
      currentCnRatio = message.cnRatio;
      currentVisibleRect = message.visibleRect;
      currentWindDrift = message.windDrift;
      currentWindNoise = message.windNoise;
      currentFlowBoost = message.flowBoost;
    } else if (message is AddParticles) {
      for (final data in message.newParticles) {
        particles.add(Particle.fromData(data));
      }
      if (particles.length > 400) {
        particles.removeRange(0, particles.length - 400);
      }
      if (!isRunning) sendSnapshot();
    } else if (message is SetParticles) {
      particles = message.particles.map(Particle.fromData).toList();
      if (particles.length > 400) {
        particles = particles.sublist(0, 400);
      }
      if (!isRunning) sendSnapshot();
    } else if (message is RemoveParticles) {
      int removed = 0;
      particles.removeWhere((p) {
        if (removed < message.count && p.type.index == message.typeIndex) {
          removed++;
          return true;
        }
        return false;
      });
      if (!isRunning) sendSnapshot();
    }
  });
}

/// Manager for the particle isolate
class ParticlePhysicsIsolateManager {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  SendPort? _childSendPort;
  final Map<int, int> _counts = {};
  final List<ParticleCommand> _pendingCommands = [];

  final StreamController<Float32List> _outputController =
      StreamController.broadcast();
  Stream<Float32List> get particleStream => _outputController.stream;
  bool _initialized = false;
  int _msgCount = 0;

  int getParticleCount(int typeIndex) => _counts[typeIndex] ?? 0;

  Future<void> init() async {
    if (kIsWeb) {
      debugPrint(
        'ParticlePhysicsIsolateManager: Running in Web Mode (Main Thread)',
      );
      return;
    }
    if (_initialized) return;
    _initialized = true;

    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      particleIsolateEntry,
      _receivePort!.sendPort,
    );

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _childSendPort = message;
        for (final cmd in _pendingCommands) {
          _childSendPort?.send(cmd);
        }
        _pendingCommands.clear();
      } else if (message is TransferableTypedData) {
        final floatList = message.materialize().asFloat32List();
        _msgCount++;
        if (_msgCount % 10 == 0) {
          // Update local counts from snapshot (less frequent to save CPU)
          _counts.clear();
          for (int i = 0; i < floatList.length; i += 10) {
            final type = floatList[i + 5].toInt();
            _counts[type] = (_counts[type] ?? 0) + 1;
          }
        }
        if (!_outputController.isClosed) {
          _outputController.add(floatList);
        }
      }
    });
  }

  bool _isWebRunning = false;
  Float32List _webParticleData = Float32List(0);
  double _webLastTickTime = 0;

  // Web environment state
  double _webTemperature = 293.15;
  double _webFriction = 1.0;
  double _webWaterFlux = 0.0;
  double _webFlowBoost = 1.0;

  void _processWebCommand(ParticleCommand cmd) {
    if (cmd is StartParticles) {
      if (!_isWebRunning) {
        _isWebRunning = true;
        _runWebLoop();
      }
    } else if (cmd is StopParticles) {
      _isWebRunning = false;
    } else if (cmd is AddParticles) {
      // Convert List<List<double>> to Float32List
      final count = cmd.newParticles.length;
      final newData = Float32List(count * 10);
      for (int i = 0; i < count; i++) {
        final pData = cmd.newParticles[i];
        if (pData.length < 7) continue;
        final offset = i * 10;
        final p = Particle.fromData(pData);
        
        newData[offset] = p.id.toDouble();
        newData[offset + 1] = p.x;
        newData[offset + 2] = p.y;
        newData[offset + 3] = p.vx;
        newData[offset + 4] = p.vy;
        newData[offset + 5] = p.type.index.toDouble();
        newData[offset + 6] = p.calculateVisualState();
        newData[offset + 7] = p.x0;
        newData[offset + 8] = p.y0;
        newData[offset + 9] = p.t;
      }

      final newList = Float32List(_webParticleData.length + newData.length);
      newList.setAll(0, _webParticleData);
      newList.setAll(_webParticleData.length, newData);
      _webParticleData = newList;
    } else if (cmd is SetParticles) {
      final count = cmd.particles.length;
      final newData = Float32List(count * 10);
      for (int i = 0; i < count; i++) {
        final pData = cmd.particles[i];
        if (pData.length < 7) continue;
        final offset = i * 10;
        final p = Particle.fromData(pData);
        
        newData[offset] = p.id.toDouble();
        newData[offset + 1] = p.x;
        newData[offset + 2] = p.y;
        newData[offset + 3] = p.vx;
        newData[offset + 4] = p.vy;
        newData[offset + 5] = p.type.index.toDouble();
        newData[offset + 6] = p.calculateVisualState();
        newData[offset + 7] = p.x0;
        newData[offset + 8] = p.y0;
        newData[offset + 9] = p.t;
      }
      _webParticleData = newData;
    } else if (cmd is UpdateEnvironment) {
      _webTemperature = cmd.temperature;
      _webFriction = cmd.friction;
      _webWaterFlux = cmd.waterFlux;
      _webFlowBoost = cmd.flowBoost;
    } else if (cmd is RemoveParticles) {
      if (_webParticleData.isEmpty) return;

      final List<double> filtered = [];
      int removedCount = 0;
      for (int i = 0; i < _webParticleData.length; i += 10) {
        final typeIndex = _webParticleData[i + 6].toInt();
        if (typeIndex == cmd.typeIndex && removedCount < cmd.count) {
          removedCount++;
          continue;
        }
        for (int j = 0; j < 10; j++) {
          filtered.add(_webParticleData[i + j]);
        }
      }
      _webParticleData = Float32List.fromList(filtered);
    }
  }

  void _runWebLoop() async {
    _webLastTickTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
    while (_isWebRunning) {
      final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final dt = (now - _webLastTickTime).clamp(0.001, 0.1);
      _webLastTickTime = now;

      if (_webParticleData.isNotEmpty) {
        // Simple Euler integration for Web mode fallback
        // Particle format: [id, x, y, vx, vy, life, type, charge, mass, radius] (stride 10)
        for (int i = 0; i < _webParticleData.length; i += 10) {
          // Apply Brownian motion based on temperature (jitter)
          final tempC = _webTemperature - 273.15;
          final jitter = math.max(0.0, tempC) * 0.005;
          _webParticleData[i + 3] += (math.Random().nextDouble() - 0.5) * jitter;
          _webParticleData[i + 4] += (math.Random().nextDouble() - 0.5) * jitter;

          // Apply water flux (vertical drift)
          _webParticleData[i + 2] += _webWaterFlux * dt * 50.0 * _webFlowBoost; // Scaled for visual effect

          // Apply velocity (Euler)
          _webParticleData[i + 1] += _webParticleData[i + 3] * dt * _webFlowBoost;
          _webParticleData[i + 2] += _webParticleData[i + 4] * dt * _webFlowBoost;

          // Apply friction
          _webParticleData[i + 3] *= (1.0 - _webFriction * dt);
          _webParticleData[i + 4] *= (1.0 - _webFriction * dt);
          
          // Natural aging
          double life = _webParticleData[i + 6].abs() % 1.0;
          life -= 0.01 * dt * _webFlowBoost;
          if (life < 0) life = 0;
          
          // Re-encode state (simple version for web loop)
          final bool isImmobilized = _webParticleData[i + 6] < 0;
          _webParticleData[i + 6] = isImmobilized ? -life : life;
        }

        // Emit data & update counts
        _msgCount++;
        if (_msgCount % 10 == 0) {
          _counts.clear();
          final List<double> living = [];
          for (int i = 0; i < _webParticleData.length; i += 10) {
            final life = _webParticleData[i + 6].abs();
            // If life is tiny or 0, consider it dead
            if (life < 0.01) continue;

            final type = _webParticleData[i + 5].toInt();
            _counts[type] = (_counts[type] ?? 0) + 1;
            for (int j = 0; j < 10; j++) {
              living.add(_webParticleData[i + j]);
            }
          }
          _webParticleData = Float32List.fromList(living);
        }

        if (!_outputController.isClosed) {
          _outputController.add(_webParticleData);
        }
      }

      await Future.delayed(const Duration(milliseconds: 32)); // ~30 FPS
    }
  }

  void _sendCommand(ParticleCommand cmd) {
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

  void start(double minX, double maxX, double height, double surfaceY) {
    _sendCommand(StartParticles(minX, maxX, height, surfaceY));
  }

  void stop() {
    _sendCommand(StopParticles());
  }

  void updateEnvironment(
    double temperature,
    List<List<double>> hotspots, {
    double friction = 1.0,
    bool isAnaerobic = false,
    double waterFlux = 0.0,
    double cnRatio = 10.0,
    List<double>? visibleRect,
    double windDrift = 10.0,
    double windNoise = 15.0,
    double flowBoost = 1.0,
  }) {
    _sendCommand(
      UpdateEnvironment(
        temperature,
        hotspots,
        friction: friction,
        isAnaerobic: isAnaerobic,
        waterFlux: waterFlux,
        cnRatio: cnRatio,
        visibleRect: visibleRect,
        windDrift: windDrift,
        windNoise: windNoise,
        flowBoost: flowBoost,
      ),
    );
  }

  void addParticles(List<Particle> newOnes) {
    final data = newOnes.map((p) => p.toData()).toList();
    _sendCommand(AddParticles(data));
  }

  void setParticles(List<Particle> particles) {
    final data = particles.map((p) => p.toData()).toList();
    _sendCommand(SetParticles(data));
  }

  void removeParticles(int count, int typeIndex) {
    _sendCommand(RemoveParticles(count, typeIndex));
  }

  void dispose() {
    stop();
    _isolate?.kill();
    _receivePort?.close();
    _outputController.close();
  }
}
