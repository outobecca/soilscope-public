import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/presentation/screens/scenario_selection_screen.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
}
