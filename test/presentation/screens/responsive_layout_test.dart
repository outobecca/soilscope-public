import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/main.dart';
import 'package:soilscope/presentation/providers/scenarios_provider.dart';
import 'package:soilscope/presentation/widgets/game/flutter_quick_actions.dart';
import 'package:soilscope/presentation/widgets/gamification_bar.dart';
import 'package:soilscope/presentation/widgets/hud_dashboard.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';

/// The simulation chrome has three layout tiers (phone, tablet, desktop).
/// These smoke tests open both sidebars at each mobile/tablet size so that
/// overflowing rows fail here instead of on a device.
void main() {
  for (final size in const [
    Size(390, 844), // phone
    Size(768, 1024), // tablet portrait
    Size(1024, 768), // tablet landscape
    Size(1280, 720), // desktop with sidebars
  ]) {
    testWidgets('simulation chrome fits ${size.width}x${size.height}', (
      WidgetTester tester,
    ) async {
      final errors = await _pumpChrome(tester, size);
      expect(errors, isEmpty, reason: 'layout errors at $size: $errors');
    });
  }

  testWidgets('chrome stays anchored and closed dashboard is unmounted', (
    WidgetTester tester,
  ) async {
    await _pumpChrome(tester, const Size(1280, 720), toggleSidebars: false);

    // Desktop opens the dashboard by default.
    expect(find.byType(HUDDashboard), findsOneWidget);
    final topOpen = tester.getCenter(find.byType(GamificationBar));
    final bottomOpen = tester.getCenter(find.byType(FlutterQuickActions));

    Future<void> settleSidebar() async {
      // The first frame rebuilds with the new width and starts the implicit
      // animation; the second advances it past the 300 ms duration.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    await tester.tap(find.byIcon(Icons.chevron_left).first);
    await settleSidebar();

    expect(
      find.byType(HUDDashboard),
      findsNothing,
      reason: 'a closed sidebar must not keep rebuilding dashboard analytics',
    );
    expect(
      tester.getCenter(find.byType(GamificationBar)).dx,
      closeTo(topOpen.dx, 0.1),
      reason: 'opening/closing the dashboard must not shift the top bar',
    );
    expect(
      tester.getCenter(find.byType(FlutterQuickActions)).dx,
      closeTo(bottomOpen.dx, 0.1),
      reason: 'the quick actions stay centred over the whole canvas',
    );

    await tester.tap(find.byIcon(Icons.menu).first);
    await settleSidebar();
    expect(find.byType(HUDDashboard), findsOneWidget);
    expect(
      tester.getCenter(find.byType(GamificationBar)).dx,
      closeTo(topOpen.dx, 0.1),
    );
    expect(
      tester.getCenter(find.byType(FlutterQuickActions)).dx,
      closeTo(bottomOpen.dx, 0.1),
    );

    await tester.tap(find.byIcon(Icons.settings).first);
    await settleSidebar();
    expect(
      tester.getCenter(find.byType(GamificationBar)).dx,
      closeTo(topOpen.dx, 0.1),
      reason: 'opening the controls sidebar must not shift the top bar',
    );
    expect(
      tester.getCenter(find.byType(FlutterQuickActions)).dx,
      closeTo(bottomOpen.dx, 0.1),
    );
  });

  testWidgets('simulation chrome fits a phone at 200% text', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final errors = await _pumpChrome(tester, const Size(390, 844));
    expect(errors, isEmpty, reason: 'layout errors at 200% text: $errors');
  });
}

Future<List<String>> _pumpChrome(
  WidgetTester tester,
  Size size, {
  bool toggleSidebars = true,
}) async {
  // The framework reports overflow through FlutterError; collect them so the
  // test can fail on the exact size that broke.
  final errors = <String>[];
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    errors.add(details.exceptionAsString());
    previousOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = previousOnError);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final mockScenario = Scenario(
    id: 'test_scenario',
    title: 'Test Scenario',
    description: 'Test Description',
    initialProfile: const SoilProfile(
      id: 'test',
      name: 'Test',
      layers: [
        SoilLayer(
          id: 'topsoil',
          depth: 0.0,
          thickness: 0.3,
          kSat: 1e-5,
          porosity: 0.45,
          thetaR: 0.05,
          vgAlpha: 2.0,
          vgN: 1.5,
          bulkDensity: 1200.0,
          waterContent: 0.25,
          temperature: 293.15,
          heatCapacity: 2.4e6,
          ph: 6.5,
          ec: 0.2,
          redoxPotential: 250.0,
          nitrateContent: 10.0,
          ammoniumContent: 5.0,
          phosphateContent: 3.0,
          microbialBiomass: 200.0,
          epsContent: 10.0,
          fungalHyphaeDensity: 20.0,
          necromass: 100.0,
          organicCarbon: 12000.0,
          particulateOrganicMatter: 6000.0,
          mineralAssociatedOrganicMatter: 6000.0,
          nitrogenContent: 1000.0,
          name: 'Topsoil',
        ),
      ],
      surfaceAlbedo: 0.2,
      slope: 0.05,
    ),
    weatherData: {'precip': 0.0, 'temp': 293.15, 'rh': 0.5},
    objectives: const [
      MissionObjective(
        id: 'clay_yield',
        title: 'Grow the crop',
        targetValue: 100,
        type: 'yield',
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        scenariosProvider.overrideWith((ref) => [mockScenario]),
      ],
      child: const SoilScopeApp(),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));

  final listFinder = find.byType(Scrollable);
  if (listFinder.evaluate().isNotEmpty) {
    // Drag until the first card's action is built: the distance to it grows
    // with the text scale, so a fixed drag overshoots at 200%.
    await tester.dragUntilVisible(
      find.text('OPEN'),
      listFinder.first,
      const Offset(0, -200),
    );
    await tester.pump(const Duration(seconds: 1));
  }
  await tester.tap(find.text('OPEN').first);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  // The desktop sidebar opens from a post-frame callback, so its implicit
  // width animation only starts on the following frame.
  await tester.pump(const Duration(milliseconds: 500));
  expect(find.byType(MainSimulationScreen), findsOneWidget);

  // A fresh install opens the onboarding tour over the whole screen; close
  // it so the chrome under test can receive taps.
  final tutorialClose = find.byIcon(Icons.close_rounded).hitTestable();
  if (tutorialClose.evaluate().isNotEmpty) {
    await tester.tap(tutorialClose.last);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  final menu = find.byIcon(Icons.menu).hitTestable();
  if (toggleSidebars && menu.evaluate().isNotEmpty) {
    await tester.tap(menu.first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  final settings = find.byIcon(Icons.settings).hitTestable();
  if (toggleSidebars && settings.evaluate().isNotEmpty) {
    await tester.tap(settings.first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  }

  return errors;
}
