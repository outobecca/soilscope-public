import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';

/// Visualizes water vapor escaping the soil surface.
/// Adjusted for narrowed soil column.
class SoilEvaporationComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  SoilEvaporationComponent() : super(priority: 12);

  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    final double time = game.currentTime();
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    if (state.profile.layers.isEmpty) return;

    // Use state property for evaporation rate
    if (state.soilEvaporation < 1e-10) return;

    // Rising vapor wisps
    for (int i = 0; i < 8; i++) {
      final x = soilX + (i + 1) * (soilWidth / 9);
      final phase = (time * 0.4 + i * 0.2) % 1.0;
      final y = surfaceY - phase * 60;
      final drift = math.sin(time + i) * 10;
      final pos = Offset(x + drift, y);
      final radius = 8 + phase * 12;
      final alpha = (1.0 - phase);

      // 1. Vapor Shadow/Glow (Complying with max 0.15 opacity)
      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = Colors.white.withValues(alpha: 0.1 * alpha)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      
      // 2. Core (Shaded look)
      final coreRadius = radius * 0.4;
      canvas.drawCircle(
        pos,
        coreRadius,
        Paint()..color = Colors.white.withValues(alpha: 0.3 * alpha),
      );
      canvas.drawCircle(
        pos - Offset(coreRadius * 0.3, coreRadius * 0.3),
        coreRadius * 0.4,
        Paint()..color = Colors.white.withValues(alpha: 0.5 * alpha),
      );
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    // Only handle hover/tap ABOVE the surface where vapor wisps are visible
    return point.y <= surfaceY &&
        point.y >= surfaceY - 65 &&
        point.x >= soilX &&
        point.x <= soilWidth + soilX;
  }
}
