import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/core/nitrogen_forms.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/default_simulation_profile.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/solvers/particle_physics_solver.dart';
import 'package:soilscope/l10n/app_localizations.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';
import 'package:soilscope/presentation/widgets/game/components/bubble_component.dart';
import 'package:soilscope/presentation/widgets/game/components/molecule_renderer.dart';
import 'package:soilscope/presentation/widgets/game/flutter_quick_actions.dart';
import 'package:soilscope/presentation/widgets/game/nitrogen_cycle_explainer.dart';

/// Seed every layer with different values so a sum across layers cannot be
/// mistaken for a single layer or a single field.
BiophysicalState seededState({double scale = 1.0}) {
  final base = defaultSoilProfile();
  final layers = <SoilLayer>[];
  for (var i = 0; i < base.layers.length; i++) {
    layers.add(
      base.layers[i].copyWith(
        organicNitrogen: (100 + i * 10) * scale,
        maomNitrogen: (50 + i * 5) * scale,
        microbialNitrogen: (10 + i) * scale,
        ammoniumContent: (8 + i * 2) * scale,
        nitrateContent: (3 + i * 3) * scale,
        nitrousOxideContent: (0.2 + i * 0.1) * scale,
      ),
    );
  }
  return BiophysicalState(
    profile: base.copyWith(layers: layers),
    plants: const [],
    timeElapsed: 0,
  );
}

({double organic, double ammonium, double nitrate, double gas}) expectedPools(
  BiophysicalState state,
) {
  var organic = 0.0;
  var ammonium = 0.0;
  var nitrate = 0.0;
  var gas = 0.0;
  for (final layer in state.profile.layers) {
    organic +=
        layer.organicNitrogen + layer.maomNitrogen + layer.microbialNitrogen;
    ammonium += layer.ammoniumContent;
    nitrate += layer.nitrateContent;
    gas += layer.nitrousOxideContent;
  }
  return (
    organic: organic,
    ammonium: ammonium,
    nitrate: nitrate,
    gas: gas,
  );
}

Future<ProviderContainer> pumpOverlay(
  WidgetTester tester, {
  required Size surface,
  double topInset = 84,
  double bottomReserve = 176,
  BiophysicalState? state,
  bool activate = true,
  bool withQuickActions = false,
}) async {
  tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      simulationProvider.overrideWithValue(state ?? seededState()),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: NitrogenCycleOverlay(
                  topInset: topInset,
                  bottomReserve: bottomReserve,
                ),
              ),
              if (withQuickActions)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: FlutterQuickActions(),
                ),
            ],
          ),
        ),
      ),
    ),
  );

  if (activate) {
    container
        .read(activeCycleProvider.notifier)
        .setCycle(ObservationCycle.nitrogen);
  }
  // setCycle() applies in a microtask; settle so the next frame includes it.
  await tester.pumpAndSettle();
  return container;
}

void expectNoFlutterError(WidgetTester tester, String context) {
  final error = tester.takeException();
  expect(
    error,
    isNull,
    reason: 'Unexpected FlutterError while $context: $error',
  );
}

void expectCardInsideSurface(
  WidgetTester tester, {
  required Size surface,
  required double topInset,
  required double bottomReserve,
  required String label,
}) {
  final card = find.byKey(const ValueKey('nitrogen-cycle-card'));
  expect(card, findsOneWidget, reason: '$label: card should be visible');

  final rect = tester.getRect(card);
  expect(rect.left, greaterThanOrEqualTo(0), reason: '$label: left edge');
  expect(rect.top, greaterThanOrEqualTo(0), reason: '$label: top edge');
  expect(
    rect.right,
    lessThanOrEqualTo(surface.width + 0.01),
    reason: '$label: right edge painted off screen',
  );
  expect(
    rect.bottom,
    lessThanOrEqualTo(surface.height + 0.01),
    reason: '$label: bottom edge painted off screen',
  );
  expect(rect.top, greaterThanOrEqualTo(topInset), reason: '$label: top inset');
  expect(
    rect.bottom,
    lessThanOrEqualTo(surface.height - bottomReserve + 0.01),
    reason: '$label: bottom reserve',
  );

  // The card must stay wide enough for its label/value rows.
  expect(rect.width, greaterThanOrEqualTo(240), reason: '$label: width');

  // Every text run must stay horizontally inside the card. This catches a
  // row that paints past the rounded surface even when no render overflow is
  // raised.
  final texts = find.descendant(of: card, matching: find.byType(Text));
  final count = texts.evaluate().length;
  expect(count, greaterThan(10), reason: '$label: card content missing');
  for (var i = 0; i < count; i++) {
    final textRect = tester.getRect(texts.at(i));
    final text = texts.at(i).evaluate().single.widget as Text;
    final plain = text.data ?? text.textSpan?.toPlainText() ?? '';
    expect(
      textRect.left,
      greaterThanOrEqualTo(rect.left - 0.01),
      reason: '$label: "$plain" paints left of the card',
    );
    expect(
      textRect.right,
      lessThanOrEqualTo(rect.right + 0.01),
      reason: '$label: "$plain" paints right of the card',
    );
  }

  expect(
    find.descendant(
      of: card,
      matching: find.byType(SingleChildScrollView),
    ),
    findsOneWidget,
    reason: '$label: card must remain scrollable instead of clipping content',
  );
}

String displayedTotal(WidgetTester tester, NitrogenForm form) {
  final text = tester.widget<Text>(
    find.byKey(ValueKey('nitrogen-total-${form.name}')),
  );
  return text.data!;
}

Color swatchColor(WidgetTester tester, NitrogenForm form) {
  final dot = tester.widget<Container>(
    find.byKey(ValueKey('nitrogen-form-dot-${form.name}')),
  );
  return (dot.decoration! as BoxDecoration).color!;
}

Color labelColor(WidgetTester tester, NitrogenForm form) {
  final label = tester.widget<Text>(
    find.byKey(ValueKey('nitrogen-form-label-${form.name}')),
  );
  return label.style!.color!;
}

Future<void> openViewActions(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.more_horiz_rounded));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ChoiceChip, 'VIEW'));
  await tester.pumpAndSettle();
}

void main() {
  const surfaces = <
    ({
      String name,
      Size size,
      double topInset,
      double bottomReserve,
    })
  >[
    (
      name: 'narrow',
      size: Size(320, 568),
      topInset: 72,
      bottomReserve: 236,
    ),
    (
      name: 'medium',
      size: Size(768, 1024),
      topInset: 84,
      bottomReserve: 176,
    ),
    (
      name: 'wide',
      size: Size(1440, 900),
      topInset: 84,
      bottomReserve: 176,
    ),
  ];

  for (final surface in surfaces) {
    testWidgets(
      'nitrogen explainer fits the ${surface.name} surface without overflow',
      (tester) async {
        await pumpOverlay(
          tester,
          surface: surface.size,
          topInset: surface.topInset,
          bottomReserve: surface.bottomReserve,
        );
        expectNoFlutterError(tester, '${surface.name} layout');

        expectCardInsideSurface(
          tester,
          surface: surface.size,
          topInset: surface.topInset,
          bottomReserve: surface.bottomReserve,
          label: surface.name,
        );

        // The pathway content below the fold must be reachable by scrolling.
        final fixation = find.textContaining('N₂ fixation');
        expect(fixation, findsOneWidget);
        await tester.ensureVisible(fixation);
        await tester.pumpAndSettle();
        expectNoFlutterError(tester, '${surface.name} scrolled layout');

        // The last pathway block must be reachable rather than permanently
        // clipped below the card viewport.
        final cardRect = tester.getRect(
          find.byKey(const ValueKey('nitrogen-cycle-card')),
        );
        final fixationRect = tester.getRect(fixation);
        expect(
          fixationRect.top,
          greaterThanOrEqualTo(cardRect.top - 0.01),
          reason: '${surface.name}: fixation block clipped above the card',
        );
        expect(
          fixationRect.bottom,
          lessThanOrEqualTo(cardRect.bottom + 0.01),
          reason: '${surface.name}: fixation block clipped below the card',
        );
      },
    );
  }

  testWidgets('pool totals are real cross-layer sums with their units', (
    tester,
  ) async {
    final state = seededState();
    await pumpOverlay(
      tester,
      surface: const Size(1440, 900),
    );
    expectNoFlutterError(tester, 'pool layout');

    final expected = expectedPools(state);
    expect(expected.organic, 528.0);
    expect(expected.ammonium, 30.0);
    expect(expected.nitrate, 18.0);
    expect(expected.gas, closeTo(0.9, 1e-9));

    expect(
      displayedTotal(tester, NitrogenForm.organic),
      expected.organic.toStringAsFixed(1),
    );
    expect(
      displayedTotal(tester, NitrogenForm.ammonium),
      expected.ammonium.toStringAsFixed(1),
    );
    expect(
      displayedTotal(tester, NitrogenForm.nitrate),
      expected.nitrate.toStringAsFixed(1),
    );
    expect(
      displayedTotal(tester, NitrogenForm.nitrousOxide),
      expected.gas.toStringAsFixed(1),
    );

    // Each non-gas row carries mg/kg; the gas row carries mol/m³.
    expect(find.text('mg/kg'), findsNWidgets(3));
    expect(find.text('mol/m³'), findsOneWidget);

    // No row may have silently collapsed to zero.
    for (final form in NitrogenForm.values) {
      expect(
        double.parse(displayedTotal(tester, form)),
        greaterThan(0),
        reason: '${form.name} total should not be zero',
      );
    }
  });

  testWidgets('pool totals follow a changed state instead of staying stale', (
    tester,
  ) async {
    await pumpOverlay(
      tester,
      surface: const Size(1440, 900),
    );
    expect(displayedTotal(tester, NitrogenForm.organic), '528.0');

    final doubled = seededState(scale: 2.0);
    await pumpOverlay(
      tester,
      surface: const Size(1440, 900),
      state: doubled,
    );
    expectNoFlutterError(tester, 'updated pool layout');

    final expected = expectedPools(doubled);
    expect(displayedTotal(tester, NitrogenForm.organic), '1056.0');
    expect(
      displayedTotal(tester, NitrogenForm.ammonium),
      expected.ammonium.toStringAsFixed(1),
    );
    expect(
      displayedTotal(tester, NitrogenForm.nitrate),
      expected.nitrate.toStringAsFixed(1),
    );
    expect(
      displayedTotal(tester, NitrogenForm.nitrousOxide),
      expected.gas.toStringAsFixed(1),
    );
    expect(find.text('528.0'), findsNothing);
  });

  testWidgets('card appears only in nitrogen mode and closes cleanly', (
    tester,
  ) async {
    final container = await pumpOverlay(
      tester,
      surface: const Size(768, 1024),
      activate: false,
    );
    final card = find.byKey(const ValueKey('nitrogen-cycle-card'));

    expect(container.read(activeCycleProvider), ObservationCycle.none);
    expect(card, findsNothing);
    expectNoFlutterError(tester, 'inactive mode');

    container
        .read(activeCycleProvider.notifier)
        .setCycle(ObservationCycle.nitrogen);
    await tester.pumpAndSettle();
    expect(container.read(activeCycleProvider), ObservationCycle.nitrogen);
    expect(card, findsOneWidget);
    expectNoFlutterError(tester, 'opening card');

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(container.read(activeCycleProvider), ObservationCycle.none);
    expect(card, findsNothing);
    expectNoFlutterError(tester, 'closing card');

    container
        .read(activeCycleProvider.notifier)
        .setCycle(ObservationCycle.nitrogen);
    await tester.pumpAndSettle();
    expect(card, findsOneWidget);

    container
        .read(activeCycleProvider.notifier)
        .setCycle(ObservationCycle.carbon);
    await tester.pumpAndSettle();
    expect(card, findsNothing);
    expectNoFlutterError(tester, 'leaving nitrogen mode');
  });

  testWidgets('card swatches match the scene nitrogen colour mapping', (
    tester,
  ) async {
    await pumpOverlay(
      tester,
      surface: const Size(1440, 900),
    );
    expectNoFlutterError(tester, 'colour mapping layout');

    for (final form in NitrogenForm.values) {
      expect(
        swatchColor(tester, form),
        form.color,
        reason: '${form.name} swatch must use the shared form colour',
      );
      expect(
        labelColor(tester, form),
        form.color,
        reason: '${form.name} label must use the shared form colour',
      );
    }

    // Particle-field path (the batch renderer used for the soil particles).
    expect(
      swatchColor(tester, NitrogenForm.organic),
      MoleculeRenderer.nitrogenHighlightColorForParticle(
        ParticleType.organicNitrogen,
      ),
    );
    expect(
      swatchColor(tester, NitrogenForm.ammonium),
      MoleculeRenderer.nitrogenHighlightColorForParticle(
        ParticleType.ammonium,
      ),
    );
    expect(
      swatchColor(tester, NitrogenForm.nitrate),
      MoleculeRenderer.nitrogenHighlightColorForParticle(
        ParticleType.nitrate,
      ),
    );

    // Hero-molecule path used by individually spawned molecules.
    expect(
      swatchColor(tester, NitrogenForm.ammonium),
      MoleculeRenderer.nitrogenHighlightColor(MoleculeType.ammonium),
    );
    expect(
      swatchColor(tester, NitrogenForm.nitrate),
      MoleculeRenderer.nitrogenHighlightColor(MoleculeType.nitrate),
    );
    expect(
      swatchColor(tester, NitrogenForm.nitrousOxide),
      MoleculeRenderer.nitrogenHighlightColor(MoleculeType.nitrousOxide),
    );

    // Gas bubbles paint through BubbleComponent's public colour mapping.
    expect(
      swatchColor(tester, NitrogenForm.nitrousOxide),
      BubbleComponent.colorForType(BubbleType.n2o),
    );

    // Non-nitrogen particles must not claim a nitrogen colour.
    expect(
      MoleculeRenderer.nitrogenHighlightColorForParticle(ParticleType.water),
      isNull,
    );
    expect(
      MoleculeRenderer.nitrogenHighlightColor(MoleculeType.water),
      isNull,
    );
  });

  testWidgets('observation-cycle tile opens the explainer', (tester) async {
    final container = await pumpOverlay(
      tester,
      surface: const Size(900, 900),
      withQuickActions: true,
      activate: false,
    );
    expect(
      find.byKey(const ValueKey('nitrogen-cycle-card')),
      findsNothing,
    );

    await openViewActions(tester);
    final cycleTile = find.ancestor(
      of: find.byIcon(Icons.published_with_changes),
      matching: find.byType(ListTile),
    );
    expect(cycleTile, findsOneWidget);
    await tester.tap(cycleTile);
    await tester.pumpAndSettle();
    expectNoFlutterError(tester, 'observation-cycle tile');

    expect(container.read(activeCycleProvider), ObservationCycle.nitrogen);
    expect(
      find.byKey(const ValueKey('nitrogen-cycle-card')),
      findsOneWidget,
    );
  });

  testWidgets('dedicated Nitrogen cycle tile opens the explainer', (
    tester,
  ) async {
    final container = await pumpOverlay(
      tester,
      surface: const Size(900, 900),
      withQuickActions: true,
      activate: false,
    );
    expect(
      find.byKey(const ValueKey('nitrogen-cycle-card')),
      findsNothing,
    );

    await openViewActions(tester);
    final nitrogenTile = find.ancestor(
      of: find.text('Nitrogen cycle'),
      matching: find.byType(ListTile),
    );
    expect(nitrogenTile, findsOneWidget);
    await tester.tap(nitrogenTile);
    await tester.pumpAndSettle();
    expectNoFlutterError(tester, 'dedicated nitrogen tile');

    expect(container.read(activeCycleProvider), ObservationCycle.nitrogen);
    expect(
      find.byKey(const ValueKey('nitrogen-cycle-card')),
      findsOneWidget,
    );
  });
}
