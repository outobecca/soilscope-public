import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'soil_component_mixin.dart';
import 'cycle_highlight_mixin.dart';

/// Visualizes the moving water front during infiltration events.
class WettingFrontComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, SoilComponentMixin, CycleHighlightMixin {
  
  @override
  Set<ObservationCycle> get memberOfCycles => {ObservationCycle.water};
  WettingFrontComponent() : super(priority: 10);

  bool _isPinned = false;
  double _lastFrontY = 0;

  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();

    if (state.profile.layers.isEmpty) return;

    double frontY = surfaceY;
    bool found = false;
    for (int i = 0; i < state.profile.layers.length; i++) {
      final layer = state.profile.layers[i];
      final saturation = layer.waterContent / layer.porosity;
      if (saturation > 0.4) {
        frontY = surfaceY + (i / state.profile.layers.length) * soilHeight + 15;
        found = true;
        break;
      }
    }
    
    if (_lastFrontY == 0) _lastFrontY = frontY;
    _lastFrontY += (frontY - _lastFrontY) * 0.1;

    if (!found && state.precipitation <= 0) return;

    final currentOpacity = cycleOpacity;
    _drawWetZone(canvas, surfaceY, _lastFrontY, backgroundX, backgroundWidth, zoom, currentOpacity);
    _drawFractalFrontLine(canvas, _lastFrontY, backgroundX, backgroundWidth, zoom, time, currentOpacity);
    _drawDropletIndicators(canvas, _lastFrontY, backgroundX, backgroundWidth, zoom, time, currentOpacity);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    if (point.x < simulationX || point.x > simulationX + simulationWidth) return false;
    return (point.y - _lastFrontY).abs() < 15;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showFrontInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showFrontInfo(pinned: false);
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

  void _showFrontInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: l.wettingFrontTitle.toUpperCase(),
        description: l.moleculeWaterDesc,
        stats: {
          l.processLabel: l.infiltration,
          l.dynamicsLabel: l.fractalFingering,
          l.stateLabel: l.saturationLabel,
        },
        isPinned: pinned,
      ),
    );
  }

  void _drawWetZone(Canvas canvas, double surfaceY, double frontY, double soilX, double soilWidth, double zoom, double cycleOpacity) {
    if (frontY <= surfaceY) return;
    final rect = Rect.fromLTWH(soilX, surfaceY, soilWidth, frontY - surfaceY);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.1 * cycleOpacity),
          const Color(0xFF0EA5E9).withValues(alpha: 0.08 * cycleOpacity),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _drawFractalFrontLine(Canvas canvas, double frontY, double soilX, double soilWidth, double zoom, double time, double cycleOpacity) {
    final frontPath = Path();
    frontPath.moveTo(soilX, frontY);
    for (double x = soilX; x <= soilX + soilWidth; x += 5) {
      final wave1 = math.sin(x * 0.02 + time * 0.5) * 12;
      final wave2 = math.sin(x * 0.08 - time * 1.2) * 5;
      final wave3 = math.sin(x * 0.2 + time * 3.0) * 2;
      frontPath.lineTo(x, frontY + (wave1 + wave2 + wave3) / zoom);
    }
    final glowPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.3 * cycleOpacity)
      ..strokeWidth = 6.0 / zoom
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(frontPath, glowPaint);
    final sharpPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.8 * cycleOpacity)
      ..strokeWidth = 1.5 / zoom
      ..style = PaintingStyle.stroke;
    canvas.drawPath(frontPath, sharpPaint);
  }

  void _drawDropletIndicators(Canvas canvas, double frontY, double soilX, double soilWidth, double zoom, double time, double cycleOpacity) {
    final dropPaint = Paint()..color = const Color(0xFFE0F2FE).withValues(alpha: 0.7 * cycleOpacity);
    for (double x = soilX + 25; x < soilX + soilWidth; x += 65) {
      final seed = x.toInt();
      final progress = ((time * 0.8 + seed * 0.13) % 2.0) / 2.0;
      final waveYOffset = (math.sin(x * 0.02 + time * 0.5) * 12 + math.sin(x * 0.08 - time * 1.2) * 5) / zoom;
      if (waveYOffset < 0) continue; 
      final dropY = frontY + waveYOffset + (progress * progress) * 40.0;
      final alpha = (1.0 - progress).clamp(0.0, 1.0) * 0.8 * cycleOpacity;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + math.sin(time * 2 + seed) * 2, dropY), width: 3.0 / zoom, height: (5.0 + progress * 8.0) / zoom),
        dropPaint..color = const Color(0xFFE0F2FE).withValues(alpha: alpha),
      );
    }
  }
}
