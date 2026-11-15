import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/services/simulation_persistence.dart';
import 'package:soilscope/domain/solvers/mycorrhiza_solver.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';
import 'package:soilscope/presentation/providers/simulation_session_provider.dart';
import 'package:soilscope/presentation/providers/ui_state_provider.dart';

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
      expect(
        advanced,
        isTrue,
        reason: 'the simulation isolate should deliver a tick',
      );
      notifier.stop();

      notifier.loadScenario(_scenario('second'));

      final state = container.read(simulationProvider);
      expect(
        state.timeElapsed,
        0,
        reason: 'the clock must not carry over between scenarios',
      );
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
      expect(container.read(simulationProvider).history.length, greaterThan(1));

      notifier.loadScenario(_scenario('second'));

      final state = container.read(simulationProvider);
      expect(state.history, hasLength(1));
      expect(state.timeElapsed, 0);
      expect(state.currentScenario?.id, 'second');
    });

    test('repeated scenario loads keep resetting the session', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);
      final session = container.read(simulationSessionProvider.notifier);

      for (final id in ['first', 'second', 'third']) {
        notifier.loadScenario(_scenario(id));
        session.selectLayer('A1');
        await Future<void>.delayed(Duration.zero);

        final state = container.read(simulationProvider);
        expect(state.currentScenario?.id, id);
        expect(state.timeElapsed, 0);
        expect(state.history, hasLength(1));
        expect(state.isRunning, isFalse);
        expect(container.read(simulationSessionProvider).selectedLayerId, 'A1');
      }
    });

    test(
      'loading a scenario clears inspection and HUD selection state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(simulationProvider.notifier);
        final session = container.read(simulationSessionProvider.notifier);
        final ui = container.read(uIStateProvider.notifier);

        notifier.loadScenario(_scenario('first'));
        session.selectLayer('A1');
        session.selectInspector('leaf');
        session.selectElement('N');
        ui.setHoverInfo(
          HoverInfo(
            title: 'LEAF',
            description: 'Pinned inspection',
            isPinned: true,
            sourceId: 'inspection-leaf',
          ),
        );
        await Future<void>.delayed(Duration.zero);

        notifier.loadScenario(_scenario('second'));

        final state = container.read(simulationSessionProvider);
        expect(state.selectedLayerId, isNull);
        expect(state.selectedInspectorType, isNull);
        expect(state.selectedElementSymbol, isNull);
        expect(state.isMicroscopeEnabled, isFalse);
        expect(state.isScrubbing, isFalse);
        expect(state.viewTime, 0);
        expect(container.read(uIStateProvider), isNull);
      },
    );
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
        SimulationPersistence.legacyStateKey: '{"timeElapsed": 10}',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      expect(await notifier.hasSavedState(), isTrue);
    });

    test('a corrupt stored session is cleared instead of resumed', () async {
      SharedPreferences.setMockInitialValues({
        SimulationPersistence.stateKey: 'not-json',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      expect(await notifier.hasSavedState(), isTrue);
      expect(await notifier.loadLastState(), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SimulationPersistence.stateKey), isFalse);
    });

    test(
      'a live run is resumable even before the first periodic save',
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
      },
    );
  });

  group('pre-calculation cancellation', () {
    test('cancelling leaves the timeline and scrub state untouched', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('cancel'));
      final before = container.read(simulationProvider).history.length;

      final completed = await notifier.preCalculateTimeline(
        30,
        shouldCancel: () => true,
      );

      expect(completed, isFalse);
      expect(container.read(simulationProvider).history.length, before);
      expect(container.read(simulationSessionProvider).isScrubbing, isFalse);
    });
  });

  group('pre-calculation snapshots', () {
    test(
      'three days produce the start plus twelve six-hourly snapshots',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(simulationProvider.notifier);

        notifier.loadScenario(_scenario('snapshots'));
        final completed = await notifier.preCalculateTimeline(3);

        expect(completed, isTrue);
        expect(
          container.read(simulationSessionProvider).isScrubbing,
          isFalse,
          reason: 'a completed pre-calculation must leave history mode',
        );
        final history = container.read(simulationProvider).history;
        expect(history, hasLength(13));
        expect(history.first.timeElapsed, 0);
        expect(history[1].timeElapsed, closeTo(3600, 1));
        for (var i = 2; i < history.length; i++) {
          expect(
            history[i].timeElapsed - history[i - 1].timeElapsed,
            closeTo(21600, 1),
            reason: 'snapshots must stay six simulated hours apart',
          );
        }
      },
    );
  });

  group('timeline display state', () {
    test('history mode opens from the initial snapshot', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('initial-timeline'));
      expect(container.read(simulationProvider).history, hasLength(1));

      notifier.startScrubbing();
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(simulationSessionProvider).isScrubbing,
        isTrue,
        reason: 'the timeline view is available from launch',
      );
      expect(container.read(simulationSessionProvider).viewTime, 0);
      expect(container.read(simulationProvider).isRunning, isFalse);
    });

    test('a timeline is available before it has a scrub range', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(simulationProvider);
      final initial = [state.copyWith(timeElapsed: 0)];
      final withRange = [...initial, state.copyWith(timeElapsed: 600)];

      expect(hasTimelineHistory(initial), isTrue);
      expect(hasTimelineHistory(const []), isFalse);
      expect(hasTimelineRange(initial), isFalse);
      expect(hasTimelineRange(withRange), isTrue);
    });

    test(
      'scrubbing shows a snapshot that still carries the full run history',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(simulationProvider.notifier);

        notifier.loadScenario(_scenario('displayed'));
        await notifier.preCalculateTimeline(1);
        final history = container.read(simulationProvider).history;
        expect(history.length, greaterThan(2));

        notifier.startScrubbing();
        final target = history[history.length ~/ 2].timeElapsed;
        notifier.scrubTo(target);
        await Future<void>.delayed(Duration.zero);

        final displayed = container.read(displayedSimulationStateProvider);
        expect(displayed.timeElapsed, closeTo(target, 1));
        expect(displayed.profile.id, 'displayed');
        expect(
          displayed.history,
          hasLength(history.length),
          reason:
              'report widgets need the run timeline while values are historical',
        );
      },
    );

    test('editing a live value leaves history mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('edit'));
      await notifier.preCalculateTimeline(1);
      notifier.startScrubbing();
      final layerId = container
          .read(simulationProvider)
          .profile
          .layers
          .first
          .id;

      notifier.updateLayer(layerId, (layer) => layer.copyWith(ph: 6.4));

      expect(
        container.read(simulationSessionProvider).isScrubbing,
        isFalse,
        reason: 'an edit must not be applied behind a historical display',
      );
      expect(container.read(simulationProvider).profile.layers.first.ph, 6.4);
    });

    test('starting a run leaves history mode', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      notifier.loadScenario(_scenario('resume'));
      await notifier.preCalculateTimeline(1);
      notifier.startScrubbing();
      expect(container.read(simulationSessionProvider).isScrubbing, isTrue);

      notifier.start();
      expect(
        container.read(simulationSessionProvider).isScrubbing,
        isFalse,
        reason: 'the visible snapshot must follow the live engine again',
      );
      notifier.stop();
    });
  });

  group('state ownership', () {
    test(
      'every BiophysicalState field is classified as UI- or engine-owned',
      () {
        final state = BiophysicalState(
          profile: _profile('classification'),
          plants: const [],
          timeElapsed: 0,
        );

        // `history` is excluded from JSON to avoid recursive nesting.
        final fields = state.toJson().keys.toSet()..add('history');
        final classified = {...Simulation.uiFields, ...Simulation.engineFields};

        expect(
          fields.difference(classified),
          isEmpty,
          reason: 'new state fields must be added to the UI or engine set',
        );
        expect(
          classified.difference(fields),
          isEmpty,
          reason: 'classifier names that no longer exist',
        );
      },
    );

    test('mycorrhiza state survives a JSON round trip', () {
      final state = BiophysicalState(
        profile: _profile('mycorrhiza'),
        plants: const [],
        timeElapsed: 0,
        mycorrhizaState: const MycorrhizaState(
          rootColonization: 0.4,
          fungalBiomass: 12.5,
          layerHyphalDensities: [1.0, 2.0],
        ),
      );

      final decoded = BiophysicalState.fromJson(
        jsonDecode(jsonEncode(state)) as Map<String, dynamic>,
      );

      expect(decoded.mycorrhizaState?.rootColonization, 0.4);
      expect(decoded.mycorrhizaState?.fungalBiomass, 12.5);
      expect(decoded.mycorrhizaState?.layerHyphalDensities, [1.0, 2.0]);
    });
  });
}
