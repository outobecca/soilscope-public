import 'dart:math' as math;

/// Frame-rate independent exponential approach.
///
/// A fixed per-frame lerp changes speed with the display refresh rate. This
/// helper converts a per-second response rate into the exact fraction of the
/// remaining distance that should be covered in [dt].
double dampTowards({
  required double current,
  required double target,
  required double rate,
  required double dt,
}) {
  if (!current.isFinite) return target;
  if (!target.isFinite) return current;
  if (!dt.isFinite || dt <= 0) return current;
  if (!rate.isFinite || rate <= 0) return current;

  final fraction = 1.0 - math.exp(-rate * dt);
  return current + (target - current) * fraction.clamp(0.0, 1.0);
}

/// Converts a per-second event rate into discrete events without losing
/// fractional time. It defaults to at most one event per frame so a delayed
/// frame cannot produce a visual burst.
class RateAccumulator {
  double _budget = 0.0;

  double get pending => _budget;

  int consume(double dt, double rate, {int maxSteps = 1}) {
    if (!dt.isFinite || dt <= 0) return 0;
    if (!rate.isFinite || rate <= 0) return 0;

    // Keep at most two pending events. A long frame should not leave a large
    // backlog that keeps firing on every subsequent frame.
    _budget = (_budget + dt * rate).clamp(0.0, 2.0);
    if (_budget < 1.0) return 0;

    final steps = math.min(_budget.floor(), maxSteps.clamp(1, 8));
    _budget -= steps;
    return steps;
  }
}
