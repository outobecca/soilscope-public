import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/screens/logic_lab_screen.dart';
import 'package:soilscope/presentation/widgets/game/components/data_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/selection_node_component.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

class _Harness {
  const _Harness({
    required this.tester,
    required this.container,
    required this.initialGame,
    required this.topLeft,
  });

  final WidgetTester tester;
  final ProviderContainer container;
  final SoilScopeGame initialGame;
  final Offset topLeft;

  SoilScopeGame get game {
    final finder = find.byWidgetPredicate((widget) => widget is GameWidget);
    if (finder.evaluate().isNotEmpty) {
      return tester.widget<GameWidget>(finder).game as SoilScopeGame;
    }
    return container.read(soilScopeGameProviderProvider) ?? initialGame;
  }

  Offset screenOf(PositionComponent component) {
    final screen = game.worldToScreen(
      component.absolutePositionOf(component.size / 2),
    );
    return topLeft + Offset(screen.x, screen.y);
  }
}

Future<_Harness> _pumpSimulation(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 900);
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
        navigatorObservers: [appRouteObserver],
        routes: {'/logic_lab': (_) => const LogicLabScreen()},
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
  await _pumpUntil(tester, () {
    final nodes = game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>();
    return nodes.any((node) => node.layerId == 'topsoil') &&
        nodes.any((node) => node.layerId == 'subsoil');
  });

  return _Harness(
    tester: tester,
    container: container,
    initialGame: game,
    topLeft: tester.getTopLeft(gameFinder),
  );
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var frame = 0; frame < 200; frame++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 20));
    if (condition()) return;
  }
  fail('the simulation did not reach the expected state');
}

Future<DataHotspotComponent> _pinHotspot(
  WidgetTester tester,
  _Harness harness, {
  required String layerId,
  required String label,
}) async {
  final game = harness.game;
  await _pumpUntil(
    tester,
    () => game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .any((node) => node.layerId == layerId),
  );

  DataHotspotComponent? hotspot;
  for (final candidate
      in game.world.descendants().whereType<DataHotspotComponent>()) {
    if (candidate.layerId == layerId && candidate.label == label) {
      hotspot = candidate;
      break;
    }
  }

  if (hotspot == null) {
    final node = game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .firstWhere(
          (candidate) =>
              candidate.layerId == layerId && candidate.metrics.contains(label),
        );
    game.camera.viewfinder.position = node.absolutePositionOf(node.size / 2);
    await tester.pump();
    await tester.tapAt(harness.screenOf(node));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    for (final candidate
        in game.world.descendants().whereType<DataHotspotComponent>()) {
      if (candidate.layerId == layerId && candidate.label == label) {
        hotspot = candidate;
        break;
      }
    }
  }

  expect(hotspot, isNotNull, reason: '$layerId/$label hotspot must exist');
  game.camera.viewfinder.position = hotspot!.absolutePositionOf(
    hotspot.size / 2,
  );
  await tester.pump();
  await tester.tapAt(harness.screenOf(hotspot));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));

  final info = harness.container.read(uIStateProvider);
  expect(info?.isPinned, isTrue, reason: '$layerId/$label must pin its card');
  return hotspot;
}

Future<void> _pinLayerNode(
  WidgetTester tester,
  _Harness harness, {
  required String layerId,
}) async {
  final game = harness.game;
  await _pumpUntil(
    tester,
    () => game.world.children.whereType<SoilLayerComponent>().any(
      (layer) => layer.layerId == layerId,
    ),
  );
  final layer = game.world.children.whereType<SoilLayerComponent>().firstWhere(
    (layer) => layer.layerId == layerId,
  );
  final node = layer.children.whereType<SelectionNodeComponent>().single;

  game.camera.viewfinder.position = node.absolutePositionOf(node.size / 2);
  await tester.pump();
  await tester.tapAt(harness.screenOf(node));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 80));

  final info = harness.container.read(uIStateProvider);
  expect(info?.isPinned, isTrue, reason: '$layerId layer node must pin');
  return;
}

Future<void> _openLabFromCard(WidgetTester tester) async {
  final button = find.text('Open Logic Lab').hitTestable();
  expect(button, findsWidgets);
  await tester.tap(button.first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.byType(LogicLabScreen), findsOneWidget);
}

Future<void> _closeLab(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.byType(MainSimulationScreen), findsOneWidget);
}

Future<void> _openLabFromQuickActions(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Quick actions'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(find.text('NAVIGATE'), findsOneWidget);
  await tester.tap(find.text('NAVIGATE'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  await tester.tap(find.text('Logic Lab'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets(
    'hotspot selection drives the Lab, edits change the canvas, and the '
    'Quick Actions route keeps the pinned context',
    (tester) async {
      final harness = await _pumpSimulation(tester);
      final container = harness.container;

      // The canvas must have a working animation clock before the route flow;
      // the browser run verifies the same after returning from the Lab.
      final initialTime = harness.game.currentTime();
      await tester.pump(const Duration(milliseconds: 200));
      expect(harness.game.currentTime(), greaterThan(initialTime));

      // Pause the engine while the real pointer flow opens the Lab so the
      // readings stay deterministic. The return path explicitly starts it
      // again to prove the simulation is not left in inspection pause.
      container.read(simulationProvider.notifier).stop();
      await tester.pump();
      expect(container.read(simulationProvider).isRunning, isFalse);

      final topsoilBefore = container
          .read(simulationProvider)
          .profile
          .layers
          .firstWhere((layer) => layer.id == 'topsoil');

      await _pinHotspot(tester, harness, layerId: 'topsoil', label: 'T');
      final temperatureInfo = container.read(uIStateProvider)!;
      expect(temperatureInfo.title, 'SENSOR - T');
      expect(temperatureInfo.layerId, 'topsoil');
      expect(temperatureInfo.logicLabModel, 'nitrification');

      await _openLabFromCard(tester);
      expect(
        container.read(uIStateProvider),
        isNull,
        reason: 'opening the Lab must release the card that froze the canvas',
      );
      expect(find.text('SENSOR - T'), findsOneWidget);
      expect(find.text('Layer: Topsoil'), findsOneWidget);
      expect(find.text('Nitrification'), findsWidgets);
      expect(find.text('Ammonium (NH₄⁺)'), findsOneWidget);
      expect(
        find.text('${topsoilBefore.ammoniumContent.toStringAsFixed(1)} mg/kg'),
        findsOneWidget,
      );

      await tester.drag(find.byType(Slider).first, const Offset(120, 0));
      await tester.pump();
      final topsoilAfter = container
          .read(simulationProvider)
          .profile
          .layers
          .firstWhere((layer) => layer.id == 'topsoil');
      expect(
        topsoilAfter.ammoniumContent,
        isNot(topsoilBefore.ammoniumContent),
      );
      expect(
        find.text('${topsoilAfter.ammoniumContent.toStringAsFixed(1)} mg/kg'),
        findsOneWidget,
        reason: 'the banner must show the live value, not the captured card',
      );

      await _closeLab(tester);
      expect(find.byType(LogicLabScreen), findsNothing);
      expect(container.read(uIStateProvider), isNull);
      await _pumpUntil(tester, () => harness.game.isMounted);
      expect(harness.game.isInspectionPaused, isFalse);
      expect(
        harness.game.displayedState.profile.layers
            .firstWhere((layer) => layer.id == 'topsoil')
            .ammoniumContent,
        closeTo(topsoilAfter.ammoniumContent, 0.001),
        reason: 'the animated canvas state must follow the Lab edit',
      );

      expect(
        container.read(simulationProvider).isRunning,
        isTrue,
        reason: 'editing the Lab must resume the simulation on return',
      );
      final resumedAt = harness.game.currentTime();
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        harness.game.currentTime(),
        greaterThan(resumedAt),
        reason: 'the canvas animation clock must resume after the Lab route',
      );
      container.read(simulationProvider.notifier).stop();
      await tester.pump();

      await _pinLayerNode(tester, harness, layerId: 'subsoil');
      final waterInfo = container.read(uIStateProvider)!;
      expect(waterInfo.title, 'SUBSOIL');
      expect(waterInfo.layerId, 'subsoil');
      expect(waterInfo.logicLabModel, 'waterRetention');

      final subsoilBefore = container
          .read(simulationProvider)
          .profile
          .layers
          .firstWhere((layer) => layer.id == 'subsoil');
      final topsoilWaterBefore = container
          .read(simulationProvider)
          .profile
          .layers
          .firstWhere((layer) => layer.id == 'topsoil')
          .waterContent;
      await _openLabFromCard(tester);
      expect(find.text('SUBSOIL'), findsOneWidget);
      expect(find.text('Layer: Subsoil'), findsOneWidget);
      expect(find.text('Soil Water Content / Pressure Head'), findsOneWidget);
      expect(find.text('Soil water content (θ)'), findsOneWidget);
      expect(
        find.text('${subsoilBefore.waterContent.toStringAsFixed(3)} m³/m³'),
        findsWidgets,
      );
      expect(
        find.textContaining(
          'Live result ${subsoilBefore.waterContent.toStringAsPrecision(3)}',
          findRichText: true,
        ),
        findsOneWidget,
        reason: 'the graph must reproduce the selected layer water content',
      );

      await tester.drag(find.byType(Slider).first, const Offset(-90, 0));
      await tester.pump();
      final subsoilAfter = container
          .read(simulationProvider)
          .profile
          .layers
          .firstWhere((layer) => layer.id == 'subsoil');
      expect(subsoilAfter.waterContent, isNot(subsoilBefore.waterContent));
      expect(
        container
            .read(simulationProvider)
            .profile
            .layers
            .firstWhere((layer) => layer.id == 'topsoil')
            .waterContent,
        topsoilWaterBefore,
        reason: 'editing the subsoil must not rewrite the topsoil',
      );
      expect(
        find.text('${subsoilAfter.waterContent.toStringAsFixed(3)} m³/m³'),
        findsWidgets,
      );

      await _closeLab(tester);
      await tester.pump(const Duration(milliseconds: 600));
      expect(harness.game.isInspectionPaused, isFalse);
      expect(
        harness.game.displayedState.profile.layers
            .firstWhere((layer) => layer.id == 'subsoil')
            .waterContent,
        closeTo(subsoilAfter.waterContent, 0.02),
      );

      // With no card open, Quick Actions must still use the soil profile
      // rather than the generic nitrification example.
      await _openLabFromQuickActions(tester);
      expect(find.byType(LogicLabScreen), findsOneWidget);
      expect(find.text('TOPSOIL'), findsOneWidget);
      expect(find.text('Layer: Topsoil'), findsOneWidget);
      expect(find.text('Soil Water Content / Pressure Head'), findsOneWidget);
      await _closeLab(tester);
      await tester.pump(const Duration(milliseconds: 600));

      await _pinHotspot(tester, harness, layerId: 'topsoil', label: 'T');
      expect(container.read(uIStateProvider)?.title, 'SENSOR - T');
      await _openLabFromQuickActions(tester);

      expect(find.byType(LogicLabScreen), findsOneWidget);
      expect(find.text('SENSOR - T'), findsOneWidget);
      expect(find.text('Layer: Topsoil'), findsOneWidget);
      expect(find.text('Nitrification'), findsWidgets);
      expect(
        container.read(uIStateProvider),
        isNull,
        reason: 'the Quick Actions fallback must release the pinned card too',
      );

      await tester.drag(find.byType(Slider).first, const Offset(100, 0));
      await tester.pump();
      expect(
        container
            .read(simulationProvider)
            .profile
            .layers
            .firstWhere((layer) => layer.id == 'topsoil')
            .ammoniumContent,
        isNot(topsoilAfter.ammoniumContent),
      );

      await _closeLab(tester);
      await tester.pump(const Duration(milliseconds: 600));
      expect(harness.game.isInspectionPaused, isFalse);
    },
  );
}

Scenario _scenario() {
  return Scenario(
    id: 'logic_lab_flow',
    title: 'Logic Lab Flow',
    description: 'Two layers with different live readings.',
    initialProfile: SoilProfile(
      id: 'logic-lab-flow',
      name: 'Logic Lab Flow',
      layers: [
        SoilLayer(
          id: 'topsoil',
          depth: 0.0,
          thickness: 0.25,
          kSat: 1e-5,
          porosity: 0.5,
          thetaR: 0.08,
          vgAlpha: 3.6,
          vgN: 1.6,
          bulkDensity: 1200.0,
          waterContent: 0.28,
          temperature: 291.15,
          heatCapacity: 2.4e6,
          ph: 6.2,
          ec: 0.2,
          redoxPotential: 320.0,
          nitrateContent: 40.0,
          ammoniumContent: 12.0,
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
        SoilLayer(
          id: 'subsoil',
          depth: 0.25,
          thickness: 0.35,
          kSat: 5e-6,
          porosity: 0.42,
          thetaR: 0.04,
          vgAlpha: 2.0,
          vgN: 1.4,
          bulkDensity: 1400.0,
          waterContent: 0.38,
          temperature: 285.15,
          heatCapacity: 2.6e6,
          ph: 7.1,
          ec: 0.3,
          redoxPotential: 120.0,
          nitrateContent: 55.0,
          ammoniumContent: 3.0,
          phosphateContent: 1.0,
          microbialBiomass: 80.0,
          epsContent: 4.0,
          fungalHyphaeDensity: 8.0,
          necromass: 30.0,
          organicCarbon: 6000.0,
          particulateOrganicMatter: 2000.0,
          mineralAssociatedOrganicMatter: 4000.0,
          nitrogenContent: 500.0,
          name: 'Subsoil',
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.05,
    ),
    weatherData: {'precip': 0.0, 'temp': 291.15, 'rh': 0.5},
  );
}
