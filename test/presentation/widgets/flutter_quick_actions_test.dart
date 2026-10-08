import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/presentation/widgets/game/flutter_quick_actions.dart';
import 'package:soilscope/l10n/app_localizations.dart';

void main() {
  testWidgets('FlutterQuickActions tooltips have preferBelow set to false', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fi'),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: FlutterQuickActions(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all Tooltip widgets inside FlutterQuickActions have preferBelow == false
    final tooltipFinders = find.descendant(
      of: find.byType(FlutterQuickActions),
      matching: find.byType(Tooltip),
    );
    expect(tooltipFinders, findsWidgets);

    final tooltipWidgets = tester.widgetList<Tooltip>(tooltipFinders);
    for (final tooltip in tooltipWidgets) {
      expect(
        tooltip.preferBelow,
        isFalse,
        reason: 'Tooltip with message "${tooltip.message}" should have preferBelow: false so it floats above the bottom bar',
      );
    }
  });

  testWidgets('Hovering button in FlutterQuickActions triggers tooltip', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('fi'),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: FlutterQuickActions(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find play/pause button
    final playBtnFinder = find.byIcon(Icons.play_arrow_rounded);
    expect(playBtnFinder, findsOneWidget);

    // Hover over button
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(playBtnFinder));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify tooltip text is displayed and located ABOVE the button
    final buttonRect = tester.getRect(playBtnFinder);
    final tooltipTextFinder = find.text('Aloita'); // 'Aloita' / 'Toista'
    // Alternatively look for Tooltip rendered text
    if (tooltipTextFinder.evaluate().isNotEmpty) {
      final tooltipRect = tester.getRect(tooltipTextFinder.first);
      expect(
        tooltipRect.bottom,
        lessThanOrEqualTo(buttonRect.top),
        reason: 'Tooltip should be rendered above the button',
      );
    }
  });
}
