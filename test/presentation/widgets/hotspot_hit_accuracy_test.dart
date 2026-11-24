import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/animated_plant_component.dart';
import 'package:soilscope/presentation/widgets/game/components/capillary_rise_component.dart';
import 'package:soilscope/presentation/widgets/game/components/process_label_component.dart';
import 'package:soilscope/presentation/widgets/game/components/scene_coordinate_mapper.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

import 'support/canvas_scene_harness.dart';

void main() {
  testWidgets('plant hit area follows the drawn stem and canopy', (
    tester,
  ) async {
    final scene = await pumpCanvasScene(tester);
    scene.container.read(simulationProvider.notifier).stop();
    await tester.pump(const Duration(milliseconds: 120));

    final game = scene.game;
    final plant = game.world
        .descendants()
        .whereType<AnimatedPlantComponent>()
        .first;
    final plantData = game.displayedState.plants.first;
    final scale = SceneCoordinateMapper.getShootScale(plantData);

    // Inside the old 200 x 320 px rectangle, but in the empty gap between the
    // lower branches and the canopy. Clicking there must reach what is drawn
    // behind the plant, not open the plant card.
    expect(
      plant.containsLocalPoint(Vector2(99 * scale, -250 * scale)),
      isFalse,
      reason: 'empty space beside the canopy must not belong to the plant',
    );

    // The painted stem runs to 450 * scale; the old rectangle stopped at
    // 320 * scale even though the stem was still visible there.
    expect(
      plant.containsLocalPoint(Vector2(0, -430 * scale)),
      isTrue,
      reason: 'a tap on the drawn upper stem must still open the plant',
    );
  });

  testWidgets('capillary rise claims only its drawn meniscus', (tester) async {
    final scene = await pumpCanvasScene(tester);
    scene.container.read(simulationProvider.notifier).stop();
    await tester.pump(const Duration(milliseconds: 120));

    final game = scene.game;
    final capillary = game.world
        .descendants()
        .whereType<CapillaryRiseComponent>()
        .first;
    final tips = capillary.meniscusPointsAt(game.currentTime());
    expect(tips, isNotEmpty);
    expect(
      capillary.containsLocalPoint(tips.first),
      isTrue,
      reason: 'the visible advancing droplet must stay clickable',
    );

    // Pick a point in the same finger's column but far from every advancing
    // droplet. The old implementation accepted the whole column at any depth,
    // so this used to open capillary rise instead of the element drawn there.
    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    Vector2? blindSpot;
    for (
      double y = surfaceY + 8;
      y < surfaceY + soilHeight - 4 && blindSpot == null;
      y += 12
    ) {
      for (double dx = -8; dx <= 8; dx += 4) {
        final candidate = Vector2(tips.first.x + dx, y);
        if (candidate.x < soilX + 2 || candidate.x > soilX + soilWidth - 2) {
          continue;
        }
        if (tips.every((tip) => tip.distanceTo(candidate) > 30)) {
          blindSpot = candidate;
          break;
        }
      }
    }
    expect(blindSpot, isNotNull);
    expect(
      capillary.containsLocalPoint(blindSpot!),
      isFalse,
      reason: 'capillary rise must not own the whole finger column',
    );
  });

  testWidgets('nutrient uptake marker travels through the plant', (
    tester,
  ) async {
    final scene = await pumpCanvasScene(tester);
    await startCanvasScene(tester, scene);

    ProcessLabel? label;
    await pumpCanvasUntil(tester, () {
      label = scene.game.world.children
          .query<ProcessLabel>()
          .where(
            (candidate) => candidate.type == ProcessMarkerType.nutrientUptake,
          )
          .firstOrNull;
      return label != null;
    });

    final marker = label!;
    final path = marker.path;
    expect(
      path,
      isNotNull,
      reason: 'nutrient uptake must use the plant vascular path',
    );
    expect(path!.length, greaterThan(2));
    expect(
      marker.position.distanceTo(path.first),
      lessThan(8.0),
      reason: 'the marker must start at the root tip end of the path',
    );

    final startY = marker.position.y;
    for (var frame = 0; frame < 60 && marker.isMounted; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)),
      );
      await tester.pump(const Duration(milliseconds: 25));
    }

    expect(marker.isMounted, isTrue);
    expect(
      marker.position.y,
      lessThan(startY - 5),
      reason: 'the uptake marker must climb through the plant, not hover',
    );
  });
}
