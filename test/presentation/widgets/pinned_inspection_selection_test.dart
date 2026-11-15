import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/flame_simulation_view.dart';
import 'package:soilscope/presentation/widgets/game/components/data_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

void main() {
  testWidgets('selecting another hotspot works while a pinned card is open', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final mockScenario = Scenario(
      id: 'test_scenario',
      title: 'Test Scenario',
      description: 'Test Description',
      initialProfile: const SoilProfile(
        id: 'test',
        name: 'Test',
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
      objectives: const [
        MissionObjective(
          id: 'clay_yield',
          title: 'Grow the crop',
          targetValue: 100,
          type: 'yield',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          scenariosProvider.overrideWith((ref) => [mockScenario]),
        ],
        child: const SoilScopeApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final listFinder = find.byType(Scrollable);
    if (listFinder.evaluate().isNotEmpty) {
      await tester.dragUntilVisible(
        find.text('OPEN'),
        listFinder.first,
        const Offset(0, -200),
      );
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.tap(find.text('OPEN').first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 500));

    final tutorialClose = find.byIcon(Icons.close_rounded).hitTestable();
    if (tutorialClose.evaluate().isNotEmpty) {
      await tester.tap(tutorialClose.last);
      await tester.pump(const Duration(milliseconds: 500));
    }

    final gameWidgetFinder = find.byWidgetPredicate(
      (widget) => widget is GameWidget,
    );
    expect(gameWidgetFinder, findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FlameSimulationView)),
      listen: false,
    );
    final game =
        tester.widget<GameWidget>(gameWidgetFinder).game as SoilScopeGame;
    final topLeft = tester.getTopLeft(gameWidgetFinder);

    final layers = game.world.children.whereType<SoilLayerComponent>().toList();
    expect(layers.length, 1, reason: 'one layer must have one scene component');

    final nodes = game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .toList();
    expect(nodes.length, greaterThanOrEqualTo(2));
    final nodePositions = nodes
        .map(
          (node) =>
              '${node.layerId}:${node.position.x.toStringAsFixed(1)}:'
              '${node.position.y.toStringAsFixed(1)}',
        )
        .toSet();
    expect(
      nodePositions.length,
      nodes.length,
      reason: 'each expandable hotspot must have a unique position',
    );

    // A resize triggers the same full scene rebuild that previously created
    // a second layer before Flame mounted the first. The rebuild must reuse
    // the existing component and its hotspot set.
    game.onGameResize(game.size);
    await tester.pump();
    expect(
      game.world.children.whereType<SoilLayerComponent>().length,
      1,
      reason: 'a scene rebuild must not add a second layer component',
    );
    final rebuiltNodes = game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .toList();
    expect(rebuiltNodes.length, nodes.length);
    expect(
      rebuiltNodes
          .map(
            (node) =>
                '${node.layerId}:${node.position.x.toStringAsFixed(1)}:'
                '${node.position.y.toStringAsFixed(1)}',
          )
          .toSet()
          .length,
      rebuiltNodes.length,
    );

    Offset screenOf(PositionComponent component) {
      final pos = game.worldToScreen(
        component.absolutePositionOf(component.size / 2),
      );
      return topLeft + Offset(pos.x, pos.y);
    }

    // Expand the first cluster, then pin one of its metrics.
    await tester.tapAt(screenOf(nodes[0]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final hotspots = game.world
        .descendants()
        .whereType<DataHotspotComponent>()
        .toList();
    expect(hotspots.length, greaterThanOrEqualTo(2));

    await tester.tapAt(screenOf(hotspots[0]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final first = container.read(uIStateProvider);
    expect(first?.isPinned, isTrue);

    await tester.tapAt(screenOf(hotspots[1]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final second = container.read(uIStateProvider);
    expect(second?.isPinned, isTrue);
    expect(second?.title, isNot(first?.title));

    // The pinned card freezes the canvas. Expanding a different cluster and
    // selecting one of its metrics must still work without closing the card.
    final otherScreen = screenOf(
      nodes.firstWhere((node) => screenOf(node) != screenOf(nodes[0])),
    );
    await tester.tapAt(otherScreen);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final newHotspots = game.world
        .descendants()
        .whereType<DataHotspotComponent>()
        .where((hotspot) => !hotspots.contains(hotspot))
        .toList();
    expect(newHotspots, isNotEmpty);
    expect(newHotspots.every((hotspot) => hotspot.isMounted), isTrue);

    await tester.tapAt(screenOf(newHotspots.first));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final third = container.read(uIStateProvider);
    expect(third?.isPinned, isTrue);
    expect(third?.title, isNot(second?.title));
  });
}
