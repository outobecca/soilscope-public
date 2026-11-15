import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/widgets/controls/timeline_slider_widget.dart';

const _profile = SoilProfile(
  id: 'timeline-test',
  name: 'Timeline test',
  layers: [],
  surfaceAlbedo: 0.2,
  slope: 0.0,
);

BiophysicalState _state(double time) =>
    BiophysicalState(profile: _profile, plants: const [], timeElapsed: time);

void main() {
  final history = [
    _state(0),
    _state(25200), // Day 1, 07:00
    _state(29700), // Day 1, 08:15
  ];
  Future<ProviderContainer> pumpTimeline(
    WidgetTester tester, {
    required double width,
    required double viewTime,
    List<BiophysicalState>? snapshots,
  }) async {
    final timeline = snapshots ?? history;
    final state = _state(timeline.last.timeElapsed).copyWith(history: timeline);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [simulationProvider.overrideWithValue(state)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: const TimelineSliderWidget(),
              ),
            ),
          ),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TimelineSliderWidget)),
    );
    container.read(simulationSessionProvider.notifier).scrubTo(viewTime);
    await tester.pump();
    return container;
  }

  testWidgets('timeline label follows the snapped history snapshot', (
    tester,
  ) async {
    final container = await pumpTimeline(
      tester,
      width: 520,
      viewTime: 26100, // 07:15 between the 07:00 and 08:15 snapshots
    );

    expect(find.text('Day 1 · 07:00'), findsOneWidget);
    expect(find.text('Day 1 · 07:15'), findsNothing);

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.min, 0);
    expect(slider.max, 2);
    expect(slider.value, 1, reason: 'the thumb sits on the displayed snapshot');

    slider.onChanged!(1.8); // rounds to the third snapshot, 08:15
    await tester.pumpAndSettle();

    expect(container.read(simulationSessionProvider).viewTime, 29700);
    expect(find.text('Day 1 · 08:15'), findsOneWidget);
  });

  testWidgets('short timelines show seconds so early scrubbing is visible', (
    tester,
  ) async {
    await pumpTimeline(
      tester,
      width: 520,
      viewTime: 2,
      snapshots: [_state(0), _state(2)],
    );

    expect(find.text('Day 1 · 00:00:02'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
  });

  testWidgets('timeline view opens at the starting snapshot without a range', (
    tester,
  ) async {
    await pumpTimeline(tester, width: 520, viewTime: 0, snapshots: [_state(0)]);

    expect(find.text('Day 1 · 00:00:00'), findsOneWidget);
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.onChanged, isNull);
    expect(slider.max, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('timeline label and slider fit a narrow screen', (tester) async {
    final longHistory = [_state(0), _state(123 * 86400 + 23 * 3600 + 59 * 60)];
    final latest = longHistory.last.timeElapsed;

    await pumpTimeline(
      tester,
      width: 320,
      viewTime: latest,
      snapshots: longHistory,
    );

    expect(find.text('Day 124 · 23:59'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
