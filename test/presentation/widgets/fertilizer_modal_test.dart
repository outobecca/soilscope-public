import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soilscope/presentation/widgets/controls/fertilizer_modal.dart';
import 'package:soilscope/l10n/app_localizations.dart';

void main() {
  testWidgets('FertilizerModal renders without error and displays periodic table', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FertilizerModal(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(FertilizerModal), findsOneWidget);
  });

  testWidgets('FertilizerModal renders on mobile viewport (390x844)', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: FertilizerModal(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(FertilizerModal), findsOneWidget);
  });

  testWidgets('FertilizerModal allows selecting an element and toggling view mode', (tester) async {
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
            body: FertilizerModal(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find nitrogen 'N' tile and tap it
    final nFinder = find.text('N');
    expect(nFinder, findsWidgets);
    await tester.tap(nFinder.first);
    await tester.pumpAndSettle();

    // Verify nutrient slider row appears for Nitrogen
    expect(find.text('Typpi'), findsWidgets);

    // Switch to cards/list view mode
    final listIcon = find.byIcon(Icons.view_agenda_rounded);
    expect(listIcon, findsOneWidget);
    await tester.tap(listIcon);
    await tester.pumpAndSettle();

    // In card view mode, nitrogen card is visible
    expect(find.text('Typpi'), findsWidgets);
  });
}
