import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../domain/models/soil_layer.dart';
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
  final Paint _imagePaint = Paint()..filterQuality = FilterQuality.low;

  ui.Image? _textureImage;
  String? _textureImageKey;
  Rect? _textureImageRect;
  String? _pendingTextureKey;
  int _textureGeneration = 0;
  double _lastTextureRequestAt = -1;

  SoilTexturePatternComponent() : super(priority: 4);

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;
    // Use the displayed state so texture changes follow the history scrubber,
    // not the live engine behind it.
    final state = game.displayedState;
    final layers = state.profile.layers;
    if (layers.isEmpty) return;

    final totalThickness = layers.fold(0.0, (sum, l) => sum + l.thickness);
    final double scaleY = calculateVerticalScale(totalThickness);
    final totalHeight = totalThickness * scaleY;
    if (totalHeight <= 0) return;

    // The background spans a huge world width for camera panning. Snap the
    // texture window to a coarse grid so panning reuses the same raster instead
    // of regenerating it for every pixel of camera movement.
    const snap = 256.0;
    final viewportWidth = game.camera.viewport.size.x / zoom;
    final visibleLeft = game.camera.viewfinder.position.x - viewportWidth / 2;
    final visibleRight = visibleLeft + viewportWidth;
    final rawLeft = math.max(backgroundX, visibleLeft - 80);
    final rawRight = math.min(backgroundX + backgroundWidth, visibleRight + 80);
    final textureX = (rawLeft / snap).floorToDouble() * snap;
    final textureWidth = math.max(
      1.0,
      (rawRight / snap).ceilToDouble() * snap - textureX,
    );

    // Highlight overlays pulse with UI time and are intentionally kept out of
    // the cached raster.
    if (game.ref.read(simulationSessionProvider).selectedInspectorType ==
        'Soil') {
      final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 4);
      double overlayY = surfaceY;
      for (final layer in layers) {
        final endY = overlayY + layer.thickness * scaleY;
        canvas.drawRect(
          Rect.fromLTRB(textureX, overlayY, textureX + textureWidth, endY),
          _overlayPaint..color = Colors.white.withValues(alpha: 0.05 * pulse),
        );
        overlayY = endY;
      }
    }

    final zoomBucket = (zoom * 4).round() / 4;
    final key = StringBuffer()
      ..write(textureX.toStringAsFixed(0))
      ..write('|')
      ..write(textureWidth.toStringAsFixed(0))
      ..write('|')
      ..write(surfaceY.toStringAsFixed(1))
      ..write('|')
      ..write(totalHeight.toStringAsFixed(1))
      ..write('|')
      ..write(zoomBucket.toStringAsFixed(2));
    for (final layer in layers) {
      key
        ..write('|')
        ..write(layer.id)
        ..write(':')
        ..write(layer.sandFraction.toStringAsFixed(2))
        ..write(',')
        ..write(layer.clayFraction.toStringAsFixed(2))
        ..write(',')
        ..write(layer.siltFraction.toStringAsFixed(2))
        ..write(',')
        ..write((_layerCompaction(layer) * 10).round() / 10)
        ..write(',')
        ..write((layer.microbialBiomass / 20).floor() * 20);
    }
    final textureKey = key.toString();

    final destination = Rect.fromLTWH(
      textureX,
      surfaceY,
      textureWidth,
      totalHeight,
    );
    final cached = _textureImage;
    // Reuse the previous raster while a refreshed one is prepared. Falling
    // back to direct path drawing for every physical-property change caused
    // periodic multi-millisecond spikes.
    if (cached != null && _textureImageRect == destination) {
      canvas.drawImageRect(
        cached,
        Rect.fromLTWH(
          0,
          0,
          cached.width.toDouble(),
          cached.height.toDouble(),
        ),
        destination,
        _imagePaint,
      );
      if (_textureImageKey != textureKey) {
        _requestTexture(
          textureKey,
          layers,
          scaleY,
          textureX,
          textureWidth,
          totalHeight,
          zoomBucket,
          destination,
        );
      }
    } else {
      // First frame or a moved texture window: draw live until the new raster
      // covers the current window.
      _paintTexture(
        canvas,
        layers,
        scaleY,
        textureX,
        textureWidth,
        zoom,
      );
      _requestTexture(
        textureKey,
        layers,
        scaleY,
        textureX,
        textureWidth,
        totalHeight,
        zoomBucket,
        destination,
      );
    }
  }

  double _layerCompaction(SoilLayer layer) {
    return (((layer.bulkDensity - 1350.0) / 400.0).clamp(0.0, 1.0) * 0.6 +
            ((0.45 - layer.porosity) / 0.17).clamp(0.0, 1.0) * 0.4)
        .clamp(0.0, 1.0);
  }

  void _requestTexture(
    String key,
    List<SoilLayer> layers,
    double scaleY,
    double textureX,
    double textureWidth,
    double totalHeight,
    double zoomBucket,
    Rect destination,
  ) {
    if (_pendingTextureKey == key || _textureImageKey == key) return;
    // The texture is decorative. Throttle refreshes so a changing biomass
    // value cannot queue a full rasterization on every simulation tick.
    final now = DateTime.now().millisecondsSinceEpoch / 1000.0;
    if (_lastTextureRequestAt >= 0 && now - _lastTextureRequestAt < 0.75) {
      return;
    }
    _lastTextureRequestAt = now;
    _pendingTextureKey = key;
    final generation = ++_textureGeneration;
    _rasterizeTexture(
      key,
      layers,
      scaleY,
      textureX,
      textureWidth,
      totalHeight,
      zoomBucket,
      destination,
      generation,
    );
  }

  Future<void> _rasterizeTexture(
    String key,
    List<SoilLayer> layers,
    double scaleY,
    double textureX,
    double textureWidth,
    double totalHeight,
    double zoomBucket,
    Rect destination,
    int generation,
  ) async {
    try {
      final pixelRatio = zoomBucket >= 1.5 ? 1.5 : 1.0;
      final recorder = ui.PictureRecorder();
      final textureCanvas = Canvas(recorder)
        ..scale(pixelRatio)
        ..translate(-textureX, -surfaceY);
      _paintTexture(
        textureCanvas,
        layers,
        scaleY,
        textureX,
        textureWidth,
        zoomBucket,
      );
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        (textureWidth * pixelRatio).ceil(),
        (totalHeight * pixelRatio).ceil(),
      );
      picture.dispose();

      if (!isMounted || generation != _textureGeneration) {
        image.dispose();
        return;
      }
      _textureImage?.dispose();
      _textureImage = image;
      _textureImageKey = key;
      _textureImageRect = destination;
      _pendingTextureKey = null;
    } catch (_) {
      // The live path remains a valid fallback if rasterization is unavailable.
      if (generation == _textureGeneration) _pendingTextureKey = null;
    }
  }

  void _paintTexture(
    Canvas canvas,
    List<SoilLayer> layers,
    double scaleY,
    double textureX,
    double textureWidth,
    double zoom,
  ) {
    final rand = math.Random(12345);
    double currentY = surfaceY;

    for (final layer in layers) {
      final layerHeight = layer.thickness * scaleY;
      final endY = currentY + layerHeight;
      final saturation = (layer.waterContent / layer.porosity).clamp(0.0, 1.0);
      final layerCompaction = _layerCompaction(layer);

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

  @override
  void onRemove() {
    _textureGeneration++;
    _textureImage?.dispose();
    super.onRemove();
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
