import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/game/components/microbe_motility.dart';

void main() {
  group('MicrobeMotility rhizosphere envelope', () {
    test('keeps a target inside the rhizosphere unchanged', () {
      final root = Vector2(50, 50);
      final desired = Vector2(60, 65);

      expect(
        identical(MicrobeMotility.clampToRhizosphere(root, desired), desired),
        isTrue,
      );
    });

    test('pulls a distant target back to the rhizosphere edge', () {
      final root = Vector2(100, 100);
      final clamped = MicrobeMotility.clampToRhizosphere(
        root,
        Vector2(400, 100),
      );

      expect(
        clamped.distanceTo(root),
        closeTo(MicrobeMotility.rhizosphereRadius, 1e-6),
      );
      expect(clamped.x, greaterThan(root.x));
      expect(clamped.y, closeTo(root.y, 1e-6));
    });

    test('uses a centimetre-scale leash and sensing range', () {
      expect(MicrobeMotility.rhizosphereRadius, lessThanOrEqualTo(40.0));
      expect(MicrobeMotility.sensingRadiusHotspot, lessThanOrEqualTo(60.0));
      expect(MicrobeMotility.sensingRadiusExudate, lessThanOrEqualTo(80.0));
    });
  });

  group('MicrobeMotility population and spawning', () {
    test('visible cluster count follows biomass and stays capped', () {
      expect(
        MicrobeMotility.visibleClusterCount(0),
        MicrobeMotility.minVisibleClusters,
      );
      expect(MicrobeMotility.visibleClusterCount(1), 5);
      expect(MicrobeMotility.visibleClusterCount(2), 10);
      expect(
        MicrobeMotility.visibleClusterCount(100),
        MicrobeMotility.maxVisibleClusters,
      );
    });

    test('spawn offsets stay inside the rhizosphere envelope', () {
      final random = math.Random(7);
      for (var i = 0; i < 200; i++) {
        final offset = MicrobeMotility.spawnOffset(random);
        expect(
          offset.length,
          inInclusiveRange(
            MicrobeMotility.spawnOffsetMin * MicrobeMotility.spawnVerticalScale,
            MicrobeMotility.spawnOffsetMax,
          ),
        );
        expect(
          offset.y.abs(),
          lessThanOrEqualTo(
            MicrobeMotility.spawnOffsetMax * MicrobeMotility.spawnVerticalScale,
          ),
        );
      }
    });

    test('retarget delays stay inside the configured window', () {
      final random = math.Random(11);
      for (var i = 0; i < 200; i++) {
        expect(
          MicrobeMotility.retargetDelay(random),
          inInclusiveRange(
            MicrobeMotility.retargetMinSeconds,
            MicrobeMotility.retargetMaxSeconds,
          ),
        );
      }
    });
  });

  group('MicrobeMotility transport', () {
    test('passive drift follows flux direction and stays bounded', () {
      expect(MicrobeMotility.passiveDrift(0), 0);
      expect(MicrobeMotility.passiveDrift(1e-6), closeTo(0.2, 1e-9));
      expect(MicrobeMotility.passiveDrift(-1e-6), closeTo(-0.2, 1e-9));
      expect(
        MicrobeMotility.passiveDrift(1.0),
        MicrobeMotility.passiveDriftLimit,
      );
      expect(
        MicrobeMotility.passiveDrift(-1.0),
        -MicrobeMotility.passiveDriftLimit,
      );
      expect(MicrobeMotility.passiveDrift(double.nan), 0);
    });

    test('active speed is slower while feeding and temperature-bounded', () {
      final cold = MicrobeMotility.speedLimit(
        feeding: false,
        activityFactor: 0.1,
      );
      final warm = MicrobeMotility.speedLimit(
        feeding: false,
        activityFactor: 4.0,
      );
      final feeding = MicrobeMotility.speedLimit(
        feeding: true,
        activityFactor: 4.0,
      );

      expect(cold, closeTo(MicrobeMotility.seekingSpeed * 0.6, 1e-9));
      expect(warm, closeTo(MicrobeMotility.seekingSpeed * 1.3, 1e-9));
      expect(feeding, lessThan(warm));
      expect(MicrobeMotility.seekingSpeed, lessThanOrEqualTo(8.0));
    });
  });
}
