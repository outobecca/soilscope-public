import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
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
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = const Size(1024, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(
          disableAnimations: true,
          reduceMotion: true,
        );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }
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

bool _focusWithin(WidgetTester tester, String key) {
  final focusContext = FocusManager.instance.primaryFocus?.context;
  if (focusContext is! Element) return false;
  return find
      .ancestor(
        of: find.byElementPredicate(
          (element) => identical(element, focusContext),
        ),
        matching: find.byKey(ValueKey(key)),
      )
      .evaluate()
      .isNotEmpty;
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

  testWidgets('drag pans the canvas and wheel zoom stays under the pointer', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;
    final viewfinder = game.camera.viewfinder;
    final canvasCenter =
        harness.topLeft + Offset(game.size.x / 2, game.size.y / 2);
    final startZoom = viewfinder.zoom;
    final startPosition = viewfinder.position.clone();

    await tester.dragFrom(canvasCenter, const Offset(-120, 0));
    // Let the tap recognizer's disambiguation timer expire before teardown.
    await tester.pump(const Duration(milliseconds: 50));

    expect(viewfinder.zoom, closeTo(startZoom, 1e-6));
    expect(
      viewfinder.position.x,
      greaterThan(startPosition.x),
      reason: 'a left drag moves the camera right',
    );

    final zoomPoint = canvasCenter + const Offset(120, 80);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(zoomPoint));
    final worldBeforeZoom = game.camera.globalToLocal(
      Vector2(zoomPoint.dx, zoomPoint.dy),
    );
    final positionBeforeZoom = viewfinder.position.clone();

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, -120)));
    await tester.pump();

    expect(
      viewfinder.zoom,
      greaterThan(startZoom),
      reason: 'a wheel-up scroll must zoom in',
    );
    final worldAfterZoom = game.camera.globalToLocal(
      Vector2(zoomPoint.dx, zoomPoint.dy),
    );
    expect(
      (worldAfterZoom - worldBeforeZoom).length,
      lessThan(0.01),
      reason: 'zoom must stay anchored at the pointer',
    );
    expect(
      (viewfinder.position - positionBeforeZoom).length,
      greaterThan(0.01),
      reason: 'an off-center zoom must move the camera',
    );
  });

  testWidgets('canvas keyboard focus tabs into the HUD and activates actions', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final canvasFinder = find.byKey(const ValueKey('simulation-canvas-focus'));
    expect(canvasFinder, findsOneWidget);

    await tester.tapAt(
      harness.topLeft +
          Offset(harness.game.size.x / 2, harness.game.size.y * 0.3),
    );
    await tester.pump(const Duration(milliseconds: 50));
    final canvasFocus = tester.widget<Focus>(canvasFinder);
    expect(canvasFocus.focusNode?.hasFocus, isTrue);
    expect(_focusWithin(tester, 'canvas-focus-region'), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_focusWithin(tester, 'quick-actions-focus-region'), isTrue);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(_focusWithin(tester, 'canvas-focus-region'), isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_focusWithin(tester, 'quick-actions-focus-region'), isTrue);

    final wasRunning = harness.container.read(simulationProvider).isRunning;
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(
      harness.container.read(simulationProvider).isRunning,
      isNot(wasRunning),
      reason: 'Enter must activate the focused HUD action',
    );
  });

  testWidgets('canvas keyboard shortcuts inspect targets and reset the view', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;
    await _pumpUntil(
      tester,
      () => game.world.descendants().whereType<SoilLayerComponent>().isNotEmpty,
    );

    await tester.tapAt(
      harness.topLeft + Offset(game.size.x / 2, game.size.y * 0.3),
    );
    await tester.pump(const Duration(milliseconds: 50));

    await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
    await tester.pump();
    expect(game.keyboardTarget, isNotNull);
    expect(harness.container.read(uIStateProvider), isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(harness.container.read(uIStateProvider)?.isPinned, isTrue);

    final beforePan = game.camera.viewfinder.position.clone();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(game.camera.viewfinder.position.x, greaterThan(beforePan.x));

    await tester.sendKeyEvent(LogicalKeyboardKey.equal);
    await tester.pump();
    expect(game.camera.viewfinder.zoom, greaterThan(1.0));

    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pump();
    expect(game.camera.viewfinder.zoom, closeTo(1.35, 0.001));
  });

  testWidgets('canvas honors the platform reduced-motion preference', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester, reduceMotion: true);
    final game = harness.game;
    expect(game.reducedMotion, isTrue);
    expect(
      MediaQuery.of(
        tester.element(find.byKey(const ValueKey('simulation-canvas-focus'))),
      ).disableAnimations,
      isTrue,
    );

    final frozenTime = game.currentTime();
    await tester.pump(const Duration(milliseconds: 400));
    expect(game.currentTime(), frozenTime);

    tester.platformDispatcher.clearAccessibilityFeaturesTestValue();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(game.reducedMotion, isFalse);
    expect(game.currentTime(), greaterThan(frozenTime));
  });

  testWidgets('replacing a layer removes its stale technical hotspots', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;
    await _pumpUntil(
      tester,
      () => game.technicalHotspotLayer.children
          .whereType<ExpandableHotspotNode>()
          .isNotEmpty,
    );

    final oldLayer = game.world.children.whereType<SoilLayerComponent>().single;
    final oldLayerId = oldLayer.layerId;
    final oldNodes = game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .where((node) => node.layerId == oldLayerId)
        .toList();
    expect(oldNodes, isNotEmpty);

    harness.container
        .read(simulationProvider.notifier)
        .loadScenario(_scenario(withHotspot: false, layerId: 'subsoil'));
    // The screen listener is paused after the first scenario stops; push the
    // replacement snapshot directly so this test exercises scene cleanup.
    game.updateSession(
      harness.container.read(displayedSimulationStateProvider),
      harness.container.read(simulationSessionProvider),
    );
    await _pumpUntil(
      tester,
      () => game.world.children.whereType<SoilLayerComponent>().any(
        (layer) => layer.layerId == 'subsoil',
      ),
    );

    expect(
      game.world.children.whereType<SoilLayerComponent>().where(
        (layer) => layer.layerId == oldLayerId,
      ),
      isEmpty,
    );
    expect(
      game.technicalHotspotLayer.children
          .whereType<ExpandableHotspotNode>()
          .where((node) => node.layerId == oldLayerId),
      isEmpty,
      reason: 'a removed layer must not leave tappable hotspots behind',
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

Scenario _scenario({required bool withHotspot, String layerId = 'topsoil'}) {
  return Scenario(
    id: 'canvas_interaction_$layerId',
    title: 'Canvas Interaction',
    description: 'A deterministic layer for canvas interaction tests.',
    initialProfile: SoilProfile(
      id: 'canvas',
      name: 'Canvas',
      layers: [
        SoilLayer(
          id: layerId,
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
          name: layerId == 'topsoil' ? 'Topsoil' : 'Subsoil',
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
