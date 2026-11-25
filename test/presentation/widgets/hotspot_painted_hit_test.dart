import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/data_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/inspection_target_tap_router.dart';
import 'package:soilscope/presentation/widgets/game/components/process_label_component.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/scene_coordinate_mapper.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

import 'support/canvas_scene_harness.dart';

/// Removes overlays that own taps independently of the technical hotspot layer
/// so the pointer assertions below resolve to what the hotspot layer drew.
void _isolateHotspotLayer(CanvasScene scene) {
  for (final label
      in scene.game.world.descendants().whereType<ProcessLabel>().toList()) {
    label.removeFromParent();
  }
  for (final router
      in scene.game.world
          .descendants()
          .whereType<InspectionTargetTapRouter>()
          .toList()) {
    router.removeFromParent();
  }
}

List<ExpandableHotspotNode> _nodes(CanvasScene scene, String layerId) => scene
    .game
    .world
    .descendants()
    .whereType<ExpandableHotspotNode>()
    .where((node) => node.layerId == layerId)
    .toList();

void main() {
  testWidgets(
    'every painted sampling node is inside the plot and hits itself',
    (tester) async {
      final scene = await pumpCanvasScene(tester);
      final game = scene.game;
      scene.container.read(simulationProvider.notifier).stop();
      await tester.pump(const Duration(milliseconds: 120));
      _isolateHotspotLayer(scene);
      scene.container.read(uIStateProvider.notifier).setHoverInfo(null);
      await tester.pump();

      final layers = scene.layers;
      expect(layers, hasLength(2));
      final nodes = game.world
          .descendants()
          .whereType<ExpandableHotspotNode>()
          .toList();
      expect(nodes.length, greaterThanOrEqualTo(4));

      final plotWidth = SceneCoordinateMapper.plotWidth(
        SoilScopeGame.soilColumnWidth,
      );
      final plotLeft = game.plotCenterX - plotWidth / 2;
      final plotRight = game.plotCenterX + plotWidth / 2;
      final plotLeftScreen = scene
          .screenOfWorld(Vector2(plotLeft, game.soilSurfaceY))
          .dx;
      final plotRightScreen = scene
          .screenOfWorld(Vector2(plotRight, game.soilSurfaceY))
          .dx;

      for (final layer in layers) {
        final layerNodes = nodes
            .where((n) => n.layerId == layer.layerId)
            .toList();
        expect(
          layerNodes.length,
          greaterThanOrEqualTo(2),
          reason: '${layer.layerId} must draw more than one sampling node',
        );

        final layerTopScreen = scene
            .screenOfWorld(Vector2(plotLeft, layer.position.y))
            .dy;
        final layerBottomScreen = scene
            .screenOfWorld(Vector2(plotRight, layer.position.y + layer.size.y))
            .dy;

        for (final node in layerNodes) {
          final centerWorld = scene.nodeCenter(node);
          final centerScreen = scene.screenOfWorld(centerWorld);

          // The drawn centre is inside the planted plot and inside the layer
          // body in screen space too, not only in world coordinates.
          expect(centerWorld.x, inInclusiveRange(plotLeft, plotRight));
          expect(
            centerWorld.y,
            inInclusiveRange(layer.position.y, layer.position.y + layer.size.y),
          );
          expect(
            centerScreen.dx,
            inInclusiveRange(plotLeftScreen, plotRightScreen),
            reason: '${node.layerId} node must be drawn inside the plot',
          );
          expect(
            centerScreen.dy,
            inInclusiveRange(layerTopScreen, layerBottomScreen),
            reason: '${node.layerId} node must be drawn inside its layer',
          );

          final before = {for (final other in nodes) other: other.isExpanded};
          await tester.tapAt(centerScreen);
          await tester.pump(const Duration(milliseconds: 100));

          expect(
            node.isExpanded,
            isTrue,
            reason:
                'a tap at the drawn centre of the ${node.layerId} node must '
                'expand that node',
          );
          for (final other in nodes.where((other) => other != node)) {
            expect(
              other.isExpanded,
              before[other],
              reason:
                  'tapping ${node.layerId} must not expand the neighbouring '
                  'node at ${scene.screenOfWorld(scene.nodeCenter(other))}',
            );
          }

          await tester.tapAt(centerScreen);
          await tester.pump(const Duration(milliseconds: 100));
          expect(node.isExpanded, isFalse);
        }
      }

      final topPositions = _nodes(
        scene,
        'topsoil',
      ).map((n) => n.layerAnchor.x).toSet();
      final subPositions = _nodes(
        scene,
        'subsoil',
      ).map((n) => n.layerAnchor.x).toSet();
      expect(
        topPositions,
        isNot(equals(subPositions)),
        reason: 'each layer must lay its sampling nodes out independently',
      );
    },
  );

  testWidgets('expanded metric bubbles hit the component drawn under the tap', (
    tester,
  ) async {
    final scene = await pumpCanvasScene(tester);
    scene.container.read(simulationProvider.notifier).stop();
    await tester.pump(const Duration(milliseconds: 120));
    _isolateHotspotLayer(scene);
    scene.container.read(uIStateProvider.notifier).setHoverInfo(null);
    await tester.pump();

    final game = scene.game;
    final nodes = game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .toList();
    final rhizospheres = game.world
        .descendants()
        .whereType<RhizosphereHotspotComponent>()
        .toList();

    // Expand a nutrient cluster, preferring one clear of rhizosphere markers
    // and the other clusters so the metric ring is not visually overlapping.
    final candidates = nodes.where((node) => node.exposesNitrogenPools).toList()
      ..sort((a, b) {
        double clearance(ExpandableHotspotNode node) {
          final center = scene.nodeCenter(node);
          final otherCenters = [
            ...nodes.where((other) => other != node).map(scene.nodeCenter),
            ...rhizospheres.map(
              (hotspot) => hotspot.absolutePositionOf(hotspot.size / 2),
            ),
          ];
          return otherCenters
              .map((other) => (other - center).length)
              .reduce(math.min);
        }

        return clearance(b).compareTo(clearance(a));
      });
    final node = candidates.first;

    final nodeScreen = scene.screenOfWorld(scene.nodeCenter(node));
    await tester.tapAt(nodeScreen);
    await tester.pump(const Duration(milliseconds: 700));
    expect(node.isExpanded, isTrue);

    final children = node.children.whereType<DataHotspotComponent>().toList();
    expect(children, hasLength(node.metrics.length));
    final centers = <Offset>[];
    for (final child in children) {
      final center = scene.screenOfWorld(
        child.absolutePositionOf(child.size / 2),
      );
      for (final other in centers) {
        expect(
          (center - other).distance,
          greaterThan(10),
          reason: 'metric bubbles must be drawn at distinct tap targets',
        );
      }
      centers.add(center);
      expect((center - nodeScreen).distance, greaterThan(10));

      await tester.tapAt(center);
      await tester.pump(const Duration(milliseconds: 100));
      final info = scene.container.read(uIStateProvider);
      expect(
        info?.sourceId,
        'hotspot-${child.layerId}-${child.label}-${identityHashCode(child)}',
        reason:
            'the tap at ${child.label} must open that metric, not a '
            'neighbouring bubble',
      );
      expect(info?.isPinned, isTrue);

      scene.container.read(uIStateProvider.notifier).setHoverInfo(null);
      await tester.pump(const Duration(milliseconds: 60));
    }

    // Collapse the cluster to leave the scene as it was found.
    await tester.tapAt(nodeScreen);
    await tester.pump(const Duration(milliseconds: 100));
    expect(node.isExpanded, isFalse);
  });

  testWidgets('painted rhizosphere hotspot opens from its drawn centre', (
    tester,
  ) async {
    final scene = await pumpCanvasScene(tester);
    final game = scene.game;
    scene.container.read(simulationProvider.notifier).stop();
    await tester.pump(const Duration(milliseconds: 120));

    for (final label
        in game.world.descendants().whereType<ProcessLabel>().toList()) {
      label.removeFromParent();
    }
    for (final router
        in game.world
            .descendants()
            .whereType<InspectionTargetTapRouter>()
            .toList()) {
      router.removeFromParent();
    }
    scene.container.read(uIStateProvider.notifier).setHoverInfo(null);
    await tester.pump();

    final hotspot = game.world
        .descendants()
        .whereType<RhizosphereHotspotComponent>()
        .firstWhere((hotspot) => hotspot.hotspotId == 'rhizosphere-test');
    final center = scene.screenOfWorld(
      hotspot.absolutePositionOf(hotspot.size / 2),
    );
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 100));

    final info = scene.container.read(uIStateProvider);
    expect(info?.sourceId, startsWith('rhizosphere-'));
    expect(info?.isPinned, isTrue);
  });
}
