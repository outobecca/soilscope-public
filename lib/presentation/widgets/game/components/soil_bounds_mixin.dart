import 'dart:ui';
import 'package:flame/components.dart';
import 'soil_component_mixin.dart';

/// Mixin for elements that are strictly bound to the physical margins of the soil.
mixin SoilBoundsMixin on SoilComponentMixin {
  
  /// Bounding rectangle for the soil column area.
  Rect get soilBounds => Rect.fromLTWH(
        simulationX,
        surfaceY,
        simulationWidth,
        soilHeight,
      );

  /// Keeps a component's position firmly within the soil column.
  Vector2 clampToSoilColumn(Vector2 pos, {double padding = 10.0}) {
    return Vector2(
      pos.x.clamp(
        simulationX + padding,
        simulationX + simulationWidth - padding,
      ),
      pos.y.clamp(
        surfaceY + padding,
        surfaceY + soilHeight - padding,
      ),
    );
  }

  /// Verifies if coordinates sit in standard soil bounds.
  bool isInsideSoil(Vector2 pos) {
    return pos.y >= surfaceY &&
        pos.y <= surfaceY + soilHeight &&
        pos.x >= simulationX &&
        pos.x <= simulationX + simulationWidth;
  }
}
