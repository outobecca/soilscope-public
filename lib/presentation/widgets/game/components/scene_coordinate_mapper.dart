import 'package:flame/components.dart';
import '../../../../domain/models/plant.dart';

/// Shared coordinate transforms for root-system driven world positioning.
class SceneCoordinateMapper {

  static double mapRootX(double rootX, double worldWidth, {double baseX = 0.5}) {
    // baseX is the plant's anchor point [0-1] in the soil column.
    // rootX is the node's position relative to the plant center [0-1].
    
    // Distribute the plant bases more widely
    final double soilColumnX = worldWidth * 0.1 + baseX * worldWidth * 0.8;
    
    // Spread the roots relative to the base (Matched with AnimatedPlantComponent 0.45)
    return soilColumnX + (rootX - 0.5) * worldWidth * 0.45;
  }

  static double mapRootY(double rootZ, double surfaceY, double soilHeight) {
    return surfaceY + rootZ * soilHeight;
  }

  static Vector2 mapShootPosition(double baseX, double worldWidth, double surfaceY) {
    return Vector2(
      worldWidth * 0.1 + baseX * worldWidth * 0.8,
      surfaceY,
    );
  }

  static ({double x, double y}) mapRootNode(
    RootNode node,
    double worldWidth,
    double surfaceY,
    double soilHeight, {
    double baseX = 0.5,
  }) {
    return (
      x: mapRootX(node.x, worldWidth, baseX: baseX),
      y: mapRootY(node.z, surfaceY, soilHeight),
    );
  }

  /// Convenience: maps root X directly to world-space by including soilLeftX offset.
  /// Eliminates the repetitive `mapRootX(...) + soilLeftX` pattern across components.
  static double mapRootXWorld(
    double rootX,
    double worldWidth,
    double soilLeftX, {
    double baseX = 0.5,
  }) {
    return mapRootX(rootX, worldWidth, baseX: baseX) + soilLeftX;
  }

  /// Convenience: maps a RootNode to world-space Vector2 including soilLeftX offset.
  static Vector2 mapRootNodeWorld(
    RootNode node,
    double worldWidth,
    double surfaceY,
    double soilHeight,
    double soilLeftX, {
    double baseX = 0.5,
  }) {
    return Vector2(
      mapRootXWorld(node.x, worldWidth, soilLeftX, baseX: baseX),
      mapRootY(node.z, surfaceY, soilHeight),
    );
  }

  static double getShootScale(Plant plant, {double growthBoost = 0.0}) {
    // Strictly tied to biophysical height and biomass
    // Default height 1.0m maps to scale 1.0. 
    // Biomass provides secondary density/scale factor.
    final heightFactor = (plant.height * 0.8).clamp(0.1, 2.5);
    final biomassFactor = (plant.totalBiomass / 1000.0).clamp(0.0, 0.5);
    return heightFactor + biomassFactor + growthBoost;
  }

  static double plantVisualHeight(Plant plant, {double growthBoost = 0.0}) {
    // Unified base height (450.0) with scaling factor.
    return 450.0 * getShootScale(plant, growthBoost: growthBoost);
  }
}
