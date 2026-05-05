import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' hide Image, PointerMoveEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import '../logic/soil_layer_style_engine.dart';
import '../logic/soil_layer_noise_engine.dart';
import 'ion_component.dart';
import 'molecule_particle_component.dart';
import 'expandable_hotspot_node.dart';
import 'scene_coordinate_mapper.dart';
import '../soil_scope_game.dart';
import '../../../../core/cpk_standards.dart';

import '../../../../core/simulation_constants.dart';
import 'soil_component_mixin.dart';
import 'layer_tech_node_mixin.dart';
import 'riverpod_lifecycle_mixin.dart';

class SoilLayerComponent extends PositionComponent
    with HasGameReference<SoilScopeGame>, TapCallbacks, HoverCallbacks, SoilComponentMixin, LayerTechNodeMixin, RiverpodLifecycleMixin {
  final String layerId;
  SoilLayer _layer;
  bool _isSelected;

  late Paint _layerPaint;
  Picture? _noisePicture;

  SoilLayerComponent({
    required this.layerId,
    required SoilLayer initialLayer,
    required Rect initialRect,
    required bool isSelected,
  }) : _layer = initialLayer,
       _isSelected = isSelected,
       super(
         position: Vector2(initialRect.left, initialRect.top),
         size: Vector2(initialRect.width, initialRect.height),
         priority: 100,
       );

  @override
  void onMount() {
    super.onMount();
    
    // Fine-grained listener for THIS layer's data
    listenProvider<SoilLayer?>(
      displayedSimulationStateProvider.select((s) => s.profile.layers.cast<SoilLayer?>().firstWhere((l) => l?.id == layerId, orElse: () => null)),
      (prev, next) {
        if (next != null) {
          _handleLayerUpdate(next);
        }
      },
      fireImmediately: true,
    );

    // Fine-grained listener for selection state
    listenProvider<bool>(
      simulationSessionProvider.select((s) => s.selectedLayerId == layerId),
      (prev, next) {
        if (next != _isSelected) {
          _isSelected = next;
          _updatePaint();
        }
      },
    );
  }

  void _handleLayerUpdate(SoilLayer next) {
    bool needsRepaint =
        _layer.waterContent != next.waterContent ||
        _layer.redoxPotential != next.redoxPotential ||
        _layer.organicCarbon != next.organicCarbon;

    bool needsNoiseUpdate =
        _layer.sandFraction != next.sandFraction ||
        _layer.clayFraction != next.clayFraction ||
        _layer.aggregateStability != next.aggregateStability ||
        _layer.organicCarbon != next.organicCarbon;

    _layer = next;
    
    // Note: Position and size are still calculated by parent or can be reactive too
    // For now, let's keep them pushed or calculate them here if we know the total profile
    
    if (needsRepaint) _updatePaint();
    if (needsNoiseUpdate) _preRenderNoise();
    _syncSubComponents();
  }

  @override
  Future<void> onLoad() async {
    _updatePaint();
    _preRenderNoise();
  }


  void triggerSubComponentSync() {
    _syncSubComponents();
  }

  void _updatePaint() {
    _layerPaint = SoilLayerStyleEngine.calculateLayerPaint(
      _layer,
      size.toSize(),
    );
  }

  void _preRenderNoise() {
    _noisePicture = SoilLayerNoiseEngine.generateNoisePicture(_layer, layerId);
  }

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;

    // 1. Draw base soil rectangle
    final isBottomLayer = (position.y + size.y) >= (game.soilSurfaceY + game.soilColumnHeight - 5);
    final wideRect = Rect.fromLTWH(
      backgroundX - simulationX,
      0,
      backgroundWidth,
      size.y + (isBottomLayer ? 10000 : 0),
    );
    canvas.drawRect(wideRect, _layerPaint);

    // 2. Draw biological activity pulse
    final double bioFactor = (_layer.microbialBiomass / 500.0).clamp(0.0, 1.0);
    if (bioFactor > 0.1) {
      final double pulse = 0.5 + 0.5 * math.sin(game.currentTime() * (1.0 + bioFactor * 4.0));
      final bioPaint = Paint()
        ..color = const Color(0xFF689F38).withValues(alpha: 0.03 * bioFactor * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawRect(wideRect, bioPaint);
    }

    // 3. Draw noise and textures
    if (_noisePicture != null) {
      canvas.save();
      canvas.clipRect(size.toRect());
      canvas.drawPicture(_noisePicture!);
      canvas.restore();
    }

    // Depth Shadows (Vignette)
    if (position.y > game.soilSurfaceY + 1.0) {
      final topShadowRect = Rect.fromLTWH(wideRect.left, 0, wideRect.width, 25.0);
      final topShadowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ).createShader(topShadowRect)
        ..blendMode = BlendMode.multiply;
      canvas.drawRect(topShadowRect, topShadowPaint);
    }

    if (!isBottomLayer) {
      final bottomShadowRect = Rect.fromLTWH(wideRect.left, size.y - 25.0, wideRect.width, 25.0);
      final bottomShadowPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ).createShader(bottomShadowRect)
        ..blendMode = BlendMode.multiply;
      canvas.drawRect(bottomShadowRect, bottomShadowPaint);
    }

    // 4. High-zoom details
    if (zoom > 2.0) {
      if (_layer.effectiveMacroPorosity > 0.05) _drawCracks(canvas);
    }

    // 5. Selection highlight
    if (_isSelected) {
      final highlightPaint = Paint()
        ..color = Theme.of(
          game.buildContext!,
        ).colorScheme.primary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 / zoom;
      canvas.drawRect(wideRect.deflate(2), highlightPaint);
    }
  }

  void _drawCracks(Canvas canvas) {
    final crackPaint = Paint()
      ..color = Colors.black.withValues(
        alpha: 0.3 * _layer.effectiveMacroPorosity,
      )
      ..strokeWidth = 2 * _layer.effectiveMacroPorosity
      ..style = PaintingStyle.stroke;
    final nCracks = (5 * _layer.effectiveMacroPorosity).toInt().clamp(1, 10);
    final rand = math.Random(layerId.hashCode + 2);
    for (int i = 0; i < nCracks; i++) {
      double startX = rand.nextDouble() * size.x;
      canvas.drawPath(
        Path()
          ..moveTo(startX, 0)
          ..lineTo(startX + (rand.nextDouble() - 0.5) * 10, size.y * 0.5)
          ..lineTo(startX + (rand.nextDouble() - 0.5) * 10, size.y),
        crackPaint,
      );
    }
  }

  void _syncSubComponents() {
    final double zoom = game.camera.viewfinder.zoom;
    final state = game.ref.read(simulationProvider);
    final session = game.ref.read(simulationSessionProvider);
    final symbol = session.selectedElementSymbol;
    final existingIons = children.query<IonComponent>();

    if (zoom > SimulationConstants.detailZoomThreshold && symbol != null && state.plants.isNotEmpty) {
      if (existingIons.length < 20) {
        final plant = state.plants.first;
        final centerX = SceneCoordinateMapper.mapShootPosition(plant.baseX, size.x, 0).x;

        final rand = math.Random(
          layerId.hashCode + symbol.hashCode + existingIons.length,
        );

        // RHIZOSPHERE FOCUS: Gaussian bias for ions in the layer
        final ix = _nextGaussian(rand, centerX, 180.0).clamp(20.0, size.x - 20.0);
        final iy = rand.nextDouble() * size.y;

        add(
          IonComponent(
            symbol: symbol,
            layerId: layerId,
            seed: existingIons.length,
            position: Vector2(ix, iy),
            color: CPKStandards.getColor(symbol),
          ),
        );
      }
    } else {
      for (final i in existingIons) {
        i.removeFromParent();
      }
    }

    // Tech Nodes Sync (Nutrients, Sensors)
    final existingHotspots = game.technicalHotspotLayer.children
        .query<ExpandableHotspotNode>()
        .where((h) => h.layerId == layerId);

    if (existingHotspots.isEmpty) {
      spawnLayerHUDNodes(
        layerId: layerId,
        state: state,
      );
    }
  }

  /// Box-Muller transform for Gaussian distribution
  double _nextGaussian(math.Random rand, double mean, double stdDev) {
    final u1 = rand.nextDouble();
    final u2 = rand.nextDouble();
    final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return z0 * stdDev + mean;
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.ref.read(simulationSessionProvider.notifier).selectLayer(layerId);
    final session = game.ref.read(simulationSessionProvider);
    if (session.isMicroscopeEnabled) {
      game.ref.read(simulationSessionProvider.notifier).selectInspector('soilStructure');
    } else {
      game.ref.read(simulationSessionProvider.notifier).selectInspector(null);
    }
    event.handled = true;
  }

  double _nitrificationAccumulator = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!(game.simulationState?.isRunning ?? false)) return;

    final state = game.ref.read(simulationProvider);
    try {
      final layer = state.profile.layers.firstWhere((l) => l.id == layerId);

      // 1. Read Nitrification Flux (NH4 -> NO3) from Isolate
      final double nitRate = layer.nitrificationRate;
      final double nNitrified = layer.ammoniumContent * nitRate; // mg/kg/s

      final double redoxOpacity = layer.redoxPotential < 200 ? 0.1 : 1.0;

      _nitrificationAccumulator += nNitrified * SimulationConstants.nitrificationVisualDensity * dt;
      if (_nitrificationAccumulator >= 1.0) {
        _nitrificationAccumulator -= 1.0;
        
        // Throttling: Only emit if pool has capacity and not too many this frame
        final pool = game.moleculePool;
        if (pool != null) {
          _emitFluxParticle(
            fromSymbol: 'NH₄⁺',
            toSymbol: 'NO₃⁻',
            type: MoleculeType.ammonium,
            targetType: MoleculeType.nitrate,
            opacity: redoxOpacity,
            speed: SimulationConstants.particleBaseSpeed + (nitRate * SimulationConstants.fluxToSpeedScale).clamp(5.0, 50.0),
          );
        }
      }
    } catch (_) {}
  }

  void _emitFluxParticle({
    required String fromSymbol,
    required String toSymbol,
    required MoleculeType type,
    required MoleculeType targetType,
    required double opacity,
    required double speed,
  }) {
    if (game.moleculePool == null) return;

    // Find the correct nutrient hotspot for this layer
    final hotspots = game.technicalHotspotLayer.children
        .query<ExpandableHotspotNode>()
        .where((h) => h.layerId == layerId && h.metrics.contains(toSymbol));

    if (hotspots.isEmpty) return;
    final hotspot = hotspots.first;

    final rand = math.Random();
    // Start at a random position within the soil layer's interactive zone
    final startPos = Vector2(
      position.x + rand.nextDouble() * size.x,
      position.y + rand.nextDouble() * size.y,
    );

    game.moleculePool!.spawn(
      position: startPos,
      type: type,
      transformTarget: targetType,
      targetPosition: hotspot.position,
      velocity: (hotspot.position - startPos).normalized() * speed,
      lifeTime: 4.0,
      opacity: opacity,
    );
  }
}
