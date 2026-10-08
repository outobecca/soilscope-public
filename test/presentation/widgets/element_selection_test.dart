import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/presentation/widgets/controls/element_selection_modal.dart';
import 'package:soilscope/presentation/widgets/game/flutter_quick_actions.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/l10n/app_localizations.dart';

void main() {
  group('Element Selection and Pedagogical Insights Tests', () {
    testWidgets('FlutterQuickActions provides multiple essential nutrients and updates HoverInfo on selection', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return const MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale('fi'),
                home: Scaffold(
                  body: Align(
                    alignment: Alignment.bottomCenter,
                    child: FlutterQuickActions(),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify essential nutrient buttons are present: N, P, K, Ca, Mg, S, C, O, Fe
      expect(find.text('N'), findsOneWidget);
      expect(find.text('P'), findsOneWidget);
      expect(find.text('K'), findsOneWidget);
      expect(find.text('Ca'), findsOneWidget);
      expect(find.text('Mg'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('O'), findsOneWidget);
      expect(find.text('Fe'), findsOneWidget);

      // Verify periodic table launcher icon is present
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

      // Initially, no element is selected and hover info is null
      expect(container.read(simulationSessionProvider).selectedElementSymbol, isNull);
      expect(container.read(uIStateProvider), isNull);

      // Tap on Phosphorus 'P' button
      await tester.tap(find.text('P'));
      await tester.pumpAndSettle();

      // Session should have selected 'P'
      expect(container.read(simulationSessionProvider).selectedElementSymbol, equals('P'));

      // Educational HoverInfo should be populated with rich pedagogical data
      final pInfo = container.read(uIStateProvider);
      expect(pInfo, isNotNull);
      expect(pInfo!.elementSymbol, equals('P'));
      expect(pInfo.title.toLowerCase(), contains('fosfori'));
      expect(pInfo.stats?['Järjestysluku'], equals('15'));
      expect(pInfo.stats?['Rooli'], equals('Pääravinne'));
      expect(pInfo.isPinned, isTrue);

      // Tap 'P' again to deselect
      await tester.tap(find.text('P'));
      await tester.pumpAndSettle();

      expect(container.read(simulationSessionProvider).selectedElementSymbol, isNull);
      expect(container.read(uIStateProvider), isNull);
    });

    testWidgets('ElementSelectionModal allows selecting any element and reveals pedagogical context', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: const Locale('fi'),
                home: Scaffold(
                  body: Builder(
                    builder: (ctx) => Center(
                      child: ElevatedButton(
                        onPressed: () => ElementSelectionModal.show(ctx),
                        child: const Text('Open Modal'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Modal header should display localized title
      expect(find.text('Kaikki alkuaineet'), findsWidgets);

      // Find and tap 'H' (Hydrogen, period 1 group 1)
      final hFinder = find.text('H');
      expect(hFinder, findsWidgets);
      await tester.tap(hFinder.first);
      await tester.pumpAndSettle();

      // Session should have selected 'H'
      expect(container.read(simulationSessionProvider).selectedElementSymbol, equals('H'));

      // HoverInfo should contain hydrogen details
      final hInfo = container.read(uIStateProvider);
      expect(hInfo, isNotNull);
      expect(hInfo!.elementSymbol, equals('H'));
      expect(hInfo.title.toLowerCase(), contains('vety'));
      expect(hInfo.stats?['Järjestysluku'], equals('1'));

      // Test clear selection
      final clearBtn = find.text('Tyhjennä valinta');
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(container.read(simulationSessionProvider).selectedElementSymbol, isNull);
      expect(container.read(uIStateProvider), isNull);
    });
  });
}
