import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image;
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../../domain/models/plant.dart';
import '../../../../l10n/app_localizations.dart';

import 'animated_earthworm_component.dart';
import 'scene_coordinate_mapper.dart';

/// Draws water uptake flow paths (roots -> stem) and macropore bypass flow.
///
/// Features high-fidelity organic curves, direction-aware dash animation,
/// and interactive diagnostics for the SPAC continuum.
class WaterFlowPathsComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  WaterFlowPathsComponent() : super(priority: 28);

  bool _isPinned = false;
  bool _isHovered = false;

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();

    final state = game.ref.read(simulationProvider);
    if (state.plants.isEmpty) return;

    final worldWidth = SoilScopeGame.logicalSize.x;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    // --- 1. XYLEM UPTAKE (Roots -> Stem) for all plants ---
    // Visualizes suction-driven mass flow from soil solution to xylem.
    final waterFlowPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: (_isHovered || _isPinned) ? 0.6 : 0.3)
      ..strokeWidth = 1.4 / zoom
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final soilX = game.soilLeftX;

    for (final plant in state.plants) {
      final plantBase = SceneCoordinateMapper.mapShootPosition(plant.baseX, worldWidth, surfaceY);
      plantBase.x += soilX;
      final tips = plant.rootSystem.where((n) => n.isTip).toList();

      for (final tip in tips) {
        final List<Offset> points = [];
        RootNode? current = tip;

        // Trace hydraulic path back to base
        while (current != null) {
          points.add(
            Offset(
              SceneCoordinateMapper.mapRootX(current.x, worldWidth, baseX: plant.baseX) + soilX,
              SceneCoordinateMapper.mapRootY(current.z, surfaceY, soilHeight),
            ),
          );
          if (current.parentIndex != null && current.parentIndex! < plant.rootSystem.length) {
            current = plant.rootSystem[current.parentIndex!];
          } else {
            current = null;
          }
        }
        points.add(plantBase.toOffset());

        if (points.length >= 2) {
          _drawCurvedFlowPath(canvas, points, waterFlowPaint, time, zoom, isUpward: true);
        }
      }
    }

    // --- 2. MACROPORE BYPASS FLOW (Worm burrows) ---
    // High-speed infiltration through large structural voids during rain.
    if (state.precipitation > 0) {
      final worms = game.world.children.query<AnimatedEarthwormComponent>();
      final bypassPaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.4)
        ..strokeWidth = 2.5 / zoom
        ..style = PaintingStyle.stroke;

      for (final worm in worms) {
        final wormX = worm.position.x;
        final wormY = worm.position.y;

        final start = Offset(wormX, surfaceY);
        final end = Offset(wormX, wormY);

        _drawAnimatedFlowLine(canvas, start, end, bypassPaint, 12, 6, -time * 30, zoom);
      }
    }
  }

  void _drawCurvedFlowPath(
    Canvas canvas,
    List<Offset> points,
    Paint paint,
    double time,
    double zoom, {
    required bool isUpward,
  }) {
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final metrics = path.computeMetrics();
    final dashLen = 8.0 / zoom;
    final dashGap = 10.0 / zoom;

    for (final metric in metrics) {
      // Offset depends on direction. Roots -> Stem is "forward" along points list
      double currentDist = (time * 45.0) % (dashLen + dashGap);
      currentDist -= (dashLen + dashGap);

      while (currentDist < metric.length) {
        if (currentDist > 0) {
          final tangent = metric.getTangentForOffset(currentDist);
          if (tangent != null) {
            final pos = tangent.position;
            // Shaded "water droplet" pulse
            final radius = 2.0 / zoom;
            
            // Glow
            canvas.drawCircle(
              pos, 
              radius * 2.0, 
              Paint()..color = paint.color.withValues(alpha: 0.2)..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 / zoom)
            );
            
            // Core
            canvas.drawCircle(pos, radius, Paint()..color = paint.color);
            
            // Shading highlight
            canvas.drawCircle(
              pos - Offset(radius * 0.3, radius * 0.3),
              radius * 0.4,
              Paint()..color = Colors.white.withValues(alpha: 0.5)
            );
          }
          
          // Direction indicator arrow at the end of some dashes
          if (zoom > 2.0 && currentDist % (4 * (dashLen + dashGap)) < (dashLen + dashGap)) {
            _drawSmallArrow(canvas, metric, currentDist + dashLen, paint.color, zoom);
          }
        }
        currentDist += dashLen + dashGap;
      }
    }
  }

  void _drawSmallArrow(Canvas canvas, PathMetric metric, double offset, Color color, double zoom) {
    final tangent = metric.getTangentForOffset(offset.clamp(0.0, metric.length));
    if (tangent != null) {
      final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(angle);
      final arrowPath = Path()
        ..moveTo(0, 0)
        ..lineTo(-4 / zoom, -2 / zoom)
        ..lineTo(-4 / zoom, 2 / zoom)
        ..close();
      canvas.drawPath(arrowPath, Paint()..color = color.withValues(alpha: 0.8));
      canvas.restore();
    }
  }

  void _drawAnimatedFlowLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dLen,
    double dGap,
    double offset,
    double zoom,
  ) {
    final dist = (end - start).distance;
    if (dist < 1) return;
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final sLen = dLen / zoom;
    final sGap = dGap / zoom;

    double curr = offset % (sLen + sGap);
    while (curr < dist) {
      if (curr >= 0) {
        final s = start + Offset(math.cos(angle) * curr, math.sin(angle) * curr);
        final e =
            start +
            Offset(
              math.cos(angle) * (curr + sLen).clamp(0, dist),
              math.sin(angle) * (curr + sLen).clamp(0, dist),
            );
        canvas.drawLine(s, e, paint);
      }
      curr += sLen + sGap;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPinned = !_isPinned;
    _showFlowInfo(pinned: _isPinned);
    event.handled = true;
  }

  @override
  void onHoverEnter() {
    _isHovered = true;
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showFlowInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    _isHovered = false;
    if (!_isPinned) {
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  void _showFlowInfo({bool pinned = false}) {
    final l = AppLocalizations.of(game.buildContext!)!;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: l.waterFlux.toUpperCase(),
        description: l.waterFluxDesc,
        stats: {
          l.type: l.convectiveFlow,
          l.potential: l.negativeSuction,
          l.simulationStatus: l.activeInfiltration,
          "Coupling": "SPAC-enabled",
        },
        isPinned: pinned,
      ),
    );
  }
}
