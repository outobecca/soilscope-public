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
      'end': 1.0,
      'color1': Color(0xFF455A64),
      'color2': Color(0xFF37474F),
    },
  ];

  @override
  void render(Canvas canvas) {
    if (soilHeight <= 0) return;

    // One full-column gradient with a stop pair per horizon replaces six
    // full-width wavy paths and six separate shaders per frame. The horizon
    // depths are exact fractions of the column, so the simplified boundary is
    // also more faithful to the profile than the decorative waves were.
    final colors = <Color>[];
    final stops = <double>[];
    for (final h in _horizons) {
      colors
        ..add((h['color1'] as Color).withValues(alpha: 0.3))
        ..add((h['color2'] as Color).withValues(alpha: 0.3));
      stops
        ..add((h['start'] as double).clamp(0.0, 1.0))
        ..add((h['end'] as double).clamp(0.0, 1.0));
    }

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
      stops: stops,
    ).createShader(
      Rect.fromLTWH(backgroundX, surfaceY, backgroundWidth, soilHeight),
    );

    drawFullWidthSoilRect(
      canvas,
      Rect.fromLTWH(0, surfaceY, 0, soilHeight),
      Paint()..shader = gradient,
    );
  }
}
