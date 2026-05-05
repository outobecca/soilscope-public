import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';

/// Visualizes nitrous oxide (N2O) escaping the soil surface under anaerobic conditions.
class NitrousOxideBubbleComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  NitrousOxideBubbleComponent() : super(priority: 15);

  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    final double time = game.currentTime();
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    if (state.profile.layers.isEmpty) return;

    final topLayer = state.profile.layers.first;
    
    // Calculate anaerobic factor
    final double airFilledPorosity = (topLayer.porosity - topLayer.waterContent).clamp(0.0, 1.0);
    final double fWaterAerobic = airFilledPorosity > 0.05 ? 1.0 : (airFilledPorosity / 0.05);
    final double fWaterAnaerobic = 1.0 - fWaterAerobic;

    // Only emit when denitrification is active (anaerobic conditions)
    if (fWaterAnaerobic <= 0.5) return;

    // Rising grey micro-bubbles
    for (int i = 0; i < 12; i++) {
      final x = soilX + (i + 1) * (soilWidth / 13);
      final phase = (time * 0.6 + i * 0.15) % 1.0;
      final y = surfaceY - phase * 70;
      final drift = math.sin(time * 2 + i) * 15;
      final pos = Offset(x + drift, y);
      final radius = 2 + phase * 6;
      final alpha = (1.0 - phase);

      // 1. Shadow
      canvas.drawCircle(pos + const Offset(1, 1), radius, Paint()..color = Colors.black.withValues(alpha: 0.1 * alpha));
      
      // 2. Body
      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = Colors.blueGrey.withValues(alpha: 0.4 * alpha),
      );
      
      // 3. Highlight (Shaded look)
      canvas.drawCircle(
        pos - Offset(radius * 0.3, radius * 0.3),
        radius * 0.4,
        Paint()..color = Colors.white.withValues(alpha: 0.5 * alpha),
      );
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    return point.y <= surfaceY &&
        point.y >= surfaceY - 75 &&
        point.x >= soilX &&
        point.x <= soilX + soilWidth;
  }

  @override
  void onHoverEnter() {
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: "N₂O EMISSIONS",
        description: "Nitrous oxide gas escaping the soil through denitrification in anaerobic (waterlogged) conditions.",
        accentColor: Colors.pinkAccent,
      ),
    );
  }

  @override
  void onHoverExit() {
    game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }
}
