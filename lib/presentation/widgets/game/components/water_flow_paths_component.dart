import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide Image;
import '../soil_scope_game.dart';
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

  // A flowing dash used to cost three drawCircle calls plus three fresh
  // Paint objects. Collect every droplet in the frame into three point
  // batches instead: glow, core and highlight each become one drawRawPoints
  // call regardless of how many tips are visible.
  final Paint _glowPaint = Paint()..strokeCap = StrokeCap.round;
  final Paint _corePaint = Paint()..strokeCap = StrokeCap.round;
  final Paint _highlightPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..strokeCap = StrokeCap.round;
  final Paint _arrowPaint = Paint();
  final List<double> _glowPoints = [];
  final List<double> _corePoints = [];
  final List<double> _highlightPoints = [];
  final Path _arrowPath = Path();
  final Path _bypassPath = Path();

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();

    final state = game.displayedState;
    if (state.plants.isEmpty) return;

    final worldWidth = SoilScopeGame.logicalSize.x;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    // --- 1. XYLEM UPTAKE (Roots -> Stem) for all plants ---
    // Visualizes suction-driven mass flow from soil solution to xylem.
    final flowColor = const Color(
      0xFF38BDF8,
    ).withValues(alpha: (_isHovered || _isPinned) ? 0.6 : 0.3);

    final soilX = game.soilLeftX;

    for (final plant in state.plants) {
      final plantBase = SceneCoordinateMapper.mapShootPosition(worldWidth, surfaceY);
      plantBase.x += soilX;
      final tips = plant.rootSystem.where((n) => n.isTip).toList();

      for (final tip in tips) {
        final List<Offset> points = [];
        RootNode? current = tip;

        // Trace hydraulic path back to base
        while (current != null) {
          points.add(
            Offset(
              SceneCoordinateMapper.mapRootX(current.x, worldWidth) + soilX,
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
          _collectCurvedFlowPath(points, time, zoom);
        }
      }
    }
    _drawFlowDroplets(canvas, zoom, flowColor);

    // --- 2. MACROPORE BYPASS FLOW (Worm burrows) ---
    // High-speed infiltration through large structural voids during rain.
    if (state.precipitation > 0) {
      final worms = game.world.children.query<AnimatedEarthwormComponent>();
      final bypassPaint = Paint()
        ..color = const Color(0xFF60A5FA).withValues(alpha: 0.4)
        ..strokeWidth = 2.5 / zoom
        ..style = PaintingStyle.stroke;

      _bypassPath.reset();
      for (final worm in worms) {
        final wormX = worm.position.x;
        final wormY = worm.position.y;

        final start = Offset(wormX, surfaceY);
        final end = Offset(wormX, wormY);

        _collectAnimatedFlowLine(start, end, 12, 6, -time * 30, zoom);
      }
      if (_bypassPath.getBounds().isEmpty == false) {
        canvas.drawPath(_bypassPath, bypassPaint);
      }
    }
  }

  void _collectCurvedFlowPath(
    List<Offset> points,
    double time,
    double zoom,
  ) {
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

    final radius = 2.0 / zoom;
    final highlightOffset = radius * 0.3;

    for (final metric in metrics) {
      // Offset depends on direction. Roots -> Stem is "forward" along points list
      double currentDist = (time * 45.0) % (dashLen + dashGap);
      currentDist -= (dashLen + dashGap);

      while (currentDist < metric.length) {
        if (currentDist > 0) {
          final tangent = metric.getTangentForOffset(currentDist);
          if (tangent != null) {
            final pos = tangent.position;
            _glowPoints
              ..add(pos.dx)
              ..add(pos.dy);
            _corePoints
              ..add(pos.dx)
              ..add(pos.dy);
            _highlightPoints
              ..add(pos.dx - highlightOffset)
              ..add(pos.dy - highlightOffset);
          }
          
          // Direction indicator arrow at the end of some dashes
          if (zoom > 2.0 && currentDist % (4 * (dashLen + dashGap)) < (dashLen + dashGap)) {
            _collectSmallArrow(metric, currentDist + dashLen, zoom);
          }
        }
        currentDist += dashLen + dashGap;
      }
    }
  }

  void _drawFlowDroplets(Canvas canvas, double zoom, Color color) {
    _glowPaint
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 8.0 / zoom
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 / zoom);
    _corePaint
      ..color = color
      ..strokeWidth = 4.0 / zoom;
    _highlightPaint
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.6 / zoom;

    if (_glowPoints.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(_glowPoints),
        _glowPaint,
      );
    }
    if (_corePoints.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(_corePoints),
        _corePaint,
      );
    }
    if (_highlightPoints.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(_highlightPoints),
        _highlightPaint,
      );
    }
    if (_arrowPath.getBounds().isEmpty == false) {
      canvas.drawPath(
        _arrowPath,
        _arrowPaint..color = color.withValues(alpha: 0.8),
      );
    }

    _glowPoints.clear();
    _corePoints.clear();
    _highlightPoints.clear();
    _arrowPath.reset();
  }

  void _collectSmallArrow(PathMetric metric, double offset, double zoom) {
    final tangent = metric.getTangentForOffset(offset.clamp(0.0, metric.length));
    if (tangent == null) return;
    final angle = math.atan2(tangent.vector.dy, tangent.vector.dx);
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    Offset rotate(double x, double y) =>
        Offset(x * cosA - y * sinA, x * sinA + y * cosA);
    final origin = tangent.position;
    final a = rotate(-4 / zoom, -2 / zoom);
    final b = rotate(-4 / zoom, 2 / zoom);
    _arrowPath
      ..moveTo(origin.dx, origin.dy)
      ..lineTo(origin.dx + a.dx, origin.dy + a.dy)
      ..lineTo(origin.dx + b.dx, origin.dy + b.dy)
      ..close();
  }

  void _collectAnimatedFlowLine(
    Offset start,
    Offset end,
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
        _bypassPath
          ..moveTo(s.dx, s.dy)
          ..lineTo(e.dx, e.dy);
      }
      curr += sLen + sGap;
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return false;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final worldWidth = SoilScopeGame.logicalSize.x;
    final soilX = game.soilLeftX;

    // Check if within the soil column
    if (point.y < surfaceY || point.y > surfaceY + soilHeight ||
        point.x < soilX || point.x > soilX + SoilScopeGame.soilColumnWidth) {
      return false;
    }

    // Check distance to root flow paths (generous 18px tolerance)
    for (final plant in state.plants) {
      for (final node in plant.rootSystem) {
        final rx = SceneCoordinateMapper.mapRootX(node.x, worldWidth) + soilX;
        final ry = SceneCoordinateMapper.mapRootY(node.z, surfaceY, soilHeight);
        if ((point.x - rx).abs() < 18.0 && (point.y - ry).abs() < 18.0) {
          return true;
        }
      }
    }
    return false;
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
      game.ref.read(uIStateProvider.notifier).clearUnpinnedHover();
    }
  }

  void _showFlowInfo({bool pinned = false}) {
    final l = AppLocalizations.of(game.buildContext!)!;
    final anchorWorld = Vector2(
      game.soilLeftX + SoilScopeGame.soilColumnWidth / 2,
      game.soilSurfaceY + 120.0,
    );

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
        sourceId: 'water-flow-paths',
        onDismiss: () => _isPinned = false,
        accentColor: const Color(0xFF38BDF8),
        screenPosition: game.worldToScreen(anchorWorld).toOffset(),
      ),
    );
  }
}
