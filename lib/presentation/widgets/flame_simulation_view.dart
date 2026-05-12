import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game/soil_scope_game.dart';
import '../providers/game_provider.dart';

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
    _game = SoilScopeGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[FlameSimulationView] PostFrameCallback: Registering game in soilScopeGameProviderProvider');
      ref.read(soilScopeGameProviderProvider.notifier).setGame(_game);
      debugPrint('[FlameSimulationView] PostFrameCallback: Calling onGameReady');
      widget.onGameReady?.call(_game);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[FlameSimulationView] build: Returning GameWidget');
    return GameWidget(game: _game);
  }
}
