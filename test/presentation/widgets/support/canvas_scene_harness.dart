import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/flame_simulation_view.dart';
import 'package:soilscope/presentation/widgets/game/components/animated_microbe_component.dart';
import 'package:soilscope/presentation/widgets/game/components/expandable_hotspot_node.dart';
import 'package:soilscope/presentation/widgets/game/components/rhizosphere_hotspot_component.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

/// The simulation canvas without the HUD, on a fixed 1024x900 surface.
///
/// Hit tests and pixel captures use this so pointer positions and pixels are
/// never covered by the timeline, quick actions or an information card. The
/// scene itself is the production [FlameSimulationView] and production
/// providers; only the surrounding chrome is omitted.
class CanvasScene {
  CanvasScene({required this.container, required this.boundaryKey});

  final ProviderContainer container;
  final GlobalKey boundaryKey;

  SoilScopeGame get game => container.read(soilScopeGameProviderProvider)!;

  List<SoilLayerComponent> get layers =>
      game.world.children.whereType<SoilLayerComponent>().toList();

  Size get size {
    final box = testerBox;
    return box.size;
  }

  RenderBox get testerBox {
    final boundary = boundaryKey.currentContext!.findRenderObject()!;
    return boundary as RenderBox;
  }

  /// Canvas-local pixel position of a world coordinate.
  Offset screenOfWorld(Vector2 world) {
    final screen = game.worldToScreen(world);
    return testerBox.localToGlobal(Offset.zero) + Offset(screen.x, screen.y);
  }

  /// Drawn centre of an expandable hotspot cluster.
  Vector2 nodeCenter(ExpandableHotspotNode node) =>
      node.absolutePositionOf(node.size / 2);
}

/// Pumps frames and lets real isolates deliver work until [condition] holds.
Future<void> pumpCanvasUntil(
  WidgetTester tester,
  bool Function() condition, {
  int attempts = 240,
  Duration step = const Duration(milliseconds: 25),
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    await tester.runAsync(() => Future<void>.delayed(step));
    await tester.pump(step);
    if (condition()) return;
  }
  fail('the canvas did not reach the expected state');
}

/// Runs the production canvas on a fixed surface and returns its live scene.
Future<CanvasScene> pumpCanvasScene(
  WidgetTester tester, {
  Scenario? scenario,
  Size size = const Size(1024, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});

  final effectiveScenario = scenario ?? canvasScenario();
  final container = ProviderContainer(
    overrides: [
      scenariosProvider.overrideWith((ref) => [effectiveScenario]),
    ],
  );
  addTearDown(container.dispose);
  // The observation cycle is auto-disposed unless something listens; the
  // production canvas only reads it during render.
  container.listen(activeCycleProvider, (_, _) {}, fireImmediately: true);

  container.read(simulationProvider);
  await pumpCanvasUntil(
    tester,
    () => !container.read(simulationProvider).isInitializing,
  );
  container.read(simulationProvider.notifier).loadScenario(effectiveScenario);

  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: const FlameSimulationView(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  await pumpCanvasUntil(tester, () {
    final game = container.read(soilScopeGameProviderProvider);
    if (game == null) return false;
    final layers = game.world
        .descendants()
        .whereType<SoilLayerComponent>()
        .toList();
    final nodes = game.world
        .descendants()
        .whereType<ExpandableHotspotNode>()
        .toList();
    // Wait until every layer has its nutrient and sensor clusters, otherwise
    // stopping the scene can freeze a half-populated layout.
    return layers.length >= 2 &&
        layers.every(
          (layer) =>
              nodes.where((node) => node.layerId == layer.layerId).length >= 2,
        );
  });

  final scene = CanvasScene(container: container, boundaryKey: boundaryKey);
  if (effectiveScenario.initialProfile.layers.any(
    (layer) => layer.hotspots.isNotEmpty,
  )) {
    await pumpCanvasUntil(
      tester,
      () => scene.game.world
          .descendants()
          .whereType<RhizosphereHotspotComponent>()
          .isNotEmpty,
    );
  }
  return scene;
}

/// Starts the production engine and lets the visuals populate.
Future<void> startCanvasScene(WidgetTester tester, CanvasScene scene) async {
  scene.container.read(simulationProvider.notifier).start();
  await pumpCanvasUntil(
    tester,
    () => scene.game.world
        .descendants()
        .whereType<AnimatedMicrobeComponent>()
        .isNotEmpty,
  );
}

Future<ui.Image> grabCanvasImage(WidgetTester tester, CanvasScene scene) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(scene.boundaryKey),
  );
  // toImage() waits for a frame that a continuously ticking GameWidget may
  // never hand to the test binding; toImageSync() snapshots the painted layer.
  return boundary.toImageSync(pixelRatio: 1.0);
}

Future<Uint8List> canvasPngBytes(WidgetTester tester, ui.Image image) async {
  final data = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.png),
  );
  return data!.buffer.asUint8List();
}

Future<Uint8List> canvasRawBytes(WidgetTester tester, ui.Image image) async {
  final data = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  return data!.buffer.asUint8List();
}

/// Writes a PNG under build/ for human inspection. Build output is ignored by
/// version control and never shipped.
Future<String> writeCanvasPng(
  WidgetTester tester,
  ui.Image image,
  String relativePath,
) async {
  final bytes = await canvasPngBytes(tester, image);
  await tester.runAsync(() async {
    final file = File(relativePath)..parent.createSync(recursive: true);
    await file.writeAsBytes(bytes);
  });
  return relativePath;
}

/// Writes the per-pixel difference as a PNG so the changed regions can be
/// inspected, not only counted.
Future<void> writeCanvasDiffPng(
  WidgetTester tester,
  Uint8List before,
  Uint8List after,
  int width,
  int height,
  String relativePath,
) async {
  final diff = Uint8List(before.length);
  for (var i = 0; i < before.length; i += 4) {
    final changed =
        (before[i] - after[i]).abs() > 8 ||
        (before[i + 1] - after[i + 1]).abs() > 8 ||
        (before[i + 2] - after[i + 2]).abs() > 8;
    diff[i] = changed ? 255 : 0;
    diff[i + 1] = changed ? 40 : 0;
    diff[i + 2] = changed ? 40 : 0;
    diff[i + 3] = 255;
  }

  await tester.runAsync(() async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(diff);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    final file = File(relativePath)..parent.createSync(recursive: true);
    await file.writeAsBytes(data!.buffer.asUint8List());
  });
}

/// Counts pixels that differ by more than [threshold] in any colour channel,
/// optionally inside a square patch.
int changedCanvasPixels(
  Uint8List before,
  Uint8List after,
  int width,
  int height, {
  int? centerX,
  int? centerY,
  int radius = 0,
  int threshold = 8,
}) {
  var startX = 0;
  var endX = width - 1;
  var startY = 0;
  var endY = height - 1;
  if (centerX != null && centerY != null) {
    startX = (centerX - radius).clamp(0, width - 1);
    endX = (centerX + radius).clamp(0, width - 1);
    startY = (centerY - radius).clamp(0, height - 1);
    endY = (centerY + radius).clamp(0, height - 1);
  }

  var changed = 0;
  for (var y = startY; y <= endY; y++) {
    for (var x = startX; x <= endX; x++) {
      final i = (y * width + x) * 4;
      if ((before[i] - after[i]).abs() > threshold ||
          (before[i + 1] - after[i + 1]).abs() > threshold ||
          (before[i + 2] - after[i + 2]).abs() > threshold) {
        changed++;
      }
    }
  }
  return changed;
}

/// Two-layer soil column with one rhizosphere hotspot. The top layer can be
/// saturated so denitrification (and its N2O bubbles) is active in captures.
Scenario canvasScenario({double topWaterContent = 0.25}) {
  SoilLayer layer({
    required String id,
    required double depth,
    required double thickness,
    required String name,
    double waterContent = 0.25,
    List<RhizosphereHotspot> hotspots = const [],
  }) {
    return SoilLayer(
      id: id,
      depth: depth,
      thickness: thickness,
      kSat: 1e-5,
      porosity: id == 'topsoil' ? 0.52 : 0.45,
      thetaR: 0.05,
      vgAlpha: 2.0,
      vgN: 1.5,
      bulkDensity: 1200.0,
      waterContent: waterContent,
      temperature: 293.15,
      heatCapacity: 2.4e6,
      ph: 6.5,
      ec: 0.2,
      redoxPotential: id == 'topsoil' ? 120.0 : 250.0,
      nitrateContent: id == 'topsoil' ? 40.0 : 10.0,
      ammoniumContent: id == 'topsoil' ? 20.0 : 5.0,
      phosphateContent: 3.0,
      microbialBiomass: id == 'topsoil' ? 300.0 : 100.0,
      epsContent: 10.0,
      fungalHyphaeDensity: 20.0,
      necromass: 100.0,
      organicCarbon: id == 'topsoil' ? 12000.0 : 8000.0,
      particulateOrganicMatter: 6000.0,
      mineralAssociatedOrganicMatter: id == 'topsoil' ? 6000.0 : 4000.0,
      nitrogenContent: 1000.0,
      name: name,
      hotspots: hotspots,
    );
  }

  return Scenario(
    id: 'canvas_scene',
    title: 'Canvas scene',
    description: 'Two layers with a known rhizosphere hotspot.',
    initialProfile: SoilProfile(
      id: 'canvas_scene',
      name: 'Canvas scene',
      layers: [
        layer(
          id: 'topsoil',
          depth: 0.0,
          thickness: 0.3,
          name: 'Topsoil',
          waterContent: topWaterContent,
          hotspots: const [
            RhizosphereHotspot(
              id: 'rhizosphere-test',
              x: 0.0,
              z: 0.5,
              intensity: 0.8,
            ),
          ],
        ),
        layer(id: 'subsoil', depth: 0.3, thickness: 0.5, name: 'Subsoil'),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.05,
    ),
    weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
  );
}
