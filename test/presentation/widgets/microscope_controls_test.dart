import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/presentation/widgets/controls/microscope_hud_controller.dart';
import 'package:soilscope/presentation/widgets/action_bar.dart';
import 'package:soilscope/presentation/widgets/game/logic/microscope_info_helper.dart';
import 'package:soilscope/presentation/widgets/game/components/process_magnifier_component.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/l10n/app_localizations.dart';

void main() {
  group('Microscope Inspection and Pedagogical Controls Tests', () {
    test('MicroscopeInfoHelper provides correct telemetry for all 7 targets', () {
      expect(MagnifierType.values.length, 7);

      for (final type in MagnifierType.values) {
        final mag = MicroscopeInfoHelper.getMagnificationLevel(type);
        expect(mag.endsWith('x'), isTrue);

        final icon = MicroscopeInfoHelper.getIcon(type);
        expect(icon, isNotNull);

        final parsed = MicroscopeInfoHelper.parseType(type.name);
        expect(parsed, equals(type));
      }
    });

    testWidgets('MicroscopeHudController renders and switches targets with educational HoverInfo', (tester) async {
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
                    alignment: Alignment.topLeft,
                    child: MicroscopeHudController(),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify HUD title and targets are rendered
      expect(find.text('NANOVISION-MIKROSKOOPPI'), findsOneWidget);
      expect(find.text('Kärkimeristeemi'), findsOneWidget);
      expect(find.text('Lehti'), findsOneWidget);
      expect(find.text('Mikrobit'), findsOneWidget);

      // Tap on Apical Meristem target button
      await tester.tap(find.text('Kärkimeristeemi'));
      await tester.pumpAndSettle();

      // Verify simulation session inspector is updated to apicalMeristem
      final session = container.read(simulationSessionProvider);
      expect(session.selectedInspectorType, equals('apicalMeristem'));

      // Verify educational HoverInfo is populated with formulas and stats
      final hoverInfo = container.read(uIStateProvider);
      expect(hoverInfo, isNotNull);
      expect(hoverInfo!.title, contains('Kärkimeristeemi'));
      expect(hoverInfo.title, contains('800x'));
      expect(hoverInfo.formula, isNotNull);
      expect(hoverInfo.stats, isNotNull);

      // Tap on Microbial target button
      await tester.ensureVisible(find.text('Mikrobit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mikrobit'));
      await tester.pumpAndSettle();

      expect(container.read(simulationSessionProvider).selectedInspectorType, equals('microbe'));
      final microbeInfo = container.read(uIStateProvider);
      expect(microbeInfo, isNotNull);
      expect(microbeInfo!.title, contains('1200x'));

      // Tap close button on HUD
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(container.read(simulationSessionProvider).isMicroscopeEnabled, isFalse);
      expect(container.read(uIStateProvider), isNull);
    });

    testWidgets('SimulationActions microscope toolbar includes apicalMeristem and sets HoverInfo', (tester) async {
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
                    child: SimulationActions(),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enable microscope to reveal toolbar
      container.read(simulationSessionProvider.notifier).toggleMicroscope();
      await tester.pumpAndSettle();

      // Apical meristem should be present in the hotspot list
      final meristemFinder = find.text('Kärkimeristeemi');
      expect(meristemFinder, findsOneWidget);

      // Ensure visible and tap on Apical Meristem hotspot
      await tester.ensureVisible(meristemFinder);
      await tester.pumpAndSettle();
      await tester.tap(meristemFinder);
      await tester.pumpAndSettle();

      expect(container.read(simulationSessionProvider).selectedInspectorType, equals('apicalMeristem'));
      expect(container.read(uIStateProvider), isNotNull);
      expect(container.read(uIStateProvider)!.title, contains('Kärkimeristeemi'));
    });
  });
}
