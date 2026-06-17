import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_provider.dart';
import 'biological_entity_mixin.dart';
import 'visual_time_mixin.dart';
import 'cycle_highlight_mixin.dart';
import 'animated_plant_component.dart';
import 'molecule_renderer.dart';


/// Optimized Molecular Particle component with reduced pixel footprint.
/// Represents a cluster of molecules (edustusmalli).
class MoleculeParticleComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, BiologicalEntityMixin, VisualTimeMixin, CycleHighlightMixin, CollisionCallbacks {
  
  @override
  Set<ObservationCycle> get memberOfCycles {
    switch (type) {
      case MoleculeType.ammonium:
      case MoleculeType.nitrate:
      case MoleculeType.organicNitrogen:
      case MoleculeType.nitrousOxide:
        return {ObservationCycle.nitrogen};
      case MoleculeType.labileCarbon:
      case MoleculeType.stableCarbon:
      case MoleculeType.co2:
      case MoleculeType.methane:
      case MoleculeType.carbon:
        return {ObservationCycle.carbon};
      case MoleculeType.water:
      case MoleculeType.waterVapor:
        return {ObservationCycle.water};
      case MoleculeType.phosphate:
        return {ObservationCycle.phosphorus};
      case MoleculeType.potassium:
      case MoleculeType.calcium:
      case MoleculeType.magnesium:
        return {};
      case MoleculeType.oxygen:
        return {};
    }
  }
  MoleculeType type;
  MoleculeType? transformTarget; 
  int seed;
  final Vector2 velocity;
  Vector2? targetPosition; 
  List<Vector2>? path;
  int _pathIndex = 0;
  double lifeTime;
  double opacity;
  bool isInteractionEnabled;

  double _time = 0;
  bool _isAbsorbed = false;
  double _selectionPulse = 0.0;
  double _transformProgress = 0.0;

  MoleculeParticleComponent({
    required Vector2 position,
    required this.type,
    this.transformTarget,
    this.targetPosition,
    this.path,
    this.seed = 0,
    Vector2? velocity,
    this.lifeTime = 8.0,
    this.opacity = 1.0,
    this.isInteractionEnabled = true,
  }) : velocity = velocity ?? Vector2(0, 40),
       super(position: position, size: Vector2.all(6), anchor: Anchor.center, priority: 60) {
    _time = seed.toDouble();
    add(CircleHitbox(radius: 4.0, collisionType: CollisionType.active));
  }

  /// Resets the component state for pooling.
  void reset({
    required Vector2 position,
    required MoleculeType type,
    MoleculeType? transformTarget,
    Vector2? targetPosition,
    List<Vector2>? path,
    int? seed,
    Vector2? velocity,
    double? lifeTime,
    double? opacity,
    bool? isInteractionEnabled,
  }) {
    this.position.setFrom(position);
    this.type = type;
    this.transformTarget = transformTarget;
    this.targetPosition = targetPosition;
    this.path = path;
    _pathIndex = 0;
    this.seed = seed ?? math.Random().nextInt(1000);
    this.velocity.setFrom(velocity ?? Vector2(0, 40));
    this.lifeTime = lifeTime ?? 8.0;
    this.opacity = opacity ?? 1.0;
    this.isInteractionEnabled = isInteractionEnabled ?? true;
    
    _time = this.seed.toDouble();
    _isAbsorbed = false;
    _selectionPulse = 0.0;

    // Refresh hitbox
    children.query<CircleHitbox>().firstOrNull?.collisionType = CollisionType.active;
  }

  @override
  String get entityTitle => MoleculeRenderer.getMoleculeFormula(type);

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (isInteractionEnabled && other is AnimatedPlantComponent && !_isAbsorbed) {
      final plantId = other.plantId;
      final symbol = MoleculeRenderer.getMoleculeFormula(type).replaceAll(RegExp(r'[^a-zA-Z]'), '');
      game.ref.read(simulationProvider.notifier).absorbNutrient(plantId, symbol, 0.1);
      game.triggerPlantGrowth();
      _isAbsorbed = true;
      children.query<CircleHitbox>().firstOrNull?.collisionType = CollisionType.inactive;
      removeFromParent();
    }
  }

  Color get moleculeColor => MoleculeRenderer.getMoleculeColor(type);


  static final Vector2 _tmpVec = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    if (_selectionPulse > 0) _selectionPulse -= dt * 2.0;
    if (!(game.simulationState?.isRunning ?? false)) return;

    final flowMode = game.ref.read(particleFlowModeProvider);
    final boost = flowMode ? 2.5 : 1.0;
    final vdt = getPerceptualDt(dt) * boost;
    if (_isAbsorbed) {
      return; // Handled by removeFromParent immediately
    }

    _time += vdt;

    // Kinematics: Path Following or Seeking
    Vector2? currentTarget = targetPosition;
    if (path != null && _pathIndex < path!.length) {
      currentTarget = path![_pathIndex];
      // Organic "drift" around waypoints: Add a small deterministic jitter based on seed and time
      final driftX = math.sin(_time * 2.0 + seed) * 4.0;
      final driftY = math.cos(_time * 2.5 + seed) * 4.0;
      
      // If we are close to the current waypoint, advance
      if (position.distanceToSquared(currentTarget) < 400) { // 20px radius for smoother handoff
        _pathIndex++;
        if (_pathIndex < path!.length) {
          currentTarget = path![_pathIndex];
        } else {
          currentTarget = targetPosition; // Final target
        }
      }
      
      if (currentTarget != null) {
        currentTarget = currentTarget + Vector2(driftX, driftY);
      }
    }

    if (currentTarget != null) {
      _tmpVec.setFrom(currentTarget);
      _tmpVec.sub(position);
      if (_tmpVec.length > 0) {
        _tmpVec.normalize();
        // Slower lerp for more "drifting" feel (0.08 instead of 0.15)
        velocity.lerp(_tmpVec * (35.0 + math.sin(_time + seed) * 15.0), 0.08);
      }
    }

    // Visual Transformation Logic
    if (transformTarget != null) {
      _transformProgress += vdt * 2.0; // 0.5s transformation
      if (_transformProgress >= 1.0) {
        type = transformTarget!;
        transformTarget = null;
        _transformProgress = 0.0;
      }
    }

    // Atmospheric dynamics logic moved to ParticlePhysicsIsolateManager.

    // High speed = high activity (conveyed kinetically)
    position.add(velocity * vdt);

    // Bounding Box Clamping: Keep particles within visible world boundaries
    final visibleRect = game.camera.visibleWorldRect;
    
    // Remove if life ends or it's way outside the visible area
    if (_time - seed > lifeTime || 
        position.x < visibleRect.left - 50 || 
        position.x > visibleRect.right + 50 ||
        position.y < visibleRect.top - 50 ||
        position.y > visibleRect.bottom + 50) {
      removeFromParent();
    }

    // Absorption logic
    if (!_isAbsorbed && targetPosition != null && position.distanceTo(targetPosition!) < 10.0) {
      game.triggerPlantGrowth();
      _isAbsorbed = true;

      final state = game.simulationState;
      // If the particle represents a nutrient and the target is likely a root,
      // attribute the absorption to the plant. Wait, we should only attribute
      // it to the plant if the target is actually a plant root. We can use
      // the existing logic: if a target was specified, it was spawned by
      // _emitFluxParticle in SoilLayerComponent, which targets a hotspot,
      // or by _spawnNitrogenCycleFlow in BiochemicalDynamicsComponent, which
      // targets a hotspot. Actually, in BiochemicalDynamicsComponent,
      // _spawnWaterCycleFlows targets foliage, and _spawnNitrogenCycleFlow
      // targets root tips. So if it targets a root tip, attribute it.
      // But we can just use the first plant ID for now as done previously.
      if (state != null && state.plants.isNotEmpty) {
        // Find if target is close to any root
        bool targetIsRoot = false;
        String? targetPlantId;
        for (final plant in state.plants) {
           for (final pos in game.rootTipWorldPositions) {
             if (pos.distanceToSquared(targetPosition!) < 400) { // 20px radius
               targetIsRoot = true;
               targetPlantId = plant.id;
               break;
             }
           }
           if (targetIsRoot) break;
        }

        if (targetIsRoot && targetPlantId != null) {
           final symbol = MoleculeRenderer.getMoleculeFormula(type).replaceAll(RegExp(r'[^a-zA-Z]'), '');
           game.ref.read(simulationProvider.notifier).absorbNutrient(targetPlantId, symbol, 0.1);
        } else {
           // If it's not a root, it might be a soil hotspot.
           // Since we can't easily attribute it to a plant, we just let it be destroyed.
           // This maintains mass conservation for the visual aspect (it doesn't become a zombie)
           // while not double-counting nutrients for plants.
           // The simulation state (Riverpod) already handles soil-level transformations
           // mathematically in solvers; visual particles are often just representations
           // of these underlying fluxes.
        }
      }

      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final zoom = game.camera.viewfinder.zoom;
    final double elapsed = _time - seed;
    double currentOpacity = opacity;
    
    // Smooth fade in/out
    if (elapsed < 1.0) {
      currentOpacity *= elapsed;
    } else if (elapsed > lifeTime - 1.0) {
      currentOpacity *= math.max(0.0, lifeTime - elapsed);
    }

    // High Contrast Dimming
    currentOpacity *= cycleOpacity;

    final center = Offset(size.x / 2, size.y / 2);

    // 1. CYCLE GLOW
    renderCycleGlow(canvas, center, 4.0);

    // 2. MOLECULAR RENDERING (Unified)
    MoleculeRenderer.drawMolecule(
      canvas,
      center,
      type,
      opacity: currentOpacity,
      isLocked: isPinned || isHovered,
      zoom: zoom,
      phase: _time * 2.0,
      morphProgress: transformTarget != null ? _transformProgress : 0.0,
    );
  }

  @override
  void onHoverEnter() => handleHoverEnter(() => _showMoleculeInfo(pinned: false));

  @override
  void onHoverExit() => handleHoverExit();

  @override
  void onTapUp(TapUpEvent event) {
    _selectionPulse = 1.0;
    handleTapUp(({bool pinned = true}) => _showMoleculeInfo(pinned: pinned));
    event.handled = true;
  }

  void _showMoleculeInfo({bool pinned = false}) {
    final info = _getMoleculeInfo();
    
    // Determine the dominant element symbol for CPK coloring
    String? symbol;
    switch (type) {
      case MoleculeType.ammonium || MoleculeType.nitrate || MoleculeType.organicNitrogen || MoleculeType.nitrousOxide:
        symbol = 'N';
        break;
      case MoleculeType.carbon || MoleculeType.labileCarbon || MoleculeType.stableCarbon || MoleculeType.methane || MoleculeType.co2:
        symbol = 'C';
        break;
      case MoleculeType.oxygen || MoleculeType.water || MoleculeType.waterVapor:
        symbol = 'O';
        break;
      case MoleculeType.phosphate: symbol = 'P'; break;
      case MoleculeType.potassium: symbol = 'K'; break;
      case MoleculeType.calcium: symbol = 'Ca'; break;
      case MoleculeType.magnesium: symbol = 'Mg'; break;
    }

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: info['title'] as String,
            description: info['description'] as String,
            stats: info['stats'] as Map<String, String>,
            formula: MoleculeRenderer.getMoleculeFormula(type),
            isPinned: pinned,
            legends: info['legends'] as List<LegendItem>?,
            accentColor: MoleculeRenderer.getMoleculeColor(type),
            elementSymbol: symbol,
            screenPosition: game.worldToScreen(absolutePosition).toOffset(),
          ),
        );
  }

  Map<String, dynamic> _getMoleculeInfo() {
    final l = game.l10n;
    switch (type) {
      case MoleculeType.ammonium:
        return {
          'title': l.moleculeAmmoniumTitle,
          'description': l.moleculeAmmoniumDesc,
          'stats': {
            l.ionLabel: 'NH₄⁺',
            l.charge: '+1 (Kationi)',
            l.mobility: l.veryWeak,
            l.source: l.mineralizationTitle,
          },
        };
      case MoleculeType.nitrate:
        return {
          'title': l.moleculeNitrateTitle,
          'description': l.moleculeNitrateDesc,
          'stats': {
            l.ionLabel: 'NO₃⁻',
            l.charge: '-1 (Anioni)',
            l.mobility: l.veryHigh,
            l.risk: '${l.leachingTitle} / N₂O',
          },
        };
      case MoleculeType.labileCarbon:
      case MoleculeType.carbon:
        return {
          'title': l.moleculeCarbonLabileTitle,
          'description': l.moleculeCarbonLabileDesc,
          'stats': {
            l.type: 'POM',
            l.role: l.microbialEnergySource,
            l.significance: l.mineralizationTitle,
          },
        };
      case MoleculeType.stableCarbon:
        return {
          'title': l.moleculeCarbonStableTitle,
          'description': l.moleculeCarbonStableDesc,
          'stats': {
            l.type: 'Humus / MAOM',
            l.significance: l.longTerm,
            l.role: l.carbonSink,
          },
        };
      case MoleculeType.water:
        return {
          'title': l.moleculeWaterTitle,
          'description': l.moleculeWaterDesc,
          'stats': {
            l.symbolLabel: 'H₂O',
            l.role: l.transport,
            l.significance: l.soilMoisture,
          },
        };
      case MoleculeType.oxygen:
        return {
          'title': l.moleculeOxygenTitle,
          'description': l.moleculeOxygenDesc,
          'stats': {
            l.symbolLabel: 'O₂',
            l.stateLabel: l.aerobicState,
            l.role: 'TEA',
          },
        };
      case MoleculeType.co2:
        return {
          'title': l.moleculeCO2Title,
          'description': l.moleculeCO2Desc,
          'stats': {
            l.symbolLabel: 'CO₂',
            l.source: l.microbialRespiration,
            l.climateEffect: l.greenhouseGasEmissions,
          },
        };
      case MoleculeType.organicNitrogen:
        return {
          'title': l.moleculeOrganicNitrogenTitle,
          'description': l.moleculeOrganicNitrogenDesc,
          'stats': {
            l.type: 'DON / Proteins',
            l.source: 'Necromass',
            l.significance: l.mineralizationTitle,
          },
        };
      case MoleculeType.methane:
        return {
          'title': l.moleculeMethaneTitle,
          'description': l.moleculeMethaneDesc,
          'stats': {
            l.type: 'Gas',
            l.source: l.methanogenesis,
            l.climateEffect: '${l.effectLabel}: 28x CO2',
          },
        };
      case MoleculeType.nitrousOxide:
        return {
          'title': l.moleculeNitrousOxideTitle,
          'description': l.moleculeNitrousOxideDesc,
          'stats': {
            l.type: 'Gas',
            l.source: l.denitrifiers,
            l.climateEffect: '${l.effectLabel}: 298x CO2',
          },
        };
      case MoleculeType.phosphate:
        return {
          'title': l.ionPhosphateTitle,
          'description': l.ionPhosphateDescription,
          'stats': {
            l.ionLabel: 'PO₄³⁻',
            l.charge: '-3 (Anioni)',
            l.mobility: l.veryWeak,
            l.role: l.energy,
          },
        };
      case MoleculeType.potassium:
        return {
          'title': l.ionPotassiumTitle,
          'description': l.ionPotassiumDescription,
          'stats': {
            l.ionLabel: 'K⁺',
            l.charge: '+1 (Kationi)',
            l.mobility: l.mobilityModerate,
            l.role: l.stomataRegulation,
          },
        };
      case MoleculeType.calcium:
        return {
          'title': l.ionCalciumTitle,
          'description': l.ionCalciumDescription,
          'stats': {
            l.ionLabel: 'Ca²⁺',
            l.charge: '+2 (Kationi)',
            l.mobility: l.mobilitySlow,
            l.role: l.cellWallSignal,
          },
        };
      case MoleculeType.magnesium:
        return {
          'title': l.ionMagnesiumTitle,
          'description': l.ionMagnesiumDescription,
          'stats': {
            l.ionLabel: 'Mg²⁺',
            l.charge: '+2 (Kationi)',
            l.mobility: l.mobilityGood,
            l.role: l.photosynthesis,
          },
        };
      case MoleculeType.waterVapor:
        return {
          'title': l.moleculeWaterVaporTitle,
          'description': l.moleculeWaterVaporDesc,
          'stats': {
            l.type: l.gasLabel,
            l.source: l.transpirationLabel,
          },
        };
    }
  }
}
