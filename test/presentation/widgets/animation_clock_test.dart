import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/game/components/animation_clock.dart';
import 'package:soilscope/presentation/widgets/game/components/visual_seed.dart';

void main() {
  group('AnimationClock', () {
    test('clamps stalled frames and advances only while live', () {
      final clock = AnimationClock(maxFrameDelta: 0.05);

      clock.tick(
        2.0,
        isRunning: true,
        isScrubbing: false,
        inspectionPaused: false,
      );
      expect(clock.frameDt, closeTo(0.05, 1e-9));
      expect(clock.visualElapsed, closeTo(0.05, 1e-9));

      clock.tick(
        1 / 60,
        isRunning: false,
        isScrubbing: false,
        inspectionPaused: false,
      );
      expect(clock.mode, AnimationMode.paused);
      expect(clock.visualDt, 0);
      expect(clock.visualElapsed, closeTo(0.05, 1e-9));
      expect(clock.uiElapsed, closeTo(0.05, 1e-9));

      clock.tick(
        1 / 60,
        isRunning: false,
        isScrubbing: true,
        inspectionPaused: false,
      );
      expect(clock.mode, AnimationMode.history);
      expect(clock.visualDt, 0);
      expect(clock.uiElapsed, closeTo(0.05, 1e-9));

      clock.tick(
        1 / 60,
        isRunning: true,
        isScrubbing: false,
        inspectionPaused: true,
      );
      expect(clock.mode, AnimationMode.inspection);
      expect(clock.visualDt, 0);
      expect(clock.uiElapsed, closeTo(0.05, 1e-9));

      clock.tick(
        1 / 60,
        isRunning: true,
        isScrubbing: false,
        inspectionPaused: false,
        appVisible: false,
      );
      expect(clock.mode, AnimationMode.hidden);
      expect(clock.frameDt, 1 / 60);
    });

    test('ignores invalid deltas', () {
      final clock = AnimationClock();
      clock.tick(
        double.nan,
        isRunning: true,
        isScrubbing: false,
        inspectionPaused: false,
      );
      expect(clock.frameDt, 0);
      expect(clock.visualElapsed, 0);
    });
  });

  group('visual seeds', () {
    test('are stable for the same identities and distinct for others', () {
      expect(
        visualSeed(['scenario', 'plant-1', 'exudate']),
        visualSeed(['scenario', 'plant-1', 'exudate']),
      );
      expect(
        visualSeed(['scenario', 'plant-1', 'exudate']),
        isNot(visualSeed(['scenario', 'plant-2', 'exudate'])),
      );
    });

    test('produce repeatable random streams', () {
      final first = visualRandom(['scenario', 'weather']);
      final second = visualRandom(['scenario', 'weather']);
      expect(
        List.generate(8, (_) => first.nextInt(1000)),
        List.generate(8, (_) => second.nextInt(1000)),
      );
    });
  });
}
