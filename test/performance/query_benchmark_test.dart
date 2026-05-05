import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/game/components/soil_layer_component.dart';
import 'package:soilscope/presentation/widgets/game/components/data_hotspot_component.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:flutter/material.dart';

void main() {
  test('Flame query performance benchmark: Query vs Cached', () {
    final world = World();

    SoilLayerComponent? firstLayer;
    DataHotspotComponent? firstNo3Node;

    // Create a few layers
    for (int i = 0; i < 5; i++) {
      final layer = SoilLayer(
        id: 'layer_$i',
        thickness: 0.1,
        depth: i * 0.1,
        kSat: 0.1,
        porosity: 0.5,
        thetaR: 0.1,
        vgAlpha: 1.0,
        vgN: 2.0,
        bulkDensity: 1200.0,
        heatCapacity: 2000.0,
        ph: 7.0,
        ec: 1.0,
        redoxPotential: 400.0,
        phosphateContent: 0.05,
        sandFraction: 0.3,
        siltFraction: 0.4,
        clayFraction: 0.3,
        waterContent: 0.2,
        temperature: 20.0,
        particulateOrganicMatter: 10.0,
        maomNitrogen: 10.0,
        microbialBiomass: 10.0,
        fungalHyphaeDensity: 10.0,
        nitrateContent: 10.0,
        ammoniumContent: 10.0,
        aggregateStability: 0.5,
        epsContent: 10.0,
        necromass: 10.0,
        organicCarbon: 10.0,
        mineralAssociatedOrganicMatter: 10.0,
        nitrogenContent: 1.0,
      );

      final layerComp = SoilLayerComponent(
        layerId: 'layer_$i',
        initialLayer: layer,
        initialRect: Rect.fromLTWH(0, i * 100.0, 1200, 100),
        isSelected: false,
      );

      world.add(layerComp);
      if (i == 0) firstLayer = layerComp;

      // Add some nutrient hotspots to each layer
      for (int j = 0; j < 20; j++) {
        final node = DataHotspotComponent(
          label: j == 0 ? 'NO₃⁻' : 'NH₄⁺',
          color: Colors.blue,
          position: Vector2(j * 10.0, 50),
          layerId: 'layer_$i',
          type: HotspotType.nutrient,
        );
        layerComp.add(node);
        if (i == 0 && j == 0) firstNo3Node = node;
      }
    }

    const int iterations = 1000;

    // 1. Baseline (Querying every time)
    final stopwatch1 = Stopwatch()..start();
    int foundCount1 = 0;
    for (int i = 0; i < iterations; i++) {
      final topLayerComp = world.children.query<SoilLayerComponent>().firstOrNull;
      if (topLayerComp != null) {
        DataHotspotComponent? no3Node;
        for (final node in topLayerComp.children.query<DataHotspotComponent>()) {
          if (node.label == 'NO₃⁻') {
            no3Node = node;
            break;
          }
        }
        if (no3Node != null) foundCount1++;
      }
    }
    stopwatch1.stop();

    // 2. Optimized (Using cached components)
    final stopwatch2 = Stopwatch()..start();
    int foundCount2 = 0;
    for (int i = 0; i < iterations; i++) {
      final topLayerComp = firstLayer;
      final no3Node = firstNo3Node;
      if (topLayerComp != null && no3Node != null) {
        foundCount2++;
      }
    }
    stopwatch2.stop();

    debugPrint('Baseline Querying: ${stopwatch1.elapsedMicroseconds} us for $iterations iterations');
    debugPrint('Optimized Caching: ${stopwatch2.elapsedMicroseconds} us for $iterations iterations');

    if (stopwatch2.elapsedMicroseconds > 0) {
       final ratio = stopwatch1.elapsedMicroseconds / stopwatch2.elapsedMicroseconds;
       debugPrint('Improvement: ${ratio.toStringAsFixed(1)}x faster');
    }

    expect(foundCount1, equals(iterations));
    expect(foundCount2, equals(iterations));
  });
}
