import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../soil_scope_game.dart';
import 'expandable_hotspot_node.dart';
import 'scene_coordinate_mapper.dart';

/// Mixin to handle technical node (nutrients, sensors) placement in world space.
mixin LayerTechNodeMixin on PositionComponent, HasGameReference<SoilScopeGame> {
  final math.Random _random = math.Random();

  /// Box-Muller transform for Gaussian distribution
  double _nextGaussian(double mean, double stdDev) {
    final u1 = 1.0 - _random.nextDouble();
    final u2 = _random.nextDouble();
    final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return z0 * stdDev + mean;
  }

  void spawnLayerHUDNodes({
    required String layerId,
    required BiophysicalState state,
  }) {
    final layerIndex = state.profile.layers.indexWhere((l) => l.id == layerId);
    if (layerIndex == -1) return;

    final double layerHeight = size.y;
    final worldWidth = SoilScopeGame.soilColumnWidth;

    // Collect X anchors from ALL plants so that hotspots are spread across the
    // entire root zone rather than biased toward the first plant only.
    final List<double> plantCenterXs = state.plants.isNotEmpty
        ? state.plants
            .map((p) => SceneCoordinateMapper.mapShootPosition(
                  p.baseX,
                  worldWidth,
                  0,
                ).x +
                game.soilLeftX)
            .toList()
        : [game.soilLeftX + worldWidth / 2];

    final int numNodesToSpawn = 2 + _random.nextInt(3); // Spawn 2 to 4 nodes
    const double hotspotRadius = 24.0;
    const double expansionRadius = 60.0;
    // Minimum gap must accommodate two fully-expanded nodes (radius + expansion
    // on each side) so they never overlap when both are opened simultaneously.
    final double minCenterToCenterDistance = (hotspotRadius + expansionRadius) * 2;
    final double minDistanceSq = minCenterToCenterDistance * minCenterToCenterDistance;

    final existingNodes = game.technicalHotspotLayer.children.whereType<ExpandableHotspotNode>().toList();

    // Build a node-type plan: the first slot is always nutrient (biological) and
    // the second is always sensor, guaranteeing that every layer has at least one
    // of each regardless of how many total nodes are spawned (minimum is 2).
    // When exactly 2 nodes spawn the plan is fully deterministic by design —
    // one nutrient + one sensor is the correct minimal coverage.
    // Remaining slots (3rd, 4th) follow the layer-depth probability.
    final List<bool> isBiologicalPlan = [
      true,  // slot 0 → nutrient node (required for flux-particle target lookup)
      false, // slot 1 → sensor node   (required for pH/W/T/O₂/CEC inspection)
    ];
    for (int i = 2; i < numNodesToSpawn; i++) {
      isBiologicalPlan.add(
        (layerIndex == 0) ? _random.nextDouble() < 0.8 : _random.nextDouble() < 0.3,
      );
    }

    for (int i = 0; i < numNodesToSpawn; i++) {
      // Round-robin through plant anchors so every plant is equally represented
      // and no plant is left without a nearby hotspot.
      final double centerX = plantCenterXs[i % plantCenterXs.length];

      int attempts = 0;
      Vector2? validPosition;

      while (attempts < 20) {
        final px = _nextGaussian(centerX, 250.0).clamp(game.soilLeftX + 50.0, game.soilLeftX + worldWidth - 50.0);
        final py = position.y + 20.0 + _random.nextDouble() * (layerHeight - 40.0);
        final candidatePos = Vector2(px, py);

        bool isValid = true;
        for (final node in existingNodes) {
          if (node.position.distanceToSquared(candidatePos) < minDistanceSq) {
            isValid = false;
            break;
          }
        }

        if (isValid) {
          validPosition = candidatePos;
          break;
        }
        attempts++;
      }

      if (validPosition != null) {
        final isBiological = isBiologicalPlan[i];

        final List<String> metrics = [];
        if (isBiological) {
          if (layerIndex == 0) {
            metrics.addAll(['NH₄⁺', 'NO₃⁻', 'P', 'K', 'POM-N', 'Mic-N']);
          } else {
            metrics.addAll(['NH₄⁺', 'NO₃⁻', 'MAOM-N']);
          }
        } else {
          if (layerIndex == 0) {
            metrics.addAll(['pH', 'W', 'T', 'O2', 'CEC']);
          } else {
            metrics.addAll(['W', 'CEC']);
          }
        }

        final newNode = ExpandableHotspotNode(
          layerId: layerId,
          metrics: metrics,
          position: validPosition,
        );
        game.technicalHotspotLayer.add(newNode);
        existingNodes.add(newNode);
      }
    }
  }
}
