import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/debug_log.dart';
import 'game/soil_scope_game.dart';
import '../providers/game_provider.dart';
import '../providers/game_provider_reader.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import '../providers/locale_provider.dart';
import '../../domain/models/biophysical_state.dart';
import '../../l10n/app_localizations.dart';

class FlameSimulationView extends ConsumerStatefulWidget {
  final ValueChanged<SoilScopeGame>? onGameReady;

  const FlameSimulationView({super.key, this.onGameReady});

  @override
  ConsumerState<FlameSimulationView> createState() =>
      _FlameSimulationViewState();
}

class _FlameSimulationViewState extends ConsumerState<FlameSimulationView> {
  late SoilScopeGame _game;
  final FocusNode _canvasFocusNode = FocusNode(debugLabel: 'Simulation canvas');
  // Flame's GameWidget installs its own focus node and autofocuses it. Keep
  // that node out of the Tab order so canvas shortcuts and HUD traversal share
  // one deterministic focus path.
  final FocusNode _gameWidgetFocusNode = FocusNode(
    debugLabel: 'Flame input surface',
    skipTraversal: true,
  );
  final ValueNotifier<String?> _focusedTargetLabel = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    debugLog('[FlameSimulationView] initState: Creating SoilScopeGame');
    _game = SoilScopeGame(GameProviderReader.fromRef(ref));

    // Auto-register the game instance when it's created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugLog(
        '[FlameSimulationView] PostFrameCallback: Registering game in provider',
      );
      ref.read(soilScopeGameProviderProvider.notifier).setGame(_game);
      debugLog('[FlameSimulationView] PostFrameCallback: Calling onGameReady');
      widget.onGameReady?.call(_game);
    });
  }

  @override
  void dispose() {
    _canvasFocusNode.dispose();
    _gameWidgetFocusNode.dispose();
    _focusedTargetLabel.dispose();
    super.dispose();
  }

  void _syncKeyboardTargetSemantics() {
    _focusedTargetLabel.value = _game.keyboardTargetLabel;
  }

  KeyEventResult _handleCanvasKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;

    const panStep = 80.0;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      _game.panCameraBy(Vector2(-panStep, 0));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      _game.panCameraBy(Vector2(panStep, 0));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _game.panCameraBy(Vector2(0, -panStep));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _game.panCameraBy(Vector2(0, panStep));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.equal ||
        key == LogicalKeyboardKey.numpadAdd) {
      _game.zoomCameraBy(1.15);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.minus ||
        key == LogicalKeyboardKey.numpadSubtract) {
      _game.zoomCameraBy(1 / 1.15);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) {
      _game.resetCamera();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.bracketLeft) {
      _game.focusNextInspectable(reverse: true);
      _syncKeyboardTargetSemantics();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.bracketRight) {
      _game.focusNextInspectable();
      _syncKeyboardTargetSemantics();
      return KeyEventResult.handled;
    }
    if (event is KeyRepeatEvent) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _game.activateKeyboardTarget();
      _syncKeyboardTargetSemantics();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _game.clearKeyboardTarget();
      _syncKeyboardTargetSemantics();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    debugLog('[FlameSimulationView] build: Registering listeners');

    // The provider is auto-disposed. Keep a listener alive for the lifetime of
    // this view so controls can always retrieve the mounted game instance.
    ref.watch(soilScopeGameProviderProvider);

    // Reactively update the game from Riverpod
    ref.listen(appLocalizationsProvider, (previous, next) {
      _game.updateL10n(next);
    });

    ref.listen(
      simulationSessionProvider.select(
        (s) => (s.selectedLayerId, s.selectedInspectorType),
      ),
      (previous, next) {
        final state = ref.read(displayedSimulationStateProvider);
        final session = ref.read(simulationSessionProvider);
        _game.updateSession(state, session);
      },
    );

    ref.listen<bool>(simulationProvider.select((s) => s.isRunning), (
      previous,
      next,
    ) {
      final state = ref.read(displayedSimulationStateProvider);
      _game.updateIsRunning(next, state);
    });

    ref.listen<BiophysicalState>(displayedSimulationStateProvider, (
      previous,
      next,
    ) {
      _game.updateBiophysicalState(next);
    });

    ref.listen<double>(simulationProvider.select((s) => s.timeScale), (
      previous,
      next,
    ) {
      final state = ref.read(displayedSimulationStateProvider);
      _game.updateTimeScale(next, state);
    });

    ref.listen(
      displayedSimulationStateProvider.select(
        (s) => (s.profile.layers.length, s.plants.length),
      ),
      (previous, next) {
        final state = ref.read(displayedSimulationStateProvider);
        final session = ref.read(simulationSessionProvider);
        _game.updateSession(state, session);
      },
    );

    _game.setReducedMotion(MediaQuery.of(context).disableAnimations);

    debugLog('[FlameSimulationView] build: Returning GameWidget');

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      color: const Color(0xFF1A1A1A),
      child: LayoutBuilder(
        builder: (context, constraints) {
          debugLog(
            '[FlameSimulationView] Layout constraints: ${constraints.maxWidth}x${constraints.maxHeight}',
          );
          return Semantics(
            container: true,
            focusable: true,
            label: l10n?.tutorialCanvasTitle ?? 'Simulation Canvas',
            hint:
                l10n?.canvasKeyboardHint ??
                'Arrow keys pan. Plus and minus zoom. Use [ and ] to choose a '
                    'target, Enter or Space to inspect it, and 0 to reset.',
            child: Focus(
              key: const ValueKey('simulation-canvas-focus'),
              focusNode: _canvasFocusNode,
              // Flame wraps its painting surface in a FocusScope. The canvas
              // owns keyboard input here, so keep that inner scope out of
              // traversal and let Tab move directly to the HUD.
              descendantsAreFocusable: false,
              onKeyEvent: _handleCanvasKey,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _canvasFocusNode.requestFocus(),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    GameWidget(
                      key: const ValueKey('soil_scope_game_main'),
                      game: _game,
                      focusNode: _gameWidgetFocusNode,
                      autofocus: false,
                      loadingBuilder: (context) {
                        debugLog(
                          '[FlameSimulationView] GameWidget is LOADING...',
                        );
                        final loadingL10n = AppLocalizations.of(context);
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                '${loadingL10n?.loadingSimulation ?? 'Ladataan simulaatiota...'} (${constraints.maxWidth.toInt()}x${constraints.maxHeight.toInt()})',
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _canvasFocusNode,
                          builder: (context, child) {
                            if (!_canvasFocusNode.hasFocus) {
                              return const SizedBox.shrink();
                            }
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: _focusedTargetLabel,
                      builder: (context, target, child) {
                        if (target == null) return const SizedBox.shrink();
                        return Semantics(
                          key: const ValueKey('keyboard-target-semantics'),
                          container: true,
                          liveRegion: true,
                          label:
                              l10n?.canvasTargetFocused(target) ??
                              'Focused target: $target',
                          child: const SizedBox(width: 1, height: 1),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
