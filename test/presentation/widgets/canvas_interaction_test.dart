import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/animated_plant_component.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

class _Harness {
  const _Harness({
    required this.container,
    required this.game,
    required this.topLeft,
  });

  final ProviderContainer container;
  final SoilScopeGame game;
  final Offset topLeft;

  Offset screenOf(PositionComponent component) {
    final screen = game.worldToScreen(
      component.absolutePositionOf(component.size / 2),
    );
    return topLeft + Offset(screen.x, screen.y);
  }

  Offset screenOfWorld(Vector2 world) {
    final screen = game.worldToScreen(world);
    return topLeft + Offset(screen.x, screen.y);
  }
}

Future<_Harness> _pumpSimulation(
  WidgetTester tester, {
  bool withHotspot = false,
}) async {
  tester.view.physicalSize = const Size(1024, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'gesture_intro_seen_v1': true,
    'soilscope_onboarding_completed_v1': true,
  });

  final scenario = _scenario(withHotspot: withHotspot);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scenariosProvider.overrideWith((ref) => [scenario]),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: MainSimulationScreen(scenarioId: scenario.id),
      ),
    ),
  );
  await tester.pump();

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MainSimulationScreen)),
    listen: false,
  );
  await _pumpUntil(tester, () {
    final state = container.read(simulationProvider);
    final game = container.read(soilScopeGameProviderProvider);
    return state.isRunning && game != null && game.children.isNotEmpty;
  });

  final gameFinder = find.byWidgetPredicate((widget) => widget is GameWidget);
  expect(gameFinder, findsOneWidget);
  final game = tester.widget<GameWidget>(gameFinder).game as SoilScopeGame;
  await _pumpUntil(
    tester,
    () =>
        game.world.descendants().whereType<AnimatedPlantComponent>().isNotEmpty,
  );
  return _Harness(
    container: container,
    game: game,
    topLeft: tester.getTopLeft(gameFinder),
  );
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var frame = 0; frame < 160; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
    if (condition()) return;
  }
  fail('the canvas did not reach the expected state');
}

void main() {
  testWidgets('layer, shoot and root taps select their canvas targets', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;
    final container = harness.container;
    final l10n = lookupAppLocalizations(const Locale('en'));

    await tester.tapAt(
      harness.screenOfWorld(
        Vector2(game.soilLeftX + 300, game.soilSurfaceY + 70),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      container.read(simulationSessionProvider).selectedLayerId,
      'topsoil',
    );
    expect(container.read(uIStateProvider)?.title, 'TOPSOIL');

    final plant = game.world
        .descendants()
        .whereType<AnimatedPlantComponent>()
        .first;
    await tester.tapAt(
      harness.screenOfWorld(plant.absolutePositionOf(Vector2(0, -100))),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      container.read(uIStateProvider)?.title,
      l10n.plantTitle.toUpperCase(),
    );

    final plantData = container.read(simulationProvider).plants.first;
    final collar = plantData.rootSystem.first;
    final root = plantData.rootSystem.firstWhere(
      (node) => node.parentIndex != null,
      orElse: () => plantData.rootSystem.last,
    );
    final rootLocal = Vector2(
      (root.x - collar.x) * SoilScopeGame.soilColumnWidth * 0.45,
      ((root.z - collar.z) * game.soilColumnHeight).clamp(
        0.0,
        game.soilColumnHeight,
      ),
    );
    await tester.tapAt(
      harness.screenOfWorld(plant.absolutePositionOf(rootLocal)),
    );
    await tester.pump(const Duration(milliseconds: 50));

    final rootInfo = container.read(uIStateProvider);
    expect(rootInfo?.isPinned, isTrue);
    expect(
      rootInfo?.title,
      anyOf([
        l10n.carrotTaprootTitle.toUpperCase(),
        l10n.fineRootTitle.toUpperCase(),
      ]),
    );
  });

  testWidgets('rhizosphere hotspots select their own inspection card', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester, withHotspot: true);
    final game = harness.game;
    final container = harness.container;
    final l10n = lookupAppLocalizations(const Locale('en'));

    await _pumpUntil(
      tester,
      () => game.world
          .descendants()
          .whereType<RhizosphereHotspotComponent>()
          .isNotEmpty,
    );
    final hotspot = game.world
        .descendants()
        .whereType<RhizosphereHotspotComponent>()
        .first;
    await tester.tapAt(harness.screenOf(hotspot));
    await tester.pump(const Duration(milliseconds: 50));

    final info = container.read(uIStateProvider);
    expect(info?.isPinned, isTrue);
    expect(info?.title, l10n.rhizosphere.toUpperCase());
    expect(info?.sourceId, startsWith('rhizosphere-'));
  });
}

Scenario _scenario({required bool withHotspot}) {
  return Scenario(
    id: 'canvas_interaction',
    title: 'Canvas Interaction',
    description: 'A deterministic layer for canvas interaction tests.',
    initialProfile: SoilProfile(
      id: 'canvas',
      name: 'Canvas',
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
          hotspots: withHotspot
              ? const [
                  RhizosphereHotspot(
                    id: 'rhizosphere-test',
                    x: 0.25,
                    z: 0.5,
                    intensity: 0.8,
                  ),
                ]
              : const [],
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.05,
    ),
    weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
  );
}
