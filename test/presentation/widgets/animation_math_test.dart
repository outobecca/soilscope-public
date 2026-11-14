import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/game/components/animation_math.dart';

void main() {
  group('dampTowards', () {
    test('converges at the same rate for different frame rates', () {
      var at30Fps = 0.0;
      var at120Fps = 0.0;
      for (var i = 0; i < 30; i++) {
        at30Fps = dampTowards(
          current: at30Fps,
          target: 10,
          rate: 2.0,
          dt: 1 / 30,
        );
      }
      for (var i = 0; i < 120; i++) {
        at120Fps = dampTowards(
          current: at120Fps,
          target: 10,
          rate: 2.0,
          dt: 1 / 120,
        );
      }

      expect(at30Fps, closeTo(at120Fps, 1e-9));
      expect(at30Fps, greaterThan(0));
    });

    test('ignores invalid deltas and reaches its target at large deltas', () {
      expect(dampTowards(current: 2, target: 8, rate: 4, dt: 0), 2);
      expect(dampTowards(current: 2, target: 8, rate: 4, dt: double.nan), 2);
      expect(
        dampTowards(current: 2, target: 8, rate: 4, dt: 100),
        closeTo(8, 1e-9),
      );
    });
  });

  group('RateAccumulator', () {
    test('carries fractional time between events', () {
      final accumulator = RateAccumulator();

      expect(accumulator.consume(0.3, 2.0), 0);
      expect(accumulator.consume(0.2, 2.0), 1);
      expect(accumulator.pending, closeTo(0.0, 1e-9));
    });

    test('does not release a burst after a long frame', () {
      final accumulator = RateAccumulator();

      expect(accumulator.consume(5.0, 10.0), 1);
      expect(accumulator.pending, closeTo(1.0, 1e-9));
      expect(accumulator.consume(1 / 60, 10.0), 1);
      expect(accumulator.pending, closeTo(1 / 6, 1e-9));
    });
  });
}
