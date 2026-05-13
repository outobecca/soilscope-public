import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import '../soil_scope_game.dart';
import '../../../providers/ui_state_provider.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import 'scene_coordinate_mapper.dart';
import '../../../../core/cpk_standards.dart';
import 'animated_plant_component.dart';
import 'molecule_renderer.dart';
import 'biological_entity_mixin.dart';

/// Interactive ion component representing dissolved nutrients in soil solution.
/// Tap to pin detailed information about the nutrient's chemistry and plant availability.
class IonComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, BiologicalEntityMixin, CollisionCallbacks {
  Color get color => MoleculeRenderer.getMoleculeColor(_moleculeType);

  MoleculeType get _moleculeType {
    switch (symbol) {
      case 'N': return MoleculeType.nitrate;
      case 'P': return MoleculeType.phosphate;
      case 'K': return MoleculeType.potassium;
      case 'Ca': return MoleculeType.calcium;
      case 'Mg': return MoleculeType.magnesium;
      default: return MoleculeType.ammonium;
    }
  }

  final String symbol;

  @override
  String get entityTitle => symbol;

  final String layerId;
  final int seed;

  IonComponent({
    required this.symbol,
    required this.layerId,
    required this.seed,
    required Vector2 position,
  }) : super(
         position: position,
         size: Vector2.all(12.0),
         anchor: Anchor.center,
       ) {
    add(CircleHitbox(radius: 6.0, collisionType: CollisionType.active));
  }

  double _age = 0.0;
  double _selectionPulse = 0.0;
  bool _isAbsorbed = false;

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is AnimatedPlantComponent && !_isAbsorbed) {
      final plantId = other.plantId;
      // Ion absorption represents a larger pool segment
      final amount = 0.5; 
      game.ref.read(simulationProvider.notifier).absorbNutrient(plantId, symbol, amount);
      game.triggerPlantGrowth();
      _isAbsorbed = true;
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isAbsorbed) return;
    if (_selectionPulse > 0) {
      _selectionPulse -= dt * 2.0;
    }
    _age += dt;
    final state = game.simulationState;
    if (state == null) return;
    final time = game.currentTime();

    // 1. Brownian-like movement (Diffusion)
    double dx = math.sin(time * (3 + seed % 3) + seed) * 0.5;
    double dy = math.cos(time * (2 + seed % 2) + seed) * 0.5;
    position.add(Vector2(dx, dy));

    // 2. Attraction to roots (Uptake)
    final plant = state.plants.isNotEmpty ? state.plants.first : null;
    if (plant != null) {
      final worldWidth = SoilScopeGame.soilColumnWidth;
      final soilHeight = game.soilColumnHeight;
      final soilX = game.soilLeftX;

      // Find the nearest root node
      double minDistSq = 10000; // Radius ~100px
      Vector2? nearestRootPos;

      for (int i = 0; i < plant.rootSystem.length; i += 4) {
        final node = plant.rootSystem[i];
        final rx = SceneCoordinateMapper.mapRootX(node.x, worldWidth, baseX: plant.baseX) + soilX;
        final ry = SceneCoordinateMapper.mapRootY(node.z, game.soilSurfaceY, soilHeight);
        final rPos = Vector2(rx, ry);
        final distSq = position.distanceToSquared(rPos);
        if (distSq < minDistSq) {
          minDistSq = distSq;
          nearestRootPos = rPos;
        }
      }

      if (nearestRootPos != null) {
        final direction = (nearestRootPos - position).normalized();
        final speed = (1.0 - math.sqrt(minDistSq) / 100.0).clamp(0.0, 1.0) * 15.0;
        position.add(direction * speed * dt);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final double alphaScale = (_age / 0.5).clamp(0.0, 1.0);
    final center = size.toOffset() / 2;
    final zoom = game.camera.viewfinder.zoom;

    // Selection Feedback Pulse
    if (_selectionPulse > 0) {
      canvas.drawCircle(
        center,
        size.x * (1.0 + (1.0 - _selectionPulse) * 1.5),
        Paint()
          ..color = Colors.white.withValues(alpha: _selectionPulse * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 / zoom,
      );
    }

    MoleculeRenderer.drawMolecule(
      canvas,
      center,
      _moleculeType,
      opacity: alphaScale,
      isLocked: isPinned || isHovered,
      zoom: zoom,
      phase: _age * 2.0,
    );
  }

  @override
  bool containsLocalPoint(Vector2 point) => (point - size / 2).length < 12.0;

  @override
  void onTapUp(TapUpEvent event) {
    _selectionPulse = 1.0;
    
    if (isPinned) {
      game.ref.read(simulationSessionProvider.notifier).selectElement(null);
    } else {
      game.ref.read(simulationSessionProvider.notifier).selectElement(symbol);
    }

    handleTapUp(_showIonInfo);
    event.handled = true;
  }

  @override
  void onHoverEnter() => handleHoverEnter(() => _showIonInfo(pinned: false));

  @override
  void onHoverExit() => handleHoverExit();

  void _showIonInfo({bool pinned = false}) {
    final state = game.ref.read(simulationProvider);
    final layer = state.profile.layers.firstWhere((l) => l.id == layerId);
    final info = _getIonInfo(layer);

    game.ref
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: info['title'] as String,
            description: info['description'] as String,
            stats: info['stats'] as Map<String, String>,
            formula: MoleculeRenderer.getMoleculeFormula(_moleculeType),
            isPinned: pinned,
            legends: info['legends'] as List<LegendItem>?,
            accentColor: color,
            elementSymbol: symbol,
            screenPosition: game.worldToScreen(absolutePosition).toOffset(),
          ),
        );
  }

  /// Returns detailed information about the ion based on its symbol.
  Map<String, dynamic> _getIonInfo(dynamic layer) {
    final l = game.l10n;
    switch (symbol) {
      case 'N':
        return {
          'title': l.ionNitrateTitle,
          'description': l.ionNitrateDescription,
          'formula': r'NO_{3}^{-}',
          'stats': {
            l.ionLabel: l.ionNitrateName,
            l.concentrationLabel:
                '${layer.nitrateContent.toStringAsFixed(1)} mg/kg',
            l.mobility: l.veryGood,
            l.chargeLabel: l.negativeCharge('-1'),
            l.risk: l.leachingRisk,
            l.uptake: l.activeTransport,
            l.layerLabel: layerId,
          },
          'legends': [
            LegendItem(
              icon: Icons.water_drop,
              color: CPKStandards.colorN.withValues(alpha: 0.6),
              label: l.soluble,
            ),
            LegendItem(
              icon: Icons.warning,
              color: Colors.orange,
              label: l.leaches,
            ),
          ],
        };
      case 'P':
        return {
          'title': l.ionPhosphateTitle,
          'description': l.ionPhosphateDescription,
          'stats': {
            l.ionLabel: l.ionPhosphateName,
            l.concentrationLabel:
                '${layer.phosphateContent.toStringAsFixed(1)} mg/kg',
            l.mobility: l.veryWeak,
            l.chargeLabel: l.negativeCharge('-1/-2'),
            l.bindingLabel: 'Fe³⁺, Al³⁺, Ca²⁺',
            l.uptake: l.diffusionAndMycorrhiza,
            l.layerLabel: layerId,
          },
          'legends': [
            LegendItem(
              icon: Icons.battery_charging_full,
              color: CPKStandards.colorP,
              label: l.energy,
            ),
            LegendItem(
              icon: Icons.lock,
              color: Colors.brown,
              label: l.bound,
            ),
          ],
        };
      case 'K':
        return {
          'title': l.ionPotassiumTitle,
          'description': l.ionPotassiumDescription,
          'stats': {
            l.ionLabel: l.ionPotassiumName,
            l.concentrationLabel:
                '${layer.potassiumContent.toStringAsFixed(1)} mg/kg',
            l.mobility: l.moderate,
            l.chargeLabel: l.positiveCharge('+1'),
            l.bindingLabel: '${l.clayMinerals} (CEC)',
            l.uptake: l.activeTransport,
            l.layerLabel: layerId,
          },
          'legends': [
            LegendItem(
              icon: Icons.water_drop,
              color: CPKStandards.colorK.withValues(alpha: 0.8),
              label: l.waterBalance,
            ),
            LegendItem(
              icon: Icons.visibility,
              color: Colors.purple,
              label: l.stomataLabel,
            ),
          ],
        };
      case 'Ca':
        return {
          'title': l.ionCalciumTitle,
          'description': l.ionCalciumDescription,
          'stats': {
            l.ionLabel: l.ionCalciumName,
            l.concentrationLabel:
                '${layer.solutionCalcium.toStringAsFixed(0)} mg/L',
            l.mobility: l.slow,
            l.chargeLabel: l.positiveCharge('+2'),
            l.role: l.cellWallSignal,
            l.phEffect: l.limingRaisesPH,
            l.layerLabel: layerId,
          },
          'legends': [
            LegendItem(
              icon: Icons.architecture,
              color: Colors.blueGrey.shade400,
              label: l.structureLabel,
            ),
            LegendItem(
              icon: Icons.add_circle,
              color: Colors.teal,
              label: l.phBuffer,
            ),
          ],
        };

      case 'Mg':
        return {
          'title': l.ionMagnesiumTitle,
          'description': l.ionMagnesiumDescription,
          'stats': {
            l.ionLabel: l.ionMagnesiumName,
            l.concentrationLabel:
                '${(layer.solutionCalcium * 0.15).toStringAsFixed(0)} mg/L',
            l.mobility: l.goodRedistribution,
            l.chargeLabel: l.positiveCharge('+2'),
            l.role: l.chlorophyllCenter,
            l.antagonist: l.highK,
            l.layerLabel: layerId,
          },
          'legends': [
            LegendItem(
              icon: Icons.light_mode,
              color: Colors.lightGreen,
              label: l.photosynthesis,
            ),
            LegendItem(
              icon: Icons.swap_horiz,
              color: Colors.green,
              label: l.redistribution,
            ),
          ],
        };

      default:
        return {
          'title': '${l.nutrient}: $symbol',
          'description': l.solubleNutrientDesc,
          'stats': {
            l.ionLabel: symbol,
            l.type: l.solubleNutrient,
            l.layerLabel: layerId,
          },
          'legends': <LegendItem>[],
        };
    }
  }
}
