import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';

/// Draws a tech-style hexagonal grid over the soil column.
/// Adjusted for narrowed soil column.
class HexGridComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks {
  HexGridComponent() : super(priority: 0);

  @override
  void render(Canvas canvas) {
    final zoom = game.camera.viewfinder.zoom;
    final surfaceY = game.soilSurfaceY;
    final worldHeight = game.soilColumnHeight;
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8 / zoom;

    const hexSize = 25.0;
    final h = hexSize * 2;
    final w = math.sqrt(3) * hexSize;

    for (double y = surfaceY; y < surfaceY + worldHeight; y += h * 0.75) {
      final bool odd = ((y - surfaceY) / (h * 0.75)).round() % 2 == 1;
      for (double x = soilX; x < soilX + soilWidth; x += w) {
        final cx = x + (odd ? w / 2 : 0);
        _drawHex(canvas, Offset(cx, y), hexSize, paint);
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    return point.y > game.soilSurfaceY &&
        point.x >= soilX &&
        point.x <= soilX + soilWidth;
  }
}
