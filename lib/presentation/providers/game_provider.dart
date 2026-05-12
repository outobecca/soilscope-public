import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../widgets/game/soil_scope_game.dart';

part 'game_provider.g.dart';

@riverpod
class SoilScopeGameProvider extends _$SoilScopeGameProvider {
  @override
  SoilScopeGame? build() => null;

  void setGame(SoilScopeGame? game) {
    Future.microtask(() {
      state = game;
    });
  }
}
