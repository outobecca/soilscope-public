import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/domain/models/default_simulation_profile.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/screens/logic_lab/logic_lab_context.dart';
import 'package:soilscope/presentation/widgets/hover_tooltip.dart';

void main() {
  testWidgets('pinned tooltip close clears the canvas selection', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(uIStateProvider.notifier)
        .setHoverInfo(
          HoverInfo(
            title: 'TOPSOIL',
            description: 'Selected layer',
            isPinned: true,
            sourceId: 'soil-layer-topsoil',
          ),
        );
    container.read(simulationSessionProvider.notifier).selectLayer('topsoil');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: HoverTooltip())),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.pause_circle_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(find.text('Open Logic Lab'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(container.read(uIStateProvider), isNull);
    expect(container.read(simulationSessionProvider).selectedLayerId, isNull);
  });

  testWidgets('pinned tooltip opens the Lab with the hotspot context', (
    WidgetTester tester,
  ) async {
    final state = BiophysicalState(
      profile: defaultSoilProfile(),
      plants: const [],
      timeElapsed: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [simulationProvider.overrideWithValue(state)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routes: {
            '/logic_lab': (context) {
              final launchContext = ModalRoute.of(context)?.settings.arguments
                  as LogicLabLaunchContext?;
              return Scaffold(
                body: Text(launchContext?.process.name ?? 'missing context'),
              );
            },
          },
          home: const Scaffold(body: HoverTooltip()),
        ),
      ),
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HoverTooltip)),
    );
    container.read(uIStateProvider.notifier).setHoverInfo(
      HoverInfo(
        title: 'PHOTOSYNTHESIS',
        description: 'Leaf carbon gain',
        isPinned: true,
        sourceId: 'photosynthesis-indicator',
        layerId: 'B1',
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Open Logic Lab'));
    await tester.pumpAndSettle();

    expect(find.text('photosynthesis'), findsOneWidget);
  });
}
