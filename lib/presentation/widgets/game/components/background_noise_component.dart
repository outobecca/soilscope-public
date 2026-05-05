import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';

/// Adds a subtle noise texture to the background for a premium, tactile feel.
/// Uses a cached Picture to ensure high performance and zero flickering.
class BackgroundNoiseComponent extends PositionComponent
    with HasGameReference<SoilScopeGame> {
  Picture? _noisePicture;
  Vector2? _lastSize;

  BackgroundNoiseComponent() : super(anchor: Anchor.topLeft);

  @override
  void render(Canvas canvas) {
    final size = game.size;

    if (_noisePicture == null || _lastSize != size) {
      _noisePicture = _generateNoisePicture(size);
      _lastSize = size.clone();
    }

    if (_noisePicture != null) {
      canvas.drawPicture(_noisePicture!);
    }
  }

  Picture _generateNoisePicture(Vector2 size) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final random = math.Random(42); // Fixed seed for stability
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);

    final step = 3.0;
    for (double x = 0; x < size.x; x += step) {
      for (double y = 0; y < size.y; y += step) {
        if (random.nextDouble() < 0.12) {
          final dotSize = 0.5 + random.nextDouble() * 1.0;
          canvas.drawRect(
            Rect.fromLTWH(
              x + random.nextDouble() * step,
              y + random.nextDouble() * step,
              dotSize,
              dotSize,
            ),
            paint,
          );
        }
      }
    }
    return recorder.endRecording();
  }

  @override
  void onRemove() {
    _noisePicture?.dispose();
    super.onRemove();
  }
}
