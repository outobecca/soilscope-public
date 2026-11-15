import 'dart:ui' show PathMetric, lerpDouble;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/plant.dart';
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_provider.dart';
import 'canvas_hit_testing.dart';
import '../../../providers/simulation_session_provider.dart';
import 'soil_symbiosis_network_component.dart';
import 'scene_coordinate_mapper.dart';
import 'molecule_renderer.dart';
import 'riverpod_lifecycle_mixin.dart';
import 'animation_clock.dart';
import 'animation_math.dart';
import 'visual_seed.dart';

part 'animated_plant_component_painting.dart';

/// Primary visual entity representing a dynamic plant system.
/// Handles high-fidelity growth animations and biophysical interactions.
class AnimatedPlantComponent extends PositionComponent
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        RiverpodLifecycleMixin {
  final String plantId;
  late final math.Random _random = visualRandom(['plant', plantId]);

  String get keyboardLabel {
    final plant = _plantData;
    if (plant == null || plant.species.isEmpty) return plantId;
    return plant.species;
  }

  // Physiological Smoothing State
  double _smoothTurgor = 1.0;
  double _smoothVitality = 1.0;
  double _smoothBiomass = 50.0;
  double _smoothAge = 0.0;
  double _senescence = 0.0; // 0 (fresh) to 1 (senescent/yellow)
  double _solarRadiation = 800; // Average solar radiation in W/m^2
  double _growthBoost = 0.0;
  bool _isPinned = false;

  /// Root nodes are small on screen; keep their mouse target zoom-aware so
  /// they neither become impossible to hit zoomed out nor swallow the whole
  /// root zone when zoomed in.
  double get _rootHitRadius => CanvasHitTesting.worldRadius(
    zoom: game.camera.viewfinder.zoom,
    screenRadius: 24,
    visualWorldRadius: 6,
    minWorld: 6,
    maxWorld: 36,
  );
  bool _isRunning = false;

  final List<_RootTipGlow> _tipGlows = [];
  final Map<int, double> _nodeBirthTimes = {};
  final RateAccumulator _exudateAccumulator = RateAccumulator();
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
  List<Vector2>? getPlantVascularPath(
    Vector2 startWorld, {
    bool stopAtCollar = false,
  }) {
    final plant = _plantData;
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

    if (stopAtCollar) return path;

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
    // INCREASED: More points for smoother transit and reliable removal
    for (int i = 1; i <= 12; i++) {
      final t = i / 12.0;
      final lx = _cubicBezier(0, cp1X, cp2X, topX, t);
      final ly = _cubicBezier(0, cp1Y, cp2Y, topY, t);

      // Add a slight "leaf seeking" jitter at the end
      final foliageJitterX = (t > 0.8)
          ? math.sin(t * 10 + plant.baseX) * 15.0
          : 0.0;
      path.add(collarPos + Vector2(lx + foliageJitterX, ly));
    }

    return path;
  }

  @override
  void onMount() {
    super.onMount();

    // Fine-grained listener for THIS plant's data
    listenProvider<Plant?>(
      displayedSimulationStateProvider.select(
        (s) => s.plants.cast<Plant?>().firstWhere(
          (p) => p?.id == plantId,
          orElse: () => null,
        ),
      ),
      (prev, next) {
        final rootCount = next?.rootSystem.length ?? 0;
        if (rootCount > _previousRootCount && next != null) {
          final time = game.currentTime();
          for (int i = _previousRootCount; i < rootCount; i++) {
            _nodeBirthTimes[i] = time;
          }
          _onNewRootGrowth(next);
        } else if (rootCount < _previousRootCount) {
          // Scrubbing history can take the plant back before some roots grew.
          // Drop their birth times so the same indices animate as new growth
          // when the run advances again.
          _nodeBirthTimes.removeWhere((index, _) => index >= rootCount);
        }
        if (next == null) {
          _tipGlows.clear();
          _schematicRootPositions.clear();
        }
        _previousRootCount = rootCount;
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
    listenProvider<VisualLayoutMode>(visualLayoutModeStateProvider, (
      prev,
      next,
    ) {
      _layoutMode = next;
      if (next == VisualLayoutMode.schematic) {
        final plant = _plantData;
        if (plant != null) _calculateSchematicLayout(plant);
      }
    }, fireImmediately: true);
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

  /// Fetch this plant from the interpolated visual state, not the raw
  /// provider snapshot. The latter updates at the engine tick rate and would
  /// make turgor, biomass and senescence step between frames.
  Plant? get _plantData {
    for (final plant in game.displayedState.plants) {
      if (plant.id == plantId) return plant;
    }
    return null;
  }

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
    final targetProgress = _layoutMode == VisualLayoutMode.schematic
        ? 1.0
        : 0.0;
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

    // Physiological smoothing is visual motion, not simulation state. A
    // historical snapshot snaps to its exact values; live playback smooths
    // them; a paused, inspected or hidden frame must not keep drifting.
    final targetTurgor = plant.turgorPressure;
    final state = game.simulationState;
    final nContent = (state != null && state.profile.layers.isNotEmpty)
        ? (state.profile.layers.first.nitrateContent +
              state.profile.layers.first.ammoniumContent)
        : 30.0;
    final targetVitality = (nContent / 40.0).clamp(0.2, 1.0);
    final animationMode = game.animationClock.mode;

    if (animationMode == AnimationMode.history) {
      _smoothTurgor = targetTurgor;
      _smoothVitality = targetVitality;
      _smoothBiomass = plant.totalBiomass;
      _smoothAge = plant.age;
    } else if (animationMode == AnimationMode.live) {
      // Exponential smoothing keeps wilting and growth visually consistent at
      // any refresh rate, including frame drops on low-end devices.
      final visualDt = game.animationClock.visualDt;
      _smoothTurgor = dampTowards(
        current: _smoothTurgor,
        target: targetTurgor,
        rate: 0.8,
        dt: visualDt,
      );
      _smoothVitality = dampTowards(
        current: _smoothVitality,
        target: targetVitality,
        rate: 0.4,
        dt: visualDt,
      );
      _smoothBiomass = dampTowards(
        current: _smoothBiomass,
        target: plant.totalBiomass,
        rate: 0.16,
        dt: visualDt,
      );
      _smoothAge = dampTowards(
        current: _smoothAge,
        target: plant.age,
        rate: 0.1,
        dt: visualDt,
      );
    }

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
      final tips = plant.rootSystem
          .asMap()
          .entries
          .where((e) => e.value.isTip)
          .toList();
      if (tips.isNotEmpty) {
        final entry = tips[_random.nextInt(tips.length)];
        final pos = _mapRootToLocal(
          entry.value,
          entry.key,
          plant.baseX,
          worldWidth,
          game.soilColumnHeight,
        );
        _tipGlows.add(
          _RootTipGlow(position: pos, vitality: vitality, isGrowth: false),
        );
      }
    }

    for (final glow in _tipGlows) {
      glow.update(dt);
    }
    _tipGlows.removeWhere((g) => g.isDone);

    _spawnExudates(plant, dt);

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
        _tipGlows.add(
          _RootTipGlow(position: pos, vitality: vitality, isGrowth: true),
        );
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

    // Release rate in events per second. The accumulator keeps the visual
    // density independent of frame rate and avoids a burst after a slow frame.
    final spawnRatePerSecond = (0.05 + carbonAvailability * 0.15) * 60.0;

    if (_exudateAccumulator.consume(dt, spawnRatePerSecond) > 0) {
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
        final rawY = SceneCoordinateMapper.mapRootY(
          node.z,
          game.soilSurfaceY,
          game.soilColumnHeight,
        );
        return Vector2(
          SceneCoordinateMapper.mapRootX(
                node.x,
                SoilScopeGame.soilColumnWidth,
                baseX: plant.baseX,
              ) +
              game.soilLeftX,
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
              tipPos + Vector2((_random.nextDouble() - 0.5) * 40, 20),
              tipPos,
            );
            if (netPath != null) fullPath.addAll(netPath);
          }
          final plantPath = getPlantVascularPath(
            tipPos,
            stopAtCollar: type == MoleculeType.ammonium,
          );
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

  @override
  bool containsLocalPoint(Vector2 point) {
    final plant = _plantData;
    if (plant == null) return false;

    // Check shoot (stem + leaves) with generous horizontal width for spreading leaves
    final shootScale =
        0.5 + (plant.totalBiomass / 1000.0).clamp(0.0, 1.5) + _growthBoost;
    final shootHeight = 320.0 * shootScale;
    final shootRect = Rect.fromLTWH(
      -100 * shootScale,
      -shootHeight,
      200 * shootScale,
      shootHeight,
    );
    if (shootRect.contains(point.toOffset())) return true;

    // Check against root nodes with a screen-space-stable target radius.
    final nodes = plant.rootSystem;
    for (int i = 0; i < nodes.length; i++) {
      final pos = _mapRootToLocal(
        nodes[i],
        i,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );
      if (point.distanceTo(pos) <= _rootHitRadius) return true;
    }
    return false;
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    final plant = _plantData;
    if (plant == null) return;

    final localPos = event.localPosition;

    // Check root hovering with nearest-node targeting. Choosing the nearest
    // node matters where several fine roots overlap on screen.
    int? foundRootIndex;
    Vector2? foundRootPos;
    RootNode? foundRootNode;
    double nearestRootDistance = _rootHitRadius;

    for (int i = 0; i < plant.rootSystem.length; i++) {
      final node = plant.rootSystem[i];
      final pos = _mapRootToLocal(
        node,
        i,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );
      final distance = localPos.distanceTo(pos);
      if (distance <= nearestRootDistance) {
        nearestRootDistance = distance;
        foundRootIndex = i;
        foundRootPos = pos;
        foundRootNode = node;
      }
    }

    if (foundRootIndex != null) {
      if (_hoveredRootIndex != foundRootIndex) {
        _hoveredRootIndex = foundRootIndex;
        final current = game.ref.read(uIStateProvider);
        if (current == null || !current.isPinned) {
          final info = _getRootInfo(foundRootNode!, plant);
          game.ref
              .read(uIStateProvider.notifier)
              .setHoverInfo(
                HoverInfo(
                  title: info['title'] as String,
                  description: info['description'] as String,
                  stats: info['stats'] as Map<String, String>?,
                  isPinned: false,
                  accentColor: info['accentColor'] as Color?,
                  screenPosition: game
                      .worldToScreen(absolutePositionOf(foundRootPos!))
                      .toOffset(),
                ),
              );
        }
      }
      return;
    }

    // When moving away from roots onto shoot or moving within shoot
    if (_hoveredRootIndex != null) {
      _hoveredRootIndex = null;
      final current = game.ref.read(uIStateProvider);
      if (current == null || !current.isPinned) {
        _showPlantInfo(pinned: false, localHoverY: localPos.y);
      }
    } else if (isHovered) {
      _showPlantInfo(pinned: false, localHoverY: localPos.y);
    }
    super.onPointerMove(event);
  }

  /// Opens the shoot inspection used by a canvas tap. Keyboard users reach
  /// this through the canvas focus target list.
  void activateFromKeyboard() {
    if (_plantData == null) return;
    _pinnedRootIndex = null;
    _isPinned = true;
    _showPlantInfo(pinned: true, localHoverY: -100);
    game.ref.read(simulationSessionProvider.notifier).selectInspector('stem');
  }

  @override
  void onTapUp(TapUpEvent event) {
    final plant = _plantData;
    if (plant == null) return;

    final localPos = event.localPosition;

    // Check for the nearest root node within the current screen-space target.
    int? nearestRootIndex;
    Vector2? nearestRootPos;
    RootNode? nearestRootNode;
    double nearestRootDistance = _rootHitRadius;
    for (int i = 0; i < plant.rootSystem.length; i++) {
      final node = plant.rootSystem[i];
      final pos = _mapRootToLocal(
        node,
        i,
        plant.baseX,
        SoilScopeGame.soilColumnWidth,
        game.soilColumnHeight,
      );
      final distance = localPos.distanceTo(pos);
      if (distance <= nearestRootDistance) {
        nearestRootDistance = distance;
        nearestRootIndex = i;
        nearestRootPos = pos;
        nearestRootNode = node;
      }
    }

    if (nearestRootIndex != null &&
        nearestRootPos != null &&
        nearestRootNode != null) {
      final i = nearestRootIndex;
      final pos = nearestRootPos;
      final node = nearestRootNode;
      final sourceId = 'plant-root-$plantId-$i';
      final current = game.ref.read(uIStateProvider);
      if (current?.isPinned == true && current?.sourceId == sourceId) {
        // Tapping the same root again releases the inspection, matching the
        // other canvas entities on touch devices.
        _pinnedRootIndex = null;
        game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
        event.handled = true;
        return;
      }

      // A root selection replaces any shoot-level selection. Keep the two
      // local states mutually exclusive so closing the root card cannot
      // leave the plant's hover/dismiss logic stuck in its old state.
      _pinnedRootIndex = i;
      _isPinned = false;
      final info = _getRootInfo(node, plant);
      info['screenPosition'] = game
          .worldToScreen(absolutePositionOf(pos))
          .toOffset();
      info['isPinned'] = true;
      game.ref
          .read(uIStateProvider.notifier)
          .showInfo(
            info,
            sourceId: sourceId,
            onDismiss: () => _pinnedRootIndex = null,
          );
      event.handled = true;
      return;
    }

    _pinnedRootIndex = null;
    _isPinned = !_isPinned;
    _showPlantInfo(pinned: _isPinned, localHoverY: localPos.y);

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
    // A pinned root card is independent of the plant-level pin flag.
    if (!_isPinned && _pinnedRootIndex == null) {
      game.ref.read(uIStateProvider.notifier).clearUnpinnedHover();
    }
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

  void _showPlantInfo({bool pinned = false, double? localHoverY}) {
    final l = game.l10n;
    final plant = _plantData;
    if (plant == null) return;

    final shootScale =
        0.5 + (plant.totalBiomass / 1000.0).clamp(0.0, 1.5) + _growthBoost;
    final shootHeight = 320.0 * shootScale;

    // Anchor near the canopy/shoot when hovering above ground, otherwise center shoot
    final targetY = localHoverY != null && localHoverY < 0
        ? localHoverY.clamp(-shootHeight, -20.0)
        : -shootHeight * 0.55;
    final anchorWorld = absolutePositionOf(Vector2(0, targetY));

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
            sourceId: 'plant-$plantId',
            onDismiss: () => _isPinned = false,
            accentColor: const Color(0xFF10B981), // Emerald
            screenPosition: game.worldToScreen(anchorWorld).toOffset(),
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
