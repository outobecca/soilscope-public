import 'dart:math' as math;
import 'package:flame/components.dart';

/// Mixin to provide a decoupled visual time scale for micro-level animations.
/// Prevents chaotic movement when the global simulation time is highly accelerated.
mixin VisualTimeMixin on Component {
  /// Calculates a perceptual delta time that compresses large simulation steps
  /// into human-observable visual updates, while preserving directional intent.
  double getPerceptualDt(double dt) {
    // 60 FPS baseline (approx 16.6ms)
    const double baseDt = 0.01667;
    
    // If simulation is running at normal or slow speed, use the real delta
    if (dt <= baseDt) return dt;
    
    // For accelerated simulation (macroscopic growth phases),
    // we use a non-linear compression (square root) to keep movement calm.
    // Example mappings (at 60fps base):
    // dt = 0.016 (1x speed) -> 0.016 (1x visual)
    // dt = 0.160 (10x speed) -> ~0.035 (2x visual)
    // dt = 1.600 (100x speed) -> ~0.078 (4.5x visual)
    return baseDt + math.sqrt(dt - baseDt) * 0.05;
  }
}
