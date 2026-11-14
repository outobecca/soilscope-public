import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/presentation/screens/scenario_selection_screen.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ScenarioSelectionScreen displays scenario titles', (
    WidgetTester tester,
  ) async {
    final mockScenario = Scenario(
      id: 'test_scenario',
      title: 'Test Scenario',
      description: 'Test Description',
      initialProfile: const SoilProfile(
        id: 'test',
        name: 'Test',
        layers: [],
        surfaceAlbedo: 0.2,
        slope: 0.05,
      ),
      weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scenariosProvider.overrideWith((ref) => [mockScenario]),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: ScenarioSelectionScreen(),
        ),
      ),
    );

    // Initial state (loading)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the future to complete
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Now should find scenario title, scroll if needed
    final listFinder = find.byType(ListView);
    if (listFinder.evaluate().isNotEmpty) {
      await tester.drag(listFinder, const Offset(0, -1000));
      await tester.pump(const Duration(seconds: 1));
    }
    
    expect(find.text('Test Scenario'), findsWidgets);
  });

  testWidgets('first-run gesture guide lays out and can be dismissed on a phone',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scenariosProvider.overrideWith((ref) => [
                Scenario(
                  id: 'test_scenario',
                  title: 'Test Scenario',
                  description: 'Test Description',
                  initialProfile: const SoilProfile(
                    id: 'test',
                    name: 'Test',
                    layers: [],
                    surfaceAlbedo: 0.2,
                    slope: 0.05,
                  ),
                  weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
                ),
              ]),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en')],
          home: ScenarioSelectionScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Welcome to SoilScope'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Welcome to SoilScope'), findsNothing);
  });
}
