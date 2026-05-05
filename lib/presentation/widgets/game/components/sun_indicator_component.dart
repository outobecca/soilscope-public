import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';

/// Interactive sun indicator that displays real-time solar radiation data.
/// Positioned exactly over the weather "shine" at (1020, 90) in logical space.
class SunIndicatorComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  SunIndicatorComponent() : super(priority: 300);

  static const double solarConstant = 800.0;
  bool _isPinned = false;
  bool _isHovered = false;

  @override
  void onMount() {
    super.onMount();
    size = Vector2.all(120);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Position in the top-right of the sky area, within the soil column
    final soilX = game.soilLeftX;
    final soilRight = soilX + SoilScopeGame.soilColumnWidth;
    position = Vector2(soilRight - 80, 80);
  }

  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    final double rad = state.solarRadiation;
    final energyLevel = (rad / solarConstant).clamp(0.0, 1.0);
    final time = game.currentTime();

    final sunCenter = Offset(size.x / 2, size.y / 2);

    // 2. Solar Body & Corona (Layered on top of weather shine)
    final pulse = 0.5 + 0.5 * math.sin(time * 3.0);
    
    // Subtle Corona (Glow)
    final coronaPaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: (0.05 + energyLevel * 0.1).clamp(0.0, 0.15))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(sunCenter, 35 + pulse * 5, coronaPaint);

    // Main Sun Body (Shaded look)
    // Shadow
    canvas.drawCircle(
      sunCenter + const Offset(2, 2), 
      22, 
      Paint()..color = Colors.black.withValues(alpha: 0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
    );
    
    // Body
    final sunPaint = Paint()
      ..color = Colors.orange.shade400.withValues(alpha: 0.8);
    canvas.drawCircle(sunCenter, 20, sunPaint);

    // Inner Core
    canvas.drawCircle(
      sunCenter,
      16,
      Paint()..color = Colors.yellow.shade100.withValues(alpha: 0.9),
    );
    
    // Specular Highlight
    canvas.drawCircle(
      sunCenter - const Offset(6, 6),
      8,
      Paint()..color = Colors.white.withValues(alpha: 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2)
    );

    // 3. Dynamic Beams & Rays
    _drawSunRays(canvas, sunCenter, energyLevel, time);
    _drawHolographicBeams(canvas, sunCenter, energyLevel, time);

    if (_isPinned || _isHovered) {
      // Tech focus ring
      final ringPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      canvas.drawCircle(sunCenter, 49, ringPaint);

      for (int i = 0; i < 4; i++) {
        final angle = time * 2.0 + (i * math.pi / 2);
        canvas.drawArc(
          Rect.fromCircle(center: sunCenter, radius: 52),
          angle,
          0.6,
          false,
          ringPaint..strokeWidth = 2.0,
        );
      }
    }
  }

  void _drawSunRays(Canvas canvas, Offset center, double energy, double time) {
    if (energy < 0.2) return;

    final beamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03 * energy)
      ..style = PaintingStyle.fill;

    const count = 12;
    final rotation = time * 0.05;
    // Scale rays to component size (max ~80px), not 400px world space
    final rayLength = 50.0 + energy * 30.0;
    for (int i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 + rotation;
      final beamPath = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + math.cos(angle - 0.06) * rayLength,
          center.dy + math.sin(angle - 0.06) * rayLength,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.06) * rayLength,
          center.dy + math.sin(angle + 0.06) * rayLength,
        )
        ..close();
      canvas.drawPath(beamPath, beamPaint);
    }
  }

  void _drawHolographicBeams(
    Canvas canvas,
    Offset center,
    double energy,
    double time,
  ) {
    const count = 8;
    final beamPaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.25 * energy)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < count; i++) {
      final angle = (i * (360 / count)) * math.pi / 180 + (time * 0.15);
      final beamLen = 28 + math.sin(time * 3.0 + i) * 4;
      canvas.drawLine(
        center + Offset(20 * math.cos(angle), 20 * math.sin(angle)),
        center + Offset(beamLen * math.cos(angle), beamLen * math.sin(angle)),
        beamPaint,
      );
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    if (_isPinned) {
      _showSunInfo(pinned: true);
    } else {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    final currentInfo = game.ref.read(uIStateProvider);
    if (currentInfo == null || !currentInfo.isPinned) {
      _showSunInfo(pinned: false);
    }
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      final currentInfo = game.ref.read(uIStateProvider);
      if (currentInfo == null || !currentInfo.isPinned) {
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
      }
    }
  }

  void _showSunInfo({bool pinned = false}) {
    final l = game.l10n;
    final state = game.ref.read(simulationProvider);
    final double rad = state.solarRadiation;

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.solarRadiationTitle.toUpperCase(),
            description: l.sunIndicatorDesc,
            stats: {
              l.totalRadiation: '${rad.toStringAsFixed(1)} W/m²',
              l.parFraction: '45%',
              l.absorbedPar:
                  '${(state.plants.isNotEmpty ? state.plants.first.absorbedPAR : 0.0).toStringAsFixed(1)} W/m²',
              l.transmission:
                  '${((state.plants.isNotEmpty ? state.plants.first.lightTransmission : 1.0) * 100).toStringAsFixed(0)}%',
            },
            isPinned: pinned,
          ),
        );
  }
}
