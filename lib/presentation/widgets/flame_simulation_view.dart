import 'package:flame_riverpod/flame_riverpod.dart';
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
  final _gameKey = GlobalKey<RiverpodAwareGameWidgetState<SoilScopeGame>>();

  @override
  void initState() {
    super.initState();
    _game = SoilScopeGame();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soilScopeGameProviderProvider.notifier).setGame(_game);
      widget.onGameReady?.call(_game);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RiverpodAwareGameWidget(key: _gameKey, game: _game);
  }
}
