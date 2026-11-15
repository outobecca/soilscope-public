import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:material_ui/material_ui.dart';
import '../soil_scope_game.dart';
import 'soil_component_mixin.dart';

/// Draws subtle color bands for each soil horizon.
///
/// Decorative only: the soil layer components own taps for the soil body, so
/// a tap always opens the real layer's analysis instead of a generic horizon
/// card that does not match the simulated layers.
class HorizonColorBandsComponent extends Component
    with HasGameReference<SoilScopeGame>, SoilComponentMixin {
  HorizonColorBandsComponent() : super(priority: 2);

  static const List<Map<String, dynamic>> _horizons = [
    {
      'id': 'O',
      'start': 0.0,
      'end': 0.05,
      'color1': Color(0xFF2D1F15),
      'color2': Color(0xFF3E2723),
    },
    {
      'id': 'A',
      'start': 0.05,
      'end': 0.28,
      'color1': Color(0xFF3E2723),
      'color2': Color(0xFF4E342E),
    },
    {
      'id': 'B',
      'start': 0.28,
      'end': 0.52,
      'color1': Color(0xFF5D4037),
      'color2': Color(0xFF795548),
    },
    {
      'id': 'C',
      'start': 0.52,
      'end': 0.75,
      'color1': Color(0xFF795548),
      'color2': Color(0xFF8D6E63),
    },
    {
      'id': 'C2',
      'start': 0.75,
      'end': 0.90,
      'color1': Color(0xFF8D6E63),
      'color2': Color(0xFF607D8B),
    },
    {
      'id': 'R',
      'start': 0.90,
      'end': 100.0,
      'color1': Color(0xFF455A64),
      'color2': Color(0xFF37474F),
    },
  ];

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;

    for (int i = 0; i < _horizons.length; i++) {
      final h = _horizons[i];
      final startY = surfaceY + (h['start'] as double) * soilHeight;
      final endY = surfaceY + (h['end'] as double) * soilHeight;
      final color1 = h['color1'] as Color;
      final color2 = h['color2'] as Color;

      final path = Path();
      if (i == 0) {
        path.moveTo(backgroundX, startY);
        path.lineTo(backgroundX + backgroundWidth, startY);
      } else {
        _addWavyLine(
          path,
          startY,
          backgroundX,
          backgroundWidth,
          zoom,
          isMoveTo: true,
          seed: i,
        );
      }
      path.lineTo(backgroundX + backgroundWidth, endY);
      _addWavyLine(
        path,
        endY,
        backgroundX,
        backgroundWidth,
        zoom,
        isMoveTo: false,
        reverse: true,
        seed: i + 1,
      );
      path.lineTo(backgroundX, startY);
      path.close();

      final gradient =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color1.withValues(alpha: 0.3),
              color2.withValues(alpha: 0.3),
            ],
          ).createShader(
            Rect.fromLTWH(backgroundX, startY, backgroundWidth, endY - startY),
          );

      canvas.drawPath(path, Paint()..shader = gradient);
    }
  }

  void _addWavyLine(
    Path path,
    double y,
    double xStart,
    double width,
    double zoom, {
    bool isMoveTo = false,
    bool reverse = false,
    int seed = 0,
  }) {
    final steps = (width / 20).toInt();
    for (int i = 0; i <= steps; i++) {
      final t = reverse ? (1.0 - i / steps) : (i / steps);
      final x = xStart + t * width;
      final wave =
          math.sin(x * 0.02 + seed * 1.5) * 5.0 +
          math.sin(x * 0.05 - seed * 0.8) * 2.0;
      final targetY = y + wave / zoom;
      if (i == 0 && isMoveTo) {
        path.moveTo(x, targetY);
      } else {
        path.lineTo(x, targetY);
      }
    }
  }
}
