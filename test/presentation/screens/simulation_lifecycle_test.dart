import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/services/simulation_persistence.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/game_provider.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';

class _SimulationHost extends StatelessWidget {
  const _SimulationHost({required this.visible, required this.child});

  final ValueNotifier<bool> visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (context, isVisible, child) =>
          isVisible ? child! : const SizedBox.shrink(),
      child: child,
    );
  }
}

Future<ProviderContainer> _pumpSimulation(
  WidgetTester tester,
  ValueNotifier<bool> visible,
) async {
  tester.view.physicalSize = const Size(1280, 720);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'gesture_intro_seen_v1': true});

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: _SimulationHost(
          visible: visible,
          child: const MainSimulationScreen(),
        ),
      ),
    ),
  );
  await tester.pump();

  final container = ProviderScope.containerOf(
    tester.element(find.byType(MainSimulationScreen)),
    listen: false,
  );
  await _pumpUntil(tester, () => container.read(simulationProvider).isRunning);
  return container;
}

Future<void> _pumpUntil(WidgetTester tester, bool Function() condition) async {
  for (var frame = 0; frame < 120; frame++) {
    // Isolate startup is real async work; fake-clock pumps alone can finish
    // before the runtime is ready.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
    if (condition()) return;
  }
  fail('the simulation did not reach the expected state');
}

void main() {
  testWidgets('backgrounding pauses the run and resuming continues it', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );

    final container = await _pumpSimulation(tester, visible);
    expect(container.read(simulationProvider).isRunning, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(
      container.read(simulationProvider).isRunning,
      isFalse,
      reason: 'a backgrounded simulation must not keep ticking',
    );
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.containsKey(SimulationPersistence.stateKey),
      isTrue,
      reason: 'pausing must persist the run before the app is suspended',
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(
      container.read(simulationProvider).isRunning,
      isTrue,
      reason: 'resuming the app should restart a run that was active',
    );
  });

  testWidgets('backgrounding a paused run saves without restarting it', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );

    final container = await _pumpSimulation(tester, visible);
    final notifier = container.read(simulationProvider.notifier);
    notifier.stop();
    await tester.pump();
    notifier.setSpeed(3.0);
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    final saved = await SimulationPersistence().load();
    expect(saved?.timeScale, 3.0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(
      container.read(simulationProvider).isRunning,
      isFalse,
      reason: 'a run paused by the user must stay paused after resuming',
    );
  });

  testWidgets('leaving and re-entering the route starts a fresh game', (
    tester,
  ) async {
    final visible = ValueNotifier<bool>(true);
    addTearDown(visible.dispose);

    final container = await _pumpSimulation(tester, visible);
    final firstGame = container.read(soilScopeGameProviderProvider);
    expect(firstGame, isNotNull);

    visible.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      container.read(simulationProvider).isRunning,
      isFalse,
      reason: 'the keep-alive provider must not run behind the menu',
    );
    expect(container.read(soilScopeGameProviderProvider), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.containsKey(SimulationPersistence.stateKey),
      isTrue,
      reason: 'leaving the route must persist the current session',
    );

    visible.value = true;
    await tester.pump();
    await _pumpUntil(
      tester,
      () => container.read(simulationProvider).isRunning,
    );

    expect(container.read(simulationProvider).isRunning, isTrue);
    expect(container.read(soilScopeGameProviderProvider), isNotNull);
    expect(
      container.read(soilScopeGameProviderProvider),
      isNot(same(firstGame)),
      reason: 're-entering the route must create a new canvas game',
    );
  });
}
