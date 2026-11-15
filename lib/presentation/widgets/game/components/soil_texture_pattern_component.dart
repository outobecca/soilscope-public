import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../soil_scope_game.dart';
import '../../../providers/simulation_session_provider.dart';
import 'soil_component_mixin.dart';

/// High-fidelity soil texture component that visualizes physical composition
/// (sand, silt, clay) and biological hotspots.
///
/// Decorative only: soil body taps are handled by [SoilLayerComponent] so
/// they open that layer's own analysis card.
class SoilTexturePatternComponent extends Component
    with HasGameReference<SoilScopeGame>, SoilComponentMixin {
  final Paint _overlayPaint = Paint();
  final Paint _sandPaint = Paint();
  final Paint _siltPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _clayPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _clayLinePaint = Paint();
  final Paint _hotspotPaint = Paint();

  SoilTexturePatternComponent() : super(priority: 4);

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    // Use the displayed state so texture changes follow the history scrubber,
    // not the live engine behind it.
    final state = game.displayedState;
    if (state.profile.layers.isEmpty) return;

    final double scaleY = calculateVerticalScale(
      state.profile.layers.fold(0.0, (sum, l) => sum + l.thickness),
    );

    // The background spans a huge world width for camera panning. Generating
    // texture for all of it every frame is the dominant canvas cost: a clay
    // layer alone could emit 20k paths per frame. Limit procedural detail to
    // the visible slice plus a small margin.
    final viewportWidth =
        game.camera.viewport.size.x / game.camera.viewfinder.zoom;
    final visibleLeft = game.camera.viewfinder.position.x - viewportWidth / 2;
    final visibleRight = visibleLeft + viewportWidth;
    final textureX = math.max(backgroundX, visibleLeft - 80);
    final textureWidth =
        math.min(backgroundX + backgroundWidth, visibleRight + 80) - textureX;

    final rand = math.Random(12345);
    double currentY = surfaceY;

    for (final layer in state.profile.layers) {
      final layerHeight = layer.thickness * scaleY;
      final endY = currentY + layerHeight;
      final saturation = (layer.waterContent / layer.porosity).clamp(0.0, 1.0);
      final layerCompaction =
          (((layer.bulkDensity - 1350.0) / 400.0).clamp(0.0, 1.0) * 0.6 +
                  ((0.45 - layer.porosity) / 0.17).clamp(0.0, 1.0) * 0.4)
              .clamp(0.0, 1.0);
      final session = game.ref.read(simulationSessionProvider);

      // Highlight Overlay
      if (session.selectedInspectorType == 'Soil') {
        final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 4);
        canvas.drawRect(
          Rect.fromLTRB(textureX, currentY, textureX + textureWidth, endY),
          _overlayPaint..color = Colors.white.withValues(alpha: 0.05 * pulse),
        );
      }

      // 1. Draw Physical Texture
      if (layer.sandFraction > 0.5) {
        _drawSandTexture(
          canvas,
          currentY,
          endY,
          textureX,
          textureWidth,
          zoom,
          rand,
          saturation,
        );
      } else if (layer.clayFraction > 0.35) {
        _drawClayTexture(
          canvas,
          currentY,
          endY,
          textureX,
          textureWidth,
          zoom,
          rand,
          saturation,
          layerCompaction,
        );
        if (layerCompaction > 0.5) {
          _drawCompactionBand(
            canvas,
            currentY,
            endY,
            textureX,
            textureWidth,
            zoom,
            layerCompaction,
          );
        }
      } else {
        _drawSiltTexture(
          canvas,
          currentY,
          endY,
          textureX,
          textureWidth,
          zoom,
          rand,
          saturation,
        );
      }

      // 2. Draw Biological Microsites (Hotspots)
      if (layer.microbialBiomass > 20) {
        _drawBioHotspots(
          canvas,
          currentY,
          endY,
          textureX,
          textureWidth,
          zoom,
          rand,
          layer.microbialBiomass,
        );
      }

      currentY = endY;
    }
  }

  void _drawSandTexture(
    Canvas canvas,
    double startY,
    double endY,
    double xStart,
    double width,
    double zoom,
    math.Random rand,
    double saturation,
  ) {
    final grainCount = ((endY - startY) * width / 900).toInt().clamp(80, 900);
    for (int i = 0; i < grainCount; i++) {
      final x = xStart + rand.nextDouble() * width;
      final y = startY + rand.nextDouble() * (endY - startY);
      final radius = (1.2 + rand.nextDouble() * 2.2) / zoom;
      final isWhite = rand.nextDouble() > 0.6;
      final color = isWhite ? Colors.white : const Color(0xFFFFC107);
      canvas.drawCircle(
        Offset(x, y),
        radius,
        _sandPaint
          ..color = color.withValues(alpha: 0.08 + rand.nextDouble() * 0.12),
      );
    }
  }

  void _drawSiltTexture(
    Canvas canvas,
    double startY,
    double endY,
    double xStart,
    double width,
    double zoom,
    math.Random rand,
    double saturation,
  ) {
    final rowCount = ((endY - startY) / 10).toInt().clamp(6, 40);
    final paint = _siltPaint..strokeWidth = 1.0 / zoom;
    for (int i = 0; i < rowCount; i++) {
      final y = startY + (i + 0.5) * (endY - startY) / rowCount;
      paint.color = (i % 2 == 0 ? Colors.white : Colors.black).withValues(
        alpha: 0.1,
      );
      final path = Path()..moveTo(xStart, y);
      for (double x = xStart; x <= xStart + width; x += 20) {
        path.lineTo(x, y + math.sin(x * 0.1 + i) * 3);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawClayTexture(
    Canvas canvas,
    double startY,
    double endY,
    double xStart,
    double width,
    double zoom,
    math.Random rand,
    double saturation,
    double compaction,
  ) {
    // Compacted clay has more, smaller, tightly packed peds and a darker
    // matrix. Keep the cap so the desktop and web renderers stay bounded.
    final pedCount = ((endY - startY) * width / 1500).toInt().clamp(60, 900);
    final visiblePeds = (pedCount * (1.0 + compaction * 1.4)).toInt().clamp(
      60,
      1200,
    );
    final paint = _clayPaint..strokeWidth = 1.2 / zoom;
    for (int i = 0; i < visiblePeds; i++) {
      final cx = xStart + rand.nextDouble() * width;
      final cy = startY + rand.nextDouble() * (endY - startY);
      final size =
          (20 + rand.nextDouble() * 40) / zoom * (1.0 - compaction * 0.25);
      paint.color = Colors.black.withValues(alpha: 0.12 + compaction * 0.10);
      final path = Path();
      path.moveTo(cx - size / 2, cy - size / 3);
      path.lineTo(cx + size / 3, cy - size / 2);
      path.lineTo(cx + size / 2, cy + size / 4);
      path.lineTo(cx - size / 4, cy + size / 2);
      path.close();
      canvas.drawPath(path, paint);
      canvas.drawLine(
        Offset(cx - size / 2, cy),
        Offset(cx + size / 2, cy + size / 10),
        _clayLinePaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 / zoom
          ..color = Colors.white.withValues(alpha: 0.04),
      );
    }
  }

  void _drawCompactionBand(
    Canvas canvas,
    double startY,
    double endY,
    double xStart,
    double width,
    double zoom,
    double compaction,
  ) {
    final bandHeight = ((endY - startY) * 0.18).clamp(4.0 / zoom, 22.0 / zoom);
    final bandTop = startY + 2.0 / zoom;
    final bandRect = Rect.fromLTWH(xStart, bandTop, width, bandHeight);
    final bandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.26 * compaction),
          Colors.black.withValues(alpha: 0.04 * compaction),
        ],
      ).createShader(bandRect);
    canvas.drawRect(bandRect, bandPaint);

    // Dense, nearly horizontal plates are the visual signature of a plough
    // pan: less continuous pore space and fewer vertical cracks.
    final platePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28 * compaction)
      ..strokeWidth = 1.2 / zoom;
    for (int i = 0; i < 3; i++) {
      final y = bandTop + bandHeight * (i + 1) / 4;
      canvas.drawLine(Offset(xStart, y), Offset(xStart + width, y), platePaint);
    }
  }

  void _drawBioHotspots(
    Canvas canvas,
    double startY,
    double endY,
    double xStart,
    double width,
    double zoom,
    math.Random rand,
    double biomass,
  ) {
    final spotCount = (biomass / 15).toInt().clamp(2, 10);
    // CRITICAL: Blur should not explode at low zoom. Clamp it.
    final blurValue = (8.0 / zoom).clamp(4.0, 15.0);
    final spotPaint = _hotspotPaint
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurValue);

    for (int i = 0; i < spotCount; i++) {
      final x = xStart + rand.nextDouble() * width;
      final y = startY + rand.nextDouble() * (endY - startY);
      // Fixed size in screen space or constrained in world space
      final radius = (8.0 + rand.nextDouble() * 12.0);
      spotPaint.color = const Color(
        0xFF689F38,
      ).withValues(alpha: 0.1); // Increased alpha for visibility but kept small
      canvas.drawCircle(Offset(x, y), radius, spotPaint);
    }
  }
}
