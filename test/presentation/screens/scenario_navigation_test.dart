import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/screens/scenario_selection_screen.dart';

import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_profile.dart';

void main() {
  testWidgets('Tapping scenario navigates to simulation', (WidgetTester tester) async {
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
        child: const SoilScopeApp(),
      ),
    );

    // Wait for scenarios to load
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify we are on the start menu
    expect(find.byType(ScenarioSelectionScreen), findsOneWidget);

    // Find a scenario card or the "Open Scenario" button
    final listFinder = find.byType(Scrollable);
    if (listFinder.evaluate().isNotEmpty) {
      await tester.drag(listFinder, const Offset(0, -1000));
      await tester.pump(const Duration(seconds: 1));
    }
    
    final openButton = find.text('OPEN').first;
    expect(openButton, findsOneWidget);

    await tester.ensureVisible(openButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Tap it
    await tester.tap(openButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Now we should be on the MainSimulationScreen
    expect(find.byType(MainSimulationScreen), findsOneWidget);
  });
}
