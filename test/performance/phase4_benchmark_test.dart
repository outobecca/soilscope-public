import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/scenario.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/services/timeline_precalculation.dart';
import 'package:soilscope/domain/solvers/simulation_engine.dart';
import 'package:soilscope/presentation/providers/simulation_provider.dart';

SoilLayer _layer(String id, double depth, double thickness, double kSat) {
  return SoilLayer(
    id: id,
    depth: depth,
    thickness: thickness,
    kSat: kSat,
    porosity: 0.45,
    thetaR: 0.05,
    vgAlpha: 1.5,
    vgN: 1.5,
    bulkDensity: 1400.0,
    waterContent: 0.25,
    temperature: 293.15,
    heatCapacity: 2.4e6,
    ph: 6.5,
    ec: 0.2,
    redoxPotential: 400.0,
    nitrateContent: 15.0,
    ammoniumContent: 5.0,
    phosphateContent: 5.0,
    microbialBiomass: 40.0,
    epsContent: 0.0,
    fungalHyphaeDensity: 0.0,
    necromass: 0.0,
    organicCarbon: 10.0,
    mineralAssociatedOrganicMatter: 10.0,
    particulateOrganicMatter: 0.5,
    nitrogenContent: 0.2,
  );
}

BiophysicalState _state() {
  return BiophysicalState(
    profile: SoilProfile(
      id: 'phase4-benchmark',
      name: 'Phase 4 benchmark',
      layers: [_layer('A1', 0.0, 0.3, 1e-5), _layer('B1', 0.3, 0.5, 5e-6)],
      surfaceAlbedo: 0.2,
      slope: 0.02,
    ),
    plants: const [],
    timeElapsed: 0,
  );
}

Scenario _scenario(String id) {
  return Scenario(
    id: id,
    title: id,
    description: id,
    initialProfile: _state().profile,
    weatherData: const {},
  );
}

int _median(List<int> values) {
  values.sort();
  return values[values.length ~/ 2];
}

const _runMemorySample = bool.fromEnvironment('PHASE4_MEMORY');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('engine tick baseline', () {
    const ticksPerSample = 40;
    const sampleCount = 5;

    var warmup = _state();
    for (var i = 0; i < 20; i++) {
      warmup = SimulationEngine.tick(warmup, 3600);
    }

    final samples = <int>[];
    for (var sample = 0; sample < sampleCount; sample++) {
      var state = _state();
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < ticksPerSample; i++) {
        state = SimulationEngine.tick(state, 3600);
      }
      stopwatch.stop();
      samples.add(stopwatch.elapsedMicroseconds);
    }

    final median = _median(samples);
    debugPrint(
      'phase4.engine_tick_median_us=${median ~/ ticksPerSample} '
      '($ticksPerSample ticks/sample, $sampleCount samples)',
    );
  });

  test('one-day timeline pre-calculation baseline', () {
    final base = _state();
    final stopwatch = Stopwatch()..start();
    final (_, history) = preCalculateTimelineTask((base, 1));
    stopwatch.stop();

    debugPrint(
      'phase4.precalculation_1day_ms=${stopwatch.elapsedMilliseconds} '
      'snapshots=${history.length}',
    );
    expect(history, isNotEmpty);
  });

  test('timeline history lookup baseline', () {
    final base = _state();
    final history = List<BiophysicalState>.generate(
      2000,
      (index) => base.copyWith(timeElapsed: index * 600.0),
    );
    const queries = 100000;
    var found = 0;

    final stopwatch = Stopwatch()..start();
    for (var query = 0; query < queries; query++) {
      final time = (query * 7919.0) % (history.length * 600.0);
      if (nearestHistorySnapshotIndex(history, time) >= 0) found++;
    }
    stopwatch.stop();

    debugPrint(
      'phase4.history_lookup_us_for_$queries=${stopwatch.elapsedMicroseconds} '
      'snapshots=${history.length}',
    );
    expect(found, queries);
  });

  test(
    'repeated scenario loads memory sample',
    () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(simulationProvider.notifier);

      final before = ProcessInfo.currentRss;
      for (var i = 0; i < 20; i++) {
        notifier.loadScenario(_scenario('phase4-memory-$i'));
        await Future<void>.delayed(Duration.zero);
      }
      final after = ProcessInfo.currentRss;

      debugPrint(
        'phase4.scenario_load_rss_delta_bytes=${after - before} '
        'loads=20',
      );
      expect(
        container.read(simulationProvider).currentScenario?.id,
        'phase4-memory-19',
      );
    },
    skip: _runMemorySample
        ? false
        : 'Run with --dart-define=PHASE4_MEMORY=true for the memory sample',
  );
}
