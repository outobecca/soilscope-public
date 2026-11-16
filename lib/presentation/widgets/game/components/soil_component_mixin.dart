import 'dart:ui';
import 'package:flame/components.dart';
import '../soil_scope_game.dart';

/// Shared logic for components rendered within the soil-plant-atmosphere continuum.
/// Provides unified access to layout constants and coordinate mapping.
mixin SoilComponentMixin on HasGameReference<SoilScopeGame> {
  /// Width of the background paint: the visible world plus a margin. Drawing
  /// the old 16,000 px minimum built large off-screen gradients and wave paths
  /// every frame for no visual benefit.
  double get backgroundWidth {
    final viewportWidth =
        game.camera.viewport.size.x / game.camera.viewfinder.zoom;
    return (viewportWidth + 800).clamp(400.0, 100000.0);
  }

  /// The interactive simulation width (1,200px).
  double get simulationWidth => SoilScopeGame.simulationWidth;

  /// The horizontal start position for background elements, following the camera.
  double get backgroundX =>
      game.camera.viewfinder.position.x - backgroundWidth / 2;

  /// The horizontal start position for simulation elements.
  double get simulationX => game.soilLeftX;

  /// The vertical position of the soil surface.
  double get surfaceY => game.soilSurfaceY;

  /// The total height of the soil column.
  double get soilHeight => game.soilColumnHeight;

  /// The logical centre of the simulated one-square-metre plot.
  double get centerX => game.plotCenterX;

  /// Checks if a point is within the interactive simulation column.
  bool isInsideSimulation(Vector2 point) {
    return point.y >= surfaceY &&
        point.x >= simulationX &&
        point.x <= simulationX + simulationWidth;
  }

  /// Helper to draw a background rectangle covering the full visual width.
  void drawFullWidthSoilRect(Canvas canvas, Rect verticalBounds, Paint paint) {
    final rect = Rect.fromLTWH(
      backgroundX,
      verticalBounds.top,
      backgroundWidth,
      verticalBounds.height,
    );
    canvas.drawRect(rect, paint);
  }

  /// Helper to calculate the scale for depth-based rendering.
  double calculateVerticalScale(double totalThickness) {
    return soilHeight / (totalThickness > 0 ? totalThickness : 1.0);
  }
}
