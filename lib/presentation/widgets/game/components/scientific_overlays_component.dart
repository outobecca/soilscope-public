import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import 'soil_component_mixin.dart';

/// Draws scientific overlays including depth markers, horizon labels,
/// water table indicator, surface grass, and atmospheric gas exchange arrows.
///
/// Priority: 82 (UI overlay layer)
class ScientificOverlaysComponent extends Component
    with HasGameReference<SoilScopeGame>, SoilComponentMixin {
  ScientificOverlaysComponent() : super(priority: 1700);

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    final state = game.ref.read(simulationProvider);
    if (state.profile.layers.isEmpty) return;

    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    // Draw surface grass strip across the soil column
    _drawSurfaceGrass(canvas, surfaceY, soilX, soilWidth);

    // Draw depth markers that follow the camera horizontally but stay near the soil column
    final markerX = (game.camera.viewfinder.position.x - (game.size.x / 2) + 20).clamp(soilX - 100, soilX + 20);
    _drawDepthMarkers(
      canvas,
      zoom,
      surfaceY,
      soilHeight,
      markerX,
      state.profile.layers,
    );

    // Draw horizon boundaries and labels constrained to the soil column
    _drawActualHorizonOverlays(
      canvas,
      surfaceY,
      soilX,
      soilWidth,
      soilHeight,
      zoom,
      time,
      state.profile.layers,
    );

    // Draw water table indicator constrained to the soil column
    _drawWaterTable(canvas, zoom, surfaceY, soilX, soilWidth, soilHeight);

    // Draw surface boundary label (Z=0) pinned to the marker position
    _drawSurfaceLabel(canvas, surfaceY, markerX);
  }

  void _drawActualHorizonOverlays(
    Canvas canvas,
    double surfaceY,
    double soilX,
    double soilWidth,
    double soilHeight,
    double zoom,
    double time,
    List<dynamic> layers,
  ) {
    final activeLayers = layers.take(2).toList();
    final double thickness = game.activeProfileThickness;
    final double scaleY = soilHeight / thickness;

    double currentY = surfaceY;
    final boundaryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 / zoom;

    for (int i = 0; i < activeLayers.length; i++) {
      final layer = activeLayers[i];
      final double layerHeight = layer.thickness * scaleY;
      final double bottomY = currentY + layerHeight;

      // Draw dashed boundary within the soil column
      _drawDashedHorizontalLine(
        canvas,
        bottomY,
        soilX,
        soilX + soilWidth,
        boundaryPaint,
        8 / zoom,
        8 / zoom,
        time,
      );

      // Label on the right inside the soil column
      final label = i == 0 ? "O/A: TOPSOIL" : "B: SUBSOIL";
      _drawText(
        canvas,
        label,
        soilX + soilWidth - 100,
        currentY + 5,
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: 9 / zoom,
        bold: true,
      );

      currentY += layerHeight;
    }
  }

  void _drawDepthMarkers(
    Canvas canvas,
    double zoom,
    double surfaceY,
    double soilHeight,
    double soilX,
    List<dynamic> layers,
  ) {
    final activeLayers = layers.take(2).toList();
    final double thickness = game.activeProfileThickness;
    final double scaleY = soilHeight / thickness;

    final markerPaint = Paint()
      ..color = const Color(0xFF455A64).withValues(alpha: 0.6)
      ..strokeWidth = 1.0 / zoom;

    double currentY = surfaceY;

    // Draw 0cm marker at the left edge of the soil column
    _drawMarker(canvas, "0cm", currentY, soilX, markerPaint, zoom);

    for (var layer in activeLayers) {
      currentY += layer.thickness * scaleY;
      final depthCm = (layer.depth + layer.thickness) * 100;
      _drawMarker(
        canvas,
        "${depthCm.toStringAsFixed(0)}cm",
        currentY,
        soilX,
        markerPaint,
        zoom,
      );
    }
  }

  void _drawMarker(
    Canvas canvas,
    String label,
    double y,
    double soilX,
    Paint paint,
    double zoom,
  ) {
    final markerLeft = soilX + 5;
    canvas.drawLine(Offset(markerLeft, y), Offset(markerLeft + 15, y), paint);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFF455A64),
          fontSize: 9 / zoom,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(markerLeft + 17, y - tp.height / 2));
  }

  void _drawSurfaceGrass(Canvas canvas, double surfaceY, double soilX, double soilWidth) {
    // Subtle green grass strip at soil surface, constrained to soil column
    final grassPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.7);
    canvas.drawRect(Rect.fromLTWH(soilX, surfaceY - 2, soilWidth, 3), grassPaint);

    // Individual grass blades
    final rand = math.Random(42);
    final bladePaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    final darkBladePaint = Paint()
      ..color = const Color(0xFF388E3C).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final soilCenterX = soilX + soilWidth / 2;
    for (int i = 0; i < 30; i++) {
      final x = soilX + i * (soilWidth / 30) + rand.nextDouble() * 10;
      // Skip area around center where plant is
      if ((x - soilCenterX).abs() < 30) continue;

      final height = 6 + rand.nextDouble() * 7;
      final path = Path()
        ..moveTo(x - 2, surfaceY)
        ..lineTo(x, surfaceY - height)
        ..lineTo(x + 2, surfaceY)
        ..close();
      canvas.drawPath(path, rand.nextBool() ? bladePaint : darkBladePaint);
    }
  }

  void _drawDashedHorizontalLine(
    Canvas canvas,
    double y,
    double startX,
    double endX,
    Paint paint,
    double dashWidth,
    double dashSpace,
    double time,
  ) {
    double currentX = startX + (time * 10) % (dashWidth + dashSpace);
    while (currentX < endX) {
      final dashEnd = (currentX + dashWidth).clamp(startX, endX);
      if (currentX >= startX) {
        canvas.drawLine(Offset(currentX, y), Offset(dashEnd, y), paint);
      }
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawWaterTable(
    Canvas canvas,
    double zoom,
    double surfaceY,
    double soilX,
    double soilWidth,
    double soilHeight,
  ) {
    final l = game.l10n;
    final waterTableY = surfaceY + soilHeight * 0.55;
    final waterPaint = Paint()
      ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.06);
    canvas.drawRect(
      Rect.fromLTWH(backgroundX, waterTableY, backgroundWidth, soilHeight * 0.15),
      waterPaint,
    );
    final linePaint = Paint()
      ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;
    canvas.drawLine(
      Offset(backgroundX, waterTableY),
      Offset(backgroundX + backgroundWidth, waterTableY),
      linePaint,
    );
    // Saturated zone label - Centered in logical viewport
    final textX = (SoilScopeGame.logicalSize.x / 2) + 500;
    _drawTableLabel(canvas, textX, waterTableY + 10, l.saturatedZone.toUpperCase());
  }

  void _drawSurfaceLabel(Canvas canvas, double surfaceY, double soilX) {
    final boundaryTp = TextPainter(
      text: const TextSpan(
        text: 'SURFACE (Z=0)',
        style: TextStyle(
          color: Color(0xFF8B5CF6),
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    boundaryTp.paint(canvas, Offset(soilX + 10, surfaceY - boundaryTp.height - 2));
  }

  void _drawTableLabel(Canvas canvas, double x, double y, String text) {
    _drawText(
      canvas,
      text,
      x,
      y,
      color: const Color(0xFF0EA5E9),
      fontSize: 9,
      bold: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y, {
    Color color = Colors.white,
    double fontSize = 10,
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x, y));
  }
}
