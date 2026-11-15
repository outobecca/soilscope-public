import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
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
import 'package:soilscope/presentation/widgets/game/components/data_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/inspection_target_component.dart';
import 'package:soilscope/presentation/widgets/game/components/process_magnifier_component.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/scene_coordinate_mapper.dart';
import 'package:soilscope/presentation/widgets/game/components/selection_node_component.dart';
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
  Size viewport = const Size(1024, 900),
}) async {
  tester.view.physicalSize = viewport;
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
    expect(container.read(uIStateProvider)?.sourceId, 'soil-layer-topsoil');

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
    final semanticsHandle = tester.ensureSemantics();
    try {
      final harness = await _pumpSimulation(tester);
      final game = harness.game;
      await _pumpUntil(
        tester,
        () =>
            game.world.descendants().whereType<SoilLayerComponent>().isNotEmpty,
      );

      final canvasFocus = tester
          .widget<Focus>(find.byKey(const ValueKey('simulation-canvas-focus')))
          .focusNode!;
      canvasFocus.requestFocus();
      await tester.pump();
      expect(harness.container.read(uIStateProvider), isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.bracketRight);
      await tester.pump();
      expect(game.keyboardTarget, isNotNull);
      expect(game.keyboardFocusCueActive, isTrue);
      expect(game.keyboardFocusCue.isMounted, isTrue);
      final focusedTarget = game.keyboardTarget! as PositionComponent;
      final focusedCenter = focusedTarget.absolutePositionOf(
        focusedTarget.size / 2,
      );
      expect(game.keyboardFocusCuePosition, isNotNull);
      expect(game.keyboardFocusCuePosition!.x, closeTo(focusedCenter.x, 0.001));
      expect(game.keyboardFocusCuePosition!.y, closeTo(focusedCenter.y, 0.001));
      expect(
        harness.container.read(uIStateProvider),
        isNull,
        reason: 'cycling must only move focus, not open the inspection card',
      );

      final semanticsFinder = find.byKey(
        const ValueKey('keyboard-target-semantics'),
      );
      expect(semanticsFinder, findsOneWidget);
      final semanticsData = tester.getSemantics(semanticsFinder);
      expect(semanticsData.label, contains(game.keyboardTargetLabel!));
      expect(
        semanticsData.getSemanticsData().flagsCollection.isLiveRegion,
        isTrue,
      );

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

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(game.keyboardFocusCueActive, isFalse);
      expect(semanticsFinder, findsNothing);
    } finally {
      semanticsHandle.dispose();
    }
  });

  testWidgets('inspection taps route to the intended owner at every viewport', (
    tester,
  ) async {
    const viewports = <_MatrixViewport>[
      _MatrixViewport('wide', Size(1024, 900), edge: false),
      _MatrixViewport('narrow', Size(430, 900), edge: false),
      _MatrixViewport('edge-left', Size(1024, 900), edge: true),
      _MatrixViewport(
        'edge-right',
        Size(1024, 900),
        edge: true,
        fromRight: true,
      ),
    ];

    for (final viewport in viewports) {
      final harness = await _pumpSimulation(
        tester,
        withHotspot: true,
        viewport: viewport.size,
      );
      final cases = await _buildTapCases(tester, harness);

      for (final tapCase in cases) {
        await _resetInspection(tester, harness);
        var point = tapCase.point();
        await _focusCamera(
          harness.game,
          point,
          edge: viewport.edge,
          fromRight: viewport.fromRight,
        );
        await tester.pump();

        // Targets ride the growing plant, so read their position after the
        // camera pump instead of tapping a stale pre-pump coordinate.
        point = tapCase.point();
        final tap = harness.screenOfWorld(point);
        expect(
          tap.dx,
          inInclusiveRange(
            harness.topLeft.dx + 1,
            harness.topLeft.dx + harness.game.size.x - 1,
          ),
          reason: '${viewport.name}/${tapCase.label} must be inside the canvas',
        );
        expect(
          tap.dy,
          inInclusiveRange(
            harness.topLeft.dy + 1,
            harness.topLeft.dy + harness.game.size.y - 1,
          ),
          reason: '${viewport.name}/${tapCase.label} must be inside the canvas',
        );

        await tester.tapAt(tap);
        await tester.pump(const Duration(milliseconds: 50));

        final info = harness.container.read(uIStateProvider);
        final reason = '${viewport.name}/${tapCase.label}';
        if (tapCase.expectEmpty) {
          expect(info, isNull, reason: '$reason should not open a card');
          expect(
            harness.container.read(simulationSessionProvider).selectedLayerId,
            isNull,
            reason: '$reason should leave no layer selected',
          );
          expect(
            harness.container
                .read(simulationSessionProvider)
                .selectedInspectorType,
            isNull,
            reason: '$reason should leave no inspector selected',
          );
          continue;
        }

        expect(info, isNotNull, reason: '$reason should open a card');
        expect(info!.isPinned, isTrue, reason: '$reason should pin its card');
        expect(info.sourceId, tapCase.expectedSourceId, reason: reason);
        expect(info.title, tapCase.expectedTitle, reason: reason);
        if (tapCase.inspectorType != null) {
          expect(
            harness.container
                .read(simulationSessionProvider)
                .selectedInspectorType,
            tapCase.inspectorType,
            reason: '$reason should select its own microscope',
          );
        }
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('microscope target opens its matching magnifier and inspection', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;

    await _pumpUntil(
      tester,
      () => game.world
          .descendants()
          .whereType<InspectionTargetComponent>()
          .isNotEmpty,
    );
    final target = game.world
        .descendants()
        .whereType<InspectionTargetComponent>()
        .firstWhere((candidate) => candidate.type == MagnifierType.stem);

    await tester.tapAt(harness.screenOfWorld(target.absolutePosition));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final session = harness.container.read(simulationSessionProvider);
    expect(session.isMicroscopeEnabled, isTrue);
    expect(session.selectedInspectorType, MagnifierType.stem.name);
    expect(
      target.magnifier.isVisible,
      isTrue,
      reason: 'the tapped microscope target must reveal its magnifier',
    );
    expect(harness.container.read(uIStateProvider)?.isPinned, isTrue);
  });

  testWidgets('rhizosphere microscope opens on a root and near it', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;

    await _pumpUntil(
      tester,
      () => game.world
          .descendants()
          .whereType<InspectionTargetComponent>()
          .isNotEmpty,
    );
    final target = game.world
        .descendants()
        .whereType<InspectionTargetComponent>()
        .firstWhere((candidate) => candidate.type == MagnifierType.rhizosphere);

    final plant = game.displayedState.plants.isNotEmpty
        ? game.displayedState.plants.first
        : game.displayedState.plant;
    final rootWorldPositions = plant.rootSystem
        .where((node) => node.z > 0)
        .map(
          (node) => Vector2(
            SceneCoordinateMapper.mapRootX(
                  node.x,
                  SoilScopeGame.soilColumnWidth,
                  baseX: plant.baseX,
                ) +
                game.soilLeftX,
            SceneCoordinateMapper.mapRootY(
              node.z,
              game.soilSurfaceY,
              game.soilColumnHeight,
            ),
          ),
        )
        .toList();
    expect(rootWorldPositions, isNotEmpty);
    expect(
      rootWorldPositions
          .map((position) => position.distanceTo(target.position))
          .reduce(math.min),
      lessThan(25),
      reason: 'the rhizosphere target must be anchored to a root node',
    );

    // This must be reachable by a real pointer tap, not by selecting the
    // inspector in the session: the target is drawn inside the soil under
    // process overlays.
    await _focusCamera(game, _centerOf(target), edge: false);
    await tester.pump();
    await tester.tapAt(harness.screenOfWorld(_centerOf(target)));
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final session = harness.container.read(simulationSessionProvider);
    expect(session.selectedInspectorType, MagnifierType.rhizosphere.name);
    expect(target.magnifier.isVisible, isTrue);
    final targetOnScreen = game.worldToScreen(target.absolutePosition);
    expect(
      (target.magnifier.position - targetOnScreen).length,
      lessThan(320),
      reason: 'the rhizosphere microscope should open near the roots',
    );
    expect(target.magnifier.position.x, inInclusiveRange(0, game.size.x));
    expect(target.magnifier.position.y, inInclusiveRange(0, game.size.y));
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

  testWidgets('technical hotspots follow their layer when its rect changes', (
    tester,
  ) async {
    final harness = await _pumpSimulation(tester);
    final game = harness.game;

    await _pumpUntil(
      tester,
      () => game.technicalHotspotLayer.children
          .whereType<ExpandableHotspotNode>()
          .any((node) => node.layerId == 'topsoil'),
    );
    final nodes = game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .where((node) => node.layerId == 'topsoil')
        .toList();
    final layer = game.world.children
        .whereType<SoilLayerComponent>()
        .firstWhere((layer) => layer.layerId == 'topsoil');

    final nextPosition = Vector2(layer.position.x, layer.position.y + 40);
    final nextSize = Vector2(layer.size.x, layer.size.y * 0.8);
    layer.updateLayerRect(nextPosition, nextSize);
    await tester.pump();

    for (final node in nodes) {
      expect(
        node.position.x,
        closeTo(nextPosition.x + node.layerAnchor.x * nextSize.x, 0.01),
      );
      expect(
        node.position.y,
        closeTo(nextPosition.y + node.layerAnchor.y * nextSize.y, 0.01),
        reason: 'a hotspot must stay over its own layer',
      );
    }

    final selectionNode = layer.children
        .whereType<SelectionNodeComponent>()
        .single;
    expect(
      selectionNode.position.y,
      closeTo(nextSize.y / 2, 0.01),
      reason: 'the layer icon must stay in its own diagnostic gutter',
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

class _MatrixViewport {
  const _MatrixViewport(
    this.name,
    this.size, {
    required this.edge,
    this.fromRight = false,
  });

  final String name;
  final Size size;
  final bool edge;
  final bool fromRight;
}

class _TapCase {
  _TapCase({
    required this.label,
    required this.point,
    required this.expectedSourceId,
    required this.expectedTitle,
    this.inspectorType,
    this.expectEmpty = false,
  });

  final String label;
  final Vector2 Function() point;
  final String expectedSourceId;
  final String expectedTitle;
  final String? inspectorType;
  final bool expectEmpty;
}

Vector2 _centerOf(PositionComponent component) =>
    component.absolutePositionOf(component.size / 2);

double _minScreenDistance(
  Vector2 point,
  Iterable<Vector2> obstacles,
  double zoom,
) {
  var minimum = double.infinity;
  for (final obstacle in obstacles) {
    final distance = (obstacle - point).length * zoom;
    if (distance < minimum) minimum = distance;
  }
  return minimum;
}

Future<void> _focusCamera(
  SoilScopeGame game,
  Vector2 worldPoint, {
  required bool edge,
  bool fromRight = false,
}) async {
  final zoom = game.camera.viewfinder.zoom;
  if (edge) {
    // Put the point 32 screen px from the requested side without changing
    // its vertical position. This exercises the real clamp/edge behaviour
    // while keeping the pointer clear of the top bar and bottom controls.
    final screenX = fromRight ? game.size.x - 32 : 32.0;
    game.camera.viewfinder.position = Vector2(
      worldPoint.x - (screenX - game.size.x / 2) / zoom,
      worldPoint.y,
    );
  } else {
    game.camera.viewfinder.position = worldPoint.clone();
  }
}

Future<void> _resetInspection(WidgetTester tester, _Harness harness) async {
  final container = harness.container;
  container.read(uIStateProvider.notifier).setHoverInfo(null);
  // Clear all view state between rows. This is teardown, not inspection
  // selection; the next owner is chosen only by the pointer tap in the row.
  container.read(simulationSessionProvider.notifier).resetForScenario();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

Future<List<_TapCase>> _buildTapCases(
  WidgetTester tester,
  _Harness harness,
) async {
  final game = harness.game;
  final l10n = lookupAppLocalizations(const Locale('en'));

  await _pumpUntil(tester, () {
    final targets = game.world
        .descendants()
        .whereType<InspectionTargetComponent>()
        .length;
    final rhizospheres = game.world
        .descendants()
        .whereType<RhizosphereHotspotComponent>()
        .length;
    final hotspots = game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .length;
    return targets == MagnifierType.values.length &&
        rhizospheres > 0 &&
        hotspots > 0;
  });

  final layer = game.world.children.whereType<SoilLayerComponent>().firstWhere(
    (layer) => layer.layerId == 'topsoil',
  );
  final targets = game.world
      .descendants()
      .whereType<InspectionTargetComponent>()
      .toList();
  final rhizosphere = game.world
      .descendants()
      .whereType<RhizosphereHotspotComponent>()
      .first;
  final selectionNodes = game.world
      .descendants()
      .whereType<SelectionNodeComponent>()
      .toList();
  final layerNode = layer.children.whereType<SelectionNodeComponent>().single;
  final technicalNodes = game.technicalHotspotLayer.children
      .whereType<ExpandableHotspotNode>()
      .where((node) => node.layerId == layer.layerId)
      .toList();

  expect(targets, hasLength(MagnifierType.values.length));
  expect(technicalNodes, isNotEmpty);

  final targetCenters = targets.map(_centerOf).toList();
  final selectionCenters = selectionNodes.map(_centerOf).toList();
  final technicalCenters = technicalNodes.map(_centerOf).toList();
  final zoom = game.camera.viewfinder.zoom;

  // Expand a technical node that does not sit under a microscope target or
  // another inspection target, then tap one of its metrics.
  ExpandableHotspotNode? expandNode;
  var expandDistance = -1.0;
  for (final node in technicalNodes) {
    final distance = _minScreenDistance(_centerOf(node), [
      ...targetCenters,
      _centerOf(rhizosphere),
      ...selectionCenters,
    ], zoom);
    if (distance > expandDistance) {
      expandDistance = distance;
      expandNode = node;
    }
  }
  expect(expandNode, isNotNull);
  expect(
    expandDistance,
    greaterThan(20),
    reason: 'the matrix needs a technical hotspot clear of targets',
  );

  await _focusCamera(game, _centerOf(expandNode!), edge: false);
  await tester.pump();
  await tester.tapAt(harness.screenOfWorld(_centerOf(expandNode)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));

  final dataHotspots = game.world
      .descendants()
      .whereType<DataHotspotComponent>()
      .toList();
  expect(dataHotspots, isNotEmpty);

  DataHotspotComponent? dataHotspot;
  var dataDistance = -1.0;
  for (final hotspot in dataHotspots) {
    final distance = _minScreenDistance(_centerOf(hotspot), [
      ...targetCenters,
      _centerOf(rhizosphere),
      ...selectionCenters,
      ...technicalCenters,
      for (final other in dataHotspots)
        if (other != hotspot) _centerOf(other),
    ], zoom);
    if (distance > dataDistance) {
      dataDistance = distance;
      dataHotspot = hotspot;
    }
  }
  expect(dataHotspot, isNotNull);
  expect(
    dataDistance,
    greaterThan(20),
    reason: 'the matrix needs a data hotspot clear of targets',
  );

  final dataTitle = switch (dataHotspot!.type.name) {
    'nutrient' => l10n.nutrient,
    'cec' => 'CEC (Clay)',
    _ => 'SENSOR',
  };

  // Pick a real layer-body point that is not under the plant, a target, an
  // icon, a technical hotspot, a data hotspot or a rhizosphere hotspot.
  final plant = game.world
      .descendants()
      .whereType<AnimatedPlantComponent>()
      .first;
  final layerObstacles = <Vector2>[
    ...targetCenters,
    ...selectionCenters,
    ...technicalCenters,
    for (final hotspot in dataHotspots) _centerOf(hotspot),
    _centerOf(rhizosphere),
    _centerOf(plant),
  ];

  Vector2? layerPoint;
  var layerDistance = -1.0;
  for (
    var x = layer.position.x + 45;
    x <= layer.position.x + layer.size.x - 45;
    x += 30
  ) {
    for (
      var y = layer.position.y + 30;
      y <= layer.position.y + layer.size.y - 30;
      y += 30
    ) {
      final candidate = Vector2(x, y);
      final distance = _minScreenDistance(candidate, layerObstacles, zoom);
      if (distance > layerDistance) {
        layerDistance = distance;
        layerPoint = candidate;
      }
    }
  }
  expect(layerPoint, isNotNull);
  expect(
    layerDistance,
    greaterThan(20),
    reason: 'the matrix needs an empty layer-body point',
  );

  final targetTitles = <MagnifierType, String>{
    MagnifierType.apicalMeristem: l10n.apicalMeristem,
    MagnifierType.leaf: l10n.plantCanopy.toUpperCase(),
    MagnifierType.stem: l10n.stemCrossSection.toUpperCase(),
    MagnifierType.root: l10n.rootTissue.toUpperCase(),
    MagnifierType.rhizosphere: l10n.rhizosphere.toUpperCase(),
    MagnifierType.microbe: l10n.microbialCell.toUpperCase(),
    MagnifierType.soilStructure: l10n.soilStructure.toUpperCase(),
  };

  final cases = <_TapCase>[
    _TapCase(
      label: 'layer body',
      point: () => layerPoint!,
      expectedSourceId: 'soil-layer-topsoil',
      expectedTitle: 'TOPSOIL',
    ),
    _TapCase(
      label: 'layer icon',
      point: () => _centerOf(layerNode),
      expectedSourceId: 'selection-soilLayer-topsoil',
      expectedTitle: 'TOPSOIL',
    ),
    _TapCase(
      label: 'data hotspot',
      point: () => _centerOf(dataHotspot!),
      expectedSourceId:
          'hotspot-topsoil-${dataHotspot.label}-'
          '${identityHashCode(dataHotspot)}',
      expectedTitle: '$dataTitle - ${dataHotspot.label}',
    ),
    _TapCase(
      label: 'rhizosphere hotspot',
      point: () => _centerOf(rhizosphere),
      expectedSourceId: 'rhizosphere-${rhizosphere.hotspotId}',
      expectedTitle: l10n.rhizosphere.toUpperCase(),
    ),
    for (final target in targets)
      _TapCase(
        label: 'target ${target.type.name}',
        point: () => _centerOf(target),
        expectedSourceId: 'inspection-${target.type.name}',
        expectedTitle: targetTitles[target.type]!,
        inspectorType: target.type.name,
      ),
    _TapCase(
      label: 'background',
      point: () => Vector2(game.soilLeftX + 1100, game.soilSurfaceY - 260),
      expectedSourceId: '',
      expectedTitle: '',
      expectEmpty: true,
    ),
  ];

  return cases;
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
