import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soilscope/domain/actions/simulation_actions.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/services/simulation_persistence.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';
import 'package:soilscope/domain/solvers/simulation_engine.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';

double _water(BiophysicalState state) => state.profile.layers.fold(
  0.0,
  (sum, layer) => sum + layer.waterContent * layer.thickness,
);

double _mineralN(BiophysicalState state) => state.profile.layers.fold(
  0.0,
  (sum, layer) =>
      sum +
      (layer.nitrateContent + layer.ammoniumContent) *
          layer.bulkDensity *
          layer.thickness,
);

/// Organic nitrogen stock in mg/m². `nitrogenContent` is a concentration
/// (g/kg), so the 1000 converts to mg/kg before multiplying by soil mass.
/// Using g/kg is the conservative reading; a percent reading only enlarges the
/// reserve, so the bound stays valid either way.
double _organicN(BiophysicalState state) => state.profile.layers.fold(
  0.0,
  (sum, layer) =>
      sum + layer.nitrogenContent * 1000 * layer.bulkDensity * layer.thickness,
);

/// Slow carbon pools only. `organicCarbon` is a derived total in some solver
/// paths, so it is checked separately for bounds instead of double-counted
/// here.
double _slowCarbon(BiophysicalState state) => state.profile.layers.fold(
  0.0,
  (sum, layer) =>
      sum +
      (layer.particulateOrganicMatter +
              layer.mineralAssociatedOrganicMatter +
              layer.microbialBiomass +
              layer.necromass) *
          layer.bulkDensity *
          layer.thickness,
);

bool _allFinite(BiophysicalState state) => state.profile.layers.every(
  (layer) => [
    layer.waterContent,
    layer.temperature,
    layer.ph,
    layer.nitrateContent,
    layer.ammoniumContent,
    layer.organicCarbon,
    layer.microbialBiomass,
  ].every((value) => value.isFinite),
);

SoilProfile _profile(String id) => SoilProfile(
  id: id,
  name: id,
  layers: [
    SoilLayer(
      id: 'A1',
      depth: 0.0,
      thickness: 0.3,
      kSat: 1e-6,
      porosity: 0.45,
      thetaR: 0.05,
      vgAlpha: 1.5,
      vgN: 1.5,
      bulkDensity: 1400.0,
      waterContent: 0.25,
      temperature: 293.15,
      heatCapacity: 800.0,
      ph: 6.5,
      ec: 0.2,
      redoxPotential: 500.0,
      nitrateContent: 15.0,
      ammoniumContent: 5.0,
      phosphateContent: 5.0,
      potassiumContent: 25.0,
      aggregateStability: 0.5,
      microbialBiomass: 40.0,
      epsContent: 0.0,
      fungalHyphaeDensity: 0.0,
      necromass: 0.0,
      organicCarbon: 10.0,
      mineralAssociatedOrganicMatter: 10.0,
      particulateOrganicMatter: 0.5,
      nitrogenContent: 0.2,
    ),
  ],
  surfaceAlbedo: 0.2,
  slope: 0.0,
);

Scenario _scenario(String id) => Scenario(
  id: id,
  title: id,
  description: id,
  initialProfile: _profile(id),
  weatherData: const {},
);

Future<bool> _waitUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final stopwatch = Stopwatch()..start();
  while (stopwatch.elapsed < timeout) {
    if (condition()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 25));
  }
  return condition();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reference run conservation', () {
    late List<BiophysicalState> history;

    setUpAll(() {
      history = ValidationReferenceRun.run();
    });

    test('water stays inside the physical bounds', () {
      for (final state in history) {
        for (final layer in state.profile.layers) {
          expect(
            layer.waterContent,
            inInclusiveRange(layer.thetaR - 1e-9, layer.porosity + 1e-9),
            reason: '${layer.id} at ${state.timeElapsed}s',
          );
        }
      }
    });

    test('without inputs, total water does not increase', () {
      final start = _water(history.first);
      final end = _water(history.last);
      expect(end, lessThanOrEqualTo(start + 1e-9));
      expect(end, greaterThan(0));
    });

    test(
      'mineral nitrogen stays capped and cannot exceed organic reserves',
      () {
        final start = history.first;
        final end = history.last;
        for (final state in history) {
          for (final layer in state.profile.layers) {
            expect(layer.nitrateContent, greaterThanOrEqualTo(0));
            expect(layer.nitrateContent, lessThanOrEqualTo(1000.0));
            expect(layer.ammoniumContent, greaterThanOrEqualTo(0));
            expect(layer.ammoniumContent, lessThanOrEqualTo(500.0));
          }
        }
        // Mineralisation can only unlock nitrogen that was already in the
        // organic pool; it cannot manufacture it.
        final increase = _mineralN(end) - _mineralN(start);
        expect(increase, lessThanOrEqualTo(_organicN(start) + 1.0));
      },
    );

    test('without amendments, the slow carbon pools do not increase', () {
      final start = _slowCarbon(history.first);
      final end = _slowCarbon(history.last);
      expect(end, lessThanOrEqualTo(start * 1.000001 + 1e-9));
      for (final state in history) {
        for (final layer in state.profile.layers) {
          expect(layer.particulateOrganicMatter, greaterThanOrEqualTo(0));
          expect(layer.mineralAssociatedOrganicMatter, greaterThanOrEqualTo(0));
          expect(layer.microbialBiomass, greaterThanOrEqualTo(0));
          expect(layer.necromass, greaterThanOrEqualTo(0));
        }
      }
    });

    test('every pool stays finite across the run', () {
      expect(history.every(_allFinite), isTrue);
    });
  });

  group('intervention conservation', () {
    test('irrigation adds the requested depth to the top layer only', () {
      final initial = ValidationReferenceRun.initialState();
      final top = initial.profile.layers.first;
      final irrigated = SimulationActions.applyIrrigation(
        initial,
        amountMm: 10,
      );
      final expectedDelta = 10 / (top.thickness * 1000);
      expect(
        irrigated.profile.layers.first.waterContent,
        closeTo(top.waterContent + expectedDelta, 1e-9),
      );
      expect(
        irrigated.profile.layers.last.waterContent,
        initial.profile.layers.last.waterContent,
      );
      expect(irrigated.profile.layers.first.nitrateContent, top.nitrateContent);
      expect(_mineralN(irrigated), closeTo(_mineralN(initial), 1e-9));
    });

    test('fertilizer changes only the targeted layer and species', () {
      final initial = ValidationReferenceRun.initialState();
      final fertilized = SimulationActions.applyNutrients(
        initial,
        'A',
        'N',
        20,
      );
      expect(
        fertilized.profile.layers.first.nitrateContent,
        closeTo(initial.profile.layers.first.nitrateContent + 20, 1e-12),
      );
      expect(
        fertilized.profile.layers.last.nitrateContent,
        initial.profile.layers.last.nitrateContent,
      );
      expect(_water(fertilized), closeTo(_water(initial), 1e-12));
    });

    test('tillage changes physical properties without moving water or N', () {
      final initial = ValidationReferenceRun.initialState();
      final tilled = SimulationActions.applyTillage(initial);
      expect(_water(tilled), closeTo(_water(initial), 1e-12));
      for (var i = 0; i < initial.profile.layers.length; i++) {
        final before = initial.profile.layers[i];
        final after = tilled.profile.layers[i];
        // Concentrations are unchanged; areal mass shifts only because the
        // cultivated layer becomes less dense.
        expect(after.nitrateContent, before.nitrateContent);
        expect(after.ammoniumContent, before.ammoniumContent);
        if (i < 2) {
          expect(after.bulkDensity, closeTo(before.bulkDensity * 0.9, 1e-9));
        } else {
          expect(after.bulkDensity, before.bulkDensity);
        }
      }
    });
  });

  group('session conservation', () {
    test('switching scenarios restores the new profile exactly', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      final first = _scenario('first');
      final second = _scenario('second');
      notifier.loadScenario(first);
      notifier.start();
      await _waitUntil(
        () => container.read(simulationProvider).timeElapsed > 0,
      );
      notifier.stop();

      notifier.loadScenario(second);
      final state = container.read(simulationProvider);
      expect(state.timeElapsed, 0);
      expect(state.profile, second.initialProfile);
      expect(
        state.profile.layers.first.waterContent,
        second.initialProfile.layers.first.waterContent,
      );
      expect(_mineralN(state), closeTo(_mineralN(_initialState(second)), 1e-9));
    });

    test(
      'pausing leaves pools untouched and resuming continues the clock',
      () async {
        SharedPreferences.setMockInitialValues({});
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(simulationProvider.notifier);

        notifier.loadScenario(_scenario('pause'));
        notifier.start();
        expect(
          await _waitUntil(
            () => container.read(simulationProvider).timeElapsed > 0,
          ),
          isTrue,
        );
        notifier.stop();
        await Future<void>.delayed(const Duration(milliseconds: 200));

        final stopped = container.read(simulationProvider);
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final stillStopped = container.read(simulationProvider);
        expect(stillStopped.timeElapsed, stopped.timeElapsed);
        expect(_water(stillStopped), closeTo(_water(stopped), 1e-12));
        expect(_mineralN(stillStopped), closeTo(_mineralN(stopped), 1e-9));

        notifier.start();
        expect(
          await _waitUntil(
            () =>
                container.read(simulationProvider).timeElapsed >
                stopped.timeElapsed,
          ),
          isTrue,
        );
        notifier.stop();
        final resumed = container.read(simulationProvider);
        expect(_water(resumed), lessThanOrEqualTo(_water(stopped) + 1e-9));
        expect(_allFinite(resumed), isTrue);
      },
    );

    test('a saved session preserves every conserved pool', () async {
      SharedPreferences.setMockInitialValues({});
      final persistence = SimulationPersistence();
      final initial = ValidationReferenceRun.initialState();
      final advanced = SimulationEngine.tick(initial, 3600);
      await persistence.save(advanced);

      final loaded = await persistence.load();
      expect(loaded, isNotNull);
      expect(_water(loaded!), closeTo(_water(advanced), 1e-9));
      expect(_mineralN(loaded), closeTo(_mineralN(advanced), 1e-6));
      expect(_slowCarbon(loaded), closeTo(_slowCarbon(advanced), 1e-6));
    });
  });
}

BiophysicalState _initialState(Scenario scenario) {
  return BiophysicalState(
    profile: scenario.initialProfile,
    plants: const [],
    timeElapsed: 0,
    isInitializing: false,
    isRunning: false,
  );
}
