import 'dart:math' as math;
import 'package:flame/components.dart';
import '../soil_scope_game.dart';

/// Mixin for tracking the diurnal (day/night) cycle.
mixin DiurnalActivityMixin on HasGameReference<SoilScopeGame> {
  
  /// Diurnal factor oscillating over time (0.2 rad/s ≈ 8.7-hr half period).
  double get diurnalPulse {
    final t = game.currentTime();
    return (0.3 + 0.7 * math.sin(t * 0.2)).clamp(0.1, 1.0);
  }

  /// Whether current visual clock corresponds to daylight.
  bool get isDaytime {
    final t = game.currentTime();
    return math.sin(t * 0.2) > 0;
  }

  /// Range [-1.0 (Midnight) to 1.0 (Noon)].
  double get solarElevation {
    final t = game.currentTime();
    return math.sin(t * 0.2);
  }
}
