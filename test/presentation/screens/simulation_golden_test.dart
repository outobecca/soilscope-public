import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';

Future<ProviderContainer> _pumpSimulation(
  WidgetTester tester,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.binding.platformDispatcher.defaultRouteNameTestValue =
      '/simulation/golden';
  addTearDown(tester.binding.platformDispatcher.clearDefaultRouteNameTestValue);
  SharedPreferences.setMockInitialValues({
    'gesture_intro_seen_v1': true,
    'soilscope_onboarding_completed_v1': true,
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scenariosProvider.overrideWith((ref) => [_goldenScenario]),
      ],
      child: const SoilScopeApp(),
    ),
  );
  await tester.pump();

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MainSimulationScreen)),
    listen: false,
  );
  await _pumpUntil(
    tester,
    () =>
        container.read(simulationProvider).isRunning &&
        container.read(soilScopeGameProviderProvider)?.children.isNotEmpty ==
            true,
  );
  return container;
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var frame = 0; frame < 160; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
    if (condition()) return;
  }
  fail('the simulation screen did not become ready');
}

void main() {
  for (final size in const [Size(390, 844), Size(1024, 768)]) {
    testWidgets('simulation screen golden at ${size.width.toInt()}', (
      tester,
    ) async {
      final container = await _pumpSimulation(tester, size);
      container.read(simulationProvider.notifier).stop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(MainSimulationScreen),
        matchesGoldenFile('goldens/simulation_${size.width.toInt()}.png'),
      );
    });
  }

  testWidgets('simulation controls and HUD expose semantics', (tester) async {
    final handle = tester.ensureSemantics();
    try {
      await _pumpSimulation(tester, const Size(1280, 720));

      expect(find.bySemanticsLabel(RegExp('Pause|Play')), findsWidgets);
      expect(find.bySemanticsLabel('Quick actions'), findsWidgets);
      expect(find.bySemanticsLabel('Soil Structure'), findsWidgets);
    } finally {
      handle.dispose();
    }
  });
}

final Scenario _goldenScenario = Scenario(
  id: 'golden',
  title: 'Temperate Loam',
  description: 'A balanced reference soil for the simulation golden.',
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
