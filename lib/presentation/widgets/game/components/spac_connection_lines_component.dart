import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';
import 'scene_coordinate_mapper.dart';
import '../../../providers/ui_state_provider.dart';

/// Draws dashed connector lines between SPAC (Soil-Plant-Atmosphere Continuum)
/// elements to visually communicate the flow of energy, water, and nutrients.
///
/// Connection points:
/// - Sun → Plant canopy (solar radiation / PAR)
/// - Plant canopy → Root collar (xylem water upflow / phloem sugar downflow)
/// - Root tips → Soil (exudation & nutrient uptake)
///
/// Ref: SPAC continuum model (Philip, 1966).
class SPACConnectionLinesComponent extends Component
    with HasGameReference<SoilScopeGame> {
  SPACConnectionLinesComponent() : super(priority: 150);

  @override
  void render(Canvas canvas) {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return;

    final activeCycle = game.ref.read(activeCycleProvider);
    final isNitrogenCycleMode = activeCycle == ObservationCycle.nitrogen;

    final plant = state.plants.first;
    final soilX = game.soilLeftX;
    final soilColumnWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final time = game.currentTime();
    final double zoom = game.camera.viewfinder.zoom;
    // LOD: Hide continuum lines when zoomed out to reduce cognitive load
    if (zoom < 0.6) return;
    final zoomLOD = (zoom - 0.6).clamp(0.0, 1.0);

    // Plant geometry (matching AnimatedPlantComponent exactly)
    final plantWorldPos = SceneCoordinateMapper.mapShootPosition(
      plant.baseX,
      soilColumnWidth,
      surfaceY,
    );
    final plantCenterX = plantWorldPos.x + soilX;

    final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);

    // Key anchor points
    final canopyTop = Vector2(plantCenterX, surfaceY - visualHeight * 0.7);
    final rootCollar = Vector2(plantCenterX, surfaceY);
    final sunPos = Vector2(soilX + soilColumnWidth - 80, 80);

    // 1. Sun → Canopy (Solar radiation — warm orange)
    final parIntensity = (state.solarRadiation / 1000.0).clamp(0.1, 1.0);
    _drawDashedConnection(
      canvas,
      sunPos.toOffset(),
      canopyTop.toOffset(),
      const Color(0xFFFBBF24),
      time,
      dashLen: 6,
      gapLen: 10,
      alpha: (isNitrogenCycleMode ? 0.05 : 0.25) * parIntensity * zoomLOD,
      label: zoom > 1.2 ? game.l10n.par : null,
      showArrow: true,
      zoom: zoom,
    );

    // 2. Canopy → Root collar (Xylem/Phloem transport — blue/green)
    final transpirationRate = (state.plant.waterUptake / 5.0).clamp(0.1, 1.0);
    _drawDashedConnection(
      canvas,
      canopyTop.toOffset(),
      rootCollar.toOffset(),
      const Color(0xFF22D3EE),
      time,
      dashLen: 4,
      gapLen: 6,
      alpha: (isNitrogenCycleMode ? 0.6 : 0.2) * transpirationRate * zoomLOD,
      label: isNitrogenCycleMode ? (zoom > 1.2 ? 'N-TRANSPORT' : null) : (zoom > 1.2 ? game.l10n.xylem : null),
      reverse: true, // Upward flow
      showArrow: true,
      zoom: zoom,
    );

    /* 
    // 3. Root collar → Soil depth (Root exudation — green/amber)
    // REMOVED: Redundant with AnimatedPlantComponent root rendering
    final exudationRate = (state.plant.rootSystem.length / 100.0).clamp(0.1, 1.0);
    final rootDepthY = surfaceY + soilHeight * 0.4;
    _drawDashedConnection(
      canvas,
      rootCollar.toOffset(),
      Offset(plantCenterX, rootDepthY),
      const Color(0xFF4ADE80),
      time,
      dashLen: 3,
      gapLen: 8,
      alpha: (isNitrogenCycleMode ? 0.05 : 0.2) * exudationRate * zoomLOD,
      label: zoom > 1.2 ? game.l10n.exudation : null,
      showArrow: true,
      zoom: zoom,
    );

    // 3.1 Soil -> Root collar (Nitrogen Uptake - Amber)
    // REMOVED: Redundant with root tip glows and ion movement
    final nitrogenUptakeRate = (plant.nitrogenUptake / 2.0).clamp(0.1, 1.0);
    _drawDashedConnection(
      canvas,
      Offset(plantCenterX + 20, rootDepthY),
      rootCollar.toOffset(),
      const Color(0xFFFFB74D),
      time,
      dashLen: 4,
      gapLen: 4,
      alpha: 0.3 * nitrogenUptakeRate * zoomLOD,
      label: zoom > 1.2 ? game.l10n.nutrientUptake : null,
      showArrow: true,
      zoom: zoom,
    );
    */

    // 4. Soil surface → Water table (Infiltration — blue)
    final infiltrationRate = (state.precipitation / 10.0).clamp(0.05, 1.0);
    final waterTableY = surfaceY + soilHeight * 0.65;
    _drawDashedConnection(
      canvas,
      Offset(soilX + soilColumnWidth * 0.3, surfaceY + 5),
      Offset(soilX + soilColumnWidth * 0.3, waterTableY),
      const Color(0xFF38BDF8),
      time,
      dashLen: 4,
      gapLen: 12,
      alpha: (isNitrogenCycleMode ? 0.05 : 0.15) * infiltrationRate * zoomLOD,
      showArrow: true,
      zoom: zoom,
    );

    // 5. Water Table → Root Zone (Capillary Rise — cyan)
    // Visible when topsoil is drier
    final topLayerWater = state.profile.layers.first.waterContent;
    if (topLayerWater < 0.25) {
      _drawDashedConnection(
        canvas,
        Offset(soilX + soilColumnWidth * 0.7, waterTableY),
        Offset(soilX + soilColumnWidth * 0.7, surfaceY + soilHeight * 0.3),
        const Color(0xFF22D3EE),
        time,
        dashLen: 3,
        gapLen: 15,
        alpha: (isNitrogenCycleMode ? 0.02 : 0.1) * zoomLOD,
        reverse: true, // Upward flow
        showArrow: true,
        label: zoom > 1.2 ? "CAPILLARY" : null,
        zoom: zoom,
      );
    }

    // 6. Gas Exchange Flows (CO2 & O2 & N2O)
    // Connecting canopy to atmospheric indicators
    final co2UptakePos = Offset(soilX + soilColumnWidth * 0.35, surfaceY - 120);
    final o2ProductionPos = Offset(soilX + soilColumnWidth * 0.65, surfaceY - 120);
    final n2oEmissionPos = Offset(soilX + soilColumnWidth * 0.2, surfaceY - 120);

    // CO2 Atmosphere -> Canopy
    _drawDashedConnection(
      canvas,
      co2UptakePos,
      canopyTop.toOffset(),
      const Color(0xFFEC4899), // Pink (CO2)
      time,
      dashLen: 4,
      gapLen: 8,
      alpha: (isNitrogenCycleMode ? 0.05 : 0.2) * zoomLOD,
      showArrow: true,
      zoom: zoom,
    );

    // O2 Canopy -> Atmosphere
    _drawDashedConnection(
      canvas,
      canopyTop.toOffset(),
      o2ProductionPos,
      const Color(0xFF10B981), // Green (O2)
      time,
      dashLen: 4,
      gapLen: 8,
      alpha: (isNitrogenCycleMode ? 0.05 : 0.2) * zoomLOD,
      showArrow: true,
      zoom: zoom,
    );

    // N2O Atmosphere <- Soil
    _drawDashedConnection(
      canvas,
      Offset(soilX + soilColumnWidth * 0.2, surfaceY),
      n2oEmissionPos,
      const Color(0xFFA855F7), // Purple (N2O)
      time,
      dashLen: 3,
      gapLen: 12,
      alpha: (isNitrogenCycleMode ? 0.8 : 0.15) * zoomLOD,
      showArrow: true,
      label: zoom > 1.2 ? 'N2O EMISSION' : null,
      zoom: zoom,
    );

    // Soil Respiration (Root zone -> Surface)
    _drawDashedConnection(
      canvas,
      Offset(plantCenterX, surfaceY + 40),
      Offset(soilX + soilColumnWidth * 0.35, surfaceY),
      const Color(0xFFEC4899), // Pink (CO2)
      time,
      dashLen: 3,
      gapLen: 10,
      alpha: (isNitrogenCycleMode ? 0.05 : 0.15) * zoomLOD,
      showArrow: true,
      zoom: zoom,
    );

    // Draw connection node circles at key points
    _drawConnectionNode(canvas, canopyTop.toOffset(), const Color(0xFF22D3EE), time);
    _drawConnectionNode(canvas, rootCollar.toOffset(), const Color(0xFF4ADE80), time);
  }


  void _drawDashedConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double time, {
    double dashLen = 5,
    double gapLen = 8,
    double alpha = 0.3,
    String? label,
    bool showArrow = false,
    bool reverse = false,
    required double zoom,
  }) {
    final realStart = reverse ? end : start;
    final realEnd = reverse ? start : end;

    final dx = realEnd.dx - realStart.dx;
    final dy = realEnd.dy - realStart.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance < 1) return;

    final unitX = dx / distance;
    final unitY = dy / distance;

    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = 1.0 / zoom
      ..style = PaintingStyle.stroke;

    final layoutMode = game.ref.read(visualLayoutModeStateProvider);
    final isSchematic = layoutMode == VisualLayoutMode.schematic;

    // Animated dash offset for flow effect
    final flowSpeed = 20.0 + alpha * 100.0;
    final offset = (time * flowSpeed) % (dashLen + gapLen);
    
    final path = Path();
    if (isSchematic) {
      // Layered Graph Style: Orthogonal (L-shaped)
      path.moveTo(realStart.dx, realStart.dy);
      // Halfway vertically, then horizontal, then the rest vertically
      final midY = (realStart.dy + realEnd.dy) / 2;
      path.lineTo(realStart.dx, midY);
      path.lineTo(realEnd.dx, midY);
      path.lineTo(realEnd.dx, realEnd.dy);
    } else {
      // Organic: Straight line
      path.moveTo(realStart.dx, realStart.dy);
      path.lineTo(realEnd.dx, realEnd.dy);
    }

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isEmpty) return;

    for (final metric in pathMetrics) {
      double traveled = -offset;
      while (traveled < metric.length) {
        final dashStart = traveled.clamp(0.0, metric.length);
        final dashEnd = (traveled + dashLen).clamp(0.0, metric.length);

        if (dashEnd > dashStart) {
          final extract = metric.extractPath(dashStart, dashEnd);
          canvas.drawPath(extract, paint);
        }
        traveled += dashLen + gapLen;
      }
    }

    // Directional Arrow
    if (showArrow) {
      final arrowPos = Offset(
        realStart.dx + unitX * (distance * 0.6 + math.sin(time * 5) * 10),
        realStart.dy + unitY * (distance * 0.6 + math.sin(time * 5) * 10),
      );
      _drawArrowHead(canvas, arrowPos, unitX, unitY, color.withValues(alpha: alpha * 2));
    }

    // Label at midpoint
    if (label != null) {
      final mid = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color.withValues(alpha: alpha * 1.5),
            fontSize: 7,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _drawArrowHead(Canvas canvas, Offset pos, double ux, double uy, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    const size = 4.0;
    // Rotate arrow to match direction
    path.moveTo(pos.dx + ux * size, pos.dy + uy * size);
    path.lineTo(pos.dx - uy * size - ux * size, pos.dy + ux * size - uy * size);
    path.lineTo(pos.dx + uy * size - ux * size, pos.dy - ux * size - uy * size);
    path.close();
    canvas.drawPath(path, arrowPaint);
  }

  void _drawConnectionNode(Canvas canvas, Offset pos, Color color, double time) {
    final pulse = 0.6 + 0.4 * math.sin(time * 2.5);
    final radius = 3.0;

    // 1. Outer Glow (Complying with max 0.15 opacity)
    canvas.drawCircle(
      pos,
      radius * 4.0,
      Paint()
        ..color = color.withValues(alpha: 0.1 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 2. Solid Shaded Core
    // Shadow
    canvas.drawCircle(pos + const Offset(1, 1), radius, Paint()..color = Colors.black.withValues(alpha: 0.2 * pulse));
    // Body
    canvas.drawCircle(
      pos,
      radius,
      Paint()..color = color.withValues(alpha: 0.8 * pulse),
    );
    // Highlight
    canvas.drawCircle(
      pos - Offset(radius * 0.3, radius * 0.3),
      radius * 0.4,
      Paint()..color = Colors.white.withValues(alpha: 0.5 * pulse),
    );

    // 3. Tech Ring
    canvas.drawCircle(
      pos,
      radius * 2.5,
      Paint()
        ..color = color.withValues(alpha: 0.3 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }
}
