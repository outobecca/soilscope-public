import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:material_ui/material_ui.dart' hide Image, PointerMoveEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/soil_layer.dart';
import '../../../providers/simulation_provider.dart';
import '../../../providers/simulation_session_provider.dart';
import '../../../providers/ui_state_provider.dart';
import '../logic/soil_layer_style_engine.dart';
import '../logic/soil_layer_noise_engine.dart';
import 'ion_component.dart';
import 'expandable_hotspot_node.dart';
import 'molecule_renderer.dart';
import 'scene_coordinate_mapper.dart';
import 'selection_node_component.dart';
import '../soil_scope_game.dart';
import 'process_label_component.dart';
import '../../../../core/cpk_standards.dart';
import '../../../../core/simulation_constants.dart';
import 'soil_component_mixin.dart';
import 'layer_tech_node_mixin.dart';
import 'riverpod_lifecycle_mixin.dart';
import 'rhizosphere_hotspot_component.dart';
import 'visual_seed.dart';

class SoilLayerComponent extends PositionComponent
    with
        HasGameReference<SoilScopeGame>,
        SoilComponentMixin,
        LayerTechNodeMixin,
        RiverpodLifecycleMixin,
        TapCallbacks {
  @override
  final String layerId;
  SoilLayer _layer;
  bool isSelected;

  String get keyboardLabel => _layer.name.isNotEmpty ? _layer.name : layerId;

  late Paint _layerPaint;
  Image? _noiseImage;

  /// Quantized identity of the raster currently displayed. Requests compare
  /// against it, so a layer whose grain inputs have not visibly changed keeps
  /// its image even though the solver rewrites those fields every tick.
  SoilLayerNoiseKey? _noiseKey;

  /// Latest requested raster, coalesced while one is in flight.
  SoilLayer? _pendingNoiseLayer;
  SoilLayerNoiseKey? _pendingNoiseKey;
  bool _noiseRefreshRunning = false;
  int _noiseGeneration = 0;
  SoilLayer? _paintSourceLayer;
  Size _paintedSize = Size.zero;
  late final math.Random _eventRandom = visualRandom(['soil-layer', layerId]);
  SelectionNodeComponent? _selectionNode;

  /// Technical sampling nodes owned by this layer, captured when they spawn so
  /// the steady-state sync does not rescan the global overlay (a direct-child
  /// scan plus list and filter costs ~6.7 µs/call more).
  final List<ExpandableHotspotNode> _techNodes = [];

  /// Rhizosphere hotspots owned by this layer, keyed by model hotspot id.
  final Map<String, RhizosphereHotspotComponent> _rhizosphere = {};

  /// Layer geometry the sub-components were last positioned for.
  Vector2? _syncedPosition;
  Size _syncedSize = Size.zero;

  SoilLayerComponent({
    required this.layerId,
    required SoilLayer initialLayer,
    required Rect initialRect,
    required this.isSelected,
  }) : _layer = initialLayer,
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
      displayedSimulationStateProvider.select(
        (s) => s.profile.layers.cast<SoilLayer?>().firstWhere(
          (l) => l?.id == layerId,
          orElse: () => null,
        ),
      ),
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
        if (next != isSelected) {
          isSelected = next;
          _updatePaint();
        }
      },
    );

    _addLayerNode();
  }

  void _addLayerNode() {
    final node = SelectionNodeComponent(
      nodeType: SelectionNodeType.soilLayer,
      layerId: layerId,
      title: _layer.name.isNotEmpty
          ? _layer.name.toUpperCase()
          : 'LAYER ${layerId.toUpperCase()}',
      description: _layer.description.isNotEmpty
          ? _layer.description
          : game.l10n.layerAnalysisDesc,
      accentColor: Color(_layer.colorValue),
      icon: Icons.layers_rounded,
      position: Vector2(60, size.y / 2), // Aligned with diagnostic gutter
      statsProvider: () {
        final state = game.displayedState;
        try {
          final layer = state.profile.layers.firstWhere((l) => l.id == layerId);
          return {
            game.l10n.waterContentLabel:
                '${(layer.waterContent * 100).toStringAsFixed(1)}%',
            game.l10n.temperatureLabel:
                '${(layer.temperature - 273.15).toStringAsFixed(1)}°C',
            'pH': layer.ph.toStringAsFixed(1),
            'ORP': '${layer.redoxPotential.toStringAsFixed(0)}mV',
            game.l10n.bulkDensity:
                '${layer.bulkDensity.toStringAsFixed(0)} kg/m³',
            game.l10n.porosity: '${(layer.porosity * 100).toStringAsFixed(0)}%',
          };
        } catch (_) {
          return null;
        }
      },
    );
    _selectionNode = node;
    add(node);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final current = game.ref.read(uIStateProvider);
    final isThisLayerPinned =
        current != null &&
        current.isPinned &&
        current.sourceId == 'soil-layer-$layerId';

    if (isThisLayerPinned) {
      // Second tap on the same layer dismisses the inspection instead of
      // silently re-pinning it (important for touch, which has no hover exit).
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    } else {
      game.ref.read(simulationSessionProvider.notifier).selectLayer(layerId);
      _showLayerInfo(pinned: true);
    }
    event.handled = true;
  }

  void _showLayerInfo({bool pinned = false}) {
    final state = game.displayedState;
    try {
      final layer = state.profile.layers.firstWhere((l) => l.id == layerId);
      final stats = {
        game.l10n.waterContentLabel:
            '${(layer.waterContent * 100).toStringAsFixed(1)}%',
        game.l10n.temperatureLabel:
            '${(layer.temperature - 273.15).toStringAsFixed(1)}°C',
        'pH': layer.ph.toStringAsFixed(1),
        'ORP': '${layer.redoxPotential.toStringAsFixed(0)}mV',
        game.l10n.organicCarbonLabel:
            '${(layer.organicCarbon * 100).toStringAsFixed(2)}%',
        game.l10n.bulkDensity: '${layer.bulkDensity.toStringAsFixed(0)} kg/m³',
        game.l10n.porosity: '${(layer.porosity * 100).toStringAsFixed(0)}%',
      };
      game.ref
          .read(uIStateProvider.notifier)
          .setHoverInfo(
            HoverInfo(
              title: _layer.name.isNotEmpty
                  ? _layer.name.toUpperCase()
                  : 'KERROS ${layerId.toUpperCase()}',
              description: _layer.description.isNotEmpty
                  ? _layer.description
                  : game.l10n.layerAnalysisDesc,
              stats: stats,
              isPinned: pinned,
              sourceId: 'soil-layer-$layerId',
              layerId: layerId,
              logicLabModel: 'waterRetention',
              onDismiss: () {
                final session = game.ref.read(simulationSessionProvider);
                if (session.selectedLayerId == layerId) {
                  game.ref
                      .read(simulationSessionProvider.notifier)
                      .selectLayer(null);
                }
              },
              accentColor: Color(_layer.colorValue),
              screenPosition: game
                  .worldToScreen(
                    absolutePosition + Vector2(size.x / 2, size.y / 2),
                  )
                  .toOffset(),
            ),
          );
    } catch (_) {}
  }

  void _handleLayerUpdate(SoilLayer next) {
    final noiseKey = SoilLayerNoiseKey.of(next);

    _layer = next;

    if (noiseKey != _noiseKey) {
      _requestNoiseRefresh(next, noiseKey);
    }
    _syncSubComponents();
  }

  double _visualPaintTimer = 0;

  /// Follow the game's interpolated read model for the smooth properties
  /// (water, temperature, pH, redox) while the texture/gradient is refreshed
  /// at a bounded 30 Hz to avoid rebuilding shaders on every display frame.
  void _syncVisualLayer(double dt) {
    final visualState = game.displayedState;
    SoilLayer? visualLayer;
    for (final layer in visualState.profile.layers) {
      if (layer.id == layerId) {
        visualLayer = layer;
        break;
      }
    }
    if (visualLayer == null) return;

    _layer = visualLayer;
    _visualPaintTimer += dt;
    if (_visualPaintTimer < 1 / 30) return;
    _visualPaintTimer = 0;

    // The gradient only depends on these scalars. Skip rebuilding the shader
    // when the visual values have already settled at their target.
    final painted = _paintSourceLayer;
    if (painted != null &&
        _paintedSize == size.toSize() &&
        painted.waterContent == visualLayer.waterContent &&
        // The gradient's saturation term is waterContent / porosity, so a
        // porosity change repaints even when the water content is settled.
        painted.porosity == visualLayer.porosity &&
        painted.redoxPotential == visualLayer.redoxPotential &&
        painted.temperature == visualLayer.temperature &&
        painted.ph == visualLayer.ph &&
        painted.depth == visualLayer.depth &&
        painted.thickness == visualLayer.thickness) {
      return;
    }
    _updatePaint();
  }

  @override
  Future<void> onLoad() async {
    _updatePaint();
    // The first frame is intentionally rasterized in place: the layer must not
    // appear without its grain field while an asynchronous image is pending.
    _noiseKey = SoilLayerNoiseKey.of(_layer);
    _noiseImage = SoilLayerNoiseEngine.generateNoiseImage(_layer, layerId);
  }

  void triggerSubComponentSync() {
    _syncSubComponents();
  }

  /// Applies a layer snapshot through the same path as the state listener.
  ///
  /// Lifecycle tests use this to drive add/remove/geometry transitions without
  /// racing the engine's own ticks, which rewrite the hotspot list.
  @visibleForTesting
  void debugHandleLayerUpdate(SoilLayer next) => _handleLayerUpdate(next);

  void updateLayerRect(Vector2 nextPosition, Vector2 nextSize) {
    final geometryChanged =
        position.x != nextPosition.x ||
        position.y != nextPosition.y ||
        size.x != nextSize.x ||
        size.y != nextSize.y;
    if (!geometryChanged) return;

    position = nextPosition;
    size = nextSize;
    _selectionNode?.position = Vector2(60, size.y / 2);
    _syncSubComponents();
  }

  /// Opens the same layer inspection used by a canvas tap. Keyboard users
  /// reach this through the canvas focus target list.
  void activateFromKeyboard() {
    game.ref.read(simulationSessionProvider.notifier).selectLayer(layerId);
    _showLayerInfo(pinned: true);
  }

  void _updatePaint() {
    _paintSourceLayer = _layer;
    _paintedSize = size.toSize();
    _layerPaint = SoilLayerStyleEngine.calculateLayerPaint(
      _layer,
      size.toSize(),
    );
  }

  /// Requests a grain raster for [layer] without blocking the calling frame.
  ///
  /// At most one raster is in flight; a newer request replaces the pending one
  /// and is picked up when the current image lands. The previous image keeps
  /// drawing in the meantime, matching the texture raster's refresh policy.
  void _requestNoiseRefresh(SoilLayer layer, SoilLayerNoiseKey key) {
    if (key == _noiseKey || key == _pendingNoiseKey) return;
    _pendingNoiseLayer = layer;
    _pendingNoiseKey = key;
    if (_noiseRefreshRunning) return;
    _noiseRefreshRunning = true;
    unawaited(_refreshNoiseLoop());
  }

  Future<void> _refreshNoiseLoop() async {
    while (isMounted) {
      final layer = _pendingNoiseLayer;
      final key = _pendingNoiseKey;
      if (layer == null || key == null) break;
      _pendingNoiseLayer = null;
      _pendingNoiseKey = null;

      final generation = ++_noiseGeneration;
      final Image image;
      try {
        image = await SoilLayerNoiseEngine.generateNoiseImageAsync(
          layer,
          layerId,
        );
      } catch (_) {
        // A decorative raster must never take the frame loop down; keep the
        // previous image and let the next key change retry.
        break;
      }
      if (!isMounted || generation != _noiseGeneration) {
        image.dispose();
        break;
      }
      _noiseImage?.dispose();
      _noiseImage = image;
      _noiseKey = key;
    }
    _noiseRefreshRunning = false;
  }

  @override
  void onRemove() {
    _noiseImage?.dispose();
    _noiseImage = null;
    // Discards an in-flight raster so it cannot be adopted after removal.
    _noiseGeneration++;
    _pendingNoiseLayer = null;
    _pendingNoiseKey = null;
    _techNodes.clear();
    _rhizosphere.clear();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final double zoom = game.camera.viewfinder.zoom;

    // 1. Draw base soil rectangle
    final isBottomLayer =
        (position.y + size.y) >=
        (game.soilSurfaceY + game.soilColumnHeight - 5);
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
      final double pulse =
          0.5 + 0.5 * math.sin(game.currentTime() * (1.0 + bioFactor * 4.0));
      final bioPaint = Paint()
        ..color = const Color(
          0xFF689F38,
        ).withValues(alpha: 0.03 * bioFactor * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawRect(wideRect, bioPaint);
    }

    // 3. Draw noise and textures
    final noiseImage = _noiseImage;
    if (noiseImage != null) {
      canvas.save();
      canvas.clipRect(size.toRect());
      canvas.drawImage(
        noiseImage,
        Offset.zero,
        Paint()..filterQuality = FilterQuality.low,
      );
      canvas.restore();
    }

    // Depth Shadows (Vignette)
    if (position.y > game.soilSurfaceY + 1.0) {
      final topShadowRect = Rect.fromLTWH(
        wideRect.left,
        0,
        wideRect.width,
        25.0,
      );
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
      final bottomShadowRect = Rect.fromLTWH(
        wideRect.left,
        size.y - 25.0,
        wideRect.width,
        25.0,
      );
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
    if (isSelected) {
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
    final bool detailZoom = zoom > SimulationConstants.detailZoomThreshold;
    // Ions are added directly to this layer, so a direct-child scan is
    // equivalent to the recursive query and does not walk the subtree.
    final existingIons = children.whereType<IonComponent>().toList();
    final symbol = detailZoom
        ? game.ref.read(simulationSessionProvider).selectedElementSymbol
        : null;

    if (detailZoom &&
        symbol != null &&
        game.displayedState.plants.isNotEmpty) {
      if (existingIons.length < 20) {
        final centerX = SceneCoordinateMapper.mapShootPosition(size.x, 0).x;

        final rand = math.Random(
          layerId.hashCode + symbol.hashCode + existingIons.length,
        );

        // RHIZOSPHERE FOCUS: Gaussian bias for ions in the layer
        final ix = _nextGaussian(
          rand,
          centerX,
          180.0,
        ).clamp(20.0, size.x - 20.0);
        final iy = rand.nextDouble() * size.y;

        add(
          IonComponent(
            symbol: symbol,
            layerId: layerId,
            seed: existingIons.length,
            position: Vector2(ix, iy),
          ),
        );
      }
    } else {
      for (final i in existingIons) {
        i.removeFromParent();
      }
    }

    // Tech Nodes Sync (Nutrients, Sensors). The layer captures its nodes at
    // spawn, so the steady-state sync does not rescan the global overlay.
    _techNodes.removeWhere((node) => !node.isMounted || node.isRemoving);
    if (_techNodes.isEmpty) {
      _techNodes.addAll(
        spawnLayerHUDNodes(layerId: layerId, state: game.displayedState),
      );
    }

    // Layer heights change when the scenario or viewport changes. Re-anchor
    // the existing nodes so a hotspot cannot drift over a neighbouring layer
    // and open that layer's data. Their positions are derived from the layer
    // geometry, so rewriting them is only needed when that geometry changes.
    final layerSize = size.toSize();
    final bool geometryChanged =
        _syncedPosition == null ||
        _syncedPosition!.x != position.x ||
        _syncedPosition!.y != position.y ||
        _syncedSize != layerSize;
    if (geometryChanged) {
      for (final node in _techNodes) {
        node.position = Vector2(
          position.x + node.layerAnchor.x * size.x,
          position.y + node.layerAnchor.y * size.y,
        );
      }
      _syncedPosition = position.clone();
      _syncedSize = layerSize;
    }

    // --- RHIZOSPHERE HOTSPOTS SYNC ---
    // The layer owns these components; keep the id → component map instead of
    // rebuilding it from a tree query and a fresh map on every sync.
    _rhizosphere.removeWhere(
      (_, component) => !component.isMounted || component.isRemoving,
    );

    final activeHotspotIds = <String>{};
    for (final h in _layer.hotspots) {
      activeHotspotIds.add(h.id);
      final existing = _rhizosphere[h.id];

      // `h.x` is plot-normalised (0.5 = plant collar), not a fraction of the
      // full decorative column. Mapping it with the shared root transform
      // keeps the rhizosphere glow on the root that produced it. Local
      // position depends only on the layer size.
      if (existing != null) {
        if (geometryChanged) {
          existing.position = Vector2(
            SceneCoordinateMapper.mapRootX(h.x, size.x),
            h.z * size.y,
          );
        }
        existing.updateIntensity(h.intensity);
      } else {
        final hotspot = RhizosphereHotspotComponent(
          hotspotId: h.id,
          layerId: layerId,
          intensity: h.intensity,
          type: h.type,
          position: Vector2(
            SceneCoordinateMapper.mapRootX(h.x, size.x),
            h.z * size.y,
          ),
          radius: h.radius,
        );
        add(hotspot);
        _rhizosphere[h.id] = hotspot;
      }
    }

    // Remove defunct hotspots
    _rhizosphere.removeWhere((id, component) {
      if (activeHotspotIds.contains(id)) return false;
      component.removeFromParent();
      return true;
    });
  }

  /// Box-Muller transform for Gaussian distribution
  double _nextGaussian(math.Random rand, double mean, double stdDev) {
    final u1 = rand.nextDouble();
    final u2 = rand.nextDouble();
    final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return z0 * stdDev + mean;
  }

  double _nitrificationAccumulator = 0;
  double _labelCooldown = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _syncVisualLayer(dt);
    _labelCooldown = math.max(0.0, _labelCooldown - dt);
    if (!(game.simulationState?.isRunning ?? false)) return;

    final state = game.displayedState;
    final process = game.scenarioProcessProfile;
    try {
      final layer = state.profile.layers.firstWhere((l) => l.id == layerId);

      // 1. Read Nitrification Flux (NH4 -> NO3) from Isolate
      final double nitRate = layer.nitrificationRate;
      final double nNitrified = layer.ammoniumContent * nitRate; // mg/kg/s

      final double redoxOpacity = layer.redoxPotential < 200 ? 0.1 : 1.0;
      // Aerobic nitrogen scenarios get a denser visual signal, while a
      // compacted or anaerobic layer stays visually quiet.
      final double scenarioBoost = 0.8 + 0.8 * process.nitrification;

      _nitrificationAccumulator +=
          nNitrified *
          SimulationConstants.nitrificationVisualDensity *
          dt *
          scenarioBoost;
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
            speed:
                SimulationConstants.particleBaseSpeed +
                (nitRate * SimulationConstants.fluxToSpeedScale).clamp(
                  5.0,
                  50.0,
                ),
          );

          // Occasional process notification; the scenario's nitrogen signal
          // makes the label appear often enough to read before it fades.
          if (_labelCooldown <= 0 &&
              _eventRandom.nextDouble() <
                  0.003 + 0.01 * process.nitrification) {
            _labelCooldown = 3.0;
            game.world.add(
              ProcessLabel(
                type: ProcessMarkerType.nitrification,
                color: CPKStandards.colorN,
                position: Vector2(
                  position.x + _eventRandom.nextDouble() * size.x,
                  position.y + _eventRandom.nextDouble() * size.y,
                ),
                showTitle: true,
              ),
            );
          }
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

    final rand = _eventRandom;
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
