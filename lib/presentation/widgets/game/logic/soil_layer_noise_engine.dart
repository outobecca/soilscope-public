import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import '../../../../core/biophysics_utils.dart';
import '../../../../domain/models/soil_layer.dart';

/// Logic for generating soil texture noise and grain patterns.
class SoilLayerNoiseEngine {
  static Picture generateNoisePicture(SoilLayer layer, String layerId) {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final localRandom = math.Random(layerId.hashCode + 1);

    final double sandPart = layer.sandFraction;
    final double siltPart = layer.siltFraction;
    final double clayPart = layer.clayFraction;
    final double carbonPart = (layer.organicCarbon * 25).clamp(0.0, 1.0);
    final double stability = layer.aggregateStability;
    final texture = BiophysicsUtils.getSoilTextureClass(
      sandPart,
      siltPart,
      clayPart,
    );

    // 1. Organic Carbon patches (Amorphous shapes)
    if (carbonPart > 0.02) {
      final carbonPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3 * carbonPart)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      final int patches = (carbonPart * 100).toInt().clamp(8, 150);
      for (int i = 0; i < patches; i++) {
        final cx = localRandom.nextDouble() * 1000;
        final cy = localRandom.nextDouble() * 500;
        final radius = 5 + localRandom.nextDouble() * 25 * carbonPart;

        _drawAmorphousShape(
          canvas,
          Offset(cx, cy),
          radius,
          carbonPaint,
          localRandom,
        );
      }
    }

    // 2. Aggregates / Stability clusters (Irregular shapes)
    if (stability > 0.3) {
      final int nClusters = (stability * 60).toInt();
      for (int i = 0; i < nClusters; i++) {
        final double cx = localRandom.nextDouble() * 1000;
        final double cy = localRandom.nextDouble() * 500;
        final double clusterSize =
            (12 + localRandom.nextDouble() * 25 * stability) * (1.0 + clayPart);
        final clusterPaint = Paint()
          ..color = Colors.brown.shade700.withValues(alpha: 0.2);

        for (int j = 0; j < 6; j++) {
          final offX = (localRandom.nextDouble() - 0.5) * 25;
          final offY = (localRandom.nextDouble() - 0.5) * 20;
          _drawAmorphousShape(
            canvas,
            Offset(cx + offX, cy + offY),
            clusterSize * (0.4 + localRandom.nextDouble() * 0.6),
            clusterPaint,
            localRandom,
            points: 5,
          );
        }
      }
    }

    // 3. Silt Grains (Pixel noise)
    final siltPaint = Paint()
      ..color = Colors.brown.shade200.withValues(alpha: 0.12);
    final int siltGrains = (siltPart * 1200).toInt();
    for (int i = 0; i < siltGrains; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          localRandom.nextDouble() * 1000,
          localRandom.nextDouble() * 500,
          1.2,
          1.2,
        ),
        siltPaint,
      );
    }

    // 4. Sand Grains (Varied angular shapes)
    final List<Color> sandColors = _grainPalette(texture);
    final int sandGrains = _grainDensity(texture, sandPart, siltPart, clayPart);
    for (int i = 0; i < sandGrains; i++) {
      final sandPaint = Paint()
        ..color = sandColors[localRandom.nextInt(sandColors.length)].withValues(
          alpha: 0.3,
        );
      final double gSize = 2.5 + localRandom.nextDouble() * 4.5;
      final gx = localRandom.nextDouble() * 1000;
      final gy = localRandom.nextDouble() * 500;

      // Draw angular grains instead of just rects
      final grainPath = Path();
      grainPath.moveTo(gx, gy);
      grainPath.lineTo(gx + gSize, gy + localRandom.nextDouble() * 2);
      grainPath.lineTo(gx + gSize * 0.8, gy + gSize);
      grainPath.lineTo(gx - localRandom.nextDouble() * 2, gy + gSize * 0.7);
      grainPath.close();

      canvas.drawPath(grainPath, sandPaint);
    }

    return recorder.endRecording();
  }

  static void _drawAmorphousShape(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    math.Random rand, {
    int points = 6,
  }) {
    final path = Path();
    for (int i = 0; i < points; i++) {
      final angle = (i / points) * math.pi * 2;
      final r = radius * (0.7 + rand.nextDouble() * 0.6);
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  static List<Color> _grainPalette(SoilTexture texture) {
    switch (texture) {
      case SoilTexture.sand:
      case SoilTexture.loamySand:
      case SoilTexture.sandyLoam:
        return [
          Colors.amber.shade200,
          Colors.orange.shade200,
          Colors.yellow.shade100,
          Colors.brown.shade200,
        ];
      case SoilTexture.silt:
      case SoilTexture.siltLoam:
      case SoilTexture.siltyClayLoam:
      case SoilTexture.siltyClay:
        return [
          Colors.blueGrey.shade200,
          Colors.brown.shade200,
          Colors.grey.shade300,
          Colors.blueGrey.shade100,
        ];
      case SoilTexture.clay:
      case SoilTexture.clayLoam:
      case SoilTexture.sandyClay:
      case SoilTexture.sandyClayLoam:
        return [
          Colors.brown.shade500,
          Colors.brown.shade600,
          Colors.deepOrange.shade300,
          Colors.brown.shade400,
        ];
      case SoilTexture.loam:
        return [
          Colors.brown.shade300,
          Colors.orange.shade200,
          Colors.brown.shade200,
          Colors.grey.shade300,
        ];
    }
  }

  static int _grainDensity(
    SoilTexture texture,
    double sandPart,
    double siltPart,
    double clayPart,
  ) {
    final base = switch (texture) {
      SoilTexture.sand || SoilTexture.loamySand => 900,
      SoilTexture.sandyLoam || SoilTexture.loam => 650,
      SoilTexture.silt || SoilTexture.siltLoam => 520,
      SoilTexture.clay ||
      SoilTexture.clayLoam ||
      SoilTexture.sandyClay ||
      SoilTexture.siltyClay => 420,
      _ => 560,
    };
    return (base *
            (0.5 + sandPart * 0.4 + siltPart * 0.2 + (1.0 - clayPart) * 0.1))
        .toInt()
        .clamp(280, 1100);
  }
}
