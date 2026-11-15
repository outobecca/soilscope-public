import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/widgets/flame_simulation_view.dart';
import 'package:soilscope/presentation/widgets/game/soil_scope_game.dart';

void main() {
  Future<SoilScopeGame> pumpGame(
    WidgetTester tester, {
    ValueNotifier<bool>? visible,
  }) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: SizedBox.expand(
              child: visible == null
                  ? const FlameSimulationView()
                  : ValueListenableBuilder<bool>(
                      valueListenable: visible,
                      builder: (context, isVisible, child) =>
                          isVisible ? child! : const SizedBox.shrink(),
                      child: const FlameSimulationView(),
                    ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    final gameWidget = tester.widget<GameWidget>(
      find.byWidgetPredicate((widget) => widget is GameWidget),
    );
    return gameWidget.game as SoilScopeGame;
  }

  testWidgets('the mounted game remains available through the provider', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);
    final game = await pumpGame(tester, visible: visible);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(FlameSimulationView)),
      listen: false,
    );

    expect(
      container.read(soilScopeGameProviderProvider),
      same(game),
      reason: 'controls need the same live game instance as the canvas',
    );

    visible.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(
      container.read(soilScopeGameProviderProvider),
      isNull,
      reason: 'leaving the simulation route must release the game',
    );
  });

  testWidgets('fertilizer application adds a canvas effect', (tester) async {
    final game = await pumpGame(tester);
    final before = game.world.children.length;

    game.triggerFertilizerEffect({'N': Colors.green, 'P': Colors.orange});
    await tester.pump();

    expect(
      game.world.children.length,
      greaterThan(before),
      reason: 'applying fertilizer must produce a visible canvas response',
    );
  });
}
