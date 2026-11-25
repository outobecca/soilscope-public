import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:soilscope/presentation/widgets/game/components/animated_plant_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/ion_component.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

/// Lifecycle coverage for the sub-component sync on [SoilLayerComponent].
///
/// These assert observable component behaviour rather than the cache fields:
/// the layer must not accumulate duplicate technical nodes or rhizosphere
/// markers, must follow hotspot and geometry changes, and must clear ions when
/// the canvas leaves detail zoom.
class _Harness {
  const _Harness({
    required this.game,
    required this.container,
    required this.layer,
  });

  final SoilScopeGame game;
  final ProviderContainer container;
  final SoilLayerComponent layer;

  List<ExpandableHotspotNode> techNodes() => game.technicalHotspotLayer.children
      .whereType<ExpandableHotspotNode>()
      .where((node) => node.layerId == layer.layerId)
      .toList();

  List<RhizosphereHotspotComponent> rhizosphere() =>
      layer.children.whereType<RhizosphereHotspotComponent>().toList();

  List<IonComponent> ions() =>
      layer.children.whereType<IonComponent>().toList();
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

Future<_Harness> _pumpSimulation(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1024, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'gesture_intro_seen_v1': true,
    'soilscope_onboarding_completed_v1': true,
  });

  final scenario = _scenario();
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

  final layer = game.world.children.whereType<SoilLayerComponent>().first;
  // The technical nodes are spawned by the scene sync; wait for that pass.
  await _pumpUntil(tester, () {
    layer.triggerSubComponentSync();
    return game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .isNotEmpty;
  });

  return _Harness(game: game, container: container, layer: layer);
}

void main() {
  testWidgets(
    'repeated syncs do not duplicate technical or rhizosphere nodes',
    (tester) async {
      final harness = await _pumpSimulation(tester);
      for (var i = 0; i < 12; i++) {
        harness.layer.triggerSubComponentSync();
      }
      await tester.pump();

      final techNodes = harness.techNodes();
      expect(techNodes, isNotEmpty);
      expect(techNodes.map((node) => node.layerId).toSet(), {
        harness.layer.layerId,
      });
      expect(
        techNodes.map(identityHashCode).toSet().length,
        techNodes.length,
        reason: 'the same node instance must not be added twice',
      );

      final rhizosphere = harness.rhizosphere();
      expect(rhizosphere.map((h) => h.hotspotId).toList(), ['rhs-1']);
      expect(rhizosphere, hasLength(1));
    },
  );

  testWidgets('rhizosphere markers follow hotspot additions and removals', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final state = harness.container.read(simulationProvider);
    final modelLayer = state.profile.layers.firstWhere(
      (layer) => layer.id == harness.layer.layerId,
    );

    harness.layer.debugHandleLayerUpdate(
      modelLayer.copyWith(
        hotspots: const [
          RhizosphereHotspot(id: 'rhs-1', x: 0.25, z: 0.5, intensity: 0.8),
          RhizosphereHotspot(id: 'rhs-2', x: 0.7, z: 0.3, intensity: 0.4),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 32));

    expect(harness.rhizosphere().map((h) => h.hotspotId).toSet(), {
      'rhs-1',
      'rhs-2',
    });
    expect(harness.rhizosphere(), hasLength(2));

    final removed = harness.rhizosphere().firstWhere(
      (h) => h.hotspotId == 'rhs-1',
    );

    harness.layer.debugHandleLayerUpdate(
      modelLayer.copyWith(
        hotspots: const [
          RhizosphereHotspot(id: 'rhs-2', x: 0.7, z: 0.3, intensity: 0.4),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 32));

    expect(harness.rhizosphere().map((h) => h.hotspotId).toList(), ['rhs-2']);
    expect(
      removed.isMounted || removed.isRemoving,
      isFalse,
      reason: 'a hotspot removed from the model must leave the tree',
    );
  });

  testWidgets('technical nodes re-anchor when the layer geometry changes', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final nodes = harness.techNodes();
    expect(nodes, isNotEmpty);

    void expectAnchored(Vector2 position, Vector2 size) {
      for (final node in nodes) {
        expect(
          node.position.x,
          closeTo(position.x + node.layerAnchor.x * size.x, 1e-4),
        );
        expect(
          node.position.y,
          closeTo(position.y + node.layerAnchor.y * size.y, 1e-4),
        );
      }
    }

    harness.layer.updateLayerRect(Vector2(40, 60), Vector2(420, 180));
    await tester.pump();
    expectAnchored(Vector2(40, 60), Vector2(420, 180));

    // A second change must move them again: a stale geometry stamp would keep
    // the nodes at their first position.
    harness.layer.updateLayerRect(Vector2(10, 25), Vector2(300, 120));
    await tester.pump();
    expectAnchored(Vector2(10, 25), Vector2(300, 120));
  });

  testWidgets('ions are cleared when the canvas leaves detail zoom', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    harness.container
        .read(simulationSessionProvider.notifier)
        .selectElement('NH₄⁺');
    await tester.pump();

    harness.game.camera.viewfinder.zoom = 6.0;
    for (var i = 0; i < 25; i++) {
      harness.layer.triggerSubComponentSync();
    }
    await tester.pump();

    final spawned = harness.ions();
    expect(spawned, isNotEmpty);

    harness.game.camera.viewfinder.zoom = 1.0;
    harness.layer.triggerSubComponentSync();
    await tester.pump();

    expect(harness.ions(), isEmpty);
    expect(spawned.every((ion) => !ion.isMounted || ion.isRemoving), isTrue);
  });
}

Scenario _scenario() {
  return Scenario(
    id: 'subcomponent_lifecycle',
    title: 'Sub-component Lifecycle',
    description: 'A deterministic layer for sub-component lifecycle tests.',
    initialProfile: SoilProfile(
      id: 'lifecycle',
      name: 'Lifecycle',
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
          hotspots: const [
            RhizosphereHotspot(id: 'rhs-1', x: 0.25, z: 0.5, intensity: 0.8),
          ],
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.05,
    ),
    weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
  );
}
