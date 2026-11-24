import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/core/nitrogen_forms.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/animated_microbe_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/process_label_component.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/scene_coordinate_mapper.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

class _Harness {
  const _Harness({required this.container, required this.game});

  final ProviderContainer container;
  final SoilScopeGame game;
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition,
) async {
  for (var frame = 0; frame < 160; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
    if (condition()) return;
  }
  fail('the simulation screen did not reach the expected state');
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
    final game = container.read(soilScopeGameProviderProvider);
    return container.read(simulationProvider).isRunning &&
        game != null &&
        game.world.descendants().whereType<ExpandableHotspotNode>().length >= 4;
  });

  final game = container.read(soilScopeGameProviderProvider)!;
  await _pumpUntil(
    tester,
    () => game.world
        .descendants()
        .whereType<RhizosphereHotspotComponent>()
        .isNotEmpty,
  );
  return _Harness(container: container, game: game);
}

void main() {
  testWidgets('sampling nodes sit inside their layer and inside the plot', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;
    final layers = game.world.children.whereType<SoilLayerComponent>().toList();
    expect(layers.length, 2, reason: 'the scenario defines two layers');

    final plotWidth = SceneCoordinateMapper.plotWidth(
      SoilScopeGame.soilColumnWidth,
    );
    final plotLeft = game.plotCenterX - plotWidth / 2;
    final plotRight = game.plotCenterX + plotWidth / 2;

    final nodes = game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .toList();
    expect(nodes, isNotEmpty);

    for (final node in nodes) {
      final layer = layers.firstWhere((l) => l.layerId == node.layerId);
      expect(
        node.position.x,
        inInclusiveRange(plotLeft, plotRight),
        reason: '${node.layerId} hotspot must stay inside the planted plot',
      );
      expect(
        node.position.y,
        inInclusiveRange(
          layer.position.y,
          layer.position.y + layer.size.y,
        ),
        reason: '${node.layerId} hotspot must stay inside its own layer',
      );
      expect(node.layerAnchor.x, inInclusiveRange(0.0, 1.0));
      expect(node.layerAnchor.y, inInclusiveRange(0.0, 1.0));
    }

    // Each layer seeds its placement RNG with its id. Before that, both layers
    // started from the same sequence and stacked their nodes in one column.
    final topNode = nodes.firstWhere((n) => n.layerId == 'topsoil');
    final subNode = nodes.firstWhere((n) => n.layerId == 'subsoil');
    expect(
      topNode.layerAnchor.x,
      isNot(equals(subNode.layerAnchor.x)),
      reason: 'layers must not inherit the same sampling layout',
    );
  });

  testWidgets('nitrogen pools are exposed only by the nutrient cluster', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final nodes = harness.game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .toList();

    final nutrientNodes = nodes.where((n) => n.exposesNitrogenPools).toList();
    final sensorNodes = nodes.where((n) => !n.exposesNitrogenPools).toList();
    expect(
      nutrientNodes,
      isNotEmpty,
      reason: 'every layer guarantees one nutrient cluster',
    );
    expect(
      sensorNodes,
      isNotEmpty,
      reason: 'every layer guarantees one sensor cluster',
    );
    expect(
      nutrientNodes.every((n) => n.metrics.contains('NH₄⁺')),
      isTrue,
    );
  });

  testWidgets('rhizosphere hotspots follow the plot root transform', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final hotspot = harness.game.world
        .descendants()
        .whereType<RhizosphereHotspotComponent>()
        .firstWhere((h) => h.hotspotId == 'rhizosphere-test');

    final plotWidth = SceneCoordinateMapper.plotWidth(
      SoilScopeGame.soilColumnWidth,
    );
    final expectedX = harness.game.plotCenterX - plotWidth / 2;
    expect(
      hotspot.position.x,
      closeTo(expectedX, 0.5),
      reason:
          'x = 0.0 is the left edge of the plot, not the left edge of the '
          'decorative soil column',
    );
  });

  testWidgets('nitrogen mode marks the microbes that drive the cycle', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;
    await _pumpUntil(
      tester,
      () => game.world
          .descendants()
          .whereType<AnimatedMicrobeComponent>()
          .isNotEmpty,
    );
    final microbe = game.world
        .descendants()
        .whereType<AnimatedMicrobeComponent>()
        .first;

    expect(microbe.isCycleHighlighted, isFalse);
    expect(microbe.cycleGlowColor, isNull);

    harness.container
        .read(activeCycleProvider.notifier)
        .setCycle(ObservationCycle.nitrogen);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      harness.container.read(activeCycleProvider),
      ObservationCycle.nitrogen,
    );
    expect(microbe.isCycleHighlighted, isTrue);
    expect(microbe.cycleGlowColor, NitrogenForm.nitrate.color);
  });

  test('process markers are classified for the nitrogen mode', () {
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.nitrification), isTrue);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.mineralization), isTrue);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.denitrification), isTrue);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.leaching), isTrue);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.nutrientUptake), isTrue);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.photosynthesis), isFalse);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.transpiration), isFalse);
    expect(ProcessLabel.isNitrogenProcess(ProcessMarkerType.adsorption), isFalse);
  });
}

Scenario _scenario() {
  SoilLayer layer({
    required String id,
    required double depth,
    required double thickness,
    required String name,
    List<RhizosphereHotspot> hotspots = const [],
  }) {
    return SoilLayer(
      id: id,
      depth: depth,
      thickness: thickness,
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
      name: name,
      hotspots: hotspots,
    );
  }

  return Scenario(
    id: 'hotspot_layout',
    title: 'Hotspot layout',
    description: 'Two layers with a known rhizosphere hotspot.',
    initialProfile: SoilProfile(
      id: 'hotspot_layout',
      name: 'Hotspot layout',
      layers: [
        layer(
          id: 'topsoil',
          depth: 0.0,
          thickness: 0.3,
          name: 'Topsoil',
          hotspots: const [
            RhizosphereHotspot(
              id: 'rhizosphere-test',
              x: 0.0,
              z: 0.5,
              intensity: 0.8,
            ),
          ],
        ),
        layer(
          id: 'subsoil',
          depth: 0.3,
          thickness: 0.5,
          name: 'Subsoil',
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.05,
    ),
    weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
  );
}
