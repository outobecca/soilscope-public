import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../core/biophysics_utils.dart';
import '../../../providers/ui_state_provider.dart';
import 'scene_coordinate_mapper.dart';
import '../../../providers/simulation_provider.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../../domain/solvers/particle_physics_solver.dart';
import 'animated_plant_component.dart';
import 'data_hotspot_component.dart';
import 'soil_layer_component.dart';
import 'particle_system_component.dart';
import 'biological_entity_mixin.dart';
import 'visual_time_mixin.dart';
import 'cycle_highlight_mixin.dart';
import 'molecule_particle_component.dart';

/// Optimized Microbial Cluster component representing a dense colony of organisms.
/// Decouples visual representation from mathematical simulation units (1:500 ratio).
/// High performance, low-pixel footprint representation.
class AnimatedMicrobeComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, BiologicalEntityMixin, VisualTimeMixin, CycleHighlightMixin {
  
  @override
  Set<ObservationCycle> get memberOfCycles => {ObservationCycle.nitrogen, ObservationCycle.carbon};
  final int seed;

  @override
  String get entityTitle => game.l10n.microbialCell;

  double _time = 0;
  double _activationBoost = 0.0; 
  int? _anchorIndex;
  final Vector2 _velocity = Vector2.zero();
  double _retargetTimer = 0.0;
  Vector2? _chemotacticTarget;
  final math.Random _random = math.Random();

  // Visual Immobilization State
  final List<Color> _absorbedNutrients = [];
  double _pulseScale = 1.0;
  static const int _maxAbsorbed = 12;

  static final Vector2 _tmpVec = Vector2.zero();
  static final Vector2 _tmpVec2 = Vector2.zero();

  // Performance Guard: Max clusters per world
  static const int maxClusters = 50;

  final Paint _coreGlowPaint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
  final Paint _coreShadowPaint = Paint();
  final Paint _coreBodyPaint = Paint();
  final Paint _coreHighlightPaint = Paint();
  final Paint _swarmPaint = Paint()..style = PaintingStyle.fill;
  final Paint _nutrientPaint = Paint();
  final Paint _nutrientHighlightPaint = Paint();

  AnimatedMicrobeComponent({required Vector2 position, this.seed = 0})
    : super(position: position, size: Vector2.all(120), anchor: Anchor.center, priority: 80) {
    _time = seed.toDouble();
    _anchorIndex = seed;
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    // Selection radius matches the visual swarm radius
    final center = size / 2;
    return point.distanceTo(center) < 40.0; 
  }

  @override
  void update(double dt) {
    super.update(dt);

    final state = game.simulationState;
    if (state == null || !state.isRunning || state.profile.layers.isEmpty) return;

    final vdt = getPerceptualDt(dt);
    if (_activationBoost > 0) {
      _activationBoost = (_activationBoost - vdt * 0.4).clamp(0.0, 1.0);
    }

    final layer = state.profile.layers.first;
    final activityFactor = BiophysicsUtils.q10Factor(layer.temperature).clamp(0.1, 4.0);
    final totalActivity = activityFactor * (1.0 + _activationBoost * 2.5);
    _time += vdt * totalActivity;

    _decideMovementTarget(vdt);
    _handleImmobilizationAnchoring(vdt);

    if (state.plants.isNotEmpty) {
      _retargetTimer -= vdt;

      Vector2 targetPos;
      bool isFeeding = false;

      if (_chemotacticTarget != null) {
        targetPos = _chemotacticTarget!;
        if (position.distanceTo(targetPos) < 20) {
          isFeeding = true;
          _activationBoost = (_activationBoost + vdt * 1.5).clamp(0.0, 1.0);
          
          // MASS CONSERVATION: Visual feeding updates biophysical state
          if (_random.nextDouble() < 0.05 * vdt * 10) {
            final layerId = _getCurrentLayerId(state);
            if (layerId != null) {
              game.ref.read(simulationProvider.notifier).consumeResource(layerId, 'labileCarbon', 0.005);
            }
          }
        }
      } else {
        // Default wandering around roots if no high-fitness hotspot is found
        final plant = state.plants[seed % state.plants.length];
        if (_anchorIndex == null || _anchorIndex! >= plant.rootSystem.length || _retargetTimer <= 0) {
          _anchorIndex = _random.nextInt(plant.rootSystem.length);
          _retargetTimer = 4.0 + _random.nextDouble() * 6.0;
        }

        final node = plant.rootSystem[_anchorIndex!];
        final anchorX = SceneCoordinateMapper.mapRootX(node.x, SoilScopeGame.soilColumnWidth, baseX: plant.baseX) + game.soilLeftX;
        final anchorY = SceneCoordinateMapper.mapRootY(node.z, game.soilSurfaceY, game.soilColumnHeight);
        _tmpVec.setValues(anchorX, anchorY);
        targetPos = _tmpVec;

        if (position.distanceTo(targetPos) < 30) {
          isFeeding = true;
          _activationBoost = (_activationBoost + vdt * 0.5).clamp(0.0, 1.0);
          
          // Roots provide energy -> consume exudates (labile carbon)
          if (_random.nextDouble() < 0.02 * vdt * 10) {
            final layerId = _getCurrentLayerId(state);
            if (layerId != null) {
              game.ref.read(simulationProvider.notifier).consumeResource(layerId, 'labileCarbon', 0.002);
            }
          }
        }
      }

      final orbitRadius = (isFeeding ? 6.0 : 30.0) + (seed % 4) * 6;
      final orbitSpeed = isFeeding ? 0.08 : 0.4;
      final orbitAngle = _time * orbitSpeed + seed;
      
      _tmpVec2.setValues(math.cos(orbitAngle) * orbitRadius, math.sin(orbitAngle) * orbitRadius * 0.6);
      final orbitOffset = _tmpVec2;
      final desiredPos = targetPos + orbitOffset;
      
      _tmpVec2.setFrom(desiredPos);
      _tmpVec2.sub(position);
      final targetVelocity = _tmpVec2..scale(isFeeding ? 0.5 : 1.0);
      _applyMicrobeRepulsion(vdt);

      _velocity.lerp(targetVelocity, vdt * 2.5);
      
      final maxSpeed = (isFeeding ? 18.0 : 55.0) * (1.0 + activityFactor * 0.2);
      if (_velocity.length > maxSpeed) _velocity.scaleTo(maxSpeed);

      position.add(_velocity * vdt);
      
      final soilX = game.soilLeftX;
      final soilWidth = SoilScopeGame.soilColumnWidth;
      position.x = position.x.clamp(soilX + 15, soilX + soilWidth - 15);
      position.y = position.y.clamp(game.soilSurfaceY + 15, game.soilSurfaceY + game.soilColumnHeight - 15);
    }

    // Recover pulse
    if (_pulseScale > 1.0) {
      _pulseScale = math.max(1.0, _pulseScale - vdt * 2.0);
    }

    _checkForMolecularTransformations(vdt);
  }

  /// Detects nearby molecule particles and triggers biochemical transformations (e.g. Nitrification)
  void _checkForMolecularTransformations(double vdt) {
    if (_random.nextDouble() > 0.1 * vdt) return; // Optimization: check only occasionally

    final molecules = game.world.children.whereType<MoleculeParticleComponent>();
    for (final mol in molecules) {
      if (mol.transformTarget != null) continue; // Already transforming

      final dist = position.distanceTo(mol.position);
      if (dist < 40.0) {
        // MICROBIAL BIOCHEMISTRY: Determine transformation based on type
        MoleculeType? target;
        if (mol.type == MoleculeType.ammonium) {
          target = MoleculeType.nitrate; // Nitrification
        } else if (mol.type == MoleculeType.labileCarbon) {
          target = MoleculeType.co2; // Respiration
        } else if (mol.type == MoleculeType.organicNitrogen) {
          target = MoleculeType.ammonium; // Mineralization
        }

        if (target != null && _random.nextDouble() < 0.3) {
          mol.transformTarget = target;
          _pulseScale = 1.3; // Microbe pulses when active
          _activationBoost = (_activationBoost + 0.2).clamp(0.0, 1.0);
          break; // One transformation per microbe per check
        }
      }
    }
  }

  /// Pulls nearby immobilized particles towards the microbe center and "absorbs" them.
  void _handleImmobilizationAnchoring(double vdt) {
    final particleField = game.world.children.whereType<MolecularParticleFieldComponent>().firstOrNull;
    if (particleField == null) return;

    final Float32List data = particleField.particleData;
    if (data.isEmpty) return;

    final center = position;
    const double sensingRadius = 80.0;
    const double captureRadius = 6.0;
    const double pullStrength = 120.0;

    for (int i = 0; i < data.length; i += 7) {
      final pState = data[i + 6];
      if (pState >= 0) continue; // Not immobilized

      final px = data[i + 1];
      final py = data[i + 2];
      final pPos = Vector2(px, py);
      final dist = center.distanceTo(pPos);

      if (dist < sensingRadius) {
        if (dist < captureRadius) {
          // CAPTURE ANIMATION
          final pTypeIdx = data[i + 5].toInt();
          final type = ParticleType.values[pTypeIdx];
          
          // Add to visual cluster
          _absorbedNutrients.add(_getColorForParticleType(type));
          if (_absorbedNutrients.length > _maxAbsorbed) {
            _absorbedNutrients.removeAt(0);
          }
          
          _pulseScale = 1.25; // Trigger pulse
          _activationBoost = (_activationBoost + 0.1).clamp(0.0, 1.0);

          // "Hide" the particle visually by moving it out of view or setting state to 0
          data[i + 6] = 0; 
        } else {
          // DYNAMIC ABSORPTION: Lerp velocity towards center
          final toCenter = (center - pPos).normalized();
          
          // Update velocity in the shared buffer so MPFC.update moves it
          data[i + 3] = toCenter.x * pullStrength;
          data[i + 4] = toCenter.y * pullStrength;
          
          // Slight position nudge to overcome physics isolate overrides
          data[i + 1] += toCenter.x * pullStrength * 0.2 * vdt;
          data[i + 2] += toCenter.y * pullStrength * 0.2 * vdt;
        }
      }
    }
  }

  Color _getColorForParticleType(ParticleType type) {
    switch (type) {
      case ParticleType.ammonium:
      case ParticleType.nitrate:
      case ParticleType.organicNitrogen:
        return CPKStandards.colorN;
      case ParticleType.labileCarbon:
      case ParticleType.carbon:
        return CPKStandards.colorC;
      case ParticleType.stableCarbon:
        return CPKStandards.colorStableCarbon;
      case ParticleType.water:
        return Colors.blueAccent;
      case ParticleType.phosphorus:
      case ParticleType.organicPhosphorus:
        return CPKStandards.colorP;
    }
  }

  String? _getCurrentLayerId(BiophysicalState state) {
    final relY = (position.y - game.soilSurfaceY) / game.soilColumnHeight;
    final depth = relY * 1.0; // Assume 1m soil depth for mapping
    for (final layer in state.profile.layers) {
      if (depth >= layer.depth && depth <= layer.depth + layer.thickness) {
        return layer.id;
      }
    }
    return state.profile.layers.firstOrNull?.id;
  }

  void _decideMovementTarget(double dt) {
    if (_retargetTimer > 0.5 && _chemotacticTarget != null) return;

    final state = game.simulationState;
    if (state == null) return;

    final double cnRatio = state.profile.layers.first.cnRatio;
    final bool isNitrogenLimited = cnRatio > 24.0; // Microbes seek N if ratio is high

    double maxFitness = -1.0;
    Vector2? bestTarget;

    // 1. Evaluate Hotspots (Opportunistic centers)
    final hotspots = game.world.children.whereType<SoilLayerComponent>()
        .expand((l) => l.children.whereType<DataHotspotComponent>())
        .toList();

    for (final h in hotspots) {
      final dist = position.distanceTo(h.position);
      if (dist > 400) continue; // Out of sensing range

      // Base benefit from content
      double benefit = 1.0;
      if (h.type == HotspotType.nutrient) {
        benefit = 2.0;
        // Priority bonus for Nitrogen if soil is C-rich (Nitrogen limitation)
        if (isNitrogenLimited && (h.label.contains('N') || h.label.contains('NH') || h.label.contains('NO'))) {
          benefit *= 2.5; 
        }
      } else if (h.label == 'T' || h.label == 'W') {
        benefit = 1.5; // Seek optimal temperature/water
      }

      final fitness = benefit / (dist / 100.0).clamp(1.0, 10.0);
      if (fitness > maxFitness) {
        maxFitness = fitness;
        bestTarget = h.position;
      }
    }

    // 2. Evaluate Root Exudates (Consistent energy source)
    final plantComps = game.world.children.query<AnimatedPlantComponent>();
    for (final plant in plantComps) {
      for (final pos in plant.exudateWorldPositions) {
        final dist = position.distanceTo(pos);
        if (dist > 300) continue;

        // Roots provide labile carbon (high energy, low nitrogen)
        double rootBenefit = 2.5; 
        if (isNitrogenLimited) rootBenefit *= 0.6; // Less attractive if N is needed

        final fitness = rootBenefit / (dist / 80.0).clamp(1.0, 10.0);
        if (fitness > maxFitness) {
          maxFitness = fitness;
          bestTarget = pos;
        }
      }
    }

    if (bestTarget != null && maxFitness > 0.5) {
      _chemotacticTarget = bestTarget;
    } else {
      _chemotacticTarget = null;
    }
  }

  void _applyMicrobeRepulsion(double dt) {
    final others = parent?.children.whereType<AnimatedMicrobeComponent>() ?? [];
    for (final other in others) {
      if (other == this) continue;
      final dist = position.distanceTo(other.position);
      if (dist < 30) {
        _tmpVec.setFrom(position);
        _tmpVec.sub(other.position);
        _tmpVec.normalize();
        _tmpVec.scale((30 - dist) * 1.5);
        _velocity.add(_tmpVec * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final state = game.simulationState;
    if (state == null) return;

    final zoom = game.camera.viewfinder.zoom;
    final zoomLOD = (zoom - 0.3).clamp(0.0, 1.0);
    if (zoomLOD <= 0) return;

    final layer = state.profile.layers.first;
    
    // Clustering: The cluster represents a dense biomass zone
    final biomassIntensity = (layer.microbialBiomass / 0.5).clamp(0.5, 3.0);
    final center = Offset(size.x / 2, size.y / 2);
    final baseColor = Color.lerp(CPKStandards.colorMicrobeZone, Colors.white, _activationBoost * 0.3)!;

    // CRITICAL: Removed massive yellow circles/rays and cycle glows (Task 1/2)
    final currentOpacity = zoomLOD * cycleOpacity;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(_pulseScale);
    canvas.translate(-center.dx, -center.dy);

    // 1. Central Core (Hotspot requirement)
    final coreRadius = 4.0;
    // Glow
    canvas.drawCircle(
      center, 
      coreRadius * 2.5, 
      (_coreGlowPaint..color = baseColor.withValues(alpha: 0.15 * currentOpacity))
    );
    // Shadow
    canvas.drawCircle(
      center + const Offset(0.5, 0.5),
      coreRadius,
      (_coreShadowPaint..color = Colors.black.withValues(alpha: 0.3 * currentOpacity))
    );
    // Core body
    canvas.drawCircle(
      center, 
      coreRadius, 
      (_coreBodyPaint..color = baseColor.withValues(alpha: 0.9 * currentOpacity))
    );
    // Shading highlight
    canvas.drawCircle(
      center - const Offset(1.0, 1.0),
      coreRadius * 0.4,
      (_coreHighlightPaint..color = Colors.white.withValues(alpha: 0.5 * currentOpacity))
    );

    // 2. Swarm Effect: Multiple tiny dots representing individuals
    final dotCount = (6 * biomassIntensity).toInt().clamp(3, 12);
    final dotRadius = 1.0 / zoom;
    
    final swarmPaint = _swarmPaint..color = baseColor.withValues(alpha: 0.5 * currentOpacity);

    for (int i = 0; i < dotCount; i++) {
      final angle = (_time * 1.5) + (i * math.pi * 2 / dotCount) + (seed * i);
      final dist = (10.0 + 4.0 * math.sin(_time * 0.5 + i)) * biomassIntensity;
      final dotCenter = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist * 0.8);
      canvas.drawCircle(dotCenter, dotRadius, swarmPaint);
    }

    // 3. Captured Nutrients (Immobilized resources)
    for (int i = 0; i < _absorbedNutrients.length; i++) {
      final color = _absorbedNutrients[i];
      final angle = (i * math.pi * 2 / _maxAbsorbed) + _time * 0.5;
      final dist = 14.0 * biomassIntensity;
      final nutrientPos = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);
      
      // Shaded nutrient dot
      canvas.drawCircle(
        nutrientPos, 
        1.5 / zoom, 
        (_nutrientPaint..color = color.withValues(alpha: 0.8 * currentOpacity))
      );
      canvas.drawCircle(
        nutrientPos - const Offset(0.3, 0.3),
        0.5 / zoom,
        (_nutrientHighlightPaint..color = Colors.white.withValues(alpha: 0.5 * currentOpacity))
      );
    }

    canvas.restore();
  }

  void _showMicrobeInfo({bool pinned = false}) {
    final state = game.simulationState;
    if (state == null || state.profile.layers.isEmpty) return;
    final layer = state.profile.layers.first;
    game.ref.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: "MICROBIAL CLUSTER",
        description: "Represents a high-density colony of soil microbes performing biochemical decomposition.",
        stats: {
          'Simulated Units': '500+',
          'Metabolic Activity': '${(BiophysicsUtils.q10Factor(layer.temperature) * 100).toStringAsFixed(0)}%',
          'Biomass Density': '${layer.microbialBiomass.toStringAsFixed(2)} kg/m³',
          'Immobilized Nutrients': '${_absorbedNutrients.length} units',
        },
        isPinned: pinned,
      ),
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    handleTapUp(({bool pinned = false}) => _showMicrobeInfo(pinned: pinned));
    event.handled = true;
  }

  @override
  void onHoverEnter() => handleHoverEnter(() => _showMicrobeInfo(pinned: false));

  @override
  void onHoverExit() => handleHoverExit();
}
