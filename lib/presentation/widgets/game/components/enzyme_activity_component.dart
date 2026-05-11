import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../../domain/models/biophysical_state.dart';
import 'animated_microbe_component.dart';
import 'scene_coordinate_mapper.dart';

/// Visualizes enzyme activity (ripples) emanating from microbes and root tips.
/// Anchored to biological hotspots for causal realism.
class EnzymeActivityComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  final List<_EnzymeWave> _waves = [];
  final math.Random _random = math.Random.secure();
  double _spawnTimer = 0;
  bool _isPinned = false;

  EnzymeActivityComponent() : super(priority: 6);

  /// Returns the current coordinates of all active enzyme ripples.
  /// Used by AnimationLayer to sync with physics isolate.
  Iterable<Vector2> get activeWavePositions => _waves.map((w) => w.position);

  @override
  void update(double dt) {
    super.update(dt);
    final state = game.simulationState;
    if (state == null || !state.isRunning) return;

    // Spawning tied to microbial population and metabolic potential
    final totalBiomass = state.profile.layers.fold<double>(
      0,
      (sum, l) => sum + l.microbialBiomass,
    );
    final avgEps =
        state.profile.layers.fold<double>(0, (sum, l) => sum + l.epsContent) /
        state.profile.layers.length;

    // Higher biomass and EPS -> more frequent ripples
    final spawnInterval = (1.5 / (totalBiomass * 0.5 + 0.2)).clamp(0.4, 3.0);

    _spawnTimer += dt;
    if (_spawnTimer > spawnInterval) {
      _spawnTimer = 0;
      _spawnEnzymeAtHotspot(state, avgEps);
    }

    for (final wave in _waves) {
      wave.update(dt);
    }
    _waves.removeWhere((w) => w.isDone);
  }

  void _spawnEnzymeAtHotspot(BiophysicalState state, double intensity) {
    if (_waves.length > 30) return;

    final microbes = game.world.children
        .query<AnimatedMicrobeComponent>()
        .toList();
    final rootTips = state.plant.rootSystem.where((n) => n.isTip).toList();

    if (microbes.isNotEmpty && _random.nextDouble() < 0.7) {
      final m = microbes[_random.nextInt(microbes.length)];
      _waves.add(
        _EnzymeWave(
          position: m.position.clone(),
          type: _EnzymeType.values[_random.nextInt(_EnzymeType.values.length)],
          intensity: (0.5 + intensity * 2.0).clamp(0.5, 2.0),
        ),
      );
    } else if (rootTips.isNotEmpty) {
      final tip = rootTips[_random.nextInt(rootTips.length)];
      final soilWidth = SoilScopeGame.soilColumnWidth;
      final soilX = game.soilLeftX;

      final tipX =
          SceneCoordinateMapper.mapRootX(
            tip.x,
            soilWidth,
            baseX: state.plant.baseX,
          ) +
          soilX;
      final tipY =
          game.soilSurfaceY +
          SceneCoordinateMapper.mapRootY(tip.z, 0, game.soilColumnHeight);

      _waves.add(
        _EnzymeWave(
          position: Vector2(tipX, tipY),
          type: _EnzymeType.phosphatase,
          intensity: 0.8 * (1.0 + intensity),
        ),
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final zoom = game.camera.viewfinder.zoom;
    if (zoom < 1.15) return;

    for (final wave in _waves) {
      final color = _getEnzymeColor(
        wave.type,
      ).withValues(alpha: wave.alpha * 0.4);

      _drawOrganicRipple(
        canvas,
        wave.position,
        wave.radius,
        wave.alpha,
        color,
        zoom,
      );

      // Central Metabolic Core removed to avoid double visualization with microbes

      if (wave.radius > 20) {
        _drawOrganicRipple(
          canvas,
          wave.position,
          wave.radius * 0.7,
          wave.alpha * 0.5,
          color,
          zoom,
          seedOffset: 1.5,
        );
      }
    }
  }

  void _drawOrganicRipple(
    Canvas canvas,
    Vector2 center,
    double radius,
    double alpha,
    Color color,
    double zoom, {
    double seedOffset = 0,
  }) {
    final path = Path();
    const points = 16;
    final time = game.currentTime();

    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * math.pi * 2;
      final distortion =
          math.sin(angle * 3 + time * 2 + seedOffset) * (radius * 0.15) +
          math.cos(angle * 5 - time * 1.5) * (radius * 0.08);

      final r = radius + distortion;
      final x = center.x + math.cos(angle) * r;
      final y = center.y + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color.withValues(alpha: alpha * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 / zoom);

    canvas.drawPath(path, paint);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 / zoom,
    );
  }

  Color _getEnzymeColor(_EnzymeType type) {
    return switch (type) {
      _EnzymeType.urease => Colors.purpleAccent,
      _EnzymeType.phosphatase => Colors.orangeAccent,
      _EnzymeType.cellulase => Colors.greenAccent,
      _EnzymeType.protease => Colors.redAccent,
    };
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showEnzymeInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showEnzymeInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      final current = game.ref.read(uIStateProvider);
      if (current == null || !current.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showEnzymeInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.enzymesTitle.toUpperCase(),
            description: l.enzymesDesc,
            stats: {
              l.kineticsLabel: 'Michaelis-Menten',
              l.responseLabel: 'Q10 & pH',
              l.type: l.biogeochemical,
            },
            isPinned: pinned,
          ),
        );
  }
}

enum _EnzymeType { urease, phosphatase, cellulase, protease }

class _EnzymeWave {
  Vector2 position;
  final _EnzymeType type;
  final double intensity;
  double lifetime = 0;
  final double maxLifetime = 2.5;

  _EnzymeWave({
    required this.position,
    required this.type,
    required this.intensity,
  });

  void update(double dt) {
    lifetime += dt;
  }

  double get radius => 5 + lifetime * 25 * intensity;
  double get alpha {
    double fadeOut = (1 - lifetime / maxLifetime).clamp(0.0, 1.0);
    double fadeIn = (lifetime / 0.2).clamp(0.0, 1.0);
    return math.min(fadeIn, fadeOut);
  }

  bool get isDone => lifetime >= maxLifetime;
}
