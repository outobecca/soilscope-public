import 'dart:math' as math;
import 'dart:typed_data';

/// Shared hit-test sizing for interactive canvas entities.
///
/// World-space hit radii grow with camera zoom, so a fixed world radius is
/// either hard to hit when zoomed out or absurdly large when zoomed in. These
/// helpers keep tolerances close to a stable on-screen size while still
/// covering the entity's drawn footprint.
class CanvasHitTesting {
  const CanvasHitTesting._();

  /// Converts a comfortable on-screen radius into world units.
  ///
  /// [zoom] is the camera zoom, [screenRadius] the desired mouse/touch radius
  /// in logical pixels, and [visualWorldRadius] the entity's drawn radius in
  /// world units. The result is clamped so neither extreme zoom makes picking
  /// unusable.
  static double worldRadius({
    required double zoom,
    double screenRadius = 24.0,
    double visualWorldRadius = 0.0,
    double minWorld = 3.0,
    double maxWorld = 40.0,
  }) {
    final safeZoom = zoom.isFinite && zoom > 0 ? zoom : 1.0;
    final screenWorld = screenRadius / safeZoom;
    final radius = math.max(visualWorldRadius, screenWorld);
    return radius.clamp(minWorld, maxWorld).toDouble();
  }

  /// Returns the nearest point within [radius] from [origin].
  ///
  /// Returns null when every candidate is outside the hit radius, and chooses
  /// the closest candidate when several overlap.
  static int? nearestIndex({
    required List<num> xs,
    required List<num> ys,
    required double x,
    required double y,
    required double radius,
    int stride = 1,
    int offset = 0,
  }) {
    final radiusSq = radius * radius;
    double bestDistanceSq = radiusSq;
    int? bestIndex;

    for (int i = offset; i < xs.length && i < ys.length; i += stride) {
      final dx = x - xs[i];
      final dy = y - ys[i];
      final distanceSq = dx * dx + dy * dy;
      if (distanceSq <= bestDistanceSq) {
        bestDistanceSq = distanceSq;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  /// Nearest packed particle record in the isolate's Float32List layout.
  ///
  /// Records store the id at the first slot, the x/y position at
  /// [xOffset]/[yOffset], and [stride] slots between records.
  static int? nearestPackedIndex({
    required Float32List data,
    required double x,
    required double y,
    required double radius,
    int stride = 10,
    int xOffset = 1,
    int yOffset = 2,
  }) {
    if (stride <= 0) return null;
    final radiusSq = radius * radius;
    double bestDistanceSq = radiusSq;
    int? bestIndex;

    for (int i = 0; i + yOffset < data.length; i += stride) {
      final dx = x - data[i + xOffset];
      final dy = y - data[i + yOffset];
      final distanceSq = dx * dx + dy * dy;
      if (distanceSq <= bestDistanceSq) {
        bestDistanceSq = distanceSq;
        bestIndex = i;
      }
    }
    return bestIndex;
  }
}
