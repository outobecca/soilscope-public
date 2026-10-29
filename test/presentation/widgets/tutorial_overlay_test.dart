import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/tutorial_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/tutorial_overlay_widget.dart';
import 'package:soilscope/domain/models/scenario.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestWidget({required WidgetRefCallback onReady}) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fi'), Locale('en')],
        locale: const Locale('fi'),
        home: Scaffold(
          body: Consumer(
            builder: (context, ref, child) {
              onReady(ref);
              return const Stack(
                children: [
                  Center(child: Text('Background Content')),
                  Positioned.fill(child: TutorialOverlayWidget()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  group('TutorialProvider unit tests', () {
    test('initial state is inactive and not completed', () {
      final container = ProviderContainer();
      final state = container.read(tutorialProvider);
      expect(state.isVisible, false);
      expect(state.currentStepIndex, 0);
      expect(state.isCompleted, false);
      expect(state.isQuickGuideOpen, false);
    });

    test('startTutorial activates tour at step 0', () {
      final container = ProviderContainer();
      container.read(tutorialProvider.notifier).startTutorial();

      final state = container.read(tutorialProvider);
      expect(state.isVisible, true);
      expect(state.currentStepIndex, 0);
    });

    test('nextStep and previousStep navigate steps properly', () {
      final container = ProviderContainer();
      final notifier = container.read(tutorialProvider.notifier);
      notifier.startTutorial();

      notifier.nextStep();
      expect(container.read(tutorialProvider).currentStepIndex, 1);

      notifier.nextStep();
      expect(container.read(tutorialProvider).currentStepIndex, 2);

      notifier.previousStep();
      expect(container.read(tutorialProvider).currentStepIndex, 1);
    });

    test('skipTutorial dismisses and marks completed', () async {
      final container = ProviderContainer();
      final notifier = container.read(tutorialProvider.notifier);
      notifier.startTutorial();
      expect(container.read(tutorialProvider).isVisible, true);

      notifier.skipTutorial();
      expect(container.read(tutorialProvider).isVisible, false);
      expect(container.read(tutorialProvider).isCompleted, true);
    });

    test('quick guide toggle works', () {
      final container = ProviderContainer();
      final notifier = container.read(tutorialProvider.notifier);

      notifier.openQuickGuide();
      expect(container.read(tutorialProvider).isQuickGuideOpen, true);

      notifier.closeQuickGuide();
      expect(container.read(tutorialProvider).isQuickGuideOpen, false);
    });
  });

  group('TutorialOverlayWidget widget tests', () {
    testWidgets('overlay is hidden when tutorial is inactive',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(onReady: (ref) {}),
      );
      await tester.pump();

      expect(find.text('Background Content'), findsOneWidget);
      expect(find.text('Tervetuloa SoilScopeen!'), findsNothing);
    });

    testWidgets('shows step 1 when started and navigates to step 2',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      WidgetRef? widgetRef;
      await tester.pumpWidget(
        buildTestWidget(onReady: (ref) {
          widgetRef = ref;
        }),
      );
      await tester.pump();

      // Start tutorial
      widgetRef!.read(tutorialProvider.notifier).startTutorial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show step 1
      expect(find.text('Tervetuloa SoilScopeen!'), findsOneWidget);
      expect(find.text('VAIHE 1 / 7'), findsOneWidget);
      expect(find.text('Seuraava'), findsOneWidget);

      // Tap Next
      await tester.tap(find.text('Seuraava'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should show step 2
      expect(find.text('VAIHE 2 / 7'), findsOneWidget);
      expect(find.text('Simulaationäkymä & Tarkastelupisteet'), findsOneWidget);
      expect(find.text('Edellinen'), findsOneWidget);

      // Tap Previous
      await tester.tap(find.text('Edellinen'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back to step 1
      expect(find.text('VAIHE 1 / 7'), findsOneWidget);
      expect(find.text('Tervetuloa SoilScopeen!'), findsOneWidget);
    });

    testWidgets('opens quick guide and shows tabs', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      WidgetRef? widgetRef;
      await tester.pumpWidget(
        buildTestWidget(onReady: (ref) {
          widgetRef = ref;
        }),
      );
      await tester.pump();

      widgetRef!.read(tutorialProvider.notifier).startTutorial();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap Pikaopas button
      await tester.tap(find.text('Pikaopas'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Quick guide should be open
      expect(find.text('SoilScope-Pikaopas'), findsOneWidget);
      expect(find.text('Käyttöliittymä'), findsOneWidget);
      expect(find.text('SPAC-Tiede'), findsOneWidget);
      expect(find.text('Biokemia'), findsOneWidget);
      expect(find.text('Käytännön vinkit'), findsOneWidget);

      // Close quick guide
      await tester.tap(find.text('Sulje opas'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('SoilScope-Pikaopas'), findsNothing);
    });

    testWidgets('displays scenario specific step if present',
        (tester) async {
      WidgetRef? widgetRef;
      await tester.pumpWidget(
        buildTestWidget(onReady: (ref) {
          widgetRef = ref;
        }),
      );
      await tester.pump();

      const step = ScenarioTutorialStep(
        triggerTime: 1.0,
        targetId: 'rhizosphere',
        title: 'Skenaariotehtävä: Juuristo',
        description: 'Tarkastele juuriston eritteitä ja mikrobeja.',
      );

      widgetRef!.read(activeTutorialStepProvider.notifier).setTutorialStep(step);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Skenaariotehtävä: Juuristo'), findsOneWidget);
      expect(find.text('Tarkastele juuriston eritteitä ja mikrobeja.'), findsOneWidget);
      expect(find.textContaining('RHIZOSPHERE'), findsOneWidget);
      expect(find.text('Avaa Nanovision'), findsOneWidget);
      expect(find.text('Pikaopas'), findsOneWidget);
    });
  });
}

typedef WidgetRefCallback = void Function(WidgetRef ref);
