/// The horizontal footprint represented by the soil profile.
///
/// Soil layers store volumetric and gravimetric concentrations, while water
/// and nutrient fluxes are expressed per unit area. Fixing the footprint at one
/// square metre makes those per-area quantities map to one explicit plot
/// instead of an implicit unit column. The plot is centred on the plant:
/// normalized x = 0.5 is the plant collar, 0.0 the left edge and 1.0 the right
/// edge.
class SimulationPlot {
  const SimulationPlot._();

  /// Width of the square plot [m].
  static const double sideM = 1.0;

  /// Horizontal footprint of the simulated soil column [m²].
  static const double areaM2 = sideM * sideM;

  /// Normalized horizontal position of the plant and plot centre.
  static const double centerNormalizedX = 0.5;

  /// Normalized horizontal bounds of the plot.
  static const double minNormalizedX = 0.0;
  static const double maxNormalizedX = 1.0;

  /// Converts a plot-normalized x position to a signed offset from the plant
  /// collar [m]. The left edge is -0.5 m and the right edge is +0.5 m.
  static double normalizedToMetres(double normalizedX) {
    return (clampNormalizedX(normalizedX) - centerNormalizedX) * sideM;
  }

  /// Converts a signed offset from the plant collar [m] to a plot-normalized x
  /// position, clamped to the plot bounds.
  static double metresToNormalized(double metresFromCenter) {
    return clampNormalizedX(centerNormalizedX + metresFromCenter / sideM);
  }

  /// Converts a horizontal distance [m] to plot-normalized width. Distances are
  /// not centred, so this must not apply the centre offset used by positions.
  static double distanceToNormalized(double metres) => metres / sideM;

  /// Converts a plot-normalized horizontal width to metres.
  static double normalizedToDistance(double normalized) => normalized * sideM;

  /// Water volume [m³] represented by a depth [m] applied to the whole plot.
  static double volumeForDepth(double depthM) => depthM * areaM2;

  /// Depth [m] represented by a water volume [m³] spread over the whole plot.
  static double depthForVolume(double volumeM3) => volumeM3 / areaM2;

  static double clampNormalizedX(double normalizedX) =>
      normalizedX.clamp(minNormalizedX, maxNormalizedX);
}
