import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/debug_log.dart';
import '../models/biophysical_state.dart';
import '../solvers/particle_physics_isolate.dart';
import '../solvers/simulation_isolate.dart';

/// Coalesces UI state pushes into at most one per engine tick.
///
/// The engine only reads its state when its own timer fires, so intermediate
/// pushes during a slider drag are never observed: the last push before the
/// tick is the one that matters. [request] sends the first update immediately
/// (keeping the current response latency) and holds later ones until the next
/// engine frame, where [onEngineFrame] returns the latest. Pure and timer-free
/// so the policy is testable without an isolate.
class EngineSyncGate {
  BiophysicalState? _pending;
  bool _tickSeen = false;

  /// Returns the state to send now, or null when it must wait for a tick.
  BiophysicalState? request(BiophysicalState state) {
    if (!_tickSeen) {
      _tickSeen = true;
      return state;
    }
    _pending = state;
    return null;
  }

  /// Returns the coalesced state to flush after an engine frame, if any.
  BiophysicalState? onEngineFrame() {
    _tickSeen = false;
    final pending = _pending;
    _pending = null;
    return pending;
  }

  void reset() {
    _pending = null;
    _tickSeen = false;
  }
}

/// Owns the engine and particle isolates, their initialization watchdog and
/// the engine tick subscription.
///
/// The notifier supplies callbacks for state reads and failure reporting; the
/// runtime owns everything with a lifetime, so the provider no longer has to.
class SimulationRuntime {
  SimulationRuntime({this.initializationTimeout = const Duration(seconds: 10)});

  final SimulationIsolateManager engine = SimulationIsolateManager();
  final EngineSyncGate _syncGate = EngineSyncGate();
  final ParticlePhysicsIsolateManager particles =
      ParticlePhysicsIsolateManager();
  final Duration initializationTimeout;

  StreamSubscription<BiophysicalState>? _subscription;
  Timer? _watchdog;
  bool _disposed = false;
  bool _timedOut = false;

  double _minX = -7400;
  double _maxX = 8600;
  double _worldHeight = 1000;
  double _surfaceY = 450;

  /// Starts both isolates and subscribes to engine ticks.
  ///
  /// [readState] supplies the current session controls, [isScrubbing] freezes
  /// ticks while the user views history, and [onTick] receives accepted engine
  /// frames. A failed or hung start calls [onFailure] once.
  Future<void> initialize({
    required BiophysicalState Function() readState,
    required bool Function() isScrubbing,
    required void Function(BiophysicalState) onTick,
    required void Function() onFailure,
    required void Function() onReady,
  }) async {
    _disposed = false;
    _timedOut = false;
    _watchdog?.cancel();
    _watchdog = Timer(initializationTimeout, () {
      if (_disposed) return;
      _timedOut = true;
      onFailure();
    });

    // Particle startup is independent; a slow particle isolate must not delay
    // the simulation engine.
    unawaited(particles.init());

    try {
      await engine.init();
    } catch (error, stack) {
      _watchdog?.cancel();
      _watchdog = null;
      debugLog('[SimulationRuntime] Engine initialization failed: $error');
      debugPrintStack(stackTrace: stack);
      if (!_disposed) onFailure();
      return;
    }

    _watchdog?.cancel();
    _watchdog = null;

    // A watchdog may already have failed the session while spawn was hung.
    if (_disposed || _timedOut) return;

    // A retry can reach this method after the engine has already started.
    // [SimulationIsolateManager.init] returns immediately once initialized, so
    // the previous subscription must be torn down explicitly; otherwise every
    // engine tick would be processed twice.
    await _subscription?.cancel();
    _subscription = null;

    _subscription = engine.stateStream.listen((newState) {
      if (_disposed) return;
      // Flush a coalesced UI edit before deciding whether this frame is
      // accepted: the engine must see the latest controls on its next tick
      // even if this frame is skipped for scrubbing.
      final pending = _syncGate.onEngineFrame();
      if (pending != null) _push(pending);
      final current = readState();
      if (!current.isRunning || isScrubbing()) return;
      onTick(newState);
    });

    onReady();
  }

  /// Pushes UI-owned controls to a running engine.
  ///
  /// At most one push is sent per engine tick; a burst of slider events
  /// coalesces into the latest value instead of one isolate message per
  /// pointer event.
  void sync(BiophysicalState state) {
    if (!state.isRunning) return;
    final toSend = _syncGate.request(state);
    if (toSend != null) _push(toSend);
  }

  void _push(BiophysicalState state) {
    engine.updateState(
      state.copyWith(history: const []),
      state.precipitation,
    );
  }

  /// Pushes a state produced by event handling without changing the controls.
  void updateEngineState(BiophysicalState state) {
    engine.updateState(state, state.precipitation);
  }

  void start() {
    _syncGate.reset();
    engine.start();
    particles.start(_minX, _maxX, _worldHeight, _surfaceY);
  }

  void stop() {
    _syncGate.reset();
    engine.stop();
    particles.stop();
  }

  void configureParticleDomain(
    double minX,
    double maxX,
    double height,
    double surfaceY, {
    required bool isRunning,
  }) {
    _minX = minX;
    _maxX = maxX;
    _worldHeight = height;
    _surfaceY = surfaceY;
    if (isRunning) {
      particles.start(_minX, _maxX, _worldHeight, _surfaceY);
    }
  }

  void dispose() {
    _disposed = true;
    _syncGate.reset();
    _watchdog?.cancel();
    _watchdog = null;
    _subscription?.cancel();
    _subscription = null;
    engine.dispose();
    particles.dispose();
  }
}
