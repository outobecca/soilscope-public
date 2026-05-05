import 'dart:math' as math;
import '../../models/plant.dart';
import '../../models/soil_profile.dart';
import '../../models/soil_layer.dart';
import '../../../core/simulation_constants.dart';

/// Logic for plant root system growth, branching and spatial distribution.
class RootArchitectureSolver {
  static final math.Random _rand = math.Random.secure();

  /// Calculates weights for each soil layer based on root density and water availability.
  static (List<double>, double) calculateLayerWeights(
    Plant plant,
    SoilProfile profile,
  ) {
    final List<double> weights = List.filled(profile.layers.length, 0.0);
    double totalWeight = 0.0;

    for (int i = 0; i < profile.layers.length; i++) {
      final layer = profile.layers[i];
      int nodesInLayer = plant.rootSystem
          .where(
            (node) =>
                node.z >= layer.depth &&
                node.z <= layer.depth + layer.thickness,
          )
          .length;

      final waterAvailability =
          ((layer.waterContent - layer.thetaR) /
                  (layer.porosity - layer.thetaR))
              .clamp(0.0, 1.0);

      weights[i] = nodesInLayer * waterAvailability;
      totalWeight += weights[i];
    }
    return (weights, totalWeight);
  }

  /// Grows the root system: adds new nodes, branches existing ones.
  /// Includes Hydrotropism (water) and Chemotropism (N/P).
  static List<RootNode> growRoots(
    Plant plant,
    SoilProfile profile,
    double actualGrowthRate,
    double dt,
  ) {
    final List<RootNode> newRoots = List.from(plant.rootSystem);

    // Seed initial taproot if none exist
    if (newRoots.isEmpty && actualGrowthRate > 1e-9) {
      newRoots.add(
        const RootNode(
          x: 0.5,
          z: 0.0,
          radius: 0.025,
          isTip: true,
          parentIndex: null,
          branchLevel: 0,
          branchSegmentCount: 0,
        ),
      );
    }

    // Stochastic branching and extension
    if (newRoots.length < SimulationConstants.maxRootsPerPlant &&
        actualGrowthRate > 1e-9 &&
        _rand.nextDouble() < 0.18) {
      final List<int> tipIndices = [];
      for (int i = 0; i < newRoots.length; i++) {
        if (newRoots[i].isTip) tipIndices.add(i);
      }

      for (final tipIdx in tipIndices) {
        final tip = newRoots[tipIdx];

        // 0. HIERARCHICAL GROWTH CONSTRAINT: Lateral cannot be longer than parent
        if (tip.branchLevel > 0 && tip.parentIndex != null) {
          final parentBranchLen = _getBranchLength(newRoots, tip.parentIndex!);
          // Laterals are limited to 80% of parent's current length to maintain hierarchy
          if (tip.branchSegmentCount >= parentBranchLen * 0.8 && tip.branchSegmentCount > 5) {
            continue; 
          }
        }
        
        // 1. HIERARCHICAL PROFILE: Calculate factors based on depth (z: 0.0 to 1.0)
        final depthFactor = tip.z.clamp(0.0, 1.0);
        final layerIdx = profile.layers.indexWhere((l) => tip.z >= l.depth && tip.z <= l.depth + l.thickness);
        
        // APICAL DOMINANCE: Branching probability decreases exponentially with depth
        final baseBranchProb = 0.35 * math.exp(-depthFactor * 3.5); 
        final isPrimary = (tip.x - 0.5).abs() < 0.12 && (tip.parentIndex == null || tip.parentIndex! < 80);
        
        // Growth extension probability also tapers for lateral roots
        final extensionProb = isPrimary ? 0.95 : (0.85 * math.exp(-depthFactor * 1.8));
        final shouldBranch = _rand.nextDouble() < baseBranchProb;
        final shouldExtend = _rand.nextDouble() < extensionProb;

        if (shouldExtend || shouldBranch) {
          // 2. FORCES: Base Vector + Steering
          // Taproot (Level 0) always grows down. Laterals follow their branch angle.
          double baseDX = 0.0;
          double baseDZ = 1.0; 

          if (tip.branchLevel > 0 && tip.parentIndex != null) {
            // Establish base direction from the branch origin
            int? current = tipIdx;
            while (current != null && newRoots[current].branchSegmentCount > 0) {
              current = newRoots[current].parentIndex;
            }
            if (current != null && newRoots[current].parentIndex != null) {
              final origin = newRoots[newRoots[current].parentIndex!];
              final start = newRoots[current];
              baseDX = start.x - origin.x;
              baseDZ = start.z - origin.z;
              final len = math.sqrt(baseDX * baseDX + baseDZ * baseDZ);
              if (len > 0) {
                baseDX /= len;
                baseDZ /= len;
              }
            }
          }

          double steeringForceX = 0.0;
          double steeringForceZ = 0.0;

          if (layerIdx != -1) {
            final currentLayer = profile.layers[layerIdx];
            
            // 3. BIOLOGICAL MESH ATTRACTION (Chemotaxis)
            final List<({double x, double z, double energyPotential})> meshNodes = [];
            meshNodes.addAll(_getMeshNodes(currentLayer));
            if (layerIdx + 1 < profile.layers.length) {
              meshNodes.addAll(_getMeshNodes(profile.layers[layerIdx + 1]));
            }
            
            final viableNodes = meshNodes.where((node) => node.z >= tip.z).toList();
            
            double chemotaxisX = 0.0;
            double chemotaxisZ = 0.0;
            
            for (final node in viableNodes) {
              final dx = node.x - tip.x;
              final dz = node.z - tip.z;
              final dist = math.max(0.01, math.sqrt(dx*dx + dz*dz));
              final double flux = node.energyPotential / (dist * dist);
              final weight = 0.005 * math.exp(-depthFactor * 2.0);
              chemotaxisX += (dx / dist) * flux * weight;
              chemotaxisZ += (dz / dist) * flux * weight;
            }

            // Target direction combining Base + Chemotaxis
            double targetDX = baseDX + chemotaxisX;
            double targetDZ = baseDZ + chemotaxisZ;

            // GEOTROPIC CLAMP: Deviation from base vector max 15 degrees
            final double baseAngle = math.atan2(baseDZ, baseDX);
            final double rawTargetAngle = math.atan2(targetDZ, targetDX);
            
            double diff = rawTargetAngle - baseAngle;
            while (diff > math.pi) {
              diff -= 2 * math.pi;
            }
            while (diff < -math.pi) {
              diff += 2 * math.pi;
            }
            
            const double maxDev = 15 * math.pi / 180;
            diff = diff.clamp(-maxDev, maxDev);
            final double clampedAngle = baseAngle + diff;

            steeringForceX = math.cos(clampedAngle);
            steeringForceZ = math.sin(clampedAngle);

            // ABSOLUTE GEOTROPISM: No upward growth allowed
            if (steeringForceZ < 0.1) {
              steeringForceZ = 0.1;
              steeringForceX = steeringForceX > 0 ? 0.99 : -0.99;
            }
          }

          // 4. GROWTH EXECUTION
          const double growthStep = SimulationConstants.rootGrowthStep;
          
          double dx = steeringForceX * growthStep;
          double dz = steeringForceZ * growthStep;
          
          if (isPrimary) {
            dz = dz.clamp(growthStep * 0.1, growthStep);
          } else {
            // STRICT: No upward growth for any root
            dz = dz.clamp(0.0, growthStep);
          }

          // Spatial Avoidance
          bool spaceOccupied = false;
          for (final existing in newRoots) {
             if (_dist(tip.x + dx, tip.z + dz, existing.x, existing.z) < 0.008) {
                spaceOccupied = true;
                break;
             }
          }
          
          if (spaceOccupied) {
             dx += (_rand.nextDouble() - 0.5) * 0.015;
             dz += 0.004;
          }

          final newNode = RootNode(
            x: (tip.x + dx).clamp(0.02, 0.98),
            z: (tip.z + dz).clamp(0.0, 0.985),
            radius: tip.radius * (isPrimary ? 0.997 : 0.982),
            isTip: true,
            parentIndex: tipIdx,
            branchLevel: tip.branchLevel,
            branchSegmentCount: tip.branchSegmentCount + 1,
          );
          newRoots.add(newNode);
          newRoots[tipIdx] = tip.copyWith(isTip: false);

          // 5. BRANCHING: Strict rules for lateral roots
          // CONSTRAINT: Branching Inhibition - Check if this tip has branched recently
          final bool branchedRecently = _hasRecentBranch(newRoots, tipIdx, 10);
          
          if (shouldBranch && !branchedRecently && tip.branchLevel < 2) {
            const double branchStep = SimulationConstants.rootBranchStep;
            
            // CONSTRAINT: Strict branching angle 30-60 degrees downward
            final angle = (30 + _rand.nextDouble() * 30) * (math.pi / 180);
            final branchDirection = _rand.nextBool() ? 1.0 : -1.0;
            
            double bdx = math.sin(angle) * branchDirection * branchStep;
            double bdz = math.cos(angle) * branchStep;
            
            newRoots.add(
              RootNode(
                x: (tip.x + bdx).clamp(0.02, 0.98),
                z: (tip.z + bdz).clamp(0.0, 0.985),
                radius: tip.radius * 0.65, // Lateral is always thinner
                isTip: true,
                parentIndex: tipIdx,
                branchLevel: tip.branchLevel + 1,
                branchSegmentCount: 0,
              ),
            );
        }
      }
    }
  }
  return newRoots;
}

  static List<({double x, double z, double energyPotential})> _getMeshNodes(SoilLayer layer) {
    final rand = math.Random(layer.id.hashCode);
    final List<({double x, double z, double energyPotential})> points = [];
    
    // Bioenergetic value proxy based on C/N ratio and resources
    final cnRatio = layer.cnRatio;
    // Microbes and roots prefer balanced C/N (optimal ~15.0)
    final cnFactor = math.exp(-math.pow(cnRatio - SimulationConstants.microbialCnTarget, 2) / 250.0);
    
    final basePotential = (layer.nitrateContent * 2.5 + layer.phosphateContent * 4.0 + layer.labileCarbon * 0.8) * cnFactor;
    
    for (int i = 0; i < 14; i++) {
      final px = 0.1 + rand.nextDouble() * 0.8;
      final pz = layer.depth + rand.nextDouble() * layer.thickness;
      final potential = (basePotential * (0.8 + rand.nextDouble() * 0.4)).clamp(0.1, 1000.0);
      points.add((x: px, z: pz, energyPotential: potential));
    }
    return points;
  }

  static double _dist(double x1, double z1, double x2, double z2) {
    final dx = x1 - x2;
    final dz = z1 - z2;
    return math.sqrt(dx * dx + dz * dz);
  }

  /// Calculates the total number of segments in the current branch.
  static int _getBranchLength(List<RootNode> nodes, int index) {
    if (index < 0 || index >= nodes.length) return 0;
    int count = 0;
    int? current = index;
    final int level = nodes[index].branchLevel;
    // Traverse up to find the start of this branch level
    while (current != null && nodes[current].branchLevel == level) {
      count++;
      current = nodes[current].parentIndex;
    }
    return count;
  }

  /// Checks if any node has branched from this node recently.
  static bool _hasRecentBranch(List<RootNode> nodes, int index, int lookback) {
    int count = 0;
    int? current = index;
    while (current != null && count < lookback) {
      // Check if this node is a parent to more than one node
      int childrenCount = 0;
      for (final n in nodes) {
        if (n.parentIndex == current) {
          childrenCount++;
        }
        if (childrenCount > 1) {
          return true;
        }
      }
      current = nodes[current].parentIndex;
      count++;
    }
    return false;
  }
}

