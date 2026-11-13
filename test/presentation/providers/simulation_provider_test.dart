import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';

SoilProfile _profile(String id) {
  return SoilProfile(
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
}

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

  group('scenario reset', () {
    test('loading a scenario discards the previous run', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('first'));
      notifier.start();

      final advanced = await _waitUntil(
        () => container.read(simulationProvider).timeElapsed > 0,
      );
      expect(advanced, isTrue,
          reason: 'the simulation isolate should deliver a tick');
      notifier.stop();

      notifier.loadScenario(_scenario('second'));

      final state = container.read(simulationProvider);
      expect(state.timeElapsed, 0,
          reason: 'the clock must not carry over between scenarios');
      expect(state.currentScenario?.id, 'second');
      expect(state.profile.id, 'second');
      expect(state.plants, hasLength(1));
      expect(state.history, hasLength(1));
      expect(state.history.single.timeElapsed, 0);
      expect(state.isRunning, isFalse);
    });

    test('loading a scenario clears a pre-calculated timeline', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('first'));
      await notifier.preCalculateTimeline(1);
      expect(
        container.read(simulationProvider).history.length,
        greaterThan(1),
      );

      notifier.loadScenario(_scenario('second'));

      final state = container.read(simulationProvider);
      expect(state.history, hasLength(1));
      expect(state.timeElapsed, 0);
      expect(state.currentScenario?.id, 'second');
    });
  });

  group('resume availability', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a pristine session is not resumable', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      expect(await notifier.hasSavedState(), isFalse);
    });

    test('a stored snapshot makes the session resumable', () async {
      SharedPreferences.setMockInitialValues({
        'last_biophysical_state': '{"timeElapsed": 10}',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      expect(await notifier.hasSavedState(), isTrue);
    });

    test('a live run is resumable even before the first periodic save',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('live'));
      await notifier.preCalculateTimeline(1);
      expect(
        container.read(simulationProvider).history.length,
        greaterThan(1),
      );

      expect(await notifier.hasSavedState(), isTrue);
    });
  });
}
