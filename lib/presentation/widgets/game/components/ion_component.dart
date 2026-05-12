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

/// Interactive ion component representing dissolved nutrients in soil solution.
/// Tap to pin detailed information about the nutrient's chemistry and plant availability.
import 'biological_entity_mixin.dart';

/// Interactive ion component representing dissolved nutrients in soil solution.
/// Tap to pin detailed information about the nutrient's chemistry and plant availability.
class IonComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, BiologicalEntityMixin, CollisionCallbacks {
  final String symbol;

  @override
  String get entityTitle => symbol;

  final String layerId;
  final int seed;
  final Color color;

  IonComponent({
    required this.symbol,
    required this.layerId,
    required this.seed,
    required Vector2 position,
    required this.color,
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
    final radius = size.x / 3;
    final time = game.currentTime();
    final zoom = game.camera.viewfinder.zoom;

    // Subtle drop shadow
    canvas.drawCircle(
      center,
      radius * 1.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3 * alphaScale)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0),
    );
    // Selection Feedback Pulse
    if (_selectionPulse > 0) {
      canvas.drawCircle(
        center,
        radius * 1.5 * (1.0 + (1.0 - _selectionPulse) * 1.5),
        Paint()
          ..color = Colors.white.withValues(alpha: _selectionPulse * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 / zoom,
      );
    }

    // LOD at low zoom
    if (zoom < 0.6) {
      canvas.drawCircle(center, radius * 0.8, Paint()..color = color.withValues(alpha: alphaScale));
      return;
    }

    final blurValue = (4.0 / zoom).clamp(2.0, 8.0);
    final glowPaint = Paint()
      ..color = color.withValues(alpha: (0.15 + (math.sin(time * 3 + seed) * 0.05)) * alphaScale)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurValue);
    canvas.drawCircle(center, radius * 1.8, glowPaint);

    // 1. Shadow for depth
    canvas.drawCircle(
      center + const Offset(1.0, 1.0),
      radius,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4 * alphaScale)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0),
    );

    // 2. Main Ion Body
    final bodyPaint = Paint()..color = color.withValues(alpha: alphaScale);
    // Contrast halo for visibility in dark soil
    canvas.drawCircle(center, radius * 1.15, Paint()..color = Colors.white.withValues(alpha: 0.2 * alphaScale));
    canvas.drawCircle(center, radius, bodyPaint);

    // 3. Shading / Highlight
    canvas.drawCircle(
      center - Offset(radius * 0.3, radius * 0.3),
      radius * 0.35,
      Paint()..color = Colors.white.withValues(alpha: 0.5 * alphaScale),
    );

    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4 * alphaScale)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, radius * 0.8, ringPaint);

    if (zoom > 1.5) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: TextStyle(
            color: Colors.white.withValues(alpha: alphaScale),
            fontSize: radius * 1.2,
            fontWeight: FontWeight.bold,
            shadows: const [Shadow(blurRadius: 1, color: Colors.black)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, center - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    if (isPinned) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius * 2.5, highlightPaint);
      
      for (int i = 0; i < 3; i++) {
        final angle = time * 2 + (i * math.pi * 2 / 3);
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius * 2.8), angle, 0.8, false, highlightPaint..strokeWidth = 1.0);
      }
    }
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
            formula: info['formula'] as String?,
            isPinned: pinned,
            legends: info['legends'] as List<LegendItem>?,
            accentColor: CPKStandards.getColor(symbol),
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
