import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../core/biophysics_utils.dart';
import '../../../../core/nitrogen_forms.dart';
import '../../../../core/model_config.dart';
import '../../../providers/ui_state_provider.dart';
import 'scene_coordinate_mapper.dart';
import 'microbe_motility.dart';
import '../../../providers/simulation_provider.dart';
import '../../../../domain/models/biophysical_state.dart';
import '../../../../domain/solvers/particle_physics_solver.dart';
import 'data_hotspot_component.dart';
import 'soil_layer_component.dart';
import 'particle_system_component.dart';
import 'biological_entity_mixin.dart';
import 'visual_time_mixin.dart';
import 'visual_seed.dart';
import 'canvas_hit_testing.dart';
import 'cycle_highlight_mixin.dart';
import 'molecule_particle_component.dart';
import 'molecule_renderer.dart';

/// Optimized Microbial Cluster component representing a dense colony of organisms.
/// Decouples visual representation from mathematical simulation units (1:500 ratio).
/// High performance, low-pixel footprint representation.
class AnimatedMicrobeComponent extends PositionComponent
    with
        HasGameReference<SoilScopeGame>,
        TapCallbacks,
        HoverCallbacks,
        BiologicalEntityMixin,
        VisualTimeMixin,
        CycleHighlightMixin {
  @override
  Set<ObservationCycle> get memberOfCycles => {
    ObservationCycle.nitrogen,
    ObservationCycle.carbon,
  };
  final int seed;

  @override
  String get entityTitle => game.l10n.microbialCell;

  double _time = 0;
  double _activationBoost = 0.0;
  Vector2? _rootAnchor;
  final Vector2 _velocity = Vector2.zero();
  double _retargetTimer = 0.0;
  Vector2? _chemotacticTarget;
  late final math.Random _random = visualRandom(['microbe', seed]);

  // Visual Immobilization State
  final List<Color> _absorbedNutrients = [];
  double _pulseScale = 1.0;

  static final Vector2 _tmpVec = Vector2.zero();
  static final Vector2 _tmpVec2 = Vector2.zero();

  final Paint _coreGlowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
  final Paint _coreShadowPaint = Paint();
  final Paint _coreBodyPaint = Paint();
  final Paint _coreHighlightPaint = Paint();
  final Paint _swarmPaint = Paint()..style = PaintingStyle.fill;
  final Paint _nutrientPaint = Paint();
  final Paint _nutrientHighlightPaint = Paint();

  final String microbeId;

  AnimatedMicrobeComponent({
    required this.microbeId,
    required Vector2 position,
    this.seed = 0,
  }) : super(
         position: position,
         size: Vector2.all(120),
         anchor: Anchor.center,
         priority: 80,
       ) {
    _time = seed.toDouble();
  }

  double get _hitRadius => CanvasHitTesting.worldRadius(
    zoom: game.camera.viewfinder.zoom,
    screenRadius: 24,
    visualWorldRadius: 24,
    minWorld: 10,
    maxWorld: 40,
  );

  @override
  bool containsLocalPoint(Vector2 point) {
    final center = size / 2;
    return point.distanceTo(center) <= _hitRadius;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final state = game.simulationState;
    if (state == null || !state.isRunning || state.profile.layers.isEmpty) {
      return;
    }

    final vdt = getPerceptualDt(dt);
    if (_activationBoost > 0) {
      _activationBoost =
          (_activationBoost -
                  vdt * MicrobeMotility.activationDecayPerSecond)
              .clamp(0.0, 1.0);
    }

    final layer = state.profile.layers.first;
    final activityFactor = BiophysicsUtils.q10Factor(
      layer.temperature,
    ).clamp(0.1, 4.0);
    final totalActivity =
        activityFactor *
        (1.0 + _activationBoost * MicrobeMotility.activationSpeedBoost);
    _time += vdt * totalActivity;

    _retargetTimer -= vdt;
    if (_retargetTimer <= 0) {
      _refreshRootAnchor(state);
      _decideMovementTarget(state);
      _retargetTimer = MicrobeMotility.retargetDelay(_random);
    }
    _handleImmobilizationAnchoring(vdt);

    if (state.plants.isNotEmpty) {
      final rootAnchor = _rootAnchor;

      Vector2? targetPos;
      bool isFeeding = false;

      final chemotactic = _chemotacticTarget;
      if (chemotactic != null) {
        targetPos = chemotactic;
        if (position.distanceTo(chemotactic) <
            MicrobeMotility.feedingRadiusHotspot) {
          isFeeding = true;
          _activationBoost =
              (_activationBoost +
                      vdt * MicrobeMotility.activationGainHotspot)
                  .clamp(0.0, 1.0);

          // MASS CONSERVATION: Visual feeding updates biophysical state
          if (_random.nextDouble() <
              MicrobeMotility.feedingExudateRatePerSecond * vdt) {
            final layerId = _getCurrentLayerId(state);
            if (layerId != null) {
              game.ref
                  .read(simulationProvider.notifier)
                  .consumeResource(
                    layerId,
                    'labileCarbon',
                    ModelConfig.of('interaction.microbeExudateUptake'),
                  );
            }
          }
        }
      } else if (rootAnchor != null) {
        // Stay with a nearby root when no local hotspot is worth the trip.
        targetPos = rootAnchor;

        if (position.distanceTo(rootAnchor) <
            MicrobeMotility.feedingRadiusRoot) {
          isFeeding = true;
          _activationBoost =
              (_activationBoost + vdt * MicrobeMotility.activationGainRoot)
                  .clamp(0.0, 1.0);

          // Roots provide energy -> consume exudates (labile carbon)
          if (_random.nextDouble() <
              MicrobeMotility.feedingRootRatePerSecond * vdt) {
            final layerId = _getCurrentLayerId(state);
            if (layerId != null) {
              game.ref
                  .read(simulationProvider.notifier)
                  .consumeResource(
                    layerId,
                    'labileCarbon',
                    ModelConfig.of('interaction.microbeRootUptake'),
                  );
            }
          }
        }
      }

      if (targetPos != null) {
        final orbitRadius =
            (isFeeding
                ? MicrobeMotility.orbitFeedRadius
                : MicrobeMotility.orbitSeekRadius) +
            (seed % 4) * MicrobeMotility.orbitGrowthPerSeed;
        final orbitSpeed = isFeeding
            ? MicrobeMotility.orbitSpeedFeed
            : MicrobeMotility.orbitSpeedSeek;
        final orbitAngle = _time * orbitSpeed + seed;

        _tmpVec2.setValues(
          math.cos(orbitAngle) * orbitRadius,
          math.sin(orbitAngle) *
              orbitRadius *
              MicrobeMotility.orbitVerticalScale,
        );
        final desired = rootAnchor == null
            ? targetPos + _tmpVec2
            : MicrobeMotility.clampToRhizosphere(
                rootAnchor,
                targetPos + _tmpVec2,
              );

        _tmpVec2.setFrom(desired);
        _tmpVec2.sub(position);
        final targetVelocity = _tmpVec2
          ..scale(
            isFeeding
                ? MicrobeMotility.feedVelocityScale
                : MicrobeMotility.seekVelocityScale,
          );
        _applyMicrobeRepulsion(vdt);

        _velocity.lerp(targetVelocity, vdt * MicrobeMotility.velocityResponse);

        final maxSpeed = MicrobeMotility.speedLimit(
          feeding: isFeeding,
          activityFactor: activityFactor,
        );
        if (_velocity.length > maxSpeed) _velocity.scaleTo(maxSpeed);

        final moveMultiplier = (isHovered || isPinned)
            ? MicrobeMotility.hoverSpeedDamping
            : 1.0;
        position.add(_velocity * vdt * moveMultiplier);

        // Passive transport: a weak ride on the soil-water flux. Active
        // swimming dominates, but drainage still nudges the colony.
        position.y +=
            MicrobeMotility.passiveDrift(layer.verticalFlux) * vdt;

        if (rootAnchor != null &&
            position.distanceTo(rootAnchor) >
                MicrobeMotility.rhizosphereRadius) {
          position.setFrom(
            MicrobeMotility.clampToRhizosphere(rootAnchor, position),
          );
          _velocity.scale(MicrobeMotility.rhizosphereClampVelocityRetain);
        }
      }

      final soilX = game.soilLeftX;
      final soilWidth = SoilScopeGame.soilColumnWidth;
      final margin = MicrobeMotility.soilEdgeMargin;
      position.x = position.x.clamp(soilX + margin, soilX + soilWidth - margin);
      position.y = position.y.clamp(
        game.soilSurfaceY + margin,
        game.soilSurfaceY + game.soilColumnHeight - margin,
      );
    }

    // Recover pulse
    if (_pulseScale > 1.0) {
      _pulseScale = math.max(
        1.0,
        _pulseScale - vdt * MicrobeMotility.pulseDecayPerSecond,
      );
    }

    _checkForMolecularTransformations(vdt);
  }

  /// Detects nearby molecule particles and triggers biochemical transformations (e.g. Nitrification)
  void _checkForMolecularTransformations(double vdt) {
    if (_random.nextDouble() >
        MicrobeMotility.transformationCheckRate * vdt) {
      return; // Optimization: check only occasionally
    }

    final molecules =
        game.moleculePool?.activeParticles ??
        const <MoleculeParticleComponent>[];
    for (final mol in molecules) {
      if (mol.transformTarget != null) continue; // Already transforming

      final dist = position.distanceTo(mol.position);
      if (dist < MicrobeMotility.transformationRadius) {
        // MICROBIAL BIOCHEMISTRY: Determine transformation based on type
        MoleculeType? target;
        if (mol.type == MoleculeType.ammonium) {
          target = MoleculeType.nitrate; // Nitrification
        } else if (mol.type == MoleculeType.labileCarbon) {
          target = MoleculeType.co2; // Respiration
        } else if (mol.type == MoleculeType.organicNitrogen) {
          target = MoleculeType.ammonium; // Mineralization
        }

        if (target != null &&
            _random.nextDouble() < MicrobeMotility.transformationChance) {
          mol.transformTarget = target;
          _pulseScale =
              MicrobeMotility.transformationPulseScale; // Microbe pulses
          _activationBoost =
              (_activationBoost + MicrobeMotility.transformationBoost).clamp(
                0.0,
                1.0,
              );
          break; // One transformation per microbe per check
        }
      }
    }
  }

  /// Pulls nearby immobilized particles towards the microbe center and "absorbs" them.
  void _handleImmobilizationAnchoring(double vdt) {
    final particleField = game.world.children
        .whereType<MolecularParticleFieldComponent>()
        .firstOrNull;
    if (particleField == null) return;

    final Float32List data = particleField.particleData;
    if (data.isEmpty) return;

    final center = position;
    const sensingRadius = MicrobeMotility.immobilizationSensingRadius;
    const captureRadius = MicrobeMotility.immobilizationCaptureRadius;
    const pullStrength = MicrobeMotility.immobilizationPullStrength;

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
          if (_absorbedNutrients.length >
              MicrobeMotility.maxAbsorbedNutrients) {
            _absorbedNutrients.removeAt(0);
          }

          _pulseScale = MicrobeMotility.capturePulseScale; // Trigger pulse
          _activationBoost =
              (_activationBoost + MicrobeMotility.captureBoost).clamp(0.0, 1.0);

          // "Hide" the particle visually by moving it out of view or setting state to 0
          data[i + 6] = 0;
        } else {
          // DYNAMIC ABSORPTION: Lerp velocity towards center
          final toCenter = (center - pPos).normalized();

          // Update velocity in the shared buffer so MPFC.update moves it
          data[i + 3] = toCenter.x * pullStrength;
          data[i + 4] = toCenter.y * pullStrength;

          // Slight position nudge to overcome physics isolate overrides
          data[i + 1] +=
              toCenter.x *
              pullStrength *
              MicrobeMotility.immobilizationNudge *
              vdt;
          data[i + 2] +=
              toCenter.y *
              pullStrength *
              MicrobeMotility.immobilizationNudge *
              vdt;
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

  void _decideMovementTarget(BiophysicalState state) {
    final anchor = _rootAnchor;

    final double cnRatio = state.profile.layers.first.cnRatio;
    final bool isNitrogenLimited =
        cnRatio >
        MicrobeMotility
            .nitrogenLimitedCnRatio; // Microbes seek N if ratio is high

    double maxFitness = -1.0;
    Vector2? bestTarget;

    // 1. Evaluate local hotspots (opportunistic centres).
    final hotspots = game.world.children
        .whereType<SoilLayerComponent>()
        .expand((l) => l.children.whereType<DataHotspotComponent>())
        .toList();

    for (final h in hotspots) {
      final dist = position.distanceTo(h.position);
      if (dist > MicrobeMotility.sensingRadiusHotspot) continue;
      if (anchor != null &&
          h.position.distanceTo(anchor) >
              MicrobeMotility.rhizosphereRadius +
                  MicrobeMotility.rhizosphereSensingMargin) {
        continue;
      }

      // Base benefit from content
      double benefit = 1.0;
      if (h.type == HotspotType.nutrient) {
        benefit = MicrobeMotility.nutrientBenefit;
        // Priority bonus for Nitrogen if soil is C-rich (Nitrogen limitation)
        if (isNitrogenLimited &&
            (h.label.contains('N') ||
                h.label.contains('NH') ||
                h.label.contains('NO'))) {
          benefit *= MicrobeMotility.nitrogenBenefitMultiplier;
        }
      } else if (h.label == 'T' || h.label == 'W') {
        benefit =
            MicrobeMotility.climateBenefit; // Seek optimal temperature/water
      }

      final fitness =
          benefit /
          (dist / MicrobeMotility.hotspotDistanceScale).clamp(1.0, 10.0);
      if (fitness > maxFitness) {
        maxFitness = fitness;
        bestTarget = h.position;
      }
    }

    // 2. Evaluate nearby exudates (dynamic chemotaxis).
    final molecules =
        game.moleculePool?.activeParticles ??
        const <MoleculeParticleComponent>[];
    for (final mol in molecules) {
      if (mol.type != MoleculeType.labileCarbon) continue;

      final dist = position.distanceTo(mol.position);
      if (dist > MicrobeMotility.sensingRadiusExudate) continue;
            if (anchor != null &&
          mol.position.distanceTo(anchor) >
              MicrobeMotility.rhizosphereRadius +
                  MicrobeMotility.rhizosphereSensingMargin) {
        continue;
      }

      // Labile carbon is high energy
      double benefit = MicrobeMotility.exudateBenefit;
      if (isNitrogenLimited) {
        benefit *= MicrobeMotility.exudateNitrogenPenalty;
      }

      final fitness =
          benefit /
          (dist / MicrobeMotility.exudateDistanceScale).clamp(1.0, 10.0);
      if (fitness > maxFitness) {
        maxFitness = fitness;
        bestTarget = mol.position;
      }
    }

    if (bestTarget != null && maxFitness > MicrobeMotility.minimumFitness) {
      _chemotacticTarget = bestTarget;
    } else {
      _chemotacticTarget = null;
    }
  }

  /// Picks a stable root anchor from the nearest few root nodes.
  ///
  /// Seeding the choice keeps colonies spread along the local root system
  /// instead of all converging on one point.
  void _refreshRootAnchor(BiophysicalState state) {
    final roots = <Vector2>[];
    for (final plant in state.plants) {
      for (final node in plant.rootSystem) {
        roots.add(
          SceneCoordinateMapper.mapRootNodeWorld(
            node,
            SoilScopeGame.soilColumnWidth,
            game.soilSurfaceY,
            game.soilColumnHeight,
            game.soilLeftX,
          ),
        );
      }
    }

    if (roots.isEmpty) {
      _rootAnchor = null;
      return;
    }

    roots.sort(
      (a, b) => position
          .distanceToSquared(a)
          .compareTo(position.distanceToSquared(b)),
    );
    final nearby = roots.take(MicrobeMotility.rootAnchorSearchCount).toList();
    _rootAnchor = nearby[seed % nearby.length];
  }

  void _applyMicrobeRepulsion(double dt) {
    final others = parent?.children.whereType<AnimatedMicrobeComponent>() ?? [];
    for (final other in others) {
      if (other == this) continue;
      final dist = position.distanceTo(other.position);
      if (dist < MicrobeMotility.repulsionRadius) {
        _tmpVec.setFrom(position);
        _tmpVec.sub(other.position);
        _tmpVec.normalize();
        _tmpVec.scale(
          (MicrobeMotility.repulsionRadius - dist) *
              MicrobeMotility.repulsionStrength,
        );
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
    final baseColor = Color.lerp(
      CPKStandards.colorMicrobeZone,
      Colors.white,
      _activationBoost * 0.3,
    )!;

    // CRITICAL: Removed massive yellow circles/rays and cycle glows (Task 1/2)
    final currentOpacity = zoomLOD * cycleOpacity;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(_pulseScale);
    canvas.translate(-center.dx, -center.dy);

    // Hover and Selection halo
    if (isHovered || isPinned) {
      canvas.drawCircle(
        center,
        28.0,
        Paint()
          ..color = const Color(
            0xFFFACC15,
          ).withValues(alpha: isPinned ? 0.6 : 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 / zoom,
      );
      canvas.drawCircle(
        center,
        28.0,
        Paint()
          ..color = const Color(0xFFFACC15).withValues(alpha: 0.1)
          ..style = PaintingStyle.fill,
      );
    }

    // 1. Central Core (Hotspot requirement)
    final coreRadius = 4.0;
    // Glow
    canvas.drawCircle(
      center,
      coreRadius * 2.5,
      (_coreGlowPaint
        ..color = baseColor.withValues(alpha: 0.15 * currentOpacity)),
    );
    // Shadow
    canvas.drawCircle(
      center + const Offset(0.5, 0.5),
      coreRadius,
      (_coreShadowPaint
        ..color = Colors.black.withValues(alpha: 0.3 * currentOpacity)),
    );
    // Nitrogen observation emphasis: these colonies drive mineralisation,
    // nitrification and denitrification, so mark them while that cycle is
    // being studied. The ring is screen-constant and freezes with the clock.
    if (game.ref.read(activeCycleProvider) == ObservationCycle.nitrogen) {
      final pulse = 0.9 + 0.1 * math.sin(game.currentTime() * 2.2);
      canvas.drawCircle(
        center,
        22.0 * pulse,
        Paint()
          ..color = NitrogenForm.nitrate.color.withValues(
            alpha: 0.20 * currentOpacity,
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawCircle(
        center,
        15.0,
        Paint()
          ..color = NitrogenForm.nitrate.color.withValues(
            alpha: 0.8 * currentOpacity,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 / zoom,
      );
    }

    // Core body
    canvas.drawCircle(
      center,
      coreRadius,
      (_coreBodyPaint
        ..color = baseColor.withValues(alpha: 0.9 * currentOpacity)),
    );
    // Shading highlight
    canvas.drawCircle(
      center - const Offset(1.0, 1.0),
      coreRadius * 0.4,
      (_coreHighlightPaint
        ..color = Colors.white.withValues(alpha: 0.5 * currentOpacity)),
    );

    // 2. Swarm Effect: Multiple tiny dots representing individuals
    final dotCount = (MicrobeMotility.swarmDotBase * biomassIntensity)
        .toInt()
        .clamp(MicrobeMotility.swarmDotMin, MicrobeMotility.swarmDotMax);
    final dotRadius = MicrobeMotility.swarmDotRadius / zoom;

    final swarmPaint = _swarmPaint
      ..color = baseColor.withValues(alpha: 0.5 * currentOpacity);

    for (int i = 0; i < dotCount; i++) {
      // Slow internal jiggle: a colony should look like it is milling in
      // place, not spinning at a visible frame-rate.
      final angle =
          (_time * MicrobeMotility.swarmRotationSpeed) +
          (i * math.pi * 2 / dotCount) +
          (seed * i);
      final dist =
          (MicrobeMotility.swarmBaseDistance +
              MicrobeMotility.swarmPulseDistance *
                  math.sin(_time * MicrobeMotility.swarmPulseSpeed + i)) *
          biomassIntensity;
      final dotCenter =
          center +
          Offset(
            math.cos(angle) * dist,
            math.sin(angle) * dist * MicrobeMotility.swarmVerticalScale,
          );
      canvas.drawCircle(dotCenter, dotRadius, swarmPaint);
    }

    // 3. Captured Nutrients (Immobilized resources)
    for (int i = 0; i < _absorbedNutrients.length; i++) {
      final color = _absorbedNutrients[i];
      final angle =
          (i * math.pi * 2 / MicrobeMotility.maxAbsorbedNutrients) +
          _time * MicrobeMotility.nutrientOrbitSpeed;
      final dist = MicrobeMotility.nutrientOrbitDistance * biomassIntensity;
      final nutrientPos =
          center + Offset(math.cos(angle) * dist, math.sin(angle) * dist);

      // Shaded nutrient dot
      canvas.drawCircle(
        nutrientPos,
        1.5 / zoom,
        (_nutrientPaint..color = color.withValues(alpha: 0.8 * currentOpacity)),
      );
      canvas.drawCircle(
        nutrientPos - const Offset(0.3, 0.3),
        0.5 / zoom,
        (_nutrientHighlightPaint
          ..color = Colors.white.withValues(alpha: 0.5 * currentOpacity)),
      );
    }

    canvas.restore();
  }

  void _showMicrobeInfo({bool pinned = false}) {
    final l = game.l10n;
    final state = game.simulationState;
    if (state == null || state.profile.layers.isEmpty) return;
    final layer = state.profile.layers.first;
    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: l.microbialClusterTitle,
            description: l.microbialClusterDesc,
            stats: {
              l.simulatedUnits: '500+',
              l.metabolicActivity:
                  '${(BiophysicsUtils.q10Factor(layer.temperature) * 100).toStringAsFixed(0)}%',
              l.biomassDensity:
                  '${layer.microbialBiomass.toStringAsFixed(2)} kg/m³',
              l.immobilizedNutrients: '${_absorbedNutrients.length} units',
            },
            isPinned: pinned,
            accentColor: const Color(0xFFFACC15), // Golden Yellow
            // Microbes are 120 px boxes with a centre anchor; anchoring the
            // card at the origin put it 60 px away from the colony.
            screenPosition: game
                .worldToScreen(absolutePositionOf(size / 2))
                .toOffset(),
          ),
        );
  }

  @override
  void onTapUp(TapUpEvent event) {
    handleTapUp(({bool pinned = false}) => _showMicrobeInfo(pinned: pinned));
    event.handled = true;
  }

  @override
  void onHoverEnter() =>
      handleHoverEnter(() => _showMicrobeInfo(pinned: false));

  @override
  void onHoverExit() => handleHoverExit();
}
