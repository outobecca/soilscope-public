import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import 'soil_component_mixin.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_session_provider.dart';

/// Animated weather component handling rain particles, sky colors, and clouds.
class WeatherComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, SoilComponentMixin {
  final List<_RainDrop> _rainDrops = [];
  final List<_Cloud> _clouds = [];
  final math.Random _random = math.Random.secure();
  bool _isPinned = false;
  final bool animated;

  WeatherComponent({
    required Vector2 size,
    required Vector2 position,
    this.animated = true,
  }) : super(size: size, position: position, priority: -1);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initClouds();

    // Expand to cover the full visual background area for interaction
    size.x = SoilScopeGame.visualColumnWidth;
    position.x =
        -SoilScopeGame.visualColumnWidth / 2 + SoilScopeGame.logicalSize.x / 2;
  }

  void _initClouds() {
    _clouds.clear();
    // Use backgroundWidth for wide cloud distribution
    final width = backgroundWidth;
    final startX = backgroundX;
    _clouds.add(
      _Cloud(pos: Vector2(startX + width * 0.2, 50), radius: 80, speed: 12),
    );
    _clouds.add(
      _Cloud(pos: Vector2(startX + width * 0.6, 30), radius: 100, speed: 8),
    );
    _clouds.add(
      _Cloud(pos: Vector2(startX + width * 0.9, 80), radius: 60, speed: 18),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Expand significantly to cover camera panning
    this.size.x = game.size.x / (game.camera.viewfinder.zoom.clamp(0.1, 1.0));
  }

  @override
  void update(double dt) {
    super.update(dt);
    final state = game.simulationState;
    if (state == null || !state.isRunning) return;

    // Reposition to follow camera horizontally
    position.x = game.camera.viewfinder.position.x - size.x / 2;

    final precip = state.precipitation;
    final width = size.x;
    final startX = 0.0; // Local to component

    // Manage rain across full width
    if (precip > 0.01) {
      final desiredCount = (precip * 150).clamp(0, 500).toInt();
      while (_rainDrops.length < desiredCount) {
        _rainDrops.add(
          _RainDrop(
            position: Vector2(
              startX + _random.nextDouble() * width,
              -_random.nextDouble() * 200,
            ),
            speed: 250 + _random.nextDouble() * 150,
            length: 6 + _random.nextDouble() * 8,
          ),
        );
      }
    } else {
      _rainDrops.clear();
    }

    for (final drop in _rainDrops) {
      drop.position.y += drop.speed * dt;
      if (drop.position.y > size.y + 500) {
        // Allow fall below surface visually
        drop.position.y = -drop.length;
        drop.position.x = startX + _random.nextDouble() * width;
      }
    }

    // Manage clouds across full width
    for (final cloud in _clouds) {
      cloud.pos.x += cloud.speed * dt;
      if (cloud.pos.x - cloud.radius > width) cloud.pos.x = -cloud.radius;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final state = game.simulationState;
    if (state == null) return;

    // 1. Sky Gradient is now handled by SkyBackgroundComponent in screen-space.
    // This component only handles atmospheric entities (rain, clouds).

    // 2. Clouds
    final cloudAlpha = (state.precipitation > 0 ? 0.2 : 0.1);
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: cloudAlpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    for (final cloud in _clouds) {
      _drawCloudCluster(canvas, cloud.pos.toOffset(), cloud.radius, cloudPaint);
    }

    // 3. Rain
    if (_rainDrops.isNotEmpty) {
      final rainPaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
        ..strokeWidth = 1.2;
      for (final drop in _rainDrops) {
        canvas.drawLine(
          drop.position.toOffset(),
          (drop.position + Vector2(0, drop.length)).toOffset(),
          rainPaint,
        );
      }
    }
  }

  void _drawCloudCluster(
    Canvas canvas,
    Offset center,
    double baseRadius,
    Paint paint,
  ) {
    for (int i = 0; i < 5; i++) {
      final offX = math.cos(i * 1.25) * baseRadius * 0.4;
      final offY = math.sin(i * 1.25) * baseRadius * 0.15;
      canvas.drawCircle(center + Offset(offX, offY), baseRadius * 0.6, paint);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // The sky area is always everything above the soil surface
    return point.y < game.soilSurfaceY;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    event.handled = true;

    if (_isPinned) {
      game.ref
          .read(simulationSessionProvider.notifier)
          .selectLayer("atmosphere");
      game.ref.read(simulationSessionProvider.notifier).selectInspector(null);
      game.ref
          .read(uIStateProvider.notifier)
          .setHoverInfo(
            HoverInfo(
              title: game.l10n.atmosphere.toUpperCase(),
              description: game.l10n.atmosphereDesc,
              stats: {
                game.l10n.temperature:
                    '${(game.simulationState!.airTemperature - 273.15).toStringAsFixed(1)} °C',
                game.l10n.relativeHumidity:
                    '${((game.simulationState?.relativeHumidity ?? 0.6) * 100).toStringAsFixed(0)}%',
                game.l10n.precipitation.toUpperCase():
                    '${(game.simulationState?.precipitation ?? 0).toStringAsFixed(1)} mm/h',
              },
              isPinned: true,
              legends: [
                LegendItem(
                  icon: Icons.cloud_rounded,
                  color: Colors.cyanAccent,
                  label: game.l10n.atmosphere,
                ),
              ],
            ),
          );
    } else {
      game.ref.read(simulationSessionProvider.notifier).selectLayer(null);
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }
}

class _RainDrop {
  final Vector2 position;
  final double speed;
  final double length;
  _RainDrop({
    required this.position,
    required this.speed,
    required this.length,
  });
}

class _Cloud {
  final Vector2 pos;
  final double radius;
  final double speed;
  _Cloud({required this.pos, required this.radius, required this.speed});
}
