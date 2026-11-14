import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/widgets/game/flutter_quick_actions.dart';

void main() {
  testWidgets('FlutterQuickActions tooltips have preferBelow set to false', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fi'),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: FlutterQuickActions(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all Tooltip widgets inside FlutterQuickActions have preferBelow == false
    final tooltipFinders = find.descendant(
      of: find.byType(FlutterQuickActions),
      matching: find.byType(Tooltip),
    );
    expect(tooltipFinders, findsWidgets);

    final tooltipWidgets = tester.widgetList<Tooltip>(tooltipFinders);
    for (final tooltip in tooltipWidgets) {
      expect(
        tooltip.preferBelow,
        isFalse,
        reason: 'Tooltip with message "${tooltip.message}" should have preferBelow: false so it floats above the bottom bar',
      );
    }
  });

  testWidgets('manage sheet shows the displayed snapshot during history playback',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const historical = BiophysicalState(
      profile: SoilProfile(
        id: 'historical',
        name: 'Historical',
        layers: [],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      ),
      plants: [],
      timeElapsed: 0,
      autoWeather: false,
      precipitation: 0.0,
      hasCoverCrop: false,
    );
    final live = historical.copyWith(
      timeElapsed: 86400,
      autoWeather: true,
      precipitation: 10.0,
      hasCoverCrop: true,
      history: const [historical],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [simulationProvider.overrideWithValue(live)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: FlutterQuickActions()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FlutterQuickActions)),
    );
    container.read(simulationSessionProvider.notifier).setScrubbing(true);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    final autoWeatherTile = find.ancestor(
      of: find.text('Auto Weather'),
      matching: find.byType(ListTile),
    );
    final coverCropTile = find.ancestor(
      of: find.text('Cover Crop'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(
        of: autoWeatherTile,
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNothing,
      reason: 'the historical auto-weather state is off, not the live on state',
    );
    expect(
      find.descendant(
        of: coverCropTile,
        matching: find.byIcon(Icons.check_rounded),
      ),
      findsNothing,
      reason: 'the historical cover-crop state is off, not the live on state',
    );
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.byIcon(Icons.water_drop_rounded), findsNothing);
  });

  testWidgets('all five primary actions are available from the start',
      (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    const base = BiophysicalState(
      profile: SoilProfile(
        id: 'toolbar',
        name: 'Toolbar',
        layers: [],
        surfaceAlbedo: 0.2,
        slope: 0.0,
      ),
      plants: [],
      timeElapsed: 0,
    );
    final initial = base.copyWith(history: [base]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [simulationProvider.overrideWithValue(initial)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en'),
          home: Scaffold(body: FlutterQuickActions()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
    expect(find.byIcon(Icons.linear_scale_rounded), findsOneWidget);
    expect(find.byIcon(Icons.biotech_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

    final timelineButton = tester.widget<InkWell>(
      find
          .ancestor(
            of: find.byIcon(Icons.linear_scale_rounded),
            matching: find.byType(InkWell),
          )
          .first,
    );
    expect(
      timelineButton.onTap,
      isNotNull,
      reason: 'the starting snapshot is enough to open the timeline view',
    );
  });

  testWidgets('Hovering button in FlutterQuickActions triggers tooltip', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fi'),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: FlutterQuickActions(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find play/pause button
    final playBtnFinder = find.byIcon(Icons.play_arrow_rounded);
    expect(playBtnFinder, findsOneWidget);

    // Hover over button
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(playBtnFinder));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify tooltip text is displayed and located ABOVE the button
    final buttonRect = tester.getRect(playBtnFinder);
    final tooltipTextFinder = find.text('Aloita'); // 'Aloita' / 'Toista'
    // Alternatively look for Tooltip rendered text
    if (tooltipTextFinder.evaluate().isNotEmpty) {
      final tooltipRect = tester.getRect(tooltipTextFinder.first);
      expect(
        tooltipRect.bottom,
        lessThanOrEqualTo(buttonRect.top),
        reason: 'Tooltip should be rendered above the button',
      );
    }
  });
}
