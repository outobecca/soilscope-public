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

    test(
      'speed and weather controls update session fields and leave history',
      () {
        final host = _Host();

        host.interventions.setSpeed(5.0);
        expect(host.state.timeScale, 5.0);
        expect(host.leftHistory, isFalse);

        host.interventions.setPrecipitation(12.5);
        expect(host.leftHistory, isTrue);
        expect(host.state.precipitation, 12.5);

        host.leftHistory = false;
        host.interventions.toggleAutoWeather();
        expect(host.leftHistory, isTrue);
        expect(host.state.autoWeather, isTrue);

        host.leftHistory = false;
        host.interventions.setAutoWeather(false);
        expect(host.leftHistory, isTrue);
        expect(host.state.autoWeather, isFalse);

        host.leftHistory = false;
        host.interventions.updateWeather(301.15, 0.72);
        expect(host.leftHistory, isTrue);
        expect(host.state.airTemperature, 301.15);
        expect(host.state.relativeHumidity, 0.72);

        host.leftHistory = false;
        host.interventions.updateSolarRadiation(640.0);
        expect(host.leftHistory, isTrue);
        expect(host.state.solarRadiationOverride, 640.0);

        host.leftHistory = false;
        host.interventions.updatePAR(420.0);
        expect(host.leftHistory, isTrue);
        expect(host.state.solarRadiationOverride, closeTo(200.0, 1e-12));
      },
    );

    test(
      'extreme weather, organic matter, drainage and explicit cover crop log events',
      () {
        final host = _Host();

        host.interventions.setCoverCrop(true);
        expect(host.state.hasCoverCrop, isTrue);
        expect(host.logs.last, 'Cover crop planted.');

        host.interventions.triggerHeatWave();
        expect(host.logs.last, 'Heat wave!');
        expect(host.state.precipitation, 0.0);

        host.interventions.triggerFlashFlood();
        expect(host.logs.last, 'Flash flood!');
        expect(host.state.precipitation, greaterThan(0));

        final beforeCarbon = host.state.profile.layers.first.organicCarbon;
        host.interventions.applyOrganicMatter();
        expect(host.logs.last, 'Organic matter incorporated.');
        expect(
          host.state.profile.layers.first.organicCarbon,
          greaterThan(beforeCarbon),
        );

        final beforeWater = host.state.profile.layers.first.waterContent;
        host.interventions.applyDrainage();
        expect(host.logs.last, 'Soil drained and re-aerated.');
        expect(
          host.state.profile.layers.first.waterContent,
          lessThanOrEqualTo(beforeWater),
        );

        final beforeK = host.state.profile.layers.first.potassiumContent;
        host.interventions.updateNutrient('A', 'K', 11.0);
        expect(
          host.state.profile.layers.first.potassiumContent,
          closeTo(beforeK + 11.0, 1e-12),
        );
      },
    );

    test(
      'all named layer parameters update cleanly and ignore unknown keys',
      () {
        final host = _Host();

        host.interventions
          ..updateLayerParameter('A', 'kSat', 3.5e-5)
          ..updateLayerParameter('A', 'vgAlpha', 2.4)
          ..updateLayerParameter('A', 'vgN', 1.8)
          ..updateLayerParameter('A', 'sandFraction', 0.5)
          ..updateLayerParameter('A', 'siltFraction', 0.3)
          ..updateLayerParameter('A', 'clayFraction', 0.2)
          ..updateLayerParameter('A', 'organicCarbon', 18.0)
          ..updateLayerParameter('A', 'bulkDensity', 1250.0)
          ..updateLayerParameter('A', 'porosity', 0.48)
          ..updateLayerParameter('A', 'nitrateContent', 88.0)
          ..updateLayerParameter('A', 'phosphateContent', 19.0)
          ..updateLayerParameter('A', 'potassiumContent', 64.0)
          ..updateLayerParameter('A', 'unknownParam', 999.0);

        final layer = host.state.profile.layers.first;
        expect(layer.kSat, 3.5e-5);
        expect(layer.vgAlpha, 2.4);
        expect(layer.vgN, 1.8);
        expect(layer.sandFraction, 0.5);
        expect(layer.siltFraction, 0.3);
        expect(layer.clayFraction, 0.2);
        expect(layer.organicCarbon, 18.0);
        expect(layer.bulkDensity, 1250.0);
        expect(layer.porosity, 0.48);
        expect(layer.nitrateContent, 88.0);
        expect(layer.phosphateContent, 19.0);
        expect(layer.potassiumContent, 64.0);
      },
    );
  });
}
