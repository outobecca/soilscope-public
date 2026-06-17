import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';

import 'biological_entity_mixin.dart';

/// Animated earthworm component replacing the Rive-based implementation.
/// Simulates peristaltic movement through the soil.
class AnimatedEarthwormComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, BiologicalEntityMixin {
  final int seed;
  final double speed;

  @override
  String get entityTitle => game.l10n.earthworm;

  final Paint _segmentPaint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
  final Paint _clitellumPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
  final Paint _headTailPaint = Paint();
  late final List<Vector2> _segments;
  double _time = 0;
  Vector2? _target;
  double _targetTimer = 0;
  double _curlProgress = 0.0;

  AnimatedEarthwormComponent({
    required Vector2 position,
    this.seed = 0,
    this.speed = 35.0,
  }) : super(position: position, size: Vector2(60, 8), anchor: Anchor.center, priority: 40) {
    _segments = List.generate(8, (i) => Vector2(i * 7.5 - 30, 0));
    _time = seed.toDouble();
  }

  @override
  void onMount() {
    super.onMount();
    _pickNewTarget();
  }

  void _pickNewTarget() {
    final rand = math.Random(seed + _time.toInt());
    final state = game.simulationState;
    final surfaceY = game.soilSurfaceY;
    final columnHeight = game.soilColumnHeight;

    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    // Earthworm preference: Topsoil with high organic material
    // We'll favor the upper 25% of the soil column
    final isHungry = rand.nextDouble() < 0.7;

    double targetX, targetY;
    if (isHungry && state != null && state.profile.layers.isNotEmpty) {
      // Target the top layer area
      targetX = soilX + 50 + rand.nextDouble() * (soilWidth - 100);
      targetY = surfaceY + rand.nextDouble() * (columnHeight * 0.25);
      _targetTimer = 8.0 + rand.nextDouble() * 12.0;
    } else {
      // Burrow deeper or explore
      targetX = soilX + 50 + rand.nextDouble() * (soilWidth - 100);
      targetY = surfaceY + 50 + rand.nextDouble() * (columnHeight - 150);
      _targetTimer = 4.0 + rand.nextDouble() * 6.0;
    }

    _target = Vector2(targetX, targetY);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final state = game.simulationState;
    if (state == null || !state.isRunning) return;

    _time += dt;

    // Determine water content for current depth
    double currentMoisture = 0.5;
    if (state.profile.layers.isNotEmpty) {
      double totalThick = state.profile.layers.fold(0.0, (s, l) => s + l.thickness);
      double accumY = game.soilSurfaceY;
      for (final layer in state.profile.layers) {
        final h = (layer.thickness / totalThick) * game.soilColumnHeight;
        if (position.y >= accumY && position.y < accumY + h) {
          currentMoisture = layer.waterContent;
          break;
        }
        accumY += h;
      }
      if (position.y < game.soilSurfaceY) currentMoisture = state.profile.layers.first.waterContent;
      if (position.y >= game.soilSurfaceY + game.soilColumnHeight) currentMoisture = state.profile.layers.last.waterContent;
    }

    if (currentMoisture < 0.15) {
      _curlProgress = (_curlProgress + dt * 2.0).clamp(0.0, 1.0);
    } else {
      _curlProgress = (_curlProgress - dt * 2.0).clamp(0.0, 1.0);
    }

    _targetTimer -= dt;

    if (_target == null ||
        _targetTimer <= 0 ||
        (position - _target!).length < 10) {
      _pickNewTarget();
    }

    // Crawl towards target if not curled
    final direction = (_target! - position).normalized();
    position.add(direction * speed * dt * (1.0 - _curlProgress));

    // Strict Soil Bound Clamp (Bounding Box)
    position.y = position.y.clamp(game.soilSurfaceY + 15.0, game.soilSurfaceY + game.soilColumnHeight - 15.0).toDouble();
    position.x = position.x.clamp(game.soilLeftX + 15.0, game.soilLeftX + SoilScopeGame.soilColumnWidth - 15.0).toDouble();

    // Add some subtle sinusoidal wiggle to the main path
    position.add(
      Vector2(-direction.y, direction.x) * math.sin(_time * 2.0) * 0.5 * (1.0 - _curlProgress),
    );

    // Segment update (peristalsis effect + rotation towards movement)
    final angle = math.atan2(direction.y, direction.x);
    for (int i = 0; i < _segments.length; i++) {
      final phase = _time * 6.0 - i * 0.9;
      final contraction = math.sin(phase) * 3.0;

      // Local segment offset for crawling
      final localX = (i * 7.5 - 30) + contraction;
      final localY = math.sin(phase * 0.6 + i * 0.3) * 2.0;

      // Target curled positions (spiral)
      final curlAngle = i * 1.0 + _time; // slight rotation while curled
      final curlRadius = 12.0 - i * 1.0;
      final targetCurlX = math.cos(curlAngle) * curlRadius;
      final targetCurlY = math.sin(curlAngle) * curlRadius;

      // Rotate local coordinates
      final moveX = localX * math.cos(angle) - localY * math.sin(angle);
      final moveY = localX * math.sin(angle) + localY * math.cos(angle);

      // Blend based on curl progress
      _segments[i].x = moveX * (1.0 - _curlProgress) + targetCurlX * _curlProgress;
      _segments[i].y = moveY * (1.0 - _curlProgress) + targetCurlY * _curlProgress;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Muted, desaturated earthworm colors
    final baseColor = const Color(0xFFA88F88);
    final darkColor = const Color(0xFF8E7670);

    if (_segments.length < 3) return;

    // Draw the body with simplified segments and thinner stroke
    for (int i = 0; i < _segments.length - 1; i++) {
      final phase = _time * 4.0 - i * 0.8;
      final thickness = 2.5 + math.sin(phase) * 0.8;

      final segmentPaint = _segmentPaint
        ..color = Color.lerp(
          baseColor,
          darkColor,
          (math.sin(phase) * 0.5 + 0.5) * 0.2,
        )!
        ..strokeWidth = thickness;

      canvas.drawLine(
        _segments[i].toOffset(),
        _segments[i + 1].toOffset(),
        segmentPaint,
      );
    }

    // Simplified Clitellum
    final clitellumIndex = (_segments.length * 0.7).floor();
    final clitPos = _segments[clitellumIndex];
    canvas.drawCircle(
      clitPos.toOffset(),
      3.5,
      _clitellumPaint..color = const Color(0xFFBC9B92).withValues(alpha: 0.6),
    );

    // Minimal Head Detail
    final headOffset = _segments.last.toOffset();
    canvas.drawCircle(headOffset, 2.5, _headTailPaint..color = darkColor);
    
    // Tail Detail
    canvas.drawCircle(
      _segments.first.toOffset(),
      1.5,
      _headTailPaint..color = darkColor,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    handleTapUp(({bool pinned = true}) => _showEarthwormInfo(pinned: pinned));
    event.handled = true;
  }

  @override
  void onHoverEnter() => handleHoverEnter(() => _showEarthwormInfo(pinned: false));

  @override
  void onHoverExit() => handleHoverExit();

  void _showEarthwormInfo({bool pinned = false}) {
    final l = game.l10n;
    final state = game.simulationState;
    final topLayer = state?.profile.layers.firstOrNull;

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.earthworm.toUpperCase(),
            description: l.earthwormDescription,
            stats: {
              l.process: l.bioturbation,
              l.populationLabel: '100-500 m²',
              l.organicCarbonLabel: topLayer == null
                  ? 'N/A'
                  : '${(topLayer.organicCarbon * 100).toStringAsFixed(2)}%',
            },
            isPinned: pinned,
          ),
        );
  }
}
