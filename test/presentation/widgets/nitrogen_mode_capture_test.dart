import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:soilscope/domain/solvers/particle_physics_solver.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/animated_microbe_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/nitrous_oxide_bubble_component.dart';
import 'package:soilscope/presentation/widgets/game/components/particle_system_component.dart';
import 'package:soilscope/presentation/widgets/game/components/process_label_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

import 'support/canvas_scene_harness.dart';

/// Rendered proof that switching the observation mode changes the canvas,
/// including the isolate-driven batch particles, microbes, gas, process labels
/// and technical hotspots. The captures are written under build/ so they can
/// be opened and inspected, not only asserted on.
void main() {
  testWidgets('nitrogen mode repaints batch particles and the painted scene', (
    tester,
  ) async {
    final scene = await pumpCanvasScene(
      tester,
      scenario: canvasScenario(topWaterContent: 0.5),
    );
    final game = scene.game;

    await startCanvasScene(tester, scene);
    await pumpCanvasUntil(tester, () {
      final field = game.world
          .descendants()
          .whereType<MolecularParticleFieldComponent>()
          .firstOrNull;
      return field != null && field.particleData.length >= 30;
    });

    final field = game.world
        .descendants()
        .whereType<MolecularParticleFieldComponent>()
        .first;
    final realIsolateCount = field.particleData.length ~/ 10;
    expect(
      realIsolateCount,
      greaterThan(4),
      reason: 'the capture must contain the real batch particle stream',
    );

    // Seed one particle of every form the canvas highlights so the capture
    // proves each one changes, not only whichever types the run happened to
    // emit. These travel through the production isolate, its packing and the
    // same Float32List frame the renderer consumes.
    final seedWorld = <ParticleType, Vector2>{
      ParticleType.nitrate: Vector2(470, 700),
      ParticleType.ammonium: Vector2(550, 745),
      ParticleType.labileCarbon: Vector2(630, 695),
      ParticleType.organicNitrogen: Vector2(682, 735),
      // Water belongs to neither the carbon nor the nitrogen cycle. Keep it in
      // the frame as a control: both modes dim it, so its pixels barely move.
      ParticleType.water: Vector2(730, 760),
    };
    final isolate = scene.container
        .read(simulationProvider.notifier)
        .particleIsolate;
    isolate.addParticles([
      for (final entry in seedWorld.entries)
        Particle(
          id: 9000 + entry.key.index,
          type: entry.key,
          x: entry.value.x,
          y: entry.value.y,
          life: 1.0,
        ),
    ]);

    await pumpCanvasUntil(tester, () {
      final ids = <int>{};
      for (var i = 0; i < field.particleData.length; i += 10) {
        ids.add(field.particleData[i].toInt());
      }
      return seedWorld.keys.every((type) => ids.contains(9000 + type.index));
    });

    final seededIds = <int>{};
    final seededTypes = <ParticleType>{};
    for (var i = 0; i < field.particleData.length; i += 10) {
      final id = field.particleData[i].toInt();
      if (id >= 9000 && id < 9000 + ParticleType.values.length) {
        seededIds.add(id);
        seededTypes.add(ParticleType.values[field.particleData[i + 5].toInt()]);
      }
    }
    expect(seededIds, hasLength(seedWorld.length));
    expect(seededTypes, containsAll(seedWorld.keys));

    // Real process labels in known places: one nitrogen process that should
    // brighten in nitrogen mode and one that should recede.
    game.world.add(
      ProcessLabel(
        type: ProcessMarkerType.nitrification,
        color: const Color(0xFF3B82F6),
        position: Vector2(420, 800),
        isStatic: true,
        showTitle: true,
      ),
    );
    game.world.add(
      ProcessLabel(
        type: ProcessMarkerType.photosynthesis,
        color: const Color(0xFFF59E0B),
        position: Vector2(820, 700),
        isStatic: true,
        showTitle: true,
      ),
    );
    await tester.pump();

    final microbe = game.world
        .descendants()
        .whereType<AnimatedMicrobeComponent>()
        .first;
    final nitrogenNode = game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .firstWhere((node) => node.exposesNitrogenPools);

    final topLayer = game.displayedState.profile.layers.first;
    expect(
      (topLayer.porosity - topLayer.waterContent).clamp(0.0, 1.0),
      lessThan(0.025),
      reason: 'the scenario keeps the topsoil anaerobic so N2O is emitted',
    );
    expect(
      game.world.descendants().whereType<NitrousOxideBubbleComponent>(),
      isNotEmpty,
    );

    // Freeze the visual clock and the particle stream so the only difference
    // between the two captures is the observation mode.
    scene.container.read(simulationProvider.notifier).stop();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));

    // A stop command can still race a final physics snapshot. Wait until two
    // consecutive rendered frames carry the same particle buffer, then hold
    // the test to that buffer across both captures; otherwise particle motion
    // would be indistinguishable from the mode repaint in the pixel counts.
    List<double>? previousFrame;
    await pumpCanvasUntil(tester, () {
      final current = List<double>.of(field.particleData);
      final same = previousFrame != null && listEquals(current, previousFrame);
      previousFrame = current;
      return same;
    }, attempts: 30);
    final frozenFrame = List<double>.of(field.particleData);

    Future<Uint8List> capture(ObservationCycle cycle, String name) async {
      scene.container.read(activeCycleProvider.notifier).setCycle(cycle);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(scene.container.read(activeCycleProvider), cycle);

      final image = await grabCanvasImage(tester, scene);
      await writeCanvasPng(
        tester,
        image,
        'build/nitrogen_mode_capture/$name.png',
      );
      return canvasRawBytes(tester, image);
    }

    final carbon = await capture(ObservationCycle.carbon, 'carbon');
    final nitrogen = await capture(ObservationCycle.nitrogen, 'nitrogen');
    expect(
      field.particleData,
      orderedEquals(frozenFrame),
      reason: 'the particle buffer must be frozen across both captures',
    );

    final width = scene.size.width.round();
    final height = scene.size.height.round();
    expect(carbon.length, width * height * 4);
    expect(nitrogen.length, width * height * 4);

    final totalChanged = changedCanvasPixels(carbon, nitrogen, width, height);
    expect(
      totalChanged,
      greaterThan(5000),
      reason: 'the observation mode must visibly change the canvas',
    );

    int patch(Vector2 world, int radius) {
      final center = scene.screenOfWorld(world);
      return changedCanvasPixels(
        carbon,
        nitrogen,
        width,
        height,
        centerX: center.dx.round(),
        centerY: center.dy.round(),
        radius: radius,
      );
    }

    final patchResults = <String, int>{};
    for (final entry in seedWorld.entries) {
      final count = patch(entry.value, 20);
      patchResults[entry.key.name] = count;
      if (entry.key == ParticleType.water) continue;
      expect(
        count,
        greaterThan(100),
        reason:
            'batch particle ${entry.key.name} at ${entry.value} must change '
            'between carbon and nitrogen mode',
      );
    }
    patchResults['nitrogen-label'] = patch(Vector2(420, 800), 22);
    patchResults['carbon-label'] = patch(Vector2(820, 700), 22);
    patchResults['microbe'] = patch(
      microbe.absolutePositionOf(microbe.size / 2),
      24,
    );
    patchResults['hotspot'] = patch(scene.nodeCenter(nitrogenNode), 24);

    expect(patchResults['nitrogen-label'], greaterThan(200));
    expect(patchResults['carbon-label'], greaterThan(200));
    expect(patchResults['microbe'], greaterThan(200));
    expect(patchResults['hotspot'], greaterThan(200));
    // The particle buffer was frozen and water is in neither active cycle, so
    // this control patch must be pixel-identical in both modes. A non-zero
    // value would mean the diff is contaminated by particle motion.
    expect(patchResults['water'], 0);

    // Gas bubbles rise over the surface; some sit behind foreground overlays,
    // so require that at least one drawn bubble changes rather than a
    // particular index.
    var changedBubbles = 0;
    for (var i = 0; i < 12; i++) {
      final phase = (game.currentTime() * 0.6 + i * 0.15) % 1.0;
      final world = Vector2(
        game.soilLeftX +
            (i + 1) * (SoilScopeGame.soilColumnWidth / 13) +
            math.sin(game.currentTime() * 2 + i) * 15,
        game.soilSurfaceY - phase * 70,
      );
      final count = patch(world, 24);
      if (count > 30) changedBubbles++;
    }
    expect(
      changedBubbles,
      greaterThanOrEqualTo(1),
      reason: 'the denitrification bubbles must repaint in nitrogen mode',
    );

    patchResults['total'] = totalChanged;
    patchResults['changed-bubbles'] = changedBubbles;
    // ignore: avoid_print
    print(
      'NITROGEN CAPTURE: $patchResults -> '
      'build/nitrogen_mode_capture/{carbon,nitrogen}.png',
    );

    await writeCanvasDiffPng(
      tester,
      carbon,
      nitrogen,
      width,
      height,
      'build/nitrogen_mode_capture/diff.png',
    );

    expect(
      scene.container.read(activeCycleProvider),
      ObservationCycle.nitrogen,
    );
  });
}
