import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game/soil_scope_game.dart';
import '../providers/game_provider.dart';
import '../providers/simulation_provider.dart';
import '../providers/simulation_session_provider.dart';
import '../providers/locale_provider.dart';
import '../../domain/models/biophysical_state.dart';

class FlameSimulationView extends ConsumerStatefulWidget {
  final ValueChanged<SoilScopeGame>? onGameReady;

  const FlameSimulationView({super.key, this.onGameReady});

  @override
  ConsumerState<FlameSimulationView> createState() =>
      _FlameSimulationViewState();
}

class _FlameSimulationViewState extends ConsumerState<FlameSimulationView> {
  late SoilScopeGame _game;

  @override
  void initState() {
    super.initState();
    debugPrint('[FlameSimulationView] initState: Creating SoilScopeGame');
    _game = SoilScopeGame(ref);
    
    // Auto-register the game instance when it's created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[FlameSimulationView] PostFrameCallback: Registering game in provider');
      ref.read(soilScopeGameProviderProvider.notifier).setGame(_game);
      debugPrint('[FlameSimulationView] PostFrameCallback: Calling onGameReady');
      widget.onGameReady?.call(_game);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[FlameSimulationView] build: Registering listeners');

    // Reactively update the game from Riverpod
    ref.listen(appLocalizationsProvider, (previous, next) {
      _game.updateL10n(next);
    });

    ref.listen(simulationSessionProvider.select((s) => (
      s.selectedLayerId,
      s.selectedInspectorType,
    )), (previous, next) {
      final state = ref.read(displayedSimulationStateProvider);
      final session = ref.read(simulationSessionProvider);
      _game.updateSession(state, session);
    });

    ref.listen<bool>(
      simulationProvider.select((s) => s.isRunning),
      (previous, next) {
        final state = ref.read(displayedSimulationStateProvider);
        _game.updateIsRunning(next, state);
      },
    );

    ref.listen<BiophysicalState>(
      displayedSimulationStateProvider,
      (previous, next) {
        _game.updateBiophysicalState(next);
      },
    );

    ref.listen<double>(
      simulationProvider.select((s) => s.timeScale),
      (previous, next) {
        final state = ref.read(displayedSimulationStateProvider);
        _game.updateTimeScale(next, state);
      },
    );

    ref.listen(
      displayedSimulationStateProvider.select((s) => (
        s.profile.layers.length,
        s.plants.length,
      )),
      (previous, next) {
        final state = ref.read(displayedSimulationStateProvider);
        final session = ref.read(simulationSessionProvider);
        _game.updateSession(state, session);
      },
    );

    debugPrint('[FlameSimulationView] build: Returning GameWidget');

    return Container(
      color: const Color(0xFF1A1A1A), 
      child: LayoutBuilder(
        builder: (context, constraints) {
          debugPrint('[FlameSimulationView] Layout constraints: ${constraints.maxWidth}x${constraints.maxHeight}');
          return GameWidget(
            key: const ValueKey('soil_scope_game_main'),
            game: _game,
            loadingBuilder: (context) {
              debugPrint('[FlameSimulationView] GameWidget is LOADING...');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Ladataan simulaatiota... (${constraints.maxWidth.toInt()}x${constraints.maxHeight.toInt()})',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
