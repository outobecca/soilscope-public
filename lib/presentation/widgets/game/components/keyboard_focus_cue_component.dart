import 'dart:ui';

import 'package:flame/components.dart';

/// Ring drawn over the soil layer or plant selected with the canvas bracket
/// keys. It lives in the world layer so panning and zooming keep the cue glued
/// to the target without rebuilding the Flutter widget tree.
class KeyboardFocusCueComponent extends PositionComponent {
  KeyboardFocusCueComponent()
    : super(anchor: Anchor.center, size: Vector2.all(76), priority: 3000);

  bool _isActive = false;

  bool get isActive => _isActive;

  void focusAt(Vector2 worldPosition) {
    position = worldPosition;
    _isActive = true;
  }

  void clear() {
    _isActive = false;
  }

  @override
  void render(Canvas canvas) {
    if (!_isActive) return;

    final center = Offset(size.x / 2, size.y / 2);
    final ringPaint = Paint()
      ..color = const Color(0xFFFFC857)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, 24, ringPaint);
    canvas.drawCircle(
      center,
      33,
      Paint()
        ..color = const Color(0xFFFFC857).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFFFFF3D6));

    // Corner ticks make the cue read as a focus reticle rather than another
    // process hotspot.
    final tickPaint = Paint()
      ..color = const Color(0xFFFFC857)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const radius = 24.0;
    const tick = 7.0;
    for (final direction in <Offset>[
      const Offset(-1, -1),
      const Offset(1, -1),
      const Offset(-1, 1),
      const Offset(1, 1),
    ]) {
      final corner = center + direction * radius;
      final inwardX = corner + Offset(-direction.dx * tick, 0);
      final inwardY = corner + Offset(0, -direction.dy * tick);
      canvas.drawLine(corner, inwardX, tickPaint);
      canvas.drawLine(corner, inwardY, tickPaint);
    }
  }
}
