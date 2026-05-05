import 'dart:math' as math;
import 'package:flame/components.dart';
import '../soil_scope_game.dart';
import '../../../providers/simulation_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/solvers/particle_physics_solver.dart';
import 'molecule_particle_component.dart';
import 'bubble_component.dart';
import 'scene_coordinate_mapper.dart';
import 'data_hotspot_component.dart';
import 'soil_layer_component.dart';
import 'soil_symbiosis_network_component.dart';
import 'animated_plant_component.dart';
import 'riverpod_lifecycle_mixin.dart';
import 'animation_layer.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../../core/biophysics_utils.dart';

/// Orchestrates small-scale biochemical animations like root exudates,
/// enzymatic hotspots, and gas bubbles for all plants.
class BiochemicalDynamicsComponent extends Component with HasGameReference<SoilScopeGame>, RiverpodLifecycleMixin {
  final math.Random _random = math.Random();
  double _lastSync = 0;

  bool _isRunning = false;
  double _solarRadiation = 0.0;

  @override
  void onMount() {
    super.onMount();

    listenProvider<bool>(
      simulationProvider.select((s) => s.isRunning),
      (prev, next) => _isRunning = next,
      fireImmediately: true,
    );

    listenProvider<double>(
      displayedSimulationStateProvider.select((s) => s.solarRadiation),
      (prev, next) => _solarRadiation = next,
      fireImmediately: true,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_isRunning) return;

    _lastSync += dt;

    if (_lastSync > 1.0) {
      _syncMolecularParticles();
      _lastSync = 0;
    }

    _spawnExudates(dt);
    _spawnBubbles(dt);
    _spawnNitrogenCycleFlow(dt);
    _spawnGasExchangeFlows(dt);
    _spawnWaterCycleFlows(dt);
  }

  void _spawnExudates(double dt) {
    final state = game.simulationState;
    if (state == null) return;

    final existingCount = game.world.children.query<MoleculeParticleComponent>().length;
    if (existingCount > 25) return;

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    for (final plant in state.plants) {
      final nodes = plant.rootSystem;
      if (nodes.isNotEmpty && plant.totalBiomass > 1.0) {
        // Exudation depends on biomass and stress
        final activityFactor = (plant.totalBiomass / 1000.0).clamp(0.01, 1.0);
        
        // REDUCED: Decreased spawn frequency for better visibility
        if (_random.nextDouble() < 0.01 * activityFactor * dt) { 
          final node = nodes[_random.nextInt(nodes.length)];
          final pos = Vector2(
            SceneCoordinateMapper.mapRootX(node.x, worldWidth, baseX: plant.baseX) + game.soilLeftX,
            SceneCoordinateMapper.mapRootY(node.z, surfaceY, soilHeight),
          );

          // Find layer to consume Carbon from
          final layer = state.profile.layers.firstWhere(
            (l) => node.z >= l.depth && node.z <= l.depth + l.thickness,
            orElse: () => state.profile.layers.first,
          );

          // MASS CONSERVATION: Consume POM/Labile C from state
          final amount = 0.05;
          final isCarbon = _random.nextDouble() < 0.7;
          final consumed = game.ref.read(simulationProvider.notifier).consumeResource(
            layer.id, 
            isCarbon ? 'labileCarbon' : 'nitrate', 
            amount,
          );
          
          if (consumed) {
            Vector2 target = pos + Vector2((_random.nextDouble() - 0.5) * 60, 80);
            final hotspots = game.world.children.whereType<SoilLayerComponent>()
                .expand((l) => l.children.whereType<DataHotspotComponent>())
                .where((h) => h.label.contains('POM') || h.label.contains('Mic'))
                .toList();
            
            if (hotspots.isNotEmpty) {
              target = hotspots[_random.nextInt(hotspots.length)].position;
            }

            final vel = (target - pos).normalized() * (40.0 + _random.nextDouble() * 20);
            
            // PATHFINDING (Task 5/6): Use symbiotic network if possible
            List<Vector2>? networkPath;
            final network = game.world.children.query<SoilSymbiosisNetworkComponent>().firstOrNull;
            if (network != null) {
              networkPath = network.findNetworkPath(pos, target);
            }

            game.moleculePool?.spawn(
              type: isCarbon ? MoleculeType.labileCarbon : MoleculeType.organicNitrogen,
              position: pos, 
              velocity: vel,
              targetPosition: target,
              path: networkPath,
              seed: _random.nextInt(100),
              lifeTime: 6.5, // Increased lifetime for complex paths
            );
          }
        }
      }
    }
  }

  void _spawnNitrogenCycleFlow(double dt) {
    final state = game.simulationState;
    if (state == null) return;

    final flowMode = game.ref.read(particleFlowModeProvider);
    final existingCount = game.world.children.query<MoleculeParticleComponent>().length;
    final maxParticles = flowMode ? 60 : 15;
    if (existingCount > maxParticles) return; 

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    final hotspots = game.world.children.whereType<SoilLayerComponent>()
        .expand((l) => l.children.whereType<DataHotspotComponent>())
        .where((h) => h.label == 'NH₄⁺' || h.label == 'NO₃⁻' || h.label == 'N')
        .toList();

    for (int i = 0; i < state.profile.layers.length; i++) {
      final layer = state.profile.layers[i];
      final layerY = surfaceY + (layer.depth / 1.0) * soilHeight;

      // --- 1. NITRIFICATION TRANSFORMATION (NH4 -> NO3) ---
      if (layer.nitrificationRate > 1e-7 && _random.nextDouble() < 0.05 * dt) {
        final rx = game.soilLeftX + _random.nextDouble() * worldWidth;
        final ry = layerY + _random.nextDouble() * (layer.thickness * soilHeight);

        game.moleculePool?.spawn(
          type: MoleculeType.ammonium,
          transformTarget: MoleculeType.nitrate,
          position: Vector2(rx, ry),
          velocity: Vector2((_random.nextDouble() - 0.5) * 10, -5),
          seed: _random.nextInt(100),
          lifeTime: 4.0,
        );
      }

      // --- 2. DENITRIFICATION TRANSFORMATION (NO3 -> N2O) ---
      if (layer.denitrificationRate > 1e-7 && _random.nextDouble() < 0.05 * dt) {
        final rx = game.soilLeftX + _random.nextDouble() * worldWidth;
        final ry = layerY + _random.nextDouble() * (layer.thickness * soilHeight);

        game.moleculePool?.spawn(
          type: MoleculeType.nitrate,
          transformTarget: MoleculeType.nitrousOxide,
          position: Vector2(rx, ry),
          velocity: Vector2((_random.nextDouble() - 0.5) * 10, -15), // Upward drift
          seed: _random.nextInt(100),
          lifeTime: 5.0,
        );
      }

      // --- 3. LEACHING FLOW (Downwards NO3- movement) ---
      if (layer.verticalFlux > 1e-7 && layer.nitrateContent > 5.0 && _random.nextDouble() < 0.1 * dt) {
        final rx = game.soilLeftX + _random.nextDouble() * worldWidth;
        final ry = layerY + 10;

        game.moleculePool?.spawn(
          type: MoleculeType.nitrate,
          position: Vector2(rx, ry),
          velocity: Vector2(0, (layer.verticalFlux * 1e6 * 2.0).clamp(20, 150)),
          seed: _random.nextInt(100),
          lifeTime: 3.0,
        );
      }
    }

    // Existing Uptake Flow Logic
    for (final plant in state.plants) {
      final tips = plant.rootSystem.where((n) => n.isTip).toList();
      if (tips.isEmpty) continue;

      // N-flow depends on actual uptake, boosted by Flow Mode
      final layer = state.profile.layers.firstOrNull;
      final activityFactor = layer != null ? BiophysicsUtils.q10Factor(layer.temperature).clamp(0.1, 4.0) : 1.0;
      double spawnChance = 0.015 * activityFactor * dt;
      if (flowMode) spawnChance *= 2.5;

      if (_random.nextDouble() < spawnChance) {
        final tipNode = tips[_random.nextInt(tips.length)];
        final tipPos = Vector2(
          SceneCoordinateMapper.mapRootX(tipNode.x, worldWidth, baseX: plant.baseX) + game.soilLeftX,
          SceneCoordinateMapper.mapRootY(tipNode.z, surfaceY, soilHeight),
        );

        Vector2 startPos;
        String? startLayerId;

        if (hotspots.isNotEmpty) {
          final h = hotspots[_random.nextInt(hotspots.length)];
          startPos = h.position;
          startLayerId = h.layerId;
        } else {
          // Fallback: spawn from a point within the soil column, biased towards the plant
          final plantWorldX = SceneCoordinateMapper.mapRootX(0.5, worldWidth, baseX: plant.baseX) + game.soilLeftX;
          final rx = _nextGaussian(plantWorldX, 300.0).clamp(game.soilLeftX, game.soilLeftX + worldWidth);
          final ry = tipPos.y + 40.0 + _random.nextDouble() * 100.0;
          startPos = Vector2(rx, ry);
        }

        final amount = 0.05;
        final type = _random.nextBool() ? MoleculeType.nitrate : MoleculeType.ammonium;
        final resType = type == MoleculeType.nitrate ? 'nitrate' : 'ammonium';
        
        bool success = true;
        if (startLayerId != null) {
          success = game.ref.read(simulationProvider.notifier).consumeResource(startLayerId, resType, amount);
          if (success && hotspots.isNotEmpty) {
             // Find specific hotspot and pulse it
             final h = hotspots.firstWhere((h) => h.layerId == startLayerId && h.label.contains(type == MoleculeType.nitrate ? 'NO₃' : 'NH₄'), orElse: () => hotspots.first);
             h.triggerPulse();
          }
        }

        if (success) {
          final speed = 40.0 + _random.nextDouble() * 25.0;
          
          // PATHFINDING (Task 5/6): Route through fungal network AND up the plant
          final List<Vector2> fullPath = [];
          
          // 1. Fungal Network
          final network = game.world.children.query<SoilSymbiosisNetworkComponent>().firstOrNull;
          if (network != null) {
            final netPath = network.findNetworkPath(startPos, tipPos);
            if (netPath != null) fullPath.addAll(netPath);
          }
          
          // 2. Plant Vascular Path
          final plantComp = game.world.children.query<SimulationAnimationLayer>().firstOrNull
              ?.children.query<AnimatedPlantComponent>().where((p) => p.plantId == plant.id).firstOrNull;
          if (plantComp != null) {
            final plantPath = plantComp.getPlantVascularPath(tipPos);
            if (plantPath != null) fullPath.addAll(plantPath);
          }

          game.moleculePool?.spawn(
            type: type,
            position: startPos,
            targetPosition: fullPath.isNotEmpty ? fullPath.last : tipPos, 
            path: fullPath.isNotEmpty ? fullPath : null,
            velocity: (tipPos - startPos).normalized() * speed,
            seed: _random.nextInt(1000),
            lifeTime: 12.0, // Long lifetime for full plant transit
          );
        }
      }
    }
  }

  void _spawnGasExchangeFlows(double dt) {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return;

    final existingCount = game.world.children.query<MoleculeParticleComponent>().length;
    if (existingCount > 20) return; 

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final plant = state.plants.first;
    final plantWorldX = SceneCoordinateMapper.mapRootX(0.5, worldWidth, baseX: plant.baseX) + game.soilLeftX;

    final photosynthesisRate = (_solarRadiation / 1000.0).clamp(0.1, 1.0);
    // CO2 Flow: Bias start position towards the plant to represent local atmospheric drawdown
    if (_random.nextDouble() < 0.025 * photosynthesisRate * dt) {
      final startX = _nextGaussian(plantWorldX, 400.0).clamp(game.soilLeftX, game.soilLeftX + worldWidth);
      final startY = surfaceY - 500; 
      
      final plantWorldPos = SceneCoordinateMapper.mapShootPosition(plant.baseX, worldWidth, surfaceY);
      final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
      final foliageTarget = Vector2(plantWorldPos.x + game.soilLeftX, surfaceY - visualHeight * 0.6);

      game.moleculePool?.spawn(
        type: MoleculeType.co2,
        position: Vector2(startX, startY),
        targetPosition: foliageTarget,
        velocity: (foliageTarget - Vector2(startX, startY)).normalized() * 50.0,
        seed: _random.nextInt(100),
        lifeTime: 8.0,
      );
    }

    // REDUCED: Decreased spawn frequency for better visibility
    if (_random.nextDouble() < 0.01 * photosynthesisRate * dt) {
       final plantWorldPos = SceneCoordinateMapper.mapShootPosition(plant.baseX, worldWidth, surfaceY);
       final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
       final startPos = Vector2(plantWorldPos.x + game.soilLeftX + (_random.nextDouble() - 0.5) * 40, surfaceY - visualHeight * 0.7);

       game.moleculePool?.spawn(
         type: MoleculeType.oxygen,
         position: startPos,
         targetPosition: Vector2(startPos.x, surfaceY - 500),
         velocity: Vector2(0, -90.0),
         seed: _random.nextInt(100),
         lifeTime: 5.0,
       );
    }
  }

  void _spawnWaterCycleFlows(double dt) {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return;

    final existingCount = game.world.children.query<MoleculeParticleComponent>().length;
    if (existingCount > 35) return; // REDUCED: from 80

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final plant = state.plants.first;
    final transpirationActivity = (plant.actualTranspiration * 200000.0).clamp(0.1, 1.5);

    // REDUCED: Decreased spawn frequency for better visibility
    if (_random.nextDouble() < 0.025 * transpirationActivity * dt) {
      final tips = game.rootTipWorldPositions;
      if (tips.isNotEmpty) {
        final targetTip = tips[_random.nextInt(tips.length)];
        final startPos = targetTip.clone()..add(Vector2((_random.nextDouble()-0.5)*60, 100));
        
        // Water path: Soil -> Root Tip -> Stem -> Foliage
        final List<Vector2> waterPath = [];
        final plantComp = game.world.children.query<SimulationAnimationLayer>().firstOrNull
            ?.children.query<AnimatedPlantComponent>().firstOrNull;
        if (plantComp != null) {
          final pPath = plantComp.getPlantVascularPath(targetTip);
          if (pPath != null) waterPath.addAll(pPath);
        }

        game.moleculePool?.spawn(
          type: MoleculeType.water,
          position: startPos,
          targetPosition: waterPath.isNotEmpty ? waterPath.last : targetTip,
          path: waterPath.isNotEmpty ? waterPath : null,
          velocity: Vector2(0, -60.0),
          seed: _random.nextInt(100),
          lifeTime: 10.0,
        );
      }
    }

    // REDUCED: Decreased spawn frequency for better visibility
    if (_random.nextDouble() < 0.025 * transpirationActivity * dt) {
      final shootPos = SceneCoordinateMapper.mapShootPosition(plant.baseX, worldWidth, surfaceY);
      final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
      final startPos = Vector2(shootPos.x + game.soilLeftX, surfaceY);
      final foliageTarget = Vector2(startPos.x, surfaceY - visualHeight * 0.7);

      game.moleculePool?.spawn(
        type: MoleculeType.water,
        position: startPos,
        targetPosition: foliageTarget,
        velocity: Vector2(0, -110.0),
        seed: _random.nextInt(100),
        lifeTime: 4.0,
      );
    }
  }

  void _spawnBubbles(double dt) {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return;

    final existingBubbles = game.world.children.query<BubbleComponent>().length;
    if (existingBubbles > 10) return; // REDUCED: from 20

    final soilX = game.soilLeftX;
    final soilWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;
    final plant = state.plants.first;
    final centerX = SceneCoordinateMapper.mapShootPosition(plant.baseX, soilWidth, surfaceY).x + soilX;

    for (final layer in state.profile.layers.take(3)) {
      // Bubble frequency tied to concentration and saturation
      final gasConcentration = layer.co2Content + layer.methaneContent + layer.nitrousOxideContent;
      final saturation = layer.waterContent / layer.porosity;
      
      // Bubbles spawn easier in wet soil (diffusion blocked)
      final spawnChance = (gasConcentration * 0.02 * saturation).clamp(0.002, 0.1); // REDUCED: from 0.05 / 0.005 / 0.2

      if (_random.nextDouble() < spawnChance * dt * 0.75) { // FURTHER REDUCED: from 1.5
        // RHIZOSPHERE FOCUS: Gaussian bias towards plant (primary respiration source)
        final x = _nextGaussian(centerX, 200.0).clamp(soilX, soilX + soilWidth);
        final y = surfaceY + (layer.depth / 1.0) * soilHeight + _random.nextDouble() * 50;

        final eh = layer.redoxPotential;
        BubbleType bType = BubbleType.co2;
        String symbol = 'CO2';
        
        if (eh < -200 && layer.methaneContent > 0.1) {
          bType = BubbleType.ch4;
          symbol = 'CH4';
        } else if (eh < 100 && layer.nitrousOxideContent > 0.1) {
          bType = BubbleType.n2o;
          symbol = 'N2O';
        }

        // MASS CONSERVATION: Subtract from state
        final amount = 0.5; // Bubble represents 0.5 mg/kg gas pulse
        final success = game.ref.read(simulationProvider.notifier).consumeGas(layer.id, symbol, amount);
        
        if (success) {
          game.world.add(
            BubbleComponent(
              position: Vector2(x, y),
              type: bType,
              seed: _random.nextInt(100),
              speed: 20.0 + _random.nextDouble() * 15.0,
            )..priority = 120,
          );
        }
      }
    }
  }

  void _syncMolecularParticles() {
    final state = game.simulationState;
    if (state == null || state.plants.isEmpty) return;

    final worldWidth = SoilScopeGame.soilColumnWidth;
    final surfaceY = game.soilSurfaceY;
    final soilHeight = game.soilColumnHeight;

    final List<List<double>> hotspotData = [];
    for (final plant in state.plants) {
      for (final tip in plant.rootSystem.where((n) => n.isTip)) {
        hotspotData.add([
          SceneCoordinateMapper.mapRootX(tip.x, worldWidth, baseX: plant.baseX) + game.soilLeftX,
          SceneCoordinateMapper.mapRootY(tip.z, surfaceY, soilHeight),
          2.0, 
        ]);
      }
    }

    final rect = game.camera.visibleWorldRect;
    game.ref.read(simulationProvider.notifier).particleIsolate.updateEnvironment(
      state.profile.layers.first.temperature,
      hotspotData,
      isAnaerobic: state.profile.layers.first.redoxPotential < 100,
      waterFlux: state.profile.layers.first.verticalFlux,
      cnRatio: state.profile.layers.first.cnRatio,
      visibleRect: [rect.left, rect.top, rect.right, rect.bottom],
      windDrift: 10.0, // Constant light wind
      windNoise: 15.0 + state.precipitation * 20.0, // Weather-affected engine data
    );

    final topLayers = state.profile.layers.take(2).toList();
    final plant = state.plants.first;
    final centerX = SceneCoordinateMapper.mapShootPosition(plant.baseX, worldWidth, surfaceY).x + game.soilLeftX;

    for (int l = 0; l < topLayers.length; l++) {
      final layer = topLayers[l];
      final depthFactor = 1.0 / (l + 1.0);

      // FURTHER REDUCED: Balanced visual counts to keep animation calm and diverse (max ~4 per type per layer)
      final counts = {
        ParticleType.nitrate: _toVisualCount(layer.nitrateContent, factor: 0.04 * depthFactor, max: 4),
        ParticleType.ammonium: _toVisualCount(layer.ammoniumContent, factor: 0.04 * depthFactor, max: 4),
        ParticleType.organicNitrogen: _toVisualCount(layer.organicNitrogen, factor: 0.04 * depthFactor, max: 3),
        ParticleType.labileCarbon: _toVisualCount(layer.labileCarbon, factor: 0.03 * depthFactor, max: 3),
        ParticleType.water: _toVisualCount(layer.waterContent * 20.0, factor: 0.01 * depthFactor, max: 3),
      };

      final isolate = game.ref.read(simulationProvider.notifier).particleIsolate;
      counts.forEach((type, count) {
        final current = isolate.getParticleCount(type.index);
        if (count > current / topLayers.length) {
          final toAdd = (count - (current / topLayers.length)).round();
          if (toAdd > 0) {
            final List<Particle> newOnes = [];
            for (int i = 0; i < toAdd; i++) {
              // RHIZOSPHERE FOCUS: Use Gaussian distribution centered on plant X
              double px = _nextGaussian(centerX, 200.0).clamp(game.soilLeftX + 20, game.soilLeftX + worldWidth - 20);
              double py = surfaceY + (layer.depth / 1.0) * soilHeight + _random.nextDouble() * ((layer.thickness / 1.0) * soilHeight);
              
              newOnes.add(Particle(
                id: _random.nextInt(1000000),
                x: px,
                y: py,
                vx: (_random.nextDouble() - 0.5) * 20, 
                vy: (_random.nextDouble() - 0.5) * 20,
                type: type,
                life: 1.0,
                isImmobilized: false,
              ));
            }
            isolate.addParticles(newOnes);
          }
        } else if (count < current / topLayers.length) {
          isolate.removeParticles((current / topLayers.length - count).round(), type.index);
        }
      });
    }
  }

  /// Box-Muller transform for Gaussian distribution
  double _nextGaussian(double mean, double stdDev) {
    final u1 = _random.nextDouble();
    final u2 = _random.nextDouble();
    final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return z0 * stdDev + mean;
  }

  int _toVisualCount(double source, {double factor = 1.0, int min = 0, int max = 100}) {
    return (source * factor).round().clamp(min, max);
  }
}
