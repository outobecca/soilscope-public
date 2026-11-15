import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Short-lived pulse of the applied nutrient colours at the root zone.
class FertilizerEffectComponent extends PositionComponent {
  static const double duration = 1.4;

  final List<Color> colors;
  double _elapsed = 0.0;

  FertilizerEffectComponent({
    required Vector2 position,
    required Map<String, Color> nutrientColors,
  }) : colors = nutrientColors.values.toList(growable: false),
       super(position: position, anchor: Anchor.center, priority: 1200);

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final progress = (_elapsed / duration).clamp(0.0, 1.0);
    final fade = 1.0 - progress;
    final palette = colors.isEmpty ? const [Colors.green] : colors;

    canvas.drawCircle(
      Offset.zero,
      12.0 + progress * 52.0,
      Paint()
        ..color = palette.first.withValues(alpha: 0.35 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    for (var i = 0; i < palette.length; i++) {
      final angle =
          (i * 2 * math.pi / palette.length) + progress * math.pi * 0.5;
      final radius = 8.0 + progress * 42.0;
      final center = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawCircle(
        center,
        2.0 + 2.0 * fade,
        Paint()..color = palette[i].withValues(alpha: 0.85 * fade),
      );
    }
  }
}
