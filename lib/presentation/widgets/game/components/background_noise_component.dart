import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart' hide Image;
import '../soil_scope_game.dart';

/// Adds a subtle noise texture to the background for a premium, tactile feel.
/// The static field is rasterized once into an image so each frame samples a
/// texture instead of replaying tens of thousands of points.
class BackgroundNoiseComponent extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  Image? _noiseImage;
  Vector2? _lastSize;

  BackgroundNoiseComponent() : super(anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final size = game.size;

    if (_noiseImage == null || _lastSize != size) {
      _noiseImage?.dispose();
      _noiseImage = _generateNoiseImage(size);
      _lastSize = size.clone();
    }

    final image = _noiseImage;
    if (image != null) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(
          0,
          0,
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..filterQuality = FilterQuality.none,
      );
    }
  }

  Image _generateNoiseImage(Vector2 size) {
    final pixelRatio = (PlatformDispatcher
                .instance
                .implicitView
                ?.devicePixelRatio ??
            1.0)
        .clamp(1.0, 2.0);
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder)..scale(pixelRatio);
    final random = math.Random(42); // Fixed seed for stability
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Record one drawRawPoints command, then rasterize it once. Replaying the
    // points every frame costs a surprising amount of raster time for a field
    // that is intentionally static.
    final points = <double>[];
    final step = 3.0;
    for (double x = 0; x < size.x; x += step) {
      for (double y = 0; y < size.y; y += step) {
        if (random.nextDouble() < 0.12) {
          points
            ..add(x + random.nextDouble() * step)
            ..add(y + random.nextDouble() * step);
        }
      }
    }
    if (points.isNotEmpty) {
      canvas.drawRawPoints(
        PointMode.points,
        Float32List.fromList(points),
        paint,
      );
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      (size.x * pixelRatio).ceil(),
      (size.y * pixelRatio).ceil(),
    );
    picture.dispose();
    return image;
  }

  @override
  void onRemove() {
    _noiseImage?.dispose();
    super.onRemove();
  }
}
