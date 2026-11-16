import 'package:flutter_test/flutter_test.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/services/simulation_interventions.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';

class _Host {
  BiophysicalState state = ValidationReferenceRun.initialState();
  final List<String> logs = [];
  final List<double> logTimes = [];
  bool leftHistory = false;
  int writes = 0;
  String? selected;
  bool disposed = false;

  late final SimulationInterventions interventions = SimulationInterventions(
    readState: () => state,
    apply: (next) {
      state = next;
      writes++;
    },
    log: (message, time) {
      logs.add(message);
      logTimes.add(time);
    },
    leaveHistoryMode: () => leftHistory = true,
    selectedLayerId: () => selected,
    isDisposed: () => disposed,
  );
}

void main() {
  group('interventions', () {
    test('tillage mutates the top layers and logs once', () {
      final host = _Host();
      final before = host.state.profile.layers.first.bulkDensity;

      expect(host.interventions.applyTillage(), isTrue);

      expect(host.leftHistory, isTrue);
      expect(host.writes, 1);
      expect(
        host.state.profile.layers.first.bulkDensity,
        closeTo(before * 0.9, 1e-9),
      );
      expect(host.logs, ['Soil tilled.']);
      expect(host.logTimes, [host.state.timeElapsed]);
    });

    test('irrigation reports the requested depth and writes once', () {
      final host = _Host();
      final before = host.state.profile.layers.first.waterContent;

      host.interventions.applyIrrigation(amountMm: 10);

      expect(host.writes, 1);
      expect(
        host.state.profile.layers.first.waterContent,
        closeTo(before + 10 / 300, 1e-9),
      );
      expect(host.logs, ['Irrigation applied (10 mm).']);
    });

    test('cover crop toggles and names the resulting state', () {
      final host = _Host();

      host.interventions.applyCoverCrop();
      expect(host.state.hasCoverCrop, isTrue);
      expect(host.logs.last, 'Cover crop planted.');

      host.interventions.applyCoverCrop();
      expect(host.state.hasCoverCrop, isFalse);
      expect(host.logs.last, 'Cover crop removed.');
      expect(host.writes, 2);
    });

    test('setting the current cover-crop state is a no-op', () {
      final host = _Host();

      host.interventions.setCoverCrop(false);

      expect(host.writes, 0);
      expect(host.logs, isEmpty);
      expect(host.state.hasCoverCrop, isFalse);
    });

    test('a quick nutrient dose targets the selected layer', () {
      final host = _Host()..selected = 'B';
      final before = host.state.profile.layers.last.nitrateContent;

      host.interventions.applyQuickNutrient('N');

      expect(
        host.state.profile.layers.last.nitrateContent,
        closeTo(before + 20, 1e-12),
      );
      expect(host.logs, ['N applied to B.']);
    });

    test('a fertilizer mix falls back to the topsoil without a selection', () {
      final host = _Host();
      final beforeN = host.state.profile.layers.first.nitrateContent;
      final beforeP = host.state.profile.layers.first.phosphateContent;

      host.interventions.applyNutrients({'N': 7, 'P': 3});

      expect(host.leftHistory, isTrue);
      expect(host.writes, 1);
      expect(
        host.state.profile.layers.first.nitrateContent,
        closeTo(beforeN + 7, 1e-12),
      );
      expect(
        host.state.profile.layers.first.phosphateContent,
        closeTo(beforeP + 3, 1e-12),
      );
    });

    test('a stale layer selection falls back to the topsoil', () {
      final host = _Host()..selected = 'removed-layer';
      final before = host.state.profile.layers.first.nitrateContent;

      host.interventions.applyNutrients({'N': 4});

      expect(
        host.state.profile.layers.first.nitrateContent,
        closeTo(before + 4, 1e-12),
      );
      expect(host.writes, 1);
    });

    test('an empty fertilizer mix is a no-op', () {
      final host = _Host();

      host.interventions.applyNutrients(const {});

      expect(host.writes, 0);
      expect(host.leftHistory, isFalse);
    });

    test('a quick dose falls back to the topsoil', () {
      final host = _Host();
      final before = host.state.profile.layers.first.nitrateContent;

      host.interventions.applyQuickNutrient('N', amount: 5);

      expect(
        host.state.profile.layers.first.nitrateContent,
        closeTo(before + 5, 1e-12),
      );
      expect(host.logs, ['N applied to A.']);
    });

    test('an atmosphere selection is not a soil layer', () {
      final host = _Host()..selected = 'atmosphere';
      final before = host.state.profile.layers.first.nitrateContent;

      host.interventions.applyQuickNutrient('N');

      expect(
        host.state.profile.layers.first.nitrateContent,
        closeTo(before + 20, 1e-12),
      );
    });

    test('atmosphere edits keep unspecified values', () {
      final host = _Host();
      final before = host.state;

      host.interventions.updateAtmosphere(co2: 0.05);

      expect(host.state.atmCO2, 0.05);
      expect(host.state.airTemperature, before.airTemperature);
      expect(host.state.relativeHumidity, before.relativeHumidity);
      expect(host.state.precipitation, before.precipitation);
      expect(host.writes, 1);
    });

    test('linked Lab parameters update the target layer', () {
      final host = _Host();
      final beforeWater = host.state.profile.layers.first.waterContent;

      host.interventions.updateLayerParameter('A', 'waterContent', 0.35);
      host.interventions.updateLayerParameter('A', 'ammoniumContent', 42);
      host.interventions.updateLayerParameter('A', 'organicNitrogen', 77);
      host.interventions.updateLayerParameter('A', 'redoxPotential', 123);

      final layer = host.state.profile.layers.first;
      expect(layer.previousWaterContent, closeTo(beforeWater, 1e-12));
      expect(layer.waterContent, closeTo(0.35, 1e-12));
      expect(layer.ammoniumContent, 42);
      expect(layer.organicNitrogen, 77);
      expect(layer.redoxPotential, 123);
    });

    test('thetaR edits keep water content above the new residual', () {
      final host = _Host();

      host.interventions.updateLayerParameter('A', 'thetaR', 0.45);

      final layer = host.state.profile.layers.first;
      expect(layer.thetaR, 0.4);
      expect(layer.waterContent, greaterThanOrEqualTo(layer.thetaR));
    });

    test('layer edits leave history mode and write once', () {
      final host = _Host();

      host.interventions.updateLayer(
        'A',
        (layer) => layer.copyWith(kSat: 2e-5),
      );

      expect(host.leftHistory, isTrue);
      expect(host.writes, 1);
      expect(host.state.profile.layers.first.kSat, 2e-5);
    });

    test('a disposed provider ignores layer edits', () {
      final host = _Host()..disposed = true;

      host.interventions.updateLayer(
        'A',
        (layer) => layer.copyWith(kSat: 2e-5),
      );

      expect(host.writes, 0);
      expect(host.leftHistory, isFalse);
    });
  });
}
