import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import 'soil_component_mixin.dart';

/// Visualizes the thermal gradient and heat flux in the soil column.
/// Draws a subtle colored overlay representing temperature distribution.
class ThermalGradientComponent extends Component
    with HasGameReference<SoilScopeGame>, SoilComponentMixin {
  final Paint _gradientPaint = Paint();
  @override
  void render(Canvas canvas) {
    final state = game.ref.read(simulationProvider);
    if (state.profile.layers.isEmpty) return;

    final double zoom = game.camera.viewfinder.zoom;
    if (zoom < 1.2) return; // Only visible when zoomed in enough

    final double scaleY = calculateVerticalScale(game.activeProfileThickness);

    double currentY = surfaceY;

    for (final layer in state.profile.layers) {
      final double layerHeight = layer.thickness * scaleY;
      
      // Map temperature to color (K -> Color)
      // Reference: 273.15 (0C) is blueish, 298.15 (25C) is orange
      final tempC = layer.temperature - 273.15;
      final color = _getTemperatureColor(tempC);

      final paint = _gradientPaint
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.15),
          ],
        ).createShader(Rect.fromLTWH(backgroundX, currentY, backgroundWidth, layerHeight));

      drawFullWidthSoilRect(canvas, Rect.fromLTWH(0, currentY, 0, layerHeight), paint);
      currentY += layerHeight;
    }
  }

  Color _getTemperatureColor(double tempC) {
    if (tempC < 5) return Colors.blue;
    if (tempC < 15) return Colors.cyan;
    if (tempC < 25) return Colors.orange;
    return Colors.deepOrange;
  }
}
