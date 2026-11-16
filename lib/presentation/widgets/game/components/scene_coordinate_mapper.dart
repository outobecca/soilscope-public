import 'package:flame/components.dart';
import '../../../../domain/models/plant.dart';
import '../../../../domain/models/simulation_plot.dart';

/// Shared coordinate transforms for the one-square-metre plot.
///
/// The simulation column renders the plot centred on the plant. Horizontal
/// root positions are normalized to the plot (0 = left edge, 0.5 = plant
/// collar, 1 = right edge), so the solver and every visual component use the
/// same extent and centre.
class SceneCoordinateMapper {
  /// Fraction of the simulation column occupied by the 1 m² plot. The
  /// remaining margin keeps the plot readable inside the wider visual column.
  static const double plotWidthFraction = 0.45;

  /// World-space width of the 1 m² plot [px].
  static double plotWidth(double worldWidth) =>
      worldWidth * plotWidthFraction;

  /// World-space x coordinate of the plot centre and plant collar [px].
  static double plotCenterX(double worldWidth) =>
      worldWidth * SimulationPlot.centerNormalizedX;

  /// Maps a plot-normalized root x position to the simulation column [px].
  static double mapRootX(double rootX, double worldWidth) {
    final plotLeft = plotCenterX(worldWidth) - plotWidth(worldWidth) / 2.0;
    return plotLeft +
        SimulationPlot.clampNormalizedX(rootX) * plotWidth(worldWidth);
  }

  /// Horizontal offset of a root node from the plant collar [px].
  ///
  /// Used by the plant component, which positions itself at the collar, so
  /// its local root drawing and the world-space mapper cannot drift apart.
  static double rootOffsetX(
    double rootX,
    double collarX,
    double worldWidth,
  ) {
    return (SimulationPlot.clampNormalizedX(rootX) -
            SimulationPlot.clampNormalizedX(collarX)) *
        plotWidth(worldWidth);
  }

  static double mapRootY(double rootZ, double surfaceY, double soilHeight) {
    return surfaceY + rootZ * soilHeight;
  }

  static Vector2 mapShootPosition(double worldWidth, double surfaceY) {
    return Vector2(plotCenterX(worldWidth), surfaceY);
  }

  static ({double x, double y}) mapRootNode(
    RootNode node,
    double worldWidth,
    double surfaceY,
    double soilHeight,
  ) {
    return (
      x: mapRootX(node.x, worldWidth),
      y: mapRootY(node.z, surfaceY, soilHeight),
    );
  }

  /// Convenience: maps root X directly to world-space by including soilLeftX offset.
  /// Eliminates the repetitive `mapRootX(...) + soilLeftX` pattern across components.
  static double mapRootXWorld(
    double rootX,
    double worldWidth,
    double soilLeftX,
  ) {
    return mapRootX(rootX, worldWidth) + soilLeftX;
  }

  /// Convenience: maps a RootNode to world-space Vector2 including soilLeftX offset.
  static Vector2 mapRootNodeWorld(
    RootNode node,
    double worldWidth,
    double surfaceY,
    double soilHeight,
    double soilLeftX,
  ) {
    return Vector2(
      mapRootXWorld(node.x, worldWidth, soilLeftX),
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
