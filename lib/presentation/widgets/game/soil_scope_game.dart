import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Image, PointerMoveEvent;
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import '../../../domain/models/biophysical_state.dart';
import '../../providers/locale_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'components/soil_layer_component.dart';
import 'components/soil_background_layer.dart';
import 'components/background_noise_component.dart';
import 'components/animation_layer.dart';
import 'components/animated_plant_component.dart';
import 'components/weather_component.dart';
import 'components/scene_coordinate_mapper.dart';
import 'components/magnifier_group_component.dart';
import 'components/molecule_particle_pool.dart';
import 'components/sky_background_component.dart';
import 'components/soil_symbiosis_network_component.dart';

/// Main Flame game for SoilScope simulation visualization.
/// Enforces a unified central simulation column for sky and soil.
class SoilScopeGame extends FlameGame
    with
        RiverpodGameMixin,
        ScrollDetector,
        ScaleDetector,
        HasCollisionDetection {
  /// Reference logical size for coordinate calculations.
  static final Vector2 logicalSize = Vector2(1200, 900);

  /// Width of the interactive simulation column.
  static const double simulationWidth = 1200.0;

  static double get soilColumnWidth => simulationWidth;

  /// Unified width for the visual background coverage (Sky + Soil).
  static const double visualColumnWidth = 16000.0;

  /// Simulation surface position.
  /// Increased to 0.7 to give more room for the atmosphere/plant.
  static const double atmosphereFraction = 0.7;

  BiophysicalState? _lastState;
  List<Vector2> _rootTipWorldPositions = const [];
  List<Vector2> _foliageWorldPositions = const [];
  double _elapsed = 0;
  double _startZoom = 1.0;

  late AppLocalizations l10n;

  // Layout Getters
  double get soilSurfaceY => logicalSize.y * atmosphereFraction;
  double get soilLeftX => (logicalSize.x - simulationWidth) / 2;

  /// The soil column fills the remaining space below the atmosphere.
  double get soilColumnHeight => logicalSize.y - soilSurfaceY;

  /// Sum of thicknesses of the currently rendered active layers.
  double get activeProfileThickness {
    final state = simulationState;
    if (state == null || state.profile.layers.isEmpty) return 1.0;
    // We take top 3 layers for the visual column
    final activeLayers = state.profile.layers.take(3);
    return activeLayers.fold(0.0, (sum, l) => sum + l.thickness);
  }

  late final Component technicalHotspotLayer;
  MoleculeParticlePool? moleculePool;

  @override
  void update(double dt) {
    // Process sync buffer before simulation update
    if (_syncActionBuffer.isNotEmpty) {
      final actions = List<void Function()>.from(_syncActionBuffer);
      _syncActionBuffer.clear();
      for (final action in actions) {
        action();
      }
    }

    super.update(dt);
    if (simulationState?.isRunning ?? false) {
      _elapsed += dt;
      _updateMassFlow(dt);
    }
  }

  double _massFlowAccumulator = 0;

  void _updateMassFlow(double dt) {
    _massFlowAccumulator += dt;
    if (_massFlowAccumulator > 2.0) { // Every 2 seconds
      _massFlowAccumulator = 0;
      final layers = world.children.query<SoilLayerComponent>();
      for (final layer in layers) {
        layer.triggerSubComponentSync();
      }
    }
  }

  @override
  double currentTime() => _elapsed;

  BiophysicalState? get simulationState {
    if (_lastState != null) return _lastState;
    try {
      return ref.read(displayedSimulationStateProvider);
    } catch (_) {
      return null;
    }
  }

  List<Vector2> get rootTipWorldPositions => _rootTipWorldPositions;
  List<Vector2> get foliageWorldPositions => _foliageWorldPositions;



  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      l10n = ref.read(appLocalizationsProvider);
    } catch (_) {
      try {
        l10n = lookupAppLocalizations(const Locale('en'));
      } catch (e) {
        // Ultimate fallback if l10n is not working
        debugPrint('L10n fallback failed: $e');
      }
    }

    // Initial Camera: Center on the middle of the whole continuum to fit sky and soil
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(logicalSize.x / 2, logicalSize.y / 2);
    camera.viewfinder.zoom = 1.0;

    // 0. Absolute Backgrounds (Screen Space, pinned to game.size)
    add(SkyBackgroundComponent());
    add(SoilBasementComponent());

    // 1. Viewport HUD (Stays fixed)
    camera.viewport.add(BackgroundNoiseComponent()..priority = -100);
    
    // Large background sky/soil coverage (Vast width to prevent black edges)
    world.add(
      WeatherComponent(
        size: Vector2(visualColumnWidth, soilSurfaceY), 
        position: Vector2(-visualColumnWidth / 2 + logicalSize.x / 2, 0),
      )..priority = -100,
    );

    world.add(SoilBackgroundLayer()..priority = -200);
    
    // The main simulation layers
    world.add(SimulationAnimationLayer()..priority = 200);

    // Soil Symbiosis Network (Between passive hotspots/layers and active particles/roots)
    world.add(SoilSymbiosisNetworkComponent()..priority = 2000);

    // TECHNICAL OVERLAY (Always on top of world components)
    technicalHotspotLayer = Component()..priority = 2500;
    world.add(technicalHotspotLayer);

    camera.viewport.add(MagnifierGroupComponent());
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final zoomDelta = -info.scrollDelta.global.y / 500.0;
    final oldZoom = camera.viewfinder.zoom;
    final minZoom = logicalSize.x / size.x;
    final newZoom = (oldZoom + zoomDelta).clamp(math.min(0.8, minZoom), 4.0).toDouble();

    // Zoom towards cursor
    final cursorPosition = info.eventPosition.global;
    final worldCursorBefore = camera.globalToLocal(cursorPosition);

    camera.viewfinder.zoom = newZoom;

    final worldCursorAfter = camera.globalToLocal(cursorPosition);
    camera.viewfinder.position += (worldCursorBefore - worldCursorAfter);

    _clampCamera();
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final double scaleFactor = info.scale.global.y;
    final oldZoom = camera.viewfinder.zoom;
    final newZoom = (_startZoom * scaleFactor).clamp(0.8, 4.0).toDouble();

    if (newZoom != oldZoom) {
      // Use the raw Flutter focalPoint for maximum compatibility
      final focalPoint = info.raw.focalPoint;
      final cursorPosition = Vector2(focalPoint.dx, focalPoint.dy);
      final worldCursorBefore = camera.globalToLocal(cursorPosition);

      camera.viewfinder.zoom = newZoom;

      final worldCursorAfter = camera.globalToLocal(cursorPosition);
      camera.viewfinder.position += (worldCursorBefore - worldCursorAfter);
    }

    if (camera.viewfinder.zoom > 1.0) {
      camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
      _clampCamera();
    } else {
      _resetCamera();
    }
  }

  void _resetCamera() {
    camera.viewfinder.position = Vector2(logicalSize.x / 2, soilSurfaceY);
    camera.viewfinder.zoom = 1.35;
    _clampCamera();
  }

  void _clampCamera() {
    if (camera.viewfinder.zoom <= 0.05) {
      camera.viewfinder.zoom = 1.35;
    }
    final halfView = (logicalSize / 2) / camera.viewfinder.zoom;
    final minX = halfView.x - 100;
    final maxX = logicalSize.x - halfView.x + 100;
    
    bool hasMicroscope = false;
    try {
      hasMicroscope = ref.read(simulationSessionProvider).isMicroscopeEnabled;
    } catch (_) {
      // Safe default until initialized
    }
    final panelHeight = hasMicroscope ? 160.0 : 110.0;
    final soilBottom = soilSurfaceY + soilColumnHeight;

    final minY = halfView.y - 100;
    // New maxY formula to prevent soil from being under the panel
    final maxY = soilBottom - (logicalSize.y / 2 - panelHeight - 20) / camera.viewfinder.zoom;

    if (minX <= maxX) {
      camera.viewfinder.position.x = camera.viewfinder.position.x.clamp(
        minX,
        maxX,
      );
    } else {
      camera.viewfinder.position.x = logicalSize.x / 2;
    }

    if (minY <= maxY) {
      camera.viewfinder.position.y = camera.viewfinder.position.y.clamp(
        minY,
        maxY,
      );
    } else {
      // Anchor soil bottom above the panel
      camera.viewfinder.position.y = maxY;
    }
  }

  final List<void Function()> _syncActionBuffer = [];
  final List<ProviderSubscription> _riverpodSubscriptions = [];


  @override
  void onMount() {
    super.onMount();
    
    // Explicitly manage Riverpod subscriptions in the game lifecycle
    if (buildContext != null) {
      final container = ProviderScope.containerOf(buildContext!);
      
      _riverpodSubscriptions.add(
        container.listen(appLocalizationsProvider, (previous, next) {
          if (next != l10n) {
            _syncActionBuffer.add(() => l10n = next);
          }
        })
      );

      // Structural update: only re-layout when layers or plants are added/removed, or selection changes
      _riverpodSubscriptions.add(
        container.listen(
          simulationSessionProvider.select((s) => (
            s.selectedLayerId,
            s.selectedInspectorType,
          )),
          (previous, next) {
            final state = container.read(displayedSimulationStateProvider);
            final session = container.read(simulationSessionProvider);
            _syncActionBuffer.add(() {
              _updateScene(state, session);
              _lastState = state;
            });
          },
        )
      );

      // Listen to Simulation Running State
      _riverpodSubscriptions.add(
        container.listen<bool>(
          simulationProvider.select((s) => s.isRunning),
          (previous, next) {
            // Set paused directly on the game instance
            // This is critical because if paused is true, update() is not called
            // and the _syncActionBuffer would never be processed to unpause.
            paused = !next;
            
            _syncActionBuffer.add(() {
              // Force update _lastState to reflect isRunning change
              final state = container.read(displayedSimulationStateProvider);
              _lastState = state;
            });
          },
        )
      );

      // Listen to Time Scale
      _riverpodSubscriptions.add(
        container.listen<double>(
          simulationProvider.select((s) => s.timeScale),
          (previous, next) {
            _syncActionBuffer.add(() {
              final state = container.read(displayedSimulationStateProvider);
              _lastState = state;
            });
          },
        )
      );
      
      _riverpodSubscriptions.add(
        container.listen(
          displayedSimulationStateProvider.select((s) => (
            s.profile.layers.length,
            s.plants.length,
          )),
          (previous, next) {
            final state = container.read(displayedSimulationStateProvider);
            final session = container.read(simulationSessionProvider);
            _syncActionBuffer.add(() {
              _updateScene(state, session);
              _lastState = state;
            });
          },
        )
      );
    }

    try {
      final initialState = ref.read(displayedSimulationStateProvider);
      final session = ref.read(simulationSessionProvider);
      _updateScene(initialState, session);
      _lastState = initialState;
    } catch (e) {
      debugPrint('Error reading initial state in onMount: $e');
    }
    _clampCamera();
  }

  @override
  void onRemove() {
    for (final sub in _riverpodSubscriptions) {
      sub.close();
    }
    _riverpodSubscriptions.clear();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    // Ensure we always fill the width with the central column at minimum
    final fitZoom = size.x > 0 ? (size.x / logicalSize.x) : 1.35;
    if (camera.viewfinder.zoom < fitZoom) {
       camera.viewfinder.zoom = fitZoom;
    }
    if (camera.viewfinder.zoom <= 0.05) {
       camera.viewfinder.zoom = 1.35;
    }

    // Centering the simulation and clamping
    camera.viewfinder.position = Vector2(logicalSize.x / 2, soilSurfaceY);
    _clampCamera();

    if (_lastState != null) {
      final session = ref.read(simulationSessionProvider);
      _updateScene(_lastState!, session);
    }
  }

  void _updateScene(BiophysicalState state, SimulationSessionState session) {
    final currentLayers = world.children.query<SoilLayerComponent>();
    final Map<String, SoilLayerComponent> layerMap = {
      for (var l in currentLayers) l.layerId: l,
    };

    final double soilAreaY = soilSurfaceY;
    final double soilAreaHeight = soilColumnHeight;
    final double soilX = soilLeftX;
    final double soilColumnWidth_ = simulationWidth;

    // Focus on top 3 layers (most active)
    final activeLayers = state.profile.layers.take(3).toList();
    final activeIds = activeLayers.map((l) => l.id).toSet();

    for (var layerId in layerMap.keys.toList()) {
      if (!activeIds.contains(layerId)) {
        layerMap[layerId]?.removeFromParent();
        layerMap.remove(layerId);
      }
    }

    final double totalThickness = activeLayers.fold(
      0.0,
      (sum, l) => sum + l.thickness,
    );
    final double scaleY = soilAreaHeight / totalThickness;

    double currentY = soilAreaY;
    for (final layer in activeLayers) {
      final double layerHeight = layer.thickness * scaleY;
      final Rect layerRect = Rect.fromLTWH(
        soilX,
        currentY,
        soilColumnWidth_,
        layerHeight,
      );
      final bool isSelected = session.selectedLayerId == layer.id;

      final existing = layerMap[layer.id];
      final SoilLayerComponent layerComp;
      if (existing != null) {
        layerComp = existing;
      } else {
        layerComp = SoilLayerComponent(
          layerId: layer.id,
          initialLayer: layer,
          initialRect: layerRect,
          isSelected: isSelected,
        );
        world.add(layerComp);
      }
      
      layerComp.position = Vector2(layerRect.left, layerRect.top);
      layerComp.size = Vector2(layerRect.width, layerRect.height);

      currentY += layerHeight;
    }

    // 2. Update Animations
    final animLayer = world.children.query<SimulationAnimationLayer>().firstOrNull;
    if (animLayer != null) {
      animLayer.updateState(state);
    }

    // 3. Update Magnifiers (Handled by component update, no explicit call needed here)

    final List<Vector2> tips = [];
    final List<Vector2> foliage = [];

    for (final plant in state.plants) {
      for (final n in plant.rootSystem) {
        if (n.isTip) {
          tips.add(Vector2(
            SceneCoordinateMapper.mapRootX(n.x, simulationWidth, baseX: plant.baseX) + soilX,
            SceneCoordinateMapper.mapRootY(n.z, soilSurfaceY, soilAreaHeight),
          ));
        }
      }

      // Foliage points (approximate canopy centers)
      final shootPos = SceneCoordinateMapper.mapShootPosition(plant.baseX, simulationWidth, soilSurfaceY);
      final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
      foliage.add(Vector2(shootPos.x + soilX, soilSurfaceY - visualHeight * 0.6));
    }

    _rootTipWorldPositions = tips;
    _foliageWorldPositions = foliage;
  }

  void triggerFertilizerEffect(Map<String, Color> colors) {}

  void triggerPlantGrowth() {
    final animLayer = world.children
        .query<SimulationAnimationLayer>()
        .firstOrNull;
    if (animLayer != null) {
      final plants = animLayer.children.query<AnimatedPlantComponent>();
      for (final plant in plants) {
        plant.triggerGrowth();
      }
    }
  }

  @override
  Color backgroundColor() {
    try {
      final themeMode = ref.read(themeModeProvider);
      if (themeMode == ThemeMode.light) {
        return const Color(0xFFF1F5F9); // Slate 50 (Snowy)
      }
    } catch (_) {
      // Fallback for early render calls
    }
    return const Color(0xFF0B101E); // Deep Nordic Night
  }
}

/// A full-screen component that handles background taps to deselect layers.
/// By having a low priority and only handling taps not caught by others,
/// it prevents the flickering issue where a layer is selected and immediately deselected.
class BackgroundTapComponent extends Component with HasGameReference<SoilScopeGame>, TapCallbacks {
  @override
  void onTapUp(TapUpEvent event) {
    // Only deselect if we are NOT clicking on the soil column.
    // The soil layers themselves handle their own taps and set event.handled = true.
    // This component is the fallback.
    final localPos = event.localPosition;
    final isInsideSoil = localPos.x >= game.soilLeftX && 
                       localPos.x <= game.soilLeftX + SoilScopeGame.simulationWidth &&
                       localPos.y >= game.soilSurfaceY;

    if (!isInsideSoil) {
      game.ref.read(simulationSessionProvider.notifier).selectLayer(null);
      game.ref.read(simulationSessionProvider.notifier).selectInspector(null);
      game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => true; // Cover everything
}
