import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/screens/scenario_selection_screen.dart';

/// Visual regression coverage for the first screen users see. The firmware
/// layout is exercised in responsive_layout_test; these goldens catch drifted
/// spacing, card composition and header treatment at both tiers.
void main() {
  for (final size in const [Size(390, 844), Size(1024, 768)]) {
    testWidgets('scenario selection golden at ${size.width.toInt()}', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({'gesture_intro_seen_v1': true});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            scenariosProvider.overrideWith((ref) => [_goldenScenario]),
          ],
          child: const SoilScopeApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ScenarioSelectionScreen), findsOneWidget);
      await expectLater(
        find.byType(ScenarioSelectionScreen),
        matchesGoldenFile(
          'goldens/scenario_selection_${size.width.toInt()}.png',
        ),
      );
    });
  }
}

final Scenario _goldenScenario = Scenario(
  id: 'golden',
  title: 'Temperate Loam',
  description: 'A balanced reference soil for the golden screen.',
  initialProfile: const SoilProfile(
    id: 'golden',
    name: 'Loam',
    layers: [
      SoilLayer(
        id: 'topsoil',
        depth: 0.0,
        thickness: 0.3,
        kSat: 1e-5,
        porosity: 0.45,
        thetaR: 0.05,
        vgAlpha: 2.0,
        vgN: 1.5,
        bulkDensity: 1200.0,
        waterContent: 0.25,
        temperature: 293.15,
        heatCapacity: 2.4e6,
        ph: 6.5,
        ec: 0.2,
        redoxPotential: 250.0,
        nitrateContent: 10.0,
        ammoniumContent: 5.0,
        phosphateContent: 3.0,
        microbialBiomass: 200.0,
        epsContent: 10.0,
        fungalHyphaeDensity: 20.0,
        necromass: 100.0,
        organicCarbon: 12000.0,
        particulateOrganicMatter: 6000.0,
        mineralAssociatedOrganicMatter: 6000.0,
        nitrogenContent: 1000.0,
        name: 'Topsoil',
      ),
    ],
    surfaceAlbedo: 0.2,
    slope: 0.05,
  ),
  weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
);
