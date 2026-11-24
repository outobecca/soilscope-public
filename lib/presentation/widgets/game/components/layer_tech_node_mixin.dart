import 'dart:math' as math;
import 'package:flame/components.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../soil_scope_game.dart';
import 'expandable_hotspot_node.dart';
import 'scene_coordinate_mapper.dart';
import 'visual_seed.dart';

/// Mixin to handle technical node (nutrients, sensors) placement in world space.
mixin LayerTechNodeMixin on PositionComponent, HasGameReference<SoilScopeGame> {
  /// Layer identity supplied by the owning component; also seeds the node RNG.
  String get layerId;

  // Each layer needs its own sequence. A shared seed gave every layer the same
  // normal-distributed offsets, so the sampling nodes lined up in a vertical
  // column instead of following each layer's own root zone.
  late final math.Random _random = visualRandom([
    'layer-tech-nodes',
    layerId,
  ]);
  bool _hudNodesSpawned = false;

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

    // Flame does not expose a just-added child in the tree until it mounts.
    // Remember the spawn on the layer itself so two syncs in one frame cannot
    // add duplicate targets while the first set is still pending.
    final existingNodes = game.technicalHotspotLayer.children
        .query<ExpandableHotspotNode>()
        .where((node) => node.layerId == layerId)
        .toList();
    if (_hudNodesSpawned || existingNodes.isNotEmpty) {
      _hudNodesSpawned = true;
      return;
    }

    final double layerHeight = size.y;
    final worldWidth = SoilScopeGame.soilColumnWidth;

    // Sampling nodes belong to the one-square-metre plot the roots occupy, not
    // to the decorative soil margins. Anchor them on the root tips that actually
    // fall inside this layer and keep the normal spread inside the plot bounds.
    final double plotWidth = SceneCoordinateMapper.plotWidth(worldWidth);
    final double plotLeft = game.plotCenterX - plotWidth / 2;
    final double plotRight = game.plotCenterX + plotWidth / 2;
    const double hotspotHalfExtent = 20.0;
    final double minX = plotLeft + hotspotHalfExtent;
    final double maxX = plotRight - hotspotHalfExtent;

    final double layerTop = position.y;
    final double layerBottom = position.y + layerHeight;
    final List<double> rootAnchors = game.rootTipWorldPositions
        .where((tip) => tip.y >= layerTop && tip.y <= layerBottom)
        .map((tip) => tip.x)
        .toList();
    final List<double> anchorXs = rootAnchors.isEmpty
        ? [game.plotCenterX]
        : rootAnchors;

    final int numNodesToSpawn = 2 + _random.nextInt(3); // Spawn 2 to 4 nodes
    const double hotspotRadius = 24.0;
    const double expansionRadius = 60.0;
    // A tap is routed to the topmost TapCallbacks component at the point.
    // Keep expanded clusters separated so the winner is unambiguous; the gap
    // accommodates two fully-expanded nodes (radius + expansion on each side).
    final double minCenterToCenterDistance =
        (hotspotRadius + expansionRadius) * 2;
    final double minDistanceSq =
        minCenterToCenterDistance * minCenterToCenterDistance;

    final allNodes = game.technicalHotspotLayer.children
        .whereType<ExpandableHotspotNode>()
        .toList();

    // A sampling node must not sit on top of a dynamic rhizosphere marker: the
    // technical overlay wins the tap, so an overlapping node would make the
    // rhizosphere hotspot unreachable. Reserve the model hotspots that fall in
    // this layer before choosing positions.
    final List<Vector2> reservedCenters = [];
    for (final hotspot in state.profile.layers[layerIndex].hotspots) {
      reservedCenters.add(
        Vector2(
          position.x + SceneCoordinateMapper.mapRootX(hotspot.x, worldWidth),
          layerTop + hotspot.z * layerHeight,
        ),
      );
    }
    // A cluster expands its metrics to 60 px, and a metric keeps a ~24 px
    // hit radius even when zoomed out. Keep the whole expansion clear of a
    // rhizosphere marker so the two interactive targets stay distinguishable.
    const double minRhizosphereDistance = 110.0;
    final double minRhizosphereDistanceSq =
        minRhizosphereDistance * minRhizosphereDistance;

    // Build a node-type plan: the first slot is always nutrient (biological) and
    // the second is always sensor, guaranteeing that every layer has at least one
    // of each regardless of how many total nodes are spawned (minimum is 2).
    // When exactly 2 nodes spawn the plan is fully deterministic by design —
    // one nutrient + one sensor is the correct minimal coverage.
    // Remaining slots (3rd, 4th) follow the layer-depth probability.
    final List<bool> isBiologicalPlan = [
      true, // slot 0 → nutrient node (required for flux-particle target lookup)
      false, // slot 1 → sensor node   (required for pH/W/T/O₂/CEC inspection)
    ];
    for (int i = 2; i < numNodesToSpawn; i++) {
      isBiologicalPlan.add(
        (layerIndex == 0)
            ? _random.nextDouble() < 0.8
            : _random.nextDouble() < 0.3,
      );
    }

    final double verticalMargin = math.min(20.0, layerHeight / 4);
    final double usableHeight = math.max(
      0.0,
      layerHeight - verticalMargin * 2,
    );

    for (int i = 0; i < numNodesToSpawn; i++) {
      // Round-robin through the layer's root tips so the sampling nodes follow
      // the rhizosphere instead of an arbitrary point in the soil.
      final double centerX = anchorXs[i % anchorXs.length].clamp(minX, maxX);

      int attempts = 0;
      Vector2? validPosition;
      Vector2? bestPosition;
      double bestClearanceSq = -1.0;

      while (attempts < 40) {
        final px = _nextGaussian(
          centerX,
          plotWidth * 0.18,
        ).clamp(minX, maxX);
        final py =
            layerTop + verticalMargin + _random.nextDouble() * usableHeight;
        final candidatePos = Vector2(px, py);

        bool isValid = true;
        double clearanceSq = double.infinity;
        for (final node in allNodes) {
          final distanceSq = node.position.distanceToSquared(candidatePos);
          if (distanceSq < minDistanceSq) {
            isValid = false;
          }
          if (distanceSq < clearanceSq) clearanceSq = distanceSq;
        }
        for (final reserved in reservedCenters) {
          final distanceSq = reserved.distanceToSquared(candidatePos);
          if (distanceSq < minRhizosphereDistanceSq) {
            isValid = false;
          }
          if (distanceSq < clearanceSq) clearanceSq = distanceSq;
        }
        if (clearanceSq > bestClearanceSq) {
          bestClearanceSq = clearanceSq;
          bestPosition = candidatePos;
        }

        if (isValid) {
          validPosition = candidatePos;
          break;
        }
        attempts++;
      }

      // A crowded layer still gets its guaranteed sampling coverage; pick the
      // roomiest candidate instead of silently dropping the node.
      validPosition ??= bestPosition;

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
          layerAnchor: Vector2(
            ((validPosition.x - position.x) / size.x).clamp(0.0, 1.0),
            ((validPosition.y - position.y) / size.y).clamp(0.0, 1.0),
          ),
        );
        game.technicalHotspotLayer.add(newNode);
        allNodes.add(newNode);
        _hudNodesSpawned = true;
      }
    }
  }
}
