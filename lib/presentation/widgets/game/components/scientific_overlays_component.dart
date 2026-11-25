import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../soil_scope_game.dart';
import 'soil_component_mixin.dart';

/// Draws scientific overlays including depth markers, horizon labels,
/// water table indicator, surface grass, and atmospheric gas exchange arrows.
///
/// Priority: 82 (UI overlay layer)
class ScientificOverlaysComponent extends Component
    with HasGameReference<SoilScopeGame>, SoilComponentMixin {
  ScientificOverlaysComponent() : super(priority: 1700);

  final Map<String, TextPainter> _textPainters = {};

  /// Paints reused across frames; only their width fields are rewritten.
  final Paint _boundaryPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.15)
    ..style = PaintingStyle.stroke;
  final Paint _markerPaint = Paint()
    ..color = const Color(0xFF455A64).withValues(alpha: 0.6);
  final Paint _waterFillPaint = Paint()
    ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.06);
  final Paint _waterLinePaint = Paint()
    ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.4)
    ..style = PaintingStyle.stroke;

  /// The grass strip is static for a given soil geometry, so it is recorded
  /// once instead of rebuilding a `Random`, 30 `Path`s and its `Paint`s per
  /// frame.
  ui.Picture? _grassPicture;
  double _grassPictureX = double.nan;
  double _grassPictureY = double.nan;
  double _grassPictureWidth = double.nan;

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    final double time = game.currentTime();
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    final state = game.displayedState;
    if (state.profile.layers.isEmpty) return;

    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    // Draw surface grass strip across the soil column
    _drawSurfaceGrass(canvas, surfaceY, soilX, soilWidth);

    // Keep the depth rail inside the currently visible part of the soil
    // column. A fixed column-edge rail disappears entirely on phones because
    // the camera shows only the middle of the logical scene.
    final visible = _visibleWorldRect;
    final railMinX = soilX + 4 / zoom;
    final railMaxX = soilX + soilWidth - 80 / zoom;
    final markerX = railMaxX < railMinX
        ? railMinX
        : (visible.left + 16 / zoom).clamp(railMinX, railMaxX).toDouble();
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

  /// The world rectangle currently visible through the camera viewport.
  Rect get _visibleWorldRect {
    final zoom = game.camera.viewfinder.zoom;
    final viewport = game.camera.viewport.size;
    return Rect.fromCenter(
      center: game.camera.viewfinder.position.toOffset(),
      width: viewport.x / zoom,
      height: viewport.y / zoom,
    );
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
    final visible = _visibleWorldRect;
    final margin = 12 / zoom;
    final labelFontSize = 11 / zoom;

    double currentY = surfaceY;
    _boundaryPaint.strokeWidth = 0.8 / zoom;

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
        _boundaryPaint,
        8 / zoom,
        8 / zoom,
        time,
      );

      // Label on the visible right side of the soil column. Right-aligning
      // the painter keeps long localized horizon names inside the column.
      final horizonName = i == 0
          ? game.l10n.topsoilHorizon
          : game.l10n.subsoilHorizon;
      final label = i == 0
          ? 'O/A: ${horizonName.toUpperCase()}'
          : 'B: ${horizonName.toUpperCase()}';
      final tp = _textPainter(
        label,
        color: Colors.white.withValues(alpha: 0.35),
        fontSize: labelFontSize,
        bold: true,
      );
      final maxRight = math.min(soilX + soilWidth, visible.right) - margin;
      final labelX = math.max(soilX + margin, maxRight - tp.width);
      tp.paint(canvas, Offset(labelX, currentY + 5 / zoom));

      currentY += layerHeight;
    }
  }

  void _drawDepthMarkers(
    Canvas canvas,
    double zoom,
    double surfaceY,
    double soilHeight,
    double markerX,
    List<dynamic> layers,
  ) {
    final activeLayers = layers.take(2).toList();
    final double thickness = game.activeProfileThickness;
    final double scaleY = soilHeight / thickness;

    _markerPaint.strokeWidth = 1.0 / zoom;

    double currentY = surfaceY;

    // Draw 0cm marker on the visible depth rail.
    _drawMarker(canvas, "0cm", currentY, markerX, _markerPaint, zoom);

    for (var layer in activeLayers) {
      currentY += layer.thickness * scaleY;
      final depthCm = (layer.depth + layer.thickness) * 100;
      _drawMarker(
        canvas,
        "${depthCm.toStringAsFixed(0)}cm",
        currentY,
        markerX,
        _markerPaint,
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
    final markerLeft = soilX + 5 / zoom;
    canvas.drawLine(
      Offset(markerLeft, y),
      Offset(markerLeft + 15 / zoom, y),
      paint,
    );
    final tp = _textPainter(
      label,
      color: const Color(0xFF455A64),
      fontSize: 11 / zoom,
      bold: true,
    );
    tp.paint(canvas, Offset(markerLeft + 17 / zoom, y - tp.height / 2));
  }

  TextPainter _textPainter(
    String text, {
    required Color color,
    required double fontSize,
    bool bold = false,
  }) {
    final key =
        '$text|${color.toARGB32()}|${fontSize.toStringAsFixed(2)}|$bold';
    final cached = _textPainters[key];
    if (cached != null) return cached;

    final painter = TextPainter(
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
    _textPainters[key] = painter;

    // Zoom changes the key; keep the cache bounded instead of retaining one
    // painter per pixel of every label ever drawn.
    if (_textPainters.length > 64) {
      final stale = _textPainters.keys.first;
      _textPainters.remove(stale)?.dispose();
    }
    return painter;
  }

  void _drawSurfaceGrass(
    Canvas canvas,
    double surfaceY,
    double soilX,
    double soilWidth,
  ) {
    if (_grassPicture == null ||
        _grassPictureX != soilX ||
        _grassPictureY != surfaceY ||
        _grassPictureWidth != soilWidth) {
      _grassPictureX = soilX;
      _grassPictureY = surfaceY;
      _grassPictureWidth = soilWidth;
      _grassPicture?.dispose();
      _grassPicture = _buildSurfaceGrass(surfaceY, soilX, soilWidth);
    }
    canvas.drawPicture(_grassPicture!);
  }

  ui.Picture _buildSurfaceGrass(
    double surfaceY,
    double soilX,
    double soilWidth,
  ) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Subtle green grass strip at soil surface, constrained to soil column
    final grassPaint = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.7);
    canvas.drawRect(
      Rect.fromLTWH(soilX, surfaceY - 2, soilWidth, 3),
      grassPaint,
    );

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

    return recorder.endRecording();
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
    canvas.drawRect(
      Rect.fromLTWH(
        backgroundX,
        waterTableY,
        backgroundWidth,
        soilHeight * 0.15,
      ),
      _waterFillPaint,
    );
    _waterLinePaint.strokeWidth = 1.0 / zoom;
    canvas.drawLine(
      Offset(backgroundX, waterTableY),
      Offset(backgroundX + backgroundWidth, waterTableY),
      _waterLinePaint,
    );
    // Saturated zone label: right-align it to the visible soil column instead
    // of a fixed logical x that can be clipped or far outside a phone viewport.
    final visible = _visibleWorldRect;
    final margin = 12 / zoom;
    final label = _textPainter(
      l.saturatedZone.toUpperCase(),
      color: const Color(0xFF0EA5E9),
      fontSize: 12 / zoom,
      bold: true,
    );
    final maxRight = math.min(soilX + soilWidth, visible.right) - margin;
    final textX = math.max(soilX + margin, maxRight - label.width);
    label.paint(canvas, Offset(textX, waterTableY + 10 / zoom));
  }

  void _drawSurfaceLabel(Canvas canvas, double surfaceY, double soilX) {
    final visible = _visibleWorldRect;
    final zoom = game.camera.viewfinder.zoom;
    final boundaryTp = _textPainter(
      game.l10n.surfaceLabel.toUpperCase(),
      color: const Color(0xFF8B5CF6),
      fontSize: 12 / zoom,
      bold: true,
    );
    final minX = math.max(soilX + 10 / zoom, visible.left + 8 / zoom);
    final maxX = math.max(
      minX,
      math.min(
        soilX + SoilScopeGame.soilColumnWidth - boundaryTp.width - 8 / zoom,
        visible.right - boundaryTp.width - 8 / zoom,
      ),
    );
    final labelX = (soilX + 10 / zoom).clamp(minX, maxX).toDouble();
    boundaryTp.paint(
      canvas,
      Offset(labelX, surfaceY - boundaryTp.height - 2 / zoom),
    );
  }

  @override
  void onRemove() {
    _grassPicture?.dispose();
    _grassPicture = null;
    for (final painter in _textPainters.values) {
      painter.dispose();
    }
    _textPainters.clear();
    super.onRemove();
  }
}
