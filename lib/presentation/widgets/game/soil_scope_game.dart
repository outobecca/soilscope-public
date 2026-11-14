import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/events.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Image, PointerMoveEvent;
import '../../../core/debug_log.dart';
import '../../providers/simulation_provider.dart';
import '../../providers/simulation_session_provider.dart';
import '../../../domain/models/biophysical_state.dart';
import '../../../domain/models/scenario_process_profile.dart';
import '../../providers/locale_provider.dart';
import '../../providers/ui_state_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'components/soil_layer_component.dart';
import 'components/soil_background_layer.dart';
import 'components/background_noise_component.dart';
import 'components/simulation_animation_layer_component.dart';
import 'components/animated_plant_component.dart';
import 'components/weather_component.dart';
import 'components/scene_coordinate_mapper.dart';
import 'components/magnifier_group_component.dart';
import 'components/molecule_particle_pool.dart';
import 'components/sky_background_component.dart';
import 'components/soil_symbiosis_network_component.dart';
import 'components/animation_clock.dart';
import 'components/visual_state_interpolator.dart';

/// Main Flame game for SoilScope simulation visualization.
/// Enforces a unified central simulation column for sky and soil.
class SoilScopeGame extends FlameGame
    with ScrollDetector, ScaleDetector, HasCollisionDetection {
  final WidgetRef ref;

  SoilScopeGame(this.ref) {
    debugLog('[SoilScopeGame] Constructor called');
    technicalHotspotLayer = Component()..priority = 2500;
  }

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
  BiophysicalState? _lastAnimationState;
  final VisualStateInterpolator _visualState = VisualStateInterpolator(
    transitionSeconds: 0.2,
  );
  ScenarioProcessProfile _scenarioProcessProfile = ScenarioProcessProfile.empty;
  List<Vector2> _rootTipWorldPositions = const [];
  List<Vector2> _foliageWorldPositions = const [];
  final AnimationClock _animationClock = AnimationClock();
  BiophysicalState? _pendingSceneState;
  SimulationSessionState? _pendingSceneSession;
  BiophysicalState? _pendingAnimationState;
  double _startZoom = 1.0;
  bool _inspectionPaused = false;

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

    // Coalesce scene rebuilds requested by multiple provider listeners into a
    // single topology update for this frame. This prevents layer/plant nodes
    // from being removed and recreated more than once per state tick.
    final pendingSceneState = _pendingSceneState;
    final pendingSceneSession = _pendingSceneSession;
    _pendingSceneState = null;
    _pendingSceneSession = null;
    if (pendingSceneState != null && pendingSceneSession != null) {
      _updateScene(pendingSceneState, pendingSceneSession);
    }

    // Selecting an element for its info is an inspection mode: freeze the
    // canvas animation while leaving the simulation isolate and Flutter HUD
    // responsive. The next frame after the card is dismissed resumes normally.
    final wasInspectionPaused = _inspectionPaused;
    _inspectionPaused = _readInspectionPaused();
    if (wasInspectionPaused && !_inspectionPaused) {
      final pending = _pendingAnimationState;
      _pendingAnimationState = null;
      if (pending != null) _applyAnimationState(pending);
    }
    final isRunning = simulationState?.isRunning ?? false;
    _animationClock.tick(
      dt,
      isRunning: isRunning,
      isScrubbing: _readIsScrubbing(),
      inspectionPaused: _inspectionPaused,
    );
    final frameDt = _animationClock.frameDt;

    if (!_inspectionPaused) {
      _visualState.advance(frameDt);
      super.update(frameDt);
    } else {
      // Magnifiers live in the viewport, outside the simulation world. Keep
      // their fade/position updates running so selecting a microscope target
      // can actually reveal the microscope while the world itself is frozen.
      final magnifierGroup = camera.viewport.children
          .query<MagnifierGroupComponent>()
          .firstOrNull;
      magnifierGroup?.updateForInspectionPause(frameDt);
    }
    if (isRunning && !_inspectionPaused) {
      _updateMassFlow(frameDt);
    }
  }

  /// Whether the canvas is frozen so the selected info can be inspected.
  bool get isInspectionPaused => _inspectionPaused;

  bool _readInspectionPaused() {
    try {
      return ref.read(inspectionPausedProvider);
    } catch (_) {
      return false;
    }
  }

  bool _readIsScrubbing() {
    try {
      return ref.read(simulationSessionProvider).isScrubbing;
    } catch (_) {
      return false;
    }
  }

  Vector2 worldToScreen(Vector2 worldPos) {
    final zoom = camera.viewfinder.zoom;
    final camPos = camera.viewfinder.position;
    final viewportSize = camera.viewport.size;
    return Vector2(
      (worldPos.x - camPos.x) * zoom + viewportSize.x / 2,
      (worldPos.y - camPos.y) * zoom + viewportSize.y / 2,
    );
  }

  double _massFlowAccumulator = 0;

  void _updateMassFlow(double dt) {
    _massFlowAccumulator += dt;
    // Subtract the interval instead of resetting to zero so a 2.1 s frame
    // does not silently stretch the sync period.
    while (_massFlowAccumulator >= 2.0) {
      _massFlowAccumulator -= 2.0;
      final layers = world.children.query<SoilLayerComponent>();
      for (final layer in layers) {
        layer.triggerSubComponentSync();
      }
    }
  }

  @override
  double currentTime() => _animationClock.visualElapsed;

  double uiTime() => _animationClock.uiElapsed;

  AnimationClock get animationClock => _animationClock;

  AnimationMode get animationMode => _animationClock.mode;

  BiophysicalState? get simulationState {
    if (_visualState.value != null) return _visualState.value;
    if (_lastState != null) return _lastState;
    try {
      return ref.read(displayedSimulationStateProvider);
    } catch (_) {
      return null;
    }
  }

  /// State the canvas should draw. It is interpolated between engine snapshots
  /// so the 5 Hz simulation does not visibly step at 60 fps. The HUD keeps
  /// using the provider's exact snapshot.
  BiophysicalState get displayedState =>
      _visualState.value ??
      _lastState ??
      ref.read(displayedSimulationStateProvider);

  /// Scenario-derived emphasis used by process animations and soil texture.
  ScenarioProcessProfile get scenarioProcessProfile => _scenarioProcessProfile;

  List<Vector2> get rootTipWorldPositions => _rootTipWorldPositions;
  List<Vector2> get foliageWorldPositions => _foliageWorldPositions;

  @override
  Future<void> onLoad() async {
    debugLog('[SoilScopeGame] onLoad started');
    await super.onLoad();
    try {
      debugLog('[SoilScopeGame] onLoad: attempting to read l10n');
      l10n = ref.read(appLocalizationsProvider);
      debugLog('[SoilScopeGame] l10n loaded successfully');
    } catch (e) {
      debugLog('[SoilScopeGame] l10n loading failed: $e, using fallback');
      try {
        l10n = lookupAppLocalizations(const Locale('en'));
      } catch (e2) {
        debugLog('L10n fallback failed: $e2');
      }
    }

    // Initial Camera: Center on the middle of the whole continuum to fit sky and soil
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(logicalSize.x / 2, logicalSize.y / 2);
    camera.viewfinder.zoom = 1.0;

    // 0. Absolute Backgrounds (Screen Space, pinned to game.size)
    debugLog('[SoilScopeGame] Adding static backgrounds');
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
    debugLog('[SoilScopeGame] Adding SimulationAnimationLayerComponent');
    world.add(SimulationAnimationLayerComponent()..priority = 200);

    // Soil Symbiosis Network (Between passive hotspots/layers and active particles/roots)
    world.add(SoilSymbiosisNetworkComponent()..priority = 2000);

    // TECHNICAL OVERLAY (Always on top of world components)
    world.add(technicalHotspotLayer);

    // Background tap fallback for deselecting layers/inspectors
    world.add(BackgroundTapComponent()..priority = -50);

    camera.viewport.add(MagnifierGroupComponent());
    debugLog('[SoilScopeGame] onLoad finished');
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final zoomDelta = -info.scrollDelta.global.y / 500.0;
    final oldZoom = camera.viewfinder.zoom;
    final minZoom = logicalSize.x / size.x;
    final newZoom = (oldZoom + zoomDelta)
        .clamp(math.min(0.8, minZoom), 10.0)
        .toDouble();

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
    final newZoom = (_startZoom * scaleFactor).clamp(0.8, 10.0).toDouble();

    if (newZoom != oldZoom) {
      // Use the raw Flutter focalPoint for maximum compatibility
      final focalPoint = info.raw.focalPoint;
      final cursorPosition = Vector2(focalPoint.dx, focalPoint.dy);
      final worldCursorBefore = camera.globalToLocal(cursorPosition);

      camera.viewfinder.zoom = newZoom;

      final worldCursorAfter = camera.globalToLocal(cursorPosition);
      camera.viewfinder.position += (worldCursorBefore - worldCursorAfter);
    }

    // Allow panning regardless of zoom level to enable mobile exploration of edges
    camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
    _clampCamera();
  }

  void resetCamera() {
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
    final maxY =
        soilBottom -
        (logicalSize.y / 2 - panelHeight - 20) / camera.viewfinder.zoom;

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

  /// External reactive updates from UI/Riverpod
  void updateL10n(AppLocalizations next) {
    if (next != l10n) {
      _syncActionBuffer.add(() => l10n = next);
    }
  }

  void updateSession(BiophysicalState state, SimulationSessionState session) {
    _syncActionBuffer.add(() {
      _lastState = state;
      // Scrubbing is direct manipulation: the soil should follow the thumb
      // immediately instead of lagging one transition behind it.
      _visualState.setTarget(state, immediate: _readIsScrubbing());
      _pendingSceneState = state;
      _pendingSceneSession = session;
    });
  }

  void updateIsRunning(bool isRunning, BiophysicalState state) {
    _syncActionBuffer.add(() {
      _lastState = state;
      _visualState.setTarget(state, immediate: _readIsScrubbing());
      _scenarioProcessProfile = ScenarioProcessProfile.fromState(state);
    });
  }

  void updateBiophysicalState(BiophysicalState next) {
    _syncActionBuffer.add(() {
      _lastState = next;
      _visualState.setTarget(next, immediate: _readIsScrubbing());
      _scenarioProcessProfile = ScenarioProcessProfile.fromState(next);
      _applyAnimationState(next);
    });
  }

  void updateTimeScale(double timeScale, BiophysicalState state) {
    _syncActionBuffer.add(() {
      _lastState = state;
      _visualState.setTarget(state, immediate: _readIsScrubbing());
      _scenarioProcessProfile = ScenarioProcessProfile.fromState(state);
    });
  }

  @override
  void onMount() {
    debugLog('[SoilScopeGame] onMount started');
    super.onMount();

    try {
      final initialState = ref.read(displayedSimulationStateProvider);
      final session = ref.read(simulationSessionProvider);
      debugLog('[SoilScopeGame] onMount: performing initial _updateScene');
      _visualState.reset(initialState);
      _updateScene(initialState, session);
      _lastState = initialState;
    } catch (e) {
      debugLog('Error reading initial state in onMount: $e');
    }
    _clampCamera();
    debugLog('[SoilScopeGame] onMount finished');
  }

  @override
  void onRemove() {
    debugLog('[SoilScopeGame] onRemove');
    _animationClock.reset();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    debugLog('[SoilScopeGame] onGameResize: ${size.x}x${size.y}');
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

  /// Applies the animation-layer part of a state update once per distinct
  /// snapshot. The scene update and the displayed-state listener can both
  /// arrive for the same tick; without this guard every state would rebuild
  /// flux indicators and inspection targets twice.
  void _applyAnimationState(BiophysicalState state) {
    // Do not consume the dedupe slot while the canvas is frozen. Keep only
    // the latest snapshot and apply it on the first resumed frame; otherwise a
    // state update that arrives while an inspection card is open is lost.
    if (_inspectionPaused) {
      _pendingAnimationState = state;
      return;
    }
    _pendingAnimationState = null;
    if (identical(_lastAnimationState, state)) return;
    _lastAnimationState = state;
    final animLayer = world.children
        .query<SimulationAnimationLayerComponent>()
        .firstOrNull;
    animLayer?.updateState(state);
  }

  void _updateScene(BiophysicalState state, SimulationSessionState session) {
    _scenarioProcessProfile = ScenarioProcessProfile.fromState(state);
    final currentLayers = world.children.query<SoilLayerComponent>();
    final Map<String, SoilLayerComponent> layerMap = {
      for (var l in currentLayers) l.layerId: l,
    };

    final double soilAreaY = soilSurfaceY;
    final double soilAreaHeight = soilColumnHeight;
    final double soilX = soilLeftX;
    final double soilColumnWidth_ = simulationWidth;

    // Include all active soil layers in profile
    final activeLayers = state.profile.layers;
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
    _applyAnimationState(state);

    // 3. Update Magnifiers (Handled by component update, no explicit call needed here)

    final List<Vector2> tips = [];
    final List<Vector2> foliage = [];

    for (final plant in state.plants) {
      for (final n in plant.rootSystem) {
        if (n.isTip) {
          tips.add(
            Vector2(
              SceneCoordinateMapper.mapRootX(
                    n.x,
                    simulationWidth,
                    baseX: plant.baseX,
                  ) +
                  soilX,
              SceneCoordinateMapper.mapRootY(n.z, soilSurfaceY, soilAreaHeight),
            ),
          );
        }
      }

      // Foliage points (approximate canopy centers)
      final shootPos = SceneCoordinateMapper.mapShootPosition(
        plant.baseX,
        simulationWidth,
        soilSurfaceY,
      );
      final visualHeight = SceneCoordinateMapper.plantVisualHeight(plant);
      foliage.add(
        Vector2(shootPos.x + soilX, soilSurfaceY - visualHeight * 0.6),
      );
    }

    _rootTipWorldPositions = tips;
    _foliageWorldPositions = foliage;
  }

  void triggerFertilizerEffect(Map<String, Color> colors) {}

  void triggerPlantGrowth() {
    final animLayer = world.children
        .query<SimulationAnimationLayerComponent>()
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
class BackgroundTapComponent extends Component
    with HasGameReference<SoilScopeGame>, TapCallbacks {
  @override
  void onTapUp(TapUpEvent event) {
    // This component is the fallback for taps not caught by an interactive
    // layer, hotspot or entity. Clear both the visual selection and the info
    // card no matter where the empty tap landed (mouse or touch).
    game.ref.read(simulationSessionProvider.notifier).selectLayer(null);
    game.ref.read(simulationSessionProvider.notifier).selectInspector(null);
    game.ref.read(uIStateProvider.notifier).setHoverInfo(null);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true; // Cover everything
}
