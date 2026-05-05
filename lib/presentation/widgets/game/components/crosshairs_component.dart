import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import 'scene_coordinate_mapper.dart';

/// Draws inspection crosshairs at key plant zones (leaf and root).
/// The crosshairs indicate active monitoring/measurement locations.
///
/// Uses [SceneCoordinateMapper] and matching growth formulas from
/// [AnimatedPlantComponent] to track the actual canopy and root zones.
///
/// Priority: 88 (UI overlay layer)
class CrosshairsComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  CrosshairsComponent() : super(priority: 88);

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();
    final soilHeight = game.soilColumnHeight;

    // Use dynamic plant geometry synced with AnimatedPlantComponent
    final pg = _getPlantGeometry();
    if (pg == null) return;

    // Plant leaves crosshair (upper part of plant where leaves are)
    // Position at 70% of plant height matching leaf placement
    final leafZoneY =
        pg.surfaceY -
        math.cos(pg.wiltSway + pg.windSway) * pg.plantHeight * 0.7;
    final leafZoneX =
        pg.plantCenterX +
        math.sin(pg.wiltSway + pg.windSway) * pg.plantHeight * 0.7;
    _drawCrosshair(canvas, leafZoneX, leafZoneY, zoom, time, 'LEAF_ZONE');

    // Root zone crosshair (where roots are active)
    final rootZoneY = pg.surfaceY + soilHeight * 0.2;
    _drawCrosshair(canvas, pg.plantCenterX, rootZoneY, zoom, time, 'ROOT_ZONE');
  }

  @override
  void onTapUp(TapUpEvent event) {
    event.handled = true;
  }

  _PlantGeometry? _getPlantGeometry() {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return null;

    final plant = state.plants.first;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;

    // Match AnimatedPlantComponent's world position via SceneCoordinateMapper
    final plantWorldPos = SceneCoordinateMapper.mapShootPosition(
      plant.baseX,
      SoilScopeGame.soilColumnWidth,
      surfaceY,
    );
    final plantCenterX = plantWorldPos.x + soilX;

    final plantHeight = SceneCoordinateMapper.plantVisualHeight(plant);

    // Wilt angle based on turgor (matching plant droop angle)
    final turgor = plant.turgorPressure.clamp(0.0, 1.0);
    final droopAngle = (1.0 - turgor).clamp(0.0, 0.6) * math.pi / 4;

    // Match plant's wind sway formula
    final precip = state.precipitation;
    final windMagnitude = 0.05 + precip * 0.15;
    final time = game.currentTime();
    final windSway = math.sin(time * (1.5 + precip * 2.0)) * windMagnitude;

    return _PlantGeometry(
      surfaceY: surfaceY,
      plantCenterX: plantCenterX,
      plantHeight: plantHeight,
      wiltSway: droopAngle,
      windSway: windSway,
    );
  }

  void _drawCrosshair(
    Canvas canvas,
    double cx,
    double cy,
    double zoom,
    double time,
    String label,
  ) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 / zoom;

    final lineLength = 10 / zoom;
    final gapSize = 5 / zoom;

    // Horizontal lines with gap
    canvas.drawLine(
      Offset(cx - gapSize - lineLength, cy),
      Offset(cx - gapSize, cy),
      paint,
    );
    canvas.drawLine(
      Offset(cx + gapSize, cy),
      Offset(cx + gapSize + lineLength, cy),
      paint,
    );

    // Vertical lines with gap
    canvas.drawLine(
      Offset(cx, cy - gapSize - lineLength),
      Offset(cx, cy - gapSize),
      paint,
    );
    canvas.drawLine(
      Offset(cx, cy + gapSize),
      Offset(cx, cy + gapSize + lineLength),
      paint,
    );

    // Animated dashed circle
    final circleRadius = 15 / zoom;
    final circlePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 / zoom;

    // Draw dashed circle
    const dashAngle = 0.1;
    const gapAngle = 0.2;
    final offset = time * 0.5;
    double angle = offset;
    while (angle < offset + 2 * math.pi) {
      final startAngle = angle;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: circleRadius),
        startAngle,
        dashAngle,
        false,
        circlePaint,
      );
      angle += dashAngle + gapAngle;
    }
  }
}

class _PlantGeometry {
  final double surfaceY;
  final double plantCenterX;
  final double plantHeight;
  final double wiltSway;
  final double windSway;

  _PlantGeometry({
    required this.surfaceY,
    required this.plantCenterX,
    required this.plantHeight,
    required this.wiltSway,
    required this.windSway,
  });
}
