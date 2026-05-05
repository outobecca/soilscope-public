import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import 'cycle_highlight_mixin.dart';

/// Visualizes upward water movement via capillary forces from groundwater.
/// Represents hydraulic connectivity from the deep soil/groundwater table.
/// 
/// Pedagogy: Shows water moving AGAINST gravity due to matric potential.
class CapillaryRiseComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, CycleHighlightMixin {
  
  @override
  Set<ObservationCycle> get memberOfCycles => {ObservationCycle.water};
  CapillaryRiseComponent() : super(priority: 11);

  bool _isPinned = false;

  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    if (state.profile.layers.isEmpty) return;

    // Only visible when surface is relatively dry (capillary forces dominate over gravity)
    final topLayer = state.profile.layers.first;
    if (topLayer.waterContent > 0.3) return;

    final currentOpacity = cycleOpacity;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 / zoom
      ..strokeCap = StrokeCap.round;

    // Render rising capillary "fingers" from the bottom groundwater upwards
    for (int i = 0; i < 10; i++) {
      final startX = soilX + 40 + i * (soilWidth / 11) + math.sin(i * 123) * 15;
      
      // Phase controls the individual rising animation
      final phase = (time * 0.25 + i * 0.35) % 1.0;
      
      // ANCHOR: Strictly from the bottom of the visible soil column (groundwater source)
      final startY = surfaceY + soilHeight;
      
      // Rise height varies by "pore size" (represented by i)
      final maxRiseHeight = soilHeight * 0.7 * (0.4 + 0.6 * math.cos(i * 0.8).abs());

      final path = Path()..moveTo(startX, startY);
      
      double currentX = startX;
      double currentY = startY;
      
      for (double step = 0; step < phase; step += 0.04) {
        currentY = startY - step * maxRiseHeight;
        
        // Organic wandering through hypothetical pore network
        final drift = math.sin(step * 20 + time * 1.5 + i) * 10;
        currentX = startX + drift;
        
        path.lineTo(currentX, currentY);
      }
      
      // Draw the path with fading opacity as it moves higher (evaporation/adsorption)
      canvas.drawPath(
        path,
        paint
          ..color = const Color(0xFF38BDF8).withValues(alpha: (1.0 - phase) * 0.35 * currentOpacity),
      );
      
      // Meniscus/Droplet at the advancing tip
      if (phase > 0.02) {
        final pos = Offset(currentX, currentY);
        final radius = 2.8 / zoom;
        
        // Shadow
        canvas.drawCircle(pos + const Offset(1, 1), radius, Paint()..color = Colors.black.withValues(alpha: 0.1 * (1.0 - phase) * currentOpacity));
        // Body
        canvas.drawCircle(
          pos,
          radius,
          Paint()..color = const Color(0xFF7DD3FC).withValues(alpha: (1.0 - phase) * 0.7 * currentOpacity),
        );
        // Highlight
        canvas.drawCircle(
          pos - Offset(radius * 0.3, radius * 0.3),
          radius * 0.4,
          Paint()..color = Colors.white.withValues(alpha: 0.5 * (1.0 - phase) * currentOpacity),
        );
      }
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    
    // Quick check: must be in soil column
    if (point.y < surfaceY || point.x < soilX || point.x > soilX + soilWidth) {
      return false;
    }

    // Check proximity to any of the 10 fingers
    for (int i = 0; i < 10; i++) {
      final startX = soilX + 40 + i * (soilWidth / 11) + math.sin(i * 123) * 15;
      // The fingers are vertical-ish, check if X is close
      if ((point.x - startX).abs() < 12.0) {
        return true;
      }
    }
    return false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    if (!_isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _showInfo({bool pinned = false}) {
    final l = game.l10n;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: l.capillaryRiseTitle.toUpperCase(),
        description: l.capillaryRiseDesc,
        stats: {
          l.processLabel: l.hydraulicLift,
          l.driverLabel: l.matricPotential,
          l.sourceLabel: l.groundwaterLabel,
        },
        isPinned: pinned,
      ),
    );
  }
}
