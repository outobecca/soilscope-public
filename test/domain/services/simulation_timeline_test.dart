import 'package:flutter_test/flutter_test.dart';

import 'package:soilscope/domain/services/simulation_timeline.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';

void main() {
  group('simulation timeline', () {
    test('an entry is stored without a nested history', () {
      final state = ValidationReferenceRun.initialState();
      final timeline = SimulationTimeline();

      timeline.clearAndAdd(state.copyWith(history: [state]));

      expect(timeline.length, 1);
      expect(timeline.first.history, isEmpty);
      expect(timeline.entries.single.history, isEmpty);
    });

    test('the view is immutable and refreshes after an append', () {
      final timeline = SimulationTimeline();
      timeline.clearAndAdd(ValidationReferenceRun.initialState());

      expect(timeline.view, hasLength(1));
      expect(
        () => timeline.view.add(timeline.view.first),
        throwsUnsupportedError,
      );

      timeline.entries.add(
        timeline.first.copyWith(timeElapsed: timeline.first.timeElapsed + 1),
      );
      timeline.refresh();

      expect(timeline.view, hasLength(2));
      expect(
        timeline.view.last.timeElapsed,
        greaterThan(timeline.first.timeElapsed),
      );
    });

    test('replacing the timeline drops earlier entries', () {
      final timeline = SimulationTimeline();
      final first = ValidationReferenceRun.initialState();
      final second = first.copyWith(timeElapsed: 3600);

      timeline.clearAndAdd(first);
      timeline.clearAndAddAll([second, first]);

      expect(timeline.length, 2);
      expect(timeline.first.timeElapsed, 3600);
      expect(timeline.last.timeElapsed, 0);
      expect(timeline.view, [second, first]);
    });

    test('an empty timeline reports itself', () {
      final timeline = SimulationTimeline();

      expect(timeline.isEmpty, isTrue);
      expect(timeline.isNotEmpty, isFalse);
      expect(timeline.view, isEmpty);
    });
  });
}
