import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
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

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));

    expect(container.read(uIStateProvider), isNull);
    expect(container.read(simulationSessionProvider).selectedLayerId, isNull);
  });
}
