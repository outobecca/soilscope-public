import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:oxygen/oxygen.dart' as ecs;
import '../soil_scope_game.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../../domain/models/plant.dart';
import 'animated_plant_component.dart';
import 'animated_microbe_component.dart';
import 'animated_earthworm_component.dart';
import 'scene_coordinate_mapper.dart';

class PlantDataComponent extends ecs.Component<Plant> {
  late Plant data;

  @override
  void init([Plant? data]) {
    if (data != null) this.data = data;
  }

  @override
  void reset() {}
}

class MicrobeDataComponent extends ecs.Component<Map<String, dynamic>> {
  late double x;
  late double y;
  late int seed;

  @override
  void init([Map<String, dynamic>? data]) {
    if (data != null) {
      x = data['x'] ?? 0.0;
      y = data['y'] ?? 0.0;
      seed = data['seed'] ?? 0;
    }
  }

  @override
  void reset() {}
}

/// Manages biological entities using Oxygen ECS.
/// Enforces strict population limits for simulation stability.
class BiologicalEntitiesComponent extends Component
    with HasGameReference<SoilScopeGame> {
  final math.Random _random = math.Random.secure();
  late ecs.World _ecsWorld;

  // STRICT LIMITS: Reduced density for clarity (Task: Combine/Reduce)
  static const int maxMicrobes = 12;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _ecsWorld = ecs.World();
    _ecsWorld.registerComponent<PlantDataComponent, Plant>(
      () => PlantDataComponent(),
    );
    _ecsWorld.registerComponent<MicrobeDataComponent, Map<String, dynamic>>(
      () => MicrobeDataComponent(),
    );
    _ecsWorld.init();

    final state = game.simulationState;
    if (state != null) updateState(state);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _ecsWorld.execute(dt);
  }

  void updateState(BiophysicalState state) {
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final soilX = game.soilLeftX;
    final surfaceY = game.soilSurfaceY;

    // 1. Sync Plants ECS & Visuals
    final existingPlants = children.query<AnimatedPlantComponent>();
    final Map<String, AnimatedPlantComponent> plantMap = {
      for (var p in existingPlants) p.plantId: p,
    };

    final activePlantIds = state.plants.map((p) => p.id).toSet();

    for (var id in plantMap.keys.toList()) {
      if (!activePlantIds.contains(id)) {
        plantMap[id]?.removeFromParent();
        plantMap.remove(id);
      }
    }

    for (final plant in state.plants) {
      if (!plantMap.containsKey(plant.id)) {
        final plantPos = SceneCoordinateMapper.mapShootPosition(
          plant.baseX,
          soilWidth,
          surfaceY,
        );
        plantPos.x += soilX;

        add(
          AnimatedPlantComponent(
            plantId: plant.id,
            position: plantPos,
            size: Vector2.zero(),
          )..priority = 500,
        );

        // Store in ECS World
        _ecsWorld.createEntity().add<PlantDataComponent, Plant>(plant);
      }
    }

    // 2. Sync Microbes ECS & Visuals
    _syncMicrobes(state);

    // 3. Sync Earthworms Visuals
    if (children.query<AnimatedEarthwormComponent>().isEmpty &&
        state.plants.isNotEmpty) {
      _initEarthworms(state);
    }
  }

  void _syncMicrobes(BiophysicalState state) {
    if (state.profile.layers.isEmpty || state.plants.isEmpty) return;

    final totalBiomass = state.profile.layers.fold<double>(
      0,
      (sum, l) => sum + l.microbialBiomass,
    );
    // Target count based on science, but strictly capped at 25 (Task: Reduce density)
    final int targetCount = (totalBiomass * 5.0).toInt().clamp(3, maxMicrobes);

    final existing = children.query<AnimatedMicrobeComponent>();
    final int currentCount = existing.length;

    if (currentCount < targetCount) {
      final int toAdd = targetCount - currentCount;
      final plant = state.plants.first;
      final surfaceY = game.soilSurfaceY;
      final soilWidth = SoilScopeGame.soilColumnWidth;

      for (int i = 0; i < toAdd; i++) {
        // Double-check the limit during generation to prevent race conditions or loops
        if (children.query<AnimatedMicrobeComponent>().length >= maxMicrobes) {
          break;
        }

        final centerX =
            SceneCoordinateMapper.mapShootPosition(
              plant.baseX,
              soilWidth,
              surfaceY,
            ).x +
            game.soilLeftX;
        final mx = _nextGaussian(
          centerX,
          150.0,
        ).clamp(game.soilLeftX + 20, game.soilLeftX + soilWidth - 20);
        final my = _nextGaussian(
          surfaceY + 150,
          200.0,
        ).clamp(surfaceY + 20, surfaceY + game.soilColumnHeight - 20);

        add(
          AnimatedMicrobeComponent(
            position: Vector2(mx, my),
            seed: _random.nextInt(10000),
          )..priority = 350,
        );
      }
    } else if (currentCount > targetCount) {
      final int toRemove = currentCount - targetCount;
      final existingList = existing.toList();
      for (int i = 0; i < toRemove; i++) {
        existingList[i].removeFromParent();
      }
    }
  }

  void _initEarthworms(BiophysicalState state) {
    if (children.query<AnimatedEarthwormComponent>().length >= 3 ||
        state.plants.isEmpty) {
      return;
    }
    final plant = state.plants.first;
    final surfaceY = game.soilSurfaceY;
    final soilWidth = SoilScopeGame.soilColumnWidth;

    for (int i = 0; i < 3; i++) {
      final centerX =
          SceneCoordinateMapper.mapShootPosition(
            plant.baseX,
            soilWidth,
            surfaceY,
          ).x +
          game.soilLeftX;
      final wx = _nextGaussian(
        centerX,
        250.0,
      ).clamp(game.soilLeftX + 50, game.soilLeftX + soilWidth - 50);
      final wy = _nextGaussian(
        surfaceY + 200,
        250.0,
      ).clamp(surfaceY + 50, surfaceY + game.soilColumnHeight - 50);

      add(
        AnimatedEarthwormComponent(
          position: Vector2(wx, wy),
          seed: _random.nextInt(1000),
          speed: 25.0 + _random.nextDouble() * 15.0,
        )..priority = 400,
      );
    }
  }

  /// Box-Muller transform for Gaussian distribution
  double _nextGaussian(double mean, double stdDev) {
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return z0 * stdDev + mean;
  }

  void triggerPlantGrowth() {
    final plants = children.query<AnimatedPlantComponent>();
    for (final plant in plants) {
      plant.triggerGrowth();
    }
  }
}
