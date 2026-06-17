import 'dart:ui' show PathMetric, lerpDouble;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/plant.dart';
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import 'soil_symbiosis_network_component.dart';
import 'scene_coordinate_mapper.dart';
import 'molecule_renderer.dart';
import 'riverpod_lifecycle_mixin.dart';

/// Primary visual entity representing a dynamic plant system.
/// Handles high-fidelity growth animations and biophysical interactions.
class AnimatedPlantComponent extends PositionComponent
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        RiverpodLifecycleMixin {
  final String plantId;
  final math.Random _random = math.Random();

  // Physiological Smoothing State
  double _smoothTurgor = 1.0;
  double _smoothVitality = 1.0;
  double _smoothBiomass = 50.0;
  double _smoothAge = 0.0;
  double _senescence = 0.0; // 0 (fresh) to 1 (senescent/yellow)
  double _solarRadiation = 800; // Average solar radiation in W/m^2
  double _growthBoost = 0.0;
  bool _isPinned = false;
  Plant? _plant;
  bool _isRunning = false;

  final List<_RootTipGlow> _tipGlows = [];
  final Map<int, double> _nodeBirthTimes = {};
  double _vaporTimer = 0;
  int _previousRootCount = 0;

  // Schematic Layout State
  VisualLayoutMode _layoutMode = VisualLayoutMode.organic;
  double _layoutProgress = 0.0; // 0 = organic, 1 = schematic
  final Map<int, Vector2> _schematicRootPositions = {};
  
  static const int maxTipGlows = 25;

  int? _hoveredRootIndex;
  int? _pinnedRootIndex;

  final List<CircleHitbox> _activeHitboxes = [];

  static final Vector2 _tmpVec = Vector2.zero();

  // Cached Paints for optimization
  final Paint _branchPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _tipGlowPaint = Paint();

  final Paint _leafBasePaint = Paint()..style = PaintingStyle.fill;
  final Paint _leafGradientPaint = Paint();
  final Paint _veinPaint = Paint()
    ..color = Colors.black.withValues(alpha: 0.15)
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  final Paint _leafHighlightPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.1)
    ..style = PaintingStyle.stroke;
  final Paint _leafPulsePaint = Paint()
    ..style = PaintingStyle.stroke
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

  AnimatedPlantComponent({
    required this.plantId,
    super.position,
    super.size,
    super.anchor = Anchor.topLeft,
  }) : super(priority: 50);

  /// Finds a world-space path from a root position up to the shoot foliage.
  List<Vector2>? getPlantVascularPath(Vector2 startWorld) {
    final plant = _plant;
    if (plant == null) return null;

    // 1. Find nearest root node
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;

    RootNode? nearest;
    double minDist = 999999;

    for (int i = 0; i < plant.rootSystem.length; i++) {
      final node = plant.rootSystem[i];
      final nodeWorldPos = Vector2(
        SceneCoordinateMapper.mapRootX(node.x, worldWidth, baseX: plant.baseX) +
            soilX,
        SceneCoordinateMapper.mapRootY(node.z, surfaceY, soilHeight),
      );
      final dist = startWorld.distanceTo(nodeWorldPos);
      if (dist < minDist) {
        minDist = dist;
        nearest = node;
      }
    }

    if (nearest == null) return null;

    final List<Vector2> path = [];
    RootNode? curr = nearest;
    while (curr != null) {
      final nodePos = Vector2(
        SceneCoordinateMapper.mapRootX(curr.x, worldWidth, baseX: plant.baseX) +
            soilX,
        SceneCoordinateMapper.mapRootY(curr.z, surfaceY, soilHeight),
      );
      path.add(nodePos);
      if (curr.parentIndex != null &&
          curr.parentIndex! < plant.rootSystem.length) {
        curr = plant.rootSystem[curr.parentIndex!];
      } else {
        curr = null;
      }
    }

    // 3. Build shoot path (stem)
    final shootScale = SceneCoordinateMapper.getShootScale(
      plant,
      growthBoost: _growthBoost,
    );
    final h = 450.0 * shootScale;

    // Stem Bezier points (local to collar)
    final topX = 0.0; 
    final topY = -h;
    final cp1X = 0.0;
    final cp1Y = -h * 0.4;
    final cp2X = topX * 0.8;
    final cp2Y = topY * 0.7;

    final collarPos = path.last;
    for (int i = 1; i <= 5; i++) {
      final t = i / 5.0;
      final lx = _cubicBezier(0, cp1X, cp2X, topX, t);
      final ly = _cubicBezier(0, cp1Y, cp2Y, topY, t);
      path.add(collarPos + Vector2(lx, ly));
    }

    return path;
  }

  @override
  void onMount() {
    super.onMount();

    // Fine-grained listener for THIS plant's data
    listenProvider<Plant?>(
      displayedSimulationStateProvider.select(
        (s) => s.plants.firstWhere(
          (p) => p.id == plantId,
          orElse: () => s.plants.first,
        ),
      ),
      (prev, next) {
        _plant = next;
        if (next != null && next.rootSystem.length > _previousRootCount) {
          final time = game.currentTime();
          for (int i = _previousRootCount; i < next.rootSystem.length; i++) {
            _nodeBirthTimes[i] = time;
          }
          _onNewRootGrowth(next);
          _previousRootCount = next.rootSystem.length;
        }
      },
      fireImmediately: true,
    );

    // Listen to simulation running state
    listenProvider<bool>(
      simulationProvider.select((s) => s.isRunning),
      (prev, next) => _isRunning = next,
      fireImmediately: true,
    );

    // Listen to solar radiation (affects photosynthesis visuals)
    listenProvider<double>(
      displayedSimulationStateProvider.select((s) => s.solarRadiation),
      (prev, next) => _solarRadiation = next,
      fireImmediately: true,
    );

    // Listen to layout mode
    listenProvider<VisualLayoutMode>(
      visualLayoutModeStateProvider,
      (prev, next) {
        _layoutMode = next;
        if (next == VisualLayoutMode.schematic) {
          final plant = _plant;
          if (plant != null) _calculateSchematicLayout(plant);
        }
      },
      fireImmediately: true,
    );
  }

  void triggerGrowth() {
    _growthBoost = 0.25;
  }

  void _syncRootHitboxes(Plant plant) {
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;

    final nodes = plant.rootSystem;
    int hitboxIndex = 0;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      // Represent tips and significant nodes for collision
      if (!node.isTip && i % 4 != 0) continue;

      final localPos = _mapRootToLocal(
        node,
        i,
        plant.baseX,
        worldWidth,
        soilHeight,
      );

      if (hitboxIndex < _activeHitboxes.length) {
        _tmpVec.setFrom(localPos);
        _activeHitboxes[hitboxIndex].position.setFrom(_tmpVec);
      } else {
        _tmpVec.setFrom(localPos);
        final hb = CircleHitbox(
          radius: 6.0, // Reduced absorption reach
          position: _tmpVec.clone(),
          anchor: Anchor.center,
        );
        add(hb);
        _activeHitboxes.add(hb);
      }
      hitboxIndex++;
    }

    // Remove excess hitboxes
    while (_activeHitboxes.length > hitboxIndex) {
      final hb = _activeHitboxes.removeLast();
      hb.removeFromParent();
    }
  }

  /// Fetches the specific plant data from the simulation state.
  Plant? get _plantData => _plant;

  void _cleanupExpiredParticles() {
    // Enforce max counts
    while (_tipGlows.length > maxTipGlows) {
      _tipGlows.removeAt(0);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _cleanupExpiredParticles();

    final plant = _plantData;
    if (plant == null) return;

    // 0. Update Layout Animation
    final targetProgress = _layoutMode == VisualLayoutMode.schematic ? 1.0 : 0.0;
    if ((_layoutProgress - targetProgress).abs() > 0.001) {
      final step = dt * 1.5;
      if (_layoutProgress < targetProgress) {
        _layoutProgress = (_layoutProgress + step).clamp(0.0, 1.0);
      } else {
        _layoutProgress = (_layoutProgress - step).clamp(0.0, 1.0);
      }
    }

    if (_layoutProgress > 0.001) {
      // Recalculate if root system has grown since last calculation
      if (plant.rootSystem.length != _schematicRootPositions.length) {
        _calculateSchematicLayout(plant);
      }
    }

    // 1. Synchronize world position with Root Collar (Node 0)
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;

    final collarNode = plant.rootSystem.isNotEmpty
        ? plant.rootSystem.first
        : null;
    final collarX = collarNode?.x ?? 0.5;
    final collarZ = collarNode?.z ?? 0.0;

    final collarWorldX =
        SceneCoordinateMapper.mapRootX(
          collarX,
          worldWidth,
          baseX: plant.baseX,
        ) +
        soilX;

    final collarWorldY = SceneCoordinateMapper.mapRootY(
      collarZ,
      surfaceY,
      game.soilColumnHeight,
    );

    _tmpVec.setValues(collarWorldX, collarWorldY);
    position.setFrom(_tmpVec);

    // 1b. Synchronize Hitboxes with Root Nodes
    _syncRootHitboxes(plant);

    if (!_isRunning) return;

    if (_growthBoost > 0) {
      _growthBoost = (_growthBoost - dt * 0.4).clamp(0.0, 1.0);
    }

    if (plant.rootSystem.length > _previousRootCount) {
      _onNewRootGrowth(plant);
    }
    _previousRootCount = plant.rootSystem.length;

    // 2. Periodic "Active Maintenance" glows for healthy tips
    final vitality = (1.0 - plant.waterStressIndex).clamp(0.0, 1.0);
    if (vitality > 0.4 && _random.nextDouble() < 0.05 * dt * 60) {
      final tips = plant.rootSystem.asMap().entries.where((e) => e.value.isTip).toList();
      if (tips.isNotEmpty) {
        final entry = tips[_random.nextInt(tips.length)];
        final pos = _mapRootToLocal(
          entry.value,
          entry.key,
          plant.baseX,
          worldWidth,
          game.soilColumnHeight,
        );
        _tipGlows.add(_RootTipGlow(
          position: pos,
          vitality: vitality,
          isGrowth: false,
        ));
      }
    }

    for (final glow in _tipGlows) {
      glow.update(dt);
    }
    _tipGlows.removeWhere((g) => g.isDone);

    _spawnExudates(plant, dt);

    // Physiological Smoothing & Interpolation
    // We use a damping factor to make transitions (like wilting) feel organic
    final targetTurgor = plant.turgorPressure;
    final state = game.simulationState;
    final nContent = (state != null && state.profile.layers.isNotEmpty)
        ? (state.profile.layers.first.nitrateContent +
              state.profile.layers.first.ammoniumContent)
        : 30.0;
    final targetVitality = (nContent / 40.0).clamp(0.2, 1.0);

    const double lerpFactor = 0.8; // Speed of visual adaptation
    _smoothTurgor += (targetTurgor - _smoothTurgor) * dt * lerpFactor;
    _smoothVitality +=
        (targetVitality - _smoothVitality) * dt * (lerpFactor * 0.5);
    _smoothBiomass +=
        (plant.totalBiomass - _smoothBiomass) * dt * (lerpFactor * 0.2);
    _smoothAge += (plant.age - _smoothAge) * dt * 0.1;

    // Senescence accumulates if vitality is low for too long or plant is old
    if (_smoothVitality < 0.4 || _smoothAge > 60) {
      _senescence = (_senescence + dt * 0.01).clamp(0.0, 1.0);
    } else {
      _senescence = (_senescence - dt * 0.005).clamp(0.0, 1.0);
    }

    _spawnRootFlows(plant, dt);
    _spawnShootFlows(dt);
    _spawnNutrientMolecules(plant, dt);
    _spawnVapor(plant, dt);
  }

  void _onNewRootGrowth(Plant plant) {
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final vitality = (1.0 - plant.waterStressIndex).clamp(0.0, 1.0);

    for (
      int i = math.max(0, plant.rootSystem.length - 5);
      i < plant.rootSystem.length;
      i++
    ) {
      final node = plant.rootSystem[i];
      if (node.isTip) {
        final pos = _mapRootToLocal(
          node,
          i,
          plant.baseX,
          worldWidth,
          soilHeight,
        );
        _tipGlows.add(_RootTipGlow(
          position: pos,
          vitality: vitality,
          isGrowth: true,
        ));
      }
    }
  }

  void _spawnExudates(Plant plant, double dt) {
    if (!(game.simulationState?.isRunning ?? false)) return;

    final state = game.simulationState!;
    if (state.profile.layers.isEmpty) return;
    final solarFactor = (_solarRadiation / 1000.0).clamp(0.1, 1.0);
    final carbonAvailability =
        plant.stomatalConductance *
        (1.0 - plant.waterStressIndex).clamp(0.1, 1.0) *
        solarFactor;

    // Release rate threshold based on carbon availability
    final spawnThreshold = 0.05 + carbonAvailability * 0.15;

    if (_random.nextDouble() < spawnThreshold) {
      final nodes = plant.rootSystem;
      if (nodes.isEmpty) return;

      // Prioritize root tips and active growth zones for exudation
      final activeNodes = nodes.where((n) => n.isTip).toList();
      final node = activeNodes.isNotEmpty
          ? activeNodes[_random.nextInt(activeNodes.length)]
          : nodes[_random.nextInt(nodes.length)];

      final nodeIndex = nodes.indexOf(node);
      final pos = _mapRootToLocal(
        node,
        nodeIndex,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );

      game.moleculePool?.spawn(
        position: pos.clone(),
        type: MoleculeType.labileCarbon,
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 10,
          (_random.nextDouble() - 0.5) * 10 + 5,
        ),
        lifeTime: 3.0,
      );
    }
  }

  void _spawnRootFlows(Plant plant, double dt) {
    final isFlowMode = game.ref.read(particleFlowModeProvider);
    final boost = isFlowMode ? 3.0 : 1.0;

    // Phloem-driven carbon moving DOWN the roots
    if (_random.nextDouble() < 0.15 * dt * 60 * boost) {
      final branches = _groupNodesIntoBranches(plant.rootSystem);
      if (branches.isEmpty) return;

      final branchList = branches.values.toList();
      final branch = branchList[_random.nextInt(branchList.length)];
      
      final List<Vector2> worldPath = branch.map((node) {
        final rawY = SceneCoordinateMapper.mapRootY(node.z, game.soilSurfaceY, game.soilColumnHeight);
        return Vector2(
          SceneCoordinateMapper.mapRootX(node.x, SoilScopeGame.soilColumnWidth, baseX: plant.baseX) + game.soilLeftX,
          rawY,
        );
      }).toList();

      game.moleculePool?.spawn(
        position: worldPath.first,
        type: MoleculeType.labileCarbon,
        path: worldPath,
        lifeTime: 8.0,
      );
    }
  }

  void _spawnNutrientMolecules(Plant plant, double dt) {
    if (!(game.simulationState?.isRunning ?? false)) return;

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final surfaceY = game.soilSurfaceY;
    final soilX = game.soilLeftX;

    for (final node in plant.rootSystem) {
      if (node.isTip) {
        final seed = node.hashCode % 5; // Support more types
        // SIGNIFICANTLY reduced chance to prevent "Rogue Particle Engine"
        final isFlowMode = game.ref.read(particleFlowModeProvider);
        final boost = isFlowMode ? 4.0 : 1.0;
        final chance = 0.01 * dt * boost;
        if (_random.nextDouble() < chance) {
          final rawY = SceneCoordinateMapper.mapRootY(
            node.z,
            surfaceY,
            soilHeight,
          );
          final tipPos = Vector2(
            SceneCoordinateMapper.mapRootX(
                  node.x,
                  worldWidth,
                  baseX: plant.baseX,
                ) +
                soilX,
            rawY.clamp(surfaceY + 5.0, surfaceY + soilHeight - 5.0).toDouble(),
          );

          MoleculeType type;
          bool canSpawn = true;

          if (seed == 0) {
            type = MoleculeType.nitrate;
          } else if (seed == 1) {
            type = MoleculeType.phosphate;
          } else if (seed == 2) {
            type = MoleculeType.potassium;
            // MASS CONSERVATION: Potassium spawning must deplete the mineral/exchangeable pool
            final state = game.simulationState;
            if (state != null) {
              final layer = state.profile.layers.firstWhere(
                (l) => node.z >= l.depth && node.z <= l.depth + l.thickness,
                orElse: () => state.profile.layers.first,
              );
              // Try to consume a small amount of exchangeable K (0.05 mg/kg per particle)
              canSpawn = game.ref
                  .read(simulationProvider.notifier)
                  .consumePotassium(layer.id, 0.05);
            } else {
              canSpawn = false;
            }
          } else if (seed == 3) {
            type = MoleculeType.calcium;
          } else {
            type = MoleculeType.magnesium;
          }

          if (!canSpawn) continue;

          final dir = Vector2(
            _random.nextDouble() - 0.5,
            _random.nextDouble() - 0.5,
          )..normalize();
          final speed = 15.0 + _random.nextDouble() * 20.0;

          // PATHFINDING (Task 5/6): Use network path if available
          final List<Vector2> fullPath = [];
          final network = game.world.children
              .query<SoilSymbiosisNetworkComponent>()
              .firstOrNull;
          if (network != null) {
            final netPath = network.findNetworkPath(
              tipPos + Vector2((_random.nextDouble() - 0.5) * 100, 50),
              tipPos,
            );
            if (netPath != null) fullPath.addAll(netPath);
          }
          final plantPath = getPlantVascularPath(tipPos);
          if (plantPath != null) fullPath.addAll(plantPath);

          game.moleculePool?.spawn(
            position: fullPath.isNotEmpty
                ? fullPath.first
                : tipPos +
                      Vector2(
                        (_random.nextDouble() - 0.5) * 60,
                        (_random.nextDouble() - 0.5) * 60,
                      ),
            type: type,
            targetPosition: fullPath.isNotEmpty ? fullPath.last : tipPos,
            path: fullPath.isNotEmpty ? fullPath : null,
            velocity: dir * speed,
            lifeTime: 15.0,
            seed: _random.nextInt(1000),
          );
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final plant = _plantData;
    if (plant == null) return;

    final zoom = game.camera.viewfinder.zoom;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;

    canvas.save();
    try {
      final turgor = _smoothTurgor;
      final biomass = _smoothBiomass;
      // Increased base scale for more presence
      final shootScale = SceneCoordinateMapper.getShootScale(
        plant,
        growthBoost: _growthBoost,
      );

      final currentHeight = 450.0 * shootScale; // Increased from 320
      // Movement is disabled to ensure perfect anchoring with inspection hotspots
      const droopAngle = 0.0;
      const sway = 0.0;

      // Anatomical Highlighting
      final session = game.ref.read(simulationSessionProvider);
      final inspectorType = session.selectedInspectorType;

      _drawRhizosphereGlow(
        canvas,
        plant.rootSystem,
        game.currentTime(),
        plant.baseX,
        highlighted: inspectorType == 'Rhizosphere',
      );
      _drawRhizosheath(canvas, plant.rootSystem, plant.baseX);
      _drawNutrientDepletionZone(canvas, plant.rootSystem, plant.baseX);
      _drawRootSystem(
        canvas,
        plant.rootSystem,
        turgor,
        plant.baseX,
        shootScale,
        highlighted: inspectorType == 'Root',
      );
      _drawRootPressure(canvas, plant.rootSystem, plant.baseX, turgor);
      _drawTipAnimations(canvas);

      _drawTaperedStem(
        canvas,
        currentHeight,
        droopAngle,
        sway,
        shootScale,
        turgor,
        highlighted: inspectorType == 'Stem',
      );

      // Branch and Leaf sync based on Side Roots
      final sideRootCount = plant.rootSystem
          .where((n) => n.parentIndex != null)
          .length;
      final branchProgress = sideRootCount / 8.0;
      final branchCount = branchProgress.floor().clamp(0, 12);
      final lastBranchPartial = (branchProgress - branchProgress.floor()).clamp(
        0.0,
        1.0,
      );

      final topX = math.sin(droopAngle + sway) * currentHeight * 0.4;
      final topY = -currentHeight;
      final cp1X = math.sin(droopAngle + sway) * currentHeight * 0.1;
      final cp1Y = -currentHeight * 0.4;
      final cp2X = topX * 0.8;
      final cp2Y = topY * 0.7;

      // Vitality-based coloring: Deep emerald to healthy lime
      // Incorporate senescence (yellowing)
      final chlorophyllDensity =
          (_smoothVitality * 0.7 + (biomass / 2000).clamp(0.0, 0.3)) *
          (1.0 - _senescence * 0.6);
      final deadColor = const Color(0xFF78350F); // Brownish/yellow
      final healthyBase = const Color(0xFF065F46); // Deep emerald
      final baseStemColor = Color.lerp(
        deadColor,
        healthyBase,
        chlorophyllDensity,
      )!;
      final activeStemColor = Color.lerp(
        baseStemColor,
        const Color(0xFF10B981),
        turgor,
      )!;

      _drawBranches(
        canvas,
        branchCount,
        lastBranchPartial,
        shootScale,
        droopAngle,
        sway,
        topX,
        topY,
        cp1X,
        cp1Y,
        cp2X,
        cp2Y,
        turgor,
        activeStemColor,
        inspectorType,
      );

      _drawMainStemLeaves(
        canvas,
        biomass,
        shootScale,
        droopAngle,
        sway,
        topX,
        topY,
        cp1X,
        cp1Y,
        cp2X,
        cp2Y,
        turgor,
        inspectorType,
      );

      _drawGrowthTip(canvas, topX, topY, shootScale, turgor);

      // Draw Branches with smooth unfolding
      for (int i = 0; i < branchCount + 1; i++) {
        if (i >= 12) break;
        final heightFactor = 0.15 + (i / 12.0) * 0.75;
        if (heightFactor > 0.9) continue;

        // Only draw the partial branch if it's the last one
        final isLast = i == branchCount;
        final unfoldingScale = isLast ? lastBranchPartial : 1.0;
        if (unfoldingScale < 0.05) continue;

        final t = heightFactor;
        final bStartX = _cubicBezier(0, cp1X, cp2X, topX, t);
        final bStartY = _cubicBezier(0, cp1Y, cp2Y, topY, t);

        final bIsLeft = i % 2 == 0;
        final bLength = 65.0 * shootScale * (1.1 - t * 0.5) * unfoldingScale;
        // Sway is stronger at the top
        final heightSway = sway * (1.0 + t * 0.5);
        final bAngle =
            (bIsLeft ? -math.pi / 2.8 : math.pi / 2.8) *
                (0.8 + (1.0 - turgor) * 0.5) +
            droopAngle +
            heightSway;

        final bEndX = bStartX + math.sin(bAngle) * bLength;
        final bEndY = bStartY - math.cos(bAngle) * bLength;

        final bPaint = Paint()
          ..color = activeStemColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0 * shootScale * (1.1 - t * 0.6) * unfoldingScale
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(bStartX, bStartY), Offset(bEndX, bEndY), bPaint);

        // Branch leaf
        final bLeafScale = shootScale * 0.9 * unfoldingScale;
        _drawLeaf(
          canvas,
          Vector2(bEndX, bEndY),
          droopAngle,
          heightSway,
          bLeafScale,
          turgor,
          bIsLeft,
          seed: i + 50,
          highlighted: inspectorType == 'Leaf',
        );
      }

      // Main Stem Leaves with smooth unfolding
      final leafProgress = 2.0 + (biomass / 120.0);
      final leafCount = leafProgress.floor().clamp(2, 14);
      final lastLeafPartial = (leafProgress - leafProgress.floor()).clamp(
        0.0,
        1.0,
      );

      for (int i = 0; i < leafCount + 1; i++) {
        if (i >= 14) break;
        final heightFactor = 0.1 + (i / 14.0) * 0.85;
        final isLeft = i % 2 == 0;

        final isLast = i == leafCount;
        final unfoldingScale = isLast ? lastLeafPartial : 1.0;
        if (unfoldingScale < 0.05) continue;

        final leafScale =
            (1.2 - (i / 14.0) * 0.5) * shootScale * unfoldingScale;
        final t = heightFactor;
        final lX = _cubicBezier(0, cp1X, cp2X, topX, t);
        final lY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
        final heightSway = sway * (1.0 + t * 0.6);

        _drawLeaf(
          canvas,
          Vector2(lX, lY),
          droopAngle,
          heightSway,
          leafScale,
          turgor,
          isLeft,
          seed: i,
          highlighted: inspectorType == 'Leaf',
        );
      }
      // Growth tip glow (Meristem)
      final tipGlow = Paint()
        ..color = const Color(0xFFA7F3D0).withValues(alpha: 0.3 * turgor)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset(topX, topY), 8.0 * shootScale, tipGlow);

      if (!session.isMicroscopeEnabled) {
        _drawLabels(canvas, plant, worldWidth, soilHeight, zoom);
      }
    } catch (e) {
      // Silent fail
    }

    canvas.restore();
  }

  void _drawBranches(
    Canvas canvas,
    int branchCount,
    double lastBranchPartial,
    double shootScale,
    double droopAngle,
    double sway,
    double topX,
    double topY,
    double cp1X,
    double cp1Y,
    double cp2X,
    double cp2Y,
    double turgor,
    Color activeStemColor,
    String? inspectorType,
  ) {
    for (int i = 0; i < branchCount + 1; i++) {
      if (i >= 12) break;
      final heightFactor = 0.15 + (i / 12.0) * 0.75;
      if (heightFactor > 0.9) continue;

      // Only draw the partial branch if it's the last one
      final isLast = i == branchCount;
      final unfoldingScale = isLast ? lastBranchPartial : 1.0;
      if (unfoldingScale < 0.05) continue;

      final t = heightFactor;
      
      // Interpolate start point based on stem straightening
      final organicStartX = _cubicBezier(0, cp1X, cp2X, topX, t);
      final organicStartY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
      final schematicStartX = 0.0;
      final schematicStartY = -topY.abs() * t;
      
      final bStartX = lerpDouble(organicStartX, schematicStartX, _layoutProgress)!;
      final bStartY = lerpDouble(organicStartY, schematicStartY, _layoutProgress)!;

      final bIsLeft = i % 2 == 0;
      final bLength = 65.0 * shootScale * (1.1 - t * 0.5) * unfoldingScale;
      // Sway is stronger at the top
      final heightSway = sway * (1.0 + t * 0.5);

      // --- Angle Calculation ---
      // Organic: Stochastic based on side and turgor
      final organicAngle = (bIsLeft ? -math.pi / 2.8 : math.pi / 2.8) *
              (0.8 + (1.0 - turgor) * 0.5) +
          droopAngle +
          heightSway;
      
      // Schematic: Radial Graph distribution centered at base
      // Main stem provides context, branches radiate fully outwards.
      final bool isSchematic = _layoutProgress > 0.5;
      const double radialSweep = math.pi * 1.5; // Spread around the center
      final schematicAngle = branchCount > 0 
          ? (-radialSweep / 2 + (i / branchCount) * radialSweep) - math.pi/2
          : (bIsLeft ? -math.pi/3 : math.pi/3) - math.pi/2;
      
      final currentAngle = lerpDouble(organicAngle, schematicAngle, _layoutProgress)!;

      // In radial schematic mode, branches extend outward from origin (0,0) or low on the stem
      final targetStartX = isSchematic ? 0.0 : schematicStartX;
      final targetStartY = isSchematic ? 0.0 : schematicStartY;

      final currentStartX = lerpDouble(organicStartX, targetStartX, _layoutProgress)!;
      final currentStartY = lerpDouble(organicStartY, targetStartY, _layoutProgress)!;

      final schematicLength = bLength * 1.5; // Make them slightly longer in radial view to stand out
      final currentLength = lerpDouble(bLength, schematicLength, _layoutProgress)!;

      final bEndX = currentStartX + math.sin(currentAngle) * currentLength;
      final bEndY = currentStartY - math.cos(currentAngle) * currentLength;

      _branchPaint
        ..color = activeStemColor
        ..strokeWidth = 4.0 * shootScale * (1.1 - t * 0.6) * unfoldingScale;

      canvas.drawLine(
        Offset(currentStartX, currentStartY),
        Offset(bEndX, bEndY),
        _branchPaint,
      );

      // Branch leaf
      final bLeafScale = shootScale * 0.9 * unfoldingScale;
      _drawLeaf(
        canvas,
        Vector2(bEndX, bEndY),
        droopAngle,
        heightSway,
        bLeafScale,
        turgor,
        bIsLeft,
        seed: i + 50,
        highlighted: inspectorType == 'leaf',
      );
    }
  }

  void _drawMainStemLeaves(
    Canvas canvas,
    double biomass,
    double shootScale,
    double droopAngle,
    double sway,
    double topX,
    double topY,
    double cp1X,
    double cp1Y,
    double cp2X,
    double cp2Y,
    double turgor,
    String? inspectorType,
  ) {
    // Main Stem Leaves with smooth unfolding
    final leafProgress = 2.0 + (biomass / 120.0);
    final leafCount = leafProgress.floor().clamp(2, 14);
    final lastLeafPartial = (leafProgress - leafProgress.floor()).clamp(
      0.0,
      1.0,
    );

    for (int i = 0; i < leafCount + 1; i++) {
      if (i >= 14) break;
      final heightFactor = 0.1 + (i / 14.0) * 0.85;
      final isLeft = i % 2 == 0;

      final isLast = i == leafCount;
      final unfoldingScale = isLast ? lastLeafPartial : 1.0;
      if (unfoldingScale < 0.05) continue;

      final leafScale = (1.2 - (i / 14.0) * 0.5) * shootScale * unfoldingScale;
      final t = heightFactor;
      final organicX = _cubicBezier(0, cp1X, cp2X, topX, t);
      final organicY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
      final schematicX = 0.0;
      final schematicY = -topY.abs() * t;

      final lX = lerpDouble(organicX, schematicX, _layoutProgress)!;
      final lY = lerpDouble(organicY, schematicY, _layoutProgress)!;
      final heightSway = sway * (1.0 + t * 0.6);

      _drawLeaf(
        canvas,
        Vector2(lX, lY),
        droopAngle,
        heightSway,
        leafScale,
        turgor,
        isLeft,
        seed: i,
        highlighted: inspectorType == 'leaf',
      );
    }
  }

  void _drawGrowthTip(
    Canvas canvas,
    double topX,
    double topY,
    double shootScale,
    double turgor,
  ) {
    _tipGlowPaint
      ..color = const Color(0xFFA7F3D0).withValues(alpha: 0.3 * turgor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(topX, topY), 8.0 * shootScale, _tipGlowPaint);
  }

  void _drawLabels(
    Canvas canvas,
    Plant plant,
    double worldWidth,
    double soilHeight,
    double zoom,
  ) {
    if (isHovered || _isPinned) {
      // Info handled via global overlay
    }

    if (_hoveredRootIndex != null || _pinnedRootIndex != null) {
      final index = _hoveredRootIndex ?? _pinnedRootIndex!;
      if (index < plant.rootSystem.length) {
        final node = plant.rootSystem[index];
        final pos = _mapRootToLocal(
          node,
          index,
          plant.baseX,
          worldWidth,
          soilHeight,
        );

        canvas.drawCircle(
          pos.toOffset(),
          8 / zoom,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
      }
    }
  }

  void _drawTaperedStem(
    Canvas canvas,
    double h,
    double droop,
    double sway,
    double scale,
    double turgor, {
    bool highlighted = false,
  }) {
    final plant = _plantData;
    final biomass = plant?.totalBiomass ?? 500.0;

    // Vitality-based coloring: Deep emerald to healthy lime
    final chlorophyllDensity =
        (turgor * 0.7 + (biomass / 2000).clamp(0.0, 0.3));
    final baseColor = Color.lerp(
      const Color(0xFF451A03),
      const Color(0xFF065F46),
      chlorophyllDensity,
    )!;
    final color = Color.lerp(baseColor, const Color(0xFF10B981), turgor)!;

    final topX = math.sin(droop + sway) * h * 0.4;
    final topY = -h;
    final cp1X = math.sin(droop + sway) * h * 0.1;
    final cp1Y = -h * 0.4;
    final cp2X = topX * 0.8;
    final cp2Y = topY * 0.7;

    final leftPath = Path();
    final rightPath = Path();
    final List<Offset> centers = [];
    final List<double> widths = [];

    final int segments = 20;
    for (int i = 0; i <= segments; i++) {
      final t = i / segments;
      
      // Organic positions
      final organicX = _cubicBezier(0, cp1X, cp2X, topX, t);
      final organicY = _cubicBezier(0, cp1Y, cp2Y, topY, t);
      
      // Schematic positions: Straight vertical line
      final schematicX = 0.0;
      final schematicY = -h * t;

      final currentX = lerpDouble(organicX, schematicX, _layoutProgress)!;
      final currentY = lerpDouble(organicY, schematicY, _layoutProgress)!;
      
      centers.add(Offset(currentX, currentY));

      // Allometric scaling: stem is thicker at base
      final width = (12.0 * (1.1 - t * 0.75)) * scale;
      widths.add(width);

      double dx, dy;
      if (i < segments) {
        final nextT = (i + 1) / segments;
        final nextOrganicX = _cubicBezier(0, cp1X, cp2X, topX, nextT);
        final nextOrganicY = _cubicBezier(0, cp1Y, cp2Y, topY, nextT);
        final nextSchematicX = 0.0;
        final nextSchematicY = -h * nextT;
        
        final nextX = lerpDouble(nextOrganicX, nextSchematicX, _layoutProgress)!;
        final nextY = lerpDouble(nextOrganicY, nextSchematicY, _layoutProgress)!;
        
        dx = nextX - currentX;
        dy = nextY - currentY;
      } else {
        final prevT = (i - 1) / segments;
        final prevOrganicX = _cubicBezier(0, cp1X, cp2X, topX, prevT);
        final prevOrganicY = _cubicBezier(0, cp1Y, cp2Y, topY, prevT);
        final prevSchematicX = 0.0;
        final prevSchematicY = -h * prevT;
        
        final prevX = lerpDouble(prevOrganicX, prevSchematicX, _layoutProgress)!;
        final prevY = lerpDouble(prevOrganicY, prevSchematicY, _layoutProgress)!;
        
        dx = currentX - prevX;
        dy = currentY - prevY;
      }
      final len = math.sqrt(dx * dx + dy * dy);
      final nx = -dy / len * width;
      final ny = dx / len * width;

      if (i == 0) {
        leftPath.moveTo(currentX + nx, currentY + ny);
        rightPath.moveTo(currentX - nx, currentY - ny);
      } else {
        leftPath.lineTo(currentX + nx, currentY + ny);
        rightPath.lineTo(currentX - nx, currentY - ny);
      }
    }

    final fullPath = Path();
    fullPath.addPath(leftPath, Offset.zero);
    final rightMetrics = rightPath.computeMetrics().toList();
    if (rightMetrics.isNotEmpty) {
      final m = rightMetrics.first;
      for (double d = m.length; d >= 0; d -= 2) {
        final pos = m.getTangentForOffset(d)?.position;
        if (pos != null) fullPath.lineTo(pos.dx, pos.dy);
      }
    }
    fullPath.close();

    // Main stem fill
    canvas.drawPath(fullPath, Paint()..color = color);

    // Subtle longitudinal vascular bundles (textures)
    final vascularPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5 * scale;

    for (double offsetMult in [-0.4, 0.0, 0.4]) {
      final vPath = Path();
      for (int i = 0; i < centers.length; i++) {
        final w = widths[i];
        // Calculate tangent for offset
        double dx, dy;
        if (i < centers.length - 1) {
          dx = centers[i + 1].dx - centers[i].dx;
          dy = centers[i + 1].dy - centers[i].dy;
        } else {
          dx = centers[i].dx - centers[i - 1].dx;
          dy = centers[i].dy - centers[i - 1].dy;
        }
        final len = math.sqrt(dx * dx + dy * dy);
        final nx = -dy / len * (w * offsetMult);
        final ny = dx / len * (w * offsetMult);

        if (i == 0) {
          vPath.moveTo(centers[i].dx + nx, centers[i].dy + ny);
        } else {
          vPath.lineTo(centers[i].dx + nx, centers[i].dy + ny);
        }
      }
      canvas.drawPath(vPath, vascularPaint);
    }

    // Specular highlight for cylindrical look
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;
    final hPath = Path();
    for (int i = 0; i < centers.length; i++) {
      final w = widths[i];
      double dx, dy;
      if (i < centers.length - 1) {
        dx = centers[i + 1].dx - centers[i].dx;
        dy = centers[i + 1].dy - centers[i].dy;
      } else {
        dx = centers[i].dx - centers[i - 1].dx;
        dy = centers[i].dy - centers[i - 1].dy;
      }
      final len = math.sqrt(dx * dx + dy * dy);
      final nx = -dy / len * (w * -0.3);
      final ny = dx / len * (w * -0.3);
      if (i == 0) {
        hPath.moveTo(centers[i].dx + nx, centers[i].dy + ny);
      } else {
        hPath.lineTo(centers[i].dx + nx, centers[i].dy + ny);
      }
    }
    canvas.drawPath(hPath, highlightPaint);

    if (highlighted) {
      final zoom = game.camera.viewfinder.zoom;
      final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 8);
      canvas.drawPath(
        fullPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 / zoom
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Root collar transition
    final collarPulse = 0.5 + 0.5 * math.sin(game.currentTime() * 1.5);
    final collarGlow = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.12 * collarPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset.zero, 14.0 * scale * collarPulse, collarGlow);

    final collarPaint = Paint()
      ..color = Color.lerp(color, const Color(0xFF451A03), 0.6)!
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 13.2 * scale,
        height: 7.0 * scale,
      ),
      collarPaint,
    );
  }

  double _cubicBezier(double p0, double p1, double p2, double p3, double t) {
    final u = 1 - t;
    return u * u * u * p0 +
        3 * u * u * t * p1 +
        3 * u * t * t * p2 +
        t * t * t * p3;
  }

  void _drawRootSystem(
    Canvas canvas,
    List<RootNode> nodes,
    double turgor,
    double baseX,
    double shootScale, {
    bool highlighted = false,
  }) {
    if (nodes.isEmpty) return;
    final zoom = game.camera.viewfinder.zoom;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final time = game.currentTime();

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    // --- 1. Identify taproot chain (the most vertical descendant at each node) ---
    final Set<int> taprootNodeIndices = {};
    int? currentIdx = 0;
    while (currentIdx != null && currentIdx < nodes.length) {
      taprootNodeIndices.add(currentIdx);
      int? bestChild;
      double minXDiff = 999.0;
      for (int i = 0; i < nodes.length; i++) {
        if (nodes[i].parentIndex == currentIdx) {
          final diff = (nodes[i].x - nodes[currentIdx].x).abs();
          if (diff < minXDiff) {
            minXDiff = diff;
            bestChild = i;
          }
        }
      }
      currentIdx = bestChild;
    }

    // --- 2. Pre-compute child count per node for width calculation ---
    final List<int> childCount = List.filled(nodes.length, 0);
    for (final node in nodes) {
      if (node.parentIndex != null && node.parentIndex! < nodes.length) {
        childCount[node.parentIndex!]++;
      }
    }

    // --- 3. Draw each root segment as a filled tapered shape ---
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.parentIndex == null || node.parentIndex! >= nodes.length) {
        continue;
      }

      final parentNode = nodes[node.parentIndex!];
      final isTaproot =
          taprootNodeIndices.contains(i) &&
          taprootNodeIndices.contains(node.parentIndex!);

      final o1 = map(parentNode, node.parentIndex!).toOffset();
      final o2 = map(node, i).toOffset();
      final dx = o2.dx - o1.dx;
      final dy = o2.dy - o1.dy;
      final segLen = math.sqrt(dx * dx + dy * dy);
      if (segLen < 0.5) continue;

      // --- Organic Bezier curvature ---
      // Roots follow gravitropism (+Y/Z downward).
      // Reduced noise amplitude and removed time-based wiggling to ensure a stable, natural path.
      final noiseAmplitude = (isTaproot ? 0.8 : 3.0) / zoom;
      final noisePhase =
          node.z * 8.0 + i * 0.5; // Static phase (no time component)
      final noiseX = math.sin(noisePhase) * noiseAmplitude;
      final noiseX2 = math.cos(noisePhase * 0.8) * (noiseAmplitude * 0.4);

      final spine = Path()..moveTo(o1.dx, o1.dy);
      
      if (_layoutProgress > 0.8) {
        // Layered Graph Style: Orthogonal (L-shaped) connections
        // Roots spread wide horizontally in the topsoil first, then straight down
        spine.lineTo(o2.dx, o1.dy);
        spine.lineTo(o2.dx, o2.dy);
      } else {
        // Organic: Cubic Bezier spine with reduced horizontal swing for the taproot
        final cpIntensity = isTaproot ? 0.05 : 0.15;
        spine.cubicTo(
          o1.dx + noiseX + dx * cpIntensity, // CP1x
          o1.dy + dy * 0.35, // CP1y
          o2.dx + noiseX2 - dx * cpIntensity, // CP2x
          o1.dy + dy * 0.65, // CP2y
          o2.dx,
          o2.dy,
        );
      }

      // --- Width tapering ---
      // Parent width: feeds from the stem base (which is 13.2 * scale)
      // At the surface (z=0), we match the stem base exactly.
      final double rootCollarWidth = 13.2 * shootScale;
      final double parentWidth = isTaproot
          ? (rootCollarWidth *
                (1.0 +
                    (childCount[node.parentIndex!] *
                        0.05 *
                        (parentNode.z > 0 ? 1 : 0))))
          : ((node.radius * 350.0).clamp(2.5, 20.0) *
                    (1.0 + childCount[node.parentIndex!] * 0.06)) /
                zoom;
      final depthTaperParent = (1.0 - (parentNode.z * 0.4).clamp(0.0, 0.7));
      final wStart = parentWidth * depthTaperParent;

      // Child width: thinner than parent
      final double childWidthBase = isTaproot
          ? (9.0 * shootScale)
          : ((node.radius * 280.0).clamp(1.5, 16.0)) / zoom;
      final depthTaperChild = (1.0 - (node.z * 0.5).clamp(0.0, 0.85));
      final wEnd = childWidthBase * depthTaperChild;

      // --- Trace left and right edges along the spine to create filled tapered path ---
      final metrics = spine.computeMetrics().toList();
      if (metrics.isEmpty) continue;
      final metric = metrics.first;
      final mLen = metric.length;

      // --- Growth Interpolation ---
      final birthTime = _nodeBirthTimes[i] ?? 0.0;
      final growthAge = (time - birthTime).clamp(0.0, 1.0);
      // Smoothly interpolate the length of the segment for newly grown nodes
      final activeLen = mLen * growthAge;
      if (activeLen < 0.1) continue;

      const int taperSegments = 10;
      final List<Offset> leftEdge = [];
      final List<Offset> rightEdge = [];

      for (int s = 0; s <= taperSegments; s++) {
        final t = s / taperSegments;
        final tangent = metric.getTangentForOffset(activeLen * t);
        if (tangent == null) continue;

        final pos = tangent.position;
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        // Smooth cubic interpolation for tapering (not linear, looks more organic)
        final tSmooth = t * t * (3.0 - 2.0 * t); // smoothstep
        final halfWidth = (wStart + (wEnd - wStart) * tSmooth) / 2.0;

        leftEdge.add(pos + normal * halfWidth);
        rightEdge.add(pos - normal * halfWidth);
      }

      if (leftEdge.length < 2) continue;

      // Build filled shape
      final taperedPath = Path()..moveTo(leftEdge.first.dx, leftEdge.first.dy);
      for (int s = 1; s < leftEdge.length; s++) {
        taperedPath.lineTo(leftEdge[s].dx, leftEdge[s].dy);
      }
      // Trace back along the right edge (reversed)
      for (int s = rightEdge.length - 1; s >= 0; s--) {
        taperedPath.lineTo(rightEdge[s].dx, rightEdge[s].dy);
      }
      taperedPath.close();

      // --- Color: creamy white/beige for taproot, paler whitish for laterals ---
      final branchColor = isTaproot
          ? Color.lerp(
              const Color(0xFFFDE68A),
              const Color(0xFFFEF3C7),
              (node.z).clamp(0.0, 1.0),
            )!
          : Color.lerp(
              const Color(0xFFFEF3C7),
              const Color(0xFFFAFAF9),
              (node.z).clamp(0.0, 1.0),
            )!;

      // Smooth fade-in for newly grown segments (based on node index as proxy for age)
      final double fadeIn = (time - (i * 0.02)).clamp(0.0, 1.0);
      final fillPaint = Paint()
        ..color = branchColor.withValues(alpha: fadeIn)
        ..style = PaintingStyle.fill;
      canvas.drawPath(taperedPath, fillPaint);

      // --- Specular highlight for 3D volume illusion ---
      if (wStart > 2.0 / zoom) {
        final highlightPath = Path()
          ..moveTo(leftEdge.first.dx, leftEdge.first.dy);
        for (int s = 1; s < leftEdge.length; s++) {
          highlightPath.lineTo(leftEdge[s].dx, leftEdge[s].dy);
        }
        canvas.drawPath(
          highlightPath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.12 * fadeIn)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(0.5, (wStart * 0.2))
            ..strokeCap = StrokeCap.round,
        );
      }
      // --- Root hairs on lateral roots (Using existing method) ---
      if (!isTaproot && node.z > 0.08 && zoom > 0.8) {
        _drawRootHairs(canvas, metric, activeLen, wEnd, zoom, time, node.z, i);
      }

      // --- Inspector highlight ---
      if (highlighted) {
        final pulse = 0.5 + 0.5 * math.sin(time * 8);
        canvas.drawPath(
          taperedPath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.3 * pulse * fadeIn)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0 / zoom
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }

  /// Draws organic, curved root hairs along a root segment.
  /// Hair density and length scale with depth and zoom.
  void _drawRootHairs(
    Canvas canvas,
    PathMetric metric,
    double metricLength,
    double rootTipWidth,
    double zoom,
    double time,
    double depth,
    int nodeIndex,
  ) {
    // More hairs deeper in soil (absorption zone), fewer at surface
    final int hairCount = (4 + depth * 8).toInt().clamp(3, 10);

    final paint = Paint()
      ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4 / zoom;

    for (int i = 1; i <= hairCount; i++) {
      final t = i / (hairCount + 1);
      final tangent = metric.getTangentForOffset(metricLength * t);
      if (tangent == null) {
        continue;
      }

      final pos = tangent.position;
      final normal = Offset(-tangent.vector.dy, tangent.vector.dx);

      // Hair length varies with subtle animation
      final baseLen = (2.5 + depth * 3.0) / zoom;
      final wiggle = math.sin(time * 1.8 + i * 1.1 + nodeIndex * 0.3) * 0.4;
      final hairLen = baseLen * (0.7 + 0.3 * math.sin(i * 2.3 + nodeIndex));

      // Draw as curved quadratic bezier for organic waviness
      final hairPath = Path()..moveTo(pos.dx, pos.dy);
      final tipL = pos + normal * hairLen;
      final cpL =
          pos + normal * (hairLen * 0.6) + Offset(wiggle / zoom, wiggle / zoom);
      hairPath.quadraticBezierTo(cpL.dx, cpL.dy, tipL.dx, tipL.dy);
      canvas.drawPath(hairPath, paint);

      // Other side
      final hairPathR = Path()..moveTo(pos.dx, pos.dy);
      final tipR = pos - normal * hairLen;
      final cpR =
          pos -
          normal * (hairLen * 0.6) +
          Offset(-wiggle / zoom, wiggle / zoom);
      hairPathR.quadraticBezierTo(cpR.dx, cpR.dy, tipR.dx, tipR.dy);
      canvas.drawPath(hairPathR, paint);
    }
  }

  void _drawRhizosphereGlow(
    Canvas canvas,
    List<RootNode> nodes,
    double time,
    double baseX, {
    bool highlighted = false,
  }) {
    if (nodes.isEmpty) return;
    final state = game.simulationState;
    if (state == null) return;

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;

    // Global physiological sync: Glow pulses faster with plant vitality
    final plant = state.plants.isNotEmpty ? state.plants.first : state.plant;
    final vitality = (1.0 - plant.waterStressIndex).clamp(0.1, 1.0);
    final waterContent = state.profile.layers.first.waterContent;

    final pulseSpeed = 1.5 + vitality * 3.0;
    final pulse = 0.5 + 0.5 * math.sin(time * pulseSpeed);

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    // Rhizosphere glow using multi-layered RadialGradients
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      // Activity based on tip status and plant vitality
      final activity =
          (1.0 - (node.z * 0.4).clamp(0.0, 1.0)) *
          (node.isTip ? 1.6 : 1.0) *
          vitality;

      if (activity > 0.1) {
        final rPos = _mapRootToLocal(node, i, baseX, worldWidth, soilHeight).toOffset();
        // Reach depends on water content (capillary movement) - TIGHTENED for decluttering
        final reachBase = 12.0 + waterContent * 15.0; // Reduced from 22 + 25

        // LOD: Fade out based on zoom level
        final zoomLOD = (zoom - 0.45).clamp(0.0, 1.0);
        if (zoomLOD <= 0) continue;

        final glowRadius =
            (reachBase + 8.0 * pulse * activity) *
            0.5; // Removed /zoom to keep it relative to root
        final alphaFactor = (highlighted ? 0.3 : 0.1) * zoomLOD;

        // 1. Inner Active Core (Enzymatic concentration)
        canvas.drawCircle(
          rPos,
          glowRadius * 0.35,
          Paint()
            ..shader =
                RadialGradient(
                  colors: [
                    const Color(0xFF84CC16).withValues(
                      alpha: (alphaFactor * activity * 1.2).clamp(0.0, 0.15),
                    ),
                    const Color(0xFF84CC16).withValues(alpha: 0.0),
                  ],
                ).createShader(
                  Rect.fromCircle(center: rPos, radius: glowRadius * 0.35),
                )
            ..blendMode = BlendMode.screen,
        );

        // 2. Outer Rhizosphere Influence
        final radPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFF84CC16).withValues(
                alpha: (alphaFactor * activity * 0.7).clamp(0.0, 0.15),
              ),
              const Color(0xFF84CC16).withValues(alpha: 0.0),
            ],
            stops: const [0.3, 1.0],
          ).createShader(Rect.fromCircle(center: rPos, radius: glowRadius))
          ..blendMode = BlendMode.screen;

        canvas.drawCircle(rPos, glowRadius, radPaint);

        canvas.drawCircle(rPos, 12 / zoom, Paint()..color = Colors.transparent);

        // 3. Enzymatic Mining Particles (Representing symbiosis/nutrient release)
        if (node.isTip && activity > 0.6 && i % 3 == 0) {
          _drawMiningParticles(canvas, rPos, time + i, activity);
        }
      }
    }

    // Still draw extra glow at tips for "activity" feel
    final tipPaint = Paint()
      ..color = const Color(0xFFBEF264).withValues(alpha: 0.08 + pulse * 0.05)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 / zoom);

    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      if (n.isTip) {
        canvas.drawCircle(
          map(n, i).toOffset(),
          (8 + pulse * 4) / zoom,
          tipPaint..color = tipPaint.color.withValues(alpha: 0.1),
        );
      }
    }
  }

  void _drawMiningParticles(
    Canvas canvas,
    Offset center,
    double time,
    double activity,
  ) {
    const int count = 3;
    for (int j = 0; j < count; j++) {
      final t = (time * 0.8 + j / count) % 1.0;
      final angle = (j / count) * math.pi * 2 + time * 0.5;

      // Particles move FROM soil TO root (Nutrient Uptake / Symbiosis)
      final dist = 40 * (1.0 - t);
      final pPos =
          center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      // CPK Colors: Nitrate (Blue), Carbon (Black/Grey)
      final color = j % 2 == 0
          ? const Color(0xFF3B82F6)
          : const Color(0xFF475569);
      final pAlpha = (t * (1.0 - t) * 4.0).clamp(0.0, 1.0) * activity * 0.6;

      canvas.drawCircle(
        pPos,
        1.5,
        Paint()
          ..color = color.withValues(alpha: pAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  void _drawRhizosheath(Canvas canvas, List<RootNode> nodes, double baseX) {
    if (nodes.isEmpty) return;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;
    if (zoom < 2.0) {
      return;
    } // Only visible when zoomed in

    final crumbPaint = Paint()
      ..color = const Color(0xFF451A03).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final rand = math.Random(42);

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (rand.nextDouble() > 0.3) continue; // Sparse crumbs

      final pos = map(node, i).toOffset();
      final size = (2.0 + rand.nextDouble() * 3.0) / zoom;
      final offset = Offset(
        (rand.nextDouble() - 0.5) * 12 / zoom,
        (rand.nextDouble() - 0.5) * 12 / zoom,
      );

      // Draw a small irregular "crumb"
      canvas.drawCircle(pos + offset, size, crumbPaint);

      // Add "glue" aura (EPS)
      if (rand.nextDouble() > 0.8) {
        canvas.drawCircle(
          pos + offset,
          size * 1.5,
          Paint()
            ..color = const Color(0xFF84CC16).withValues(alpha: 0.1)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2 / zoom),
        );
      }
    }
  }

  void _drawNutrientDepletionZone(
    Canvas canvas,
    List<RootNode> nodes,
    double baseX,
  ) {
    if (nodes.isEmpty) return;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 / zoom);

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.parentIndex == null || node.parentIndex! >= nodes.length) {
        continue;
      }

      final parentNode = nodes[node.parentIndex!];
      final o1 = map(parentNode, node.parentIndex!);
      final o2 = map(node, i);

      canvas.drawLine(o1.toOffset(), o2.toOffset(), shadowPaint..strokeWidth = 45 / zoom);
    }
  }

  void _drawRootPressure(
    Canvas canvas,
    List<RootNode> nodes,
    double baseX,
    double turgor,
  ) {
    if (nodes.isEmpty || turgor < 0.7) return;
    final worldWidth = SoilScopeGame.soilColumnWidth;
    final soilHeight = game.soilColumnHeight;
    final zoom = game.camera.viewfinder.zoom;
    final time = game.currentTime();

    // Pulse traveling UP (from tip to collar)
    final pathPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final branches = _groupNodesIntoBranches(nodes);

    Vector2 map(RootNode n, int index) =>
        _mapRootToLocal(n, index, baseX, worldWidth, soilHeight);

    for (final branch in branches.values) {
      if (branch.length < 5) continue;

      // Calculate pulse position along the branch (upward)
      final progress = (time * 0.8 + branch.hashCode % 10 / 10.0) % 1.0;
      final reversedProgress = 1.0 - progress;
      final i = (reversedProgress * (branch.length - 1)).floor();

      if (i > 0 && i < branch.length) {
        final p1 = map(branch[i - 1], i - 1).toOffset();
        final p2 = map(branch[i], i).toOffset();
        canvas.drawLine(p1, p2, pathPaint..strokeWidth = 3.0 / zoom);
      }
    }
  }

  Vector2 _mapRootToLocal(
    RootNode n,
    int index,
    double baseX,
    double worldWidth,
    double soilHeight,
  ) {
    final p = _plantData;
    final collarNode = (p != null && p.rootSystem.isNotEmpty) ? p.rootSystem.first : null;
    final collarX = collarNode?.x ?? 0.5;
    final collarZ = collarNode?.z ?? 0.0;

    // Organic world position
    final organic = Vector2(
      (n.x - collarX) * worldWidth * 0.45,
      ((n.z - collarZ) * soilHeight).clamp(0.0, soilHeight).toDouble(),
    );

    if (_layoutProgress <= 0.001) return organic;

    // Schematic position (Tidier Tree)
    final schematic = _schematicRootPositions[index];
    if (schematic == null) return organic;

    // Interpolate
    return Vector2(
      lerpDouble(organic.x, schematic.x, _layoutProgress)!,
      lerpDouble(organic.y, schematic.y, _layoutProgress)!,
    );
  }

  void _calculateSchematicLayout(Plant plant) {
    _schematicRootPositions.clear();
    if (plant.rootSystem.isEmpty) return;

    // Build adjacency
    final Map<int, List<int>> children = {};
    for (int i = 0; i < plant.rootSystem.length; i++) {
      final parent = plant.rootSystem[i].parentIndex;
      if (parent != null && parent < plant.rootSystem.length) {
        children.putIfAbsent(parent, () => []).add(i);
      }
    }

    // Subtree leaf counting for spacing
    final Map<int, int> subtreeLeaves = {};
    int countLeaves(int idx) {
      final kids = children[idx] ?? [];
      if (kids.isEmpty) {
        subtreeLeaves[idx] = 1;
        return 1;
      }
      int count = 0;
      for (final k in kids) {
        count += countLeaves(k);
      }
      subtreeLeaves[idx] = count;
      return count;
    }
    countLeaves(0);

    // Layout configuration
    const double hSpacing = 45.0;
    const double vSpacing = 65.0;

    void assignPos(int idx, double xCenter, double y) {
      _schematicRootPositions[idx] = Vector2(xCenter, y);
      
      final kids = children[idx] ?? [];
      if (kids.isEmpty) return;

      // Center the children under the parent
      double totalWidth = (subtreeLeaves[idx]! - 1) * hSpacing;
      double currentX = xCenter - totalWidth / 2.0;

      for (final k in kids) {
        double kw = (subtreeLeaves[k]! - 1) * hSpacing;
        assignPos(k, currentX + kw / 2.0, y + vSpacing);
        currentX += kw + hSpacing;
      }
    }

    // Start from collar at 0,0
    assignPos(0, 0, 0);
  }

  Map<int, List<RootNode>> _groupNodesIntoBranches(List<RootNode> nodes) {
    final Map<int, List<RootNode>> branches = {};
    for (final node in nodes) {
      if (node.isTip) {
        final List<RootNode> branch = [node];
        RootNode? curr = node;
        while (curr?.parentIndex != null && curr!.parentIndex! < nodes.length) {
          curr = nodes[curr.parentIndex!];
          branch.insert(0, curr);
        }
        branches[node.hashCode] = branch;
      }
    }
    return branches;
  }

  void _drawTipAnimations(Canvas canvas) {
    final zoom = game.camera.viewfinder.zoom;
    if (zoom < 0.6) return;
    final zoomLOD = (zoom - 0.6).clamp(0.0, 1.0);

    final isFlowMode = game.ref.read(particleFlowModeProvider);
    final boost = isFlowMode ? 2.5 : 1.0;

    for (final glow in _tipGlows) {
      final alpha = glow.alpha * zoomLOD;
      final progress = glow.life / 2.5;

      // Color based on vitality: Green (healthy) -> Yellow (stress) -> White (active growth)
      final baseColor = Color.lerp(
        const Color(0xFFFACC15), // Yellow
        const Color(0xFF84CC16), // Green
        glow.vitality,
      )!;
      
      final energyColor = Color.lerp(
        baseColor,
        Colors.white,
        (glow.pulse * 0.5 + 0.5) * 0.5,
      )!;

      // 1. Expanding Metabolic Rings (Multi-layered)
      for (int r = 0; r < 2; r++) {
        final rProgress = (progress + r * 0.3) % 1.0;
        final ringAlpha = (1.0 - rProgress) * 0.2 * alpha;
        final ringRadius = (2.0 + rProgress * 15.0) / zoom;
        
        canvas.drawCircle(
          glow.position.toOffset(),
          ringRadius,
          Paint()
            ..color = energyColor.withValues(alpha: ringAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2 / zoom,
        );
      }

      // 2. Active Meristem Core
      final coreRadius = (3.0 + glow.pulse * 2.0 * boost) / zoom;
      canvas.drawCircle(
        glow.position.toOffset(),
        coreRadius,
        Paint()
          ..color = energyColor.withValues(alpha: 0.4 * alpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 / zoom),
      );

      // 3. Absorption Sparkles (Random tiny dots)
      if (glow.vitality > 0.5 && glow.pulse > 0.8) {
        final rand = math.Random(glow.hashCode + (glow.life * 10).toInt());
        for (int i = 0; i < 3; i++) {
          final offset = Offset(
            (rand.nextDouble() - 0.5) * 10 / zoom,
            (rand.nextDouble() - 0.5) * 10 / zoom,
          );
          canvas.drawCircle(
            glow.position.toOffset() + offset,
            0.8 / zoom,
            Paint()..color = Colors.white.withValues(alpha: 0.6 * alpha),
          );
        }
      }
    }
  }

  void _spawnShootFlows(double dt) {
    // Xylem flow moving UP to leaves
    if (_random.nextDouble() < 0.1 * dt * 60) {
       final shootPos = SceneCoordinateMapper.mapShootPosition(
        _plantData?.baseX ?? 0.5,
        SoilScopeGame.soilColumnWidth,
        game.soilSurfaceY,
      );
      shootPos.x += game.soilLeftX;
      
      final visualHeight = SceneCoordinateMapper.plantVisualHeight(_plantData!);
      final targetY = game.soilSurfaceY - visualHeight * 0.8;
      
      game.moleculePool?.spawn(
        position: shootPos,
        type: MoleculeType.water,
        targetPosition: Vector2(shootPos.x + (_random.nextDouble() - 0.5) * 40, targetY),
        lifeTime: 4.0,
      );
    }
  }

  void _spawnVapor(Plant plant, double dt) {
    _vaporTimer += dt;
    final transpiration = plant.actualTranspiration;
    if (transpiration < 0.00001) return;

    // Spawn rate based on transpiration
    final interval = 0.1 / (transpiration * 100000).clamp(0.1, 10.0);
    if (_vaporTimer >= interval) {
      _vaporTimer = 0;

      final shootScale =
          0.5 + (plant.totalBiomass / 1000.0).clamp(0.0, 1.5) + _growthBoost;
      final currentHeight = 450.0 * shootScale;

      // Random leaf position
      final t = _random.nextDouble();
      final angle = (t - 0.5) * math.pi;
      final x = math.sin(angle) * 30 * shootScale;
      final y = -currentHeight * (0.3 + _random.nextDouble() * 0.6);

      game.moleculePool?.spawn(
        position: position + Vector2(x, y),
        type: MoleculeType.water,
        velocity: Vector2(
          (_random.nextDouble() - 0.5) * 10,
          -20 - _random.nextDouble() * 30,
        ),
        lifeTime: 1.5,
      );
    }
  }

  void _drawLeaf(
    Canvas canvas,
    Vector2 pos,
    double droop,
    double sway,
    double scale,
    double turgor,
    bool left, {
    int seed = 0,
    bool highlighted = false,
  }) {
    if (scale < 0.01) {
      return;
    }
    canvas.save();
    canvas.translate(pos.x, pos.y);

    final state = game.simulationState;
    final nContent = (state != null && state.profile.layers.isNotEmpty)
        ? (state.profile.layers.first.nitrateContent +
              state.profile.layers.first.ammoniumContent)
        : 30.0;
    final isDeficient = nContent < 15.0;
    final isLowPar = state != null ? (state.solarRadiation < 200.0) : false;

    // Unfolding transition: small leaves are more curled
    final unfoldingFactor = (scale / 0.5).clamp(0.0, 1.0);
    final curlAmount = (1.0 - unfoldingFactor) * 0.4;

    double angleOffset = 0.0;
    if (isDeficient) {
      angleOffset = left ? 0.4 : -0.4;
    } else if (isLowPar) {
      angleOffset = left ? -0.3 : 0.3;
    }

    final baseAngle = (left ? -math.pi / 4 : math.pi / 4);
    final angle =
        baseAngle +
        angleOffset +
        (left ? -droop : droop) +
        sway * (1.3 + math.sin(seed * 0.7)) +
        (math.sin(seed * 1.2 + game.currentTime() * 0.4) * 0.08) +
        (left ? droop : -droop) * 0.5; // Additional leaf drooping
    canvas.rotate(angle);

    // Organic coloring reflecting chlorophyll, vitality and senescence
    final chlorophyllAlpha = (_smoothVitality).clamp(0.2, 1.0);
    final combinedVitality =
        turgor * chlorophyllAlpha * (1.0 - _senescence * 0.8);

    Color leafBase = Color.lerp(
      const Color(0xFF365314),
      const Color(0xFF166534),
      combinedVitality,
    )!;
    Color leafEdge = Color.lerp(
      const Color(0xFF71710a),
      const Color(0xFF4ade80),
      combinedVitality,
    )!;

    // Apply senescence (yellowing/browning)
    if (_senescence > 0.1) {
      leafBase = Color.lerp(leafBase, const Color(0xFF854D0E), _senescence)!;
      leafEdge = Color.lerp(leafEdge, const Color(0xFFEAB308), _senescence)!;
    }

    if (isDeficient) {
      leafBase = Color.lerp(leafBase, Colors.amber.shade900, 0.4)!;
      leafEdge = Color.lerp(leafEdge, Colors.yellow.shade600, 0.6)!;
    }

    _leafBasePaint.color = leafBase;

    // Organic leaf shape - slightly asymmetric
    final leafLen = 52 * scale;
    final leafWidth =
        (20 + 5 * math.sin(seed.toDouble())) * scale * unfoldingFactor;

    final path = Path()..moveTo(0, 0);
    // Upper edge
    path.cubicTo(
      leafLen * 0.2,
      -leafWidth * (0.8 + curlAmount),
      leafLen * 0.7,
      -leafWidth * (1.1 + curlAmount),
      leafLen,
      0,
    );
    // Lower edge
    path.cubicTo(
      leafLen * 0.7,
      leafWidth * (1.1 - curlAmount),
      leafLen * 0.2,
      leafWidth * (0.8 - curlAmount),
      0,
      0,
    );
    path.close();

    canvas.drawPath(path, _leafBasePaint);

    // Gradient for depth and chlorophyll distribution
    final leafGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [leafBase, leafEdge],
    ).createShader(Rect.fromLTWH(0, -leafWidth, leafLen, leafWidth * 2));
    _leafGradientPaint.shader = leafGradient;
    canvas.drawPath(path, _leafGradientPaint);

    // Midrib (Main Vein)
    _veinPaint.strokeWidth = 1.4 * scale;
    canvas.drawLine(Offset.zero, Offset(leafLen * 0.9, 0), _veinPaint);

    // Lateral veins (Secondary)
    if (scale > 0.15) {
      final secondaryVeinPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6 * scale;

      for (int i = 1; i <= 4; i++) {
        final vx = (i / 5.0) * leafLen;
        final vy = (1.0 - (i / 5.0)) * leafWidth * 0.6;
        canvas.drawLine(
          Offset(vx, 0),
          Offset(vx + 4 * scale, -vy),
          secondaryVeinPaint,
        );
        canvas.drawLine(
          Offset(vx, 0),
          Offset(vx + 4 * scale, vy),
          secondaryVeinPaint,
        );
      }
    }

    // Highlights
    _leafHighlightPaint.strokeWidth = 1.0 * scale;
    canvas.drawPath(path, _leafHighlightPaint);

    if (highlighted) {
      final zoom = game.camera.viewfinder.zoom;
      final pulse = 0.5 + 0.5 * math.sin(game.currentTime() * 8);

      _leafPulsePaint
        ..color = Colors.white.withValues(alpha: 0.6 * pulse)
        ..strokeWidth = 2.0 / zoom;

      canvas.drawPath(path, _leafPulsePaint);
    }

    // Stomata (Pores) - subtle visualization
    final stomatalOpening =
        (game.simulationState?.plant.psiLeaf ?? -0.3).abs() < 1.0 ? 1.0 : 0.2;
    if (scale > 0.3 && stomatalOpening > 0.5) {
      final stomataPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.05);
      for (int i = 0; i < 3; i++) {
        final sx = 15 * scale + i * 10 * scale;
        canvas.drawCircle(Offset(sx, 2 * scale), 1.0 * scale, stomataPaint);
        canvas.drawCircle(Offset(sx, -2 * scale), 1.0 * scale, stomataPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final plant = _plantData;
    if (plant == null) return false;

    // Check shoot (stem + leaves)
    final shootScale =
        0.5 + (plant.totalBiomass / 1000.0).clamp(0.0, 1.5) + _growthBoost;
    final shootHeight = 320.0 * shootScale;
    final shootRect = Rect.fromLTWH(
      -40 * shootScale,
      -shootHeight,
      80 * shootScale,
      shootHeight,
    );
    if (shootRect.contains(point.toOffset())) return true;

    // Check against root nodes (increased radius for selectability)
    final nodes = plant.rootSystem;
    for (int i = 0; i < nodes.length; i++) {
      final pos = _mapRootToLocal(
        nodes[i],
        i,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );
      if (point.distanceTo(pos) < 24.0) return true;
    }
    return false;
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    final plant = _plantData;
    if (plant == null) return;

    final localPos = event.localPosition;

    // Update root hovering index
    _hoveredRootIndex = null;
    for (int i = 0; i < plant.rootSystem.length; i++) {
      final node = plant.rootSystem[i];
      final pos = _mapRootToLocal(
        node,
        i,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );
      if (localPos.distanceTo(pos) < 24.0) {
        _hoveredRootIndex = i;
        if (!isHovered) _showPlantInfo(pinned: false);
        return;
      }
    }

    if (isHovered) _showPlantInfo(pinned: false);
    super.onPointerMove(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final plant = _plantData;
    if (plant == null) return;

    final localPos = event.localPosition;

    // Check for root node selection (increased radius)
    for (int i = 0; i < plant.rootSystem.length; i++) {
      final node = plant.rootSystem[i];
      final pos = _mapRootToLocal(
        node,
        i,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );
      if (localPos.distanceTo(pos) < 24.0) {
        _pinnedRootIndex = i;
        final info = _getRootInfo(node, plant);
        info['screenPosition'] = game.worldToScreen(absolutePositionOf(pos)).toOffset();
        game.ref
            .read(uIStateProvider.notifier)
            .showInfo(info);
        return;
      }
    }

    _pinnedRootIndex = null;
    _isPinned = !_isPinned;
    _showPlantInfo(pinned: _isPinned);

    if (_isPinned) {
      final isShoot = localPos.y < 0;
      if (isShoot) {
        game.ref
            .read(simulationSessionProvider.notifier)
            .selectInspector(localPos.y < -100 ? 'leaf' : 'stem');
      } else {
        game.ref
            .read(simulationSessionProvider.notifier)
            .selectInspector('root');
      }
    } else {
      game.ref.read(simulationSessionProvider.notifier).selectInspector(null);
    }

    event.handled = true;
  }

  @override
  void onHoverEnter() {
    final current = game.ref.read(uIStateProvider);
    if (current == null || !current.isPinned) _showPlantInfo(pinned: false);
  }

  @override
  void onHoverExit() {
    _hoveredRootIndex = null;
    if (!_isPinned) game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  Map<String, dynamic> _getRootInfo(RootNode node, Plant plant) {
    final l = game.l10n;
    final isTap = node.parentIndex == null;
    return {
      'title': isTap
          ? l.carrotTaprootTitle.toUpperCase()
          : l.fineRootTitle.toUpperCase(),
      'description': l.rootStructureDesc,
      'stats': {
        l.depthLabel: '${(node.z * 100).toStringAsFixed(1)} cm',
        l.radiusLabel: '${(node.radius * 1000).toStringAsFixed(2)} mm',
      },
      'accentColor': const Color(0xFF10B981), // Emerald
    };
  }

  void _showPlantInfo({bool pinned = false}) {
    final l = game.l10n;
    final plant = _plantData;
    if (plant == null) return;
    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.plantTitle.toUpperCase(),
            description: l.plantDescription,
            formula: r'\frac{dW}{dt} = L_{p}(P_{ext} - P_{int}) - k(W - W_{0})',
            stats: {
              l.heightLabel: '${(plant.height * 100).toStringAsFixed(1)} cm',
              l.turgorPressure:
                  '${(plant.turgorPressure * 100).toStringAsFixed(0)}%',
              l.biomassLabel: '${plant.totalBiomass.toStringAsFixed(1)} mg',
            },
            isPinned: pinned,
            accentColor: const Color(0xFF10B981), // Emerald
            screenPosition: game.worldToScreen(absolutePosition).toOffset(),
          ),
        );
  }
}

class _RootTipGlow {
  final Vector2 position;
  final double vitality;
  final bool isGrowth;
  double life = 0;

  _RootTipGlow({
    required this.position,
    this.vitality = 1.0,
    this.isGrowth = true,
  });

  void update(double dt) => life += dt;
  double get alpha => (1.0 - life / 2.5).clamp(0.0, 1.0);
  double get pulse => math.sin(life * (isGrowth ? 8.0 : 4.0));
  bool get isDone => life > 2.5;
}
