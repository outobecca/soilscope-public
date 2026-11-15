import 'package:flutter_test/flutter_test.dart';

import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/services/validation_reference_run.dart';
import 'package:soilscope/domain/solvers/simulation_engine.dart';

/// These are direction checks, not calibration: each perturbation must move
/// the modelled quantity the way the underlying process implies, with a
/// generous margin so the tests stay meaningful without pinning exact numbers.
List<BiophysicalState> _run(BiophysicalState initial, {int hours = 168}) {
  final history = <BiophysicalState>[initial];
  var current = initial;
  for (var i = 0; i < hours; i++) {
    current = SimulationEngine.tick(current, 3600);
    history.add(current);
  }
  return history;
}

BiophysicalState _mapLayers(
  BiophysicalState state,
  SoilLayer Function(SoilLayer layer) transform,
) {
  return state.copyWith(
    profile: state.profile.copyWith(
      layers: state.profile.layers.map(transform).toList(),
    ),
  );
}

double _totalWater(BiophysicalState state) => state.profile.layers.fold(
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

void main() {
  group('sensitivity', () {
    late BiophysicalState baselineEnd;

    setUpAll(() {
      baselineEnd = _run(ValidationReferenceRun.initialState()).last;
    });

    test('higher saturated conductivity drains more water', () {
      final drained = _mapLayers(
        ValidationReferenceRun.initialState(),
        (layer) => layer.copyWith(kSat: layer.kSat * 10),
      );
      final end = _run(drained).last;
      expect(_totalWater(end), lessThan(_totalWater(baselineEnd) * 0.999));
    });

    test('warmer subsoil stays warmer through the run', () {
      final warmed = _mapLayers(
        ValidationReferenceRun.initialState(),
        (layer) => layer.copyWith(temperature: layer.temperature + 10),
      );
      final end = _run(warmed).last;
      // The top layer is strongly coupled to the air and damps most of the
      // perturbation; the subsoil keeps a clear, monotonic signal.
      expect(
        end.profile.layers.last.temperature,
        greaterThan(baselineEnd.profile.layers.last.temperature + 1.0),
      );
      expect(_totalWater(end), greaterThan(0));
    });

    test('a wetter start leaves more water at the end', () {
      final wetter = _mapLayers(
        ValidationReferenceRun.initialState(),
        (layer) => layer.copyWith(waterContent: layer.waterContent * 1.1),
      );
      final end = _run(wetter).last;
      expect(_totalWater(end), greaterThan(_totalWater(baselineEnd) * 1.001));
    });

    test('more initial nitrate leaves more mineral nitrogen at the end', () {
      final enriched = _mapLayers(
        ValidationReferenceRun.initialState(),
        (layer) => layer.copyWith(nitrateContent: layer.nitrateContent * 2),
      );
      final initial = ValidationReferenceRun.initialState();
      expect(_mineralN(enriched), greaterThan(_mineralN(initial)));
      final end = _run(enriched).last;
      expect(_mineralN(end), greaterThan(_mineralN(baselineEnd) * 1.01));
    });

    test('a tenfold conductivity change does not destabilise the run', () {
      final altered = _mapLayers(
        ValidationReferenceRun.initialState(),
        (layer) => layer.copyWith(kSat: layer.kSat * 10),
      );
      final history = _run(altered);
      for (final state in history) {
        for (final layer in state.profile.layers) {
          expect(layer.waterContent.isFinite, isTrue);
          expect(layer.waterContent, greaterThanOrEqualTo(layer.thetaR - 1e-9));
          expect(layer.waterContent, lessThanOrEqualTo(layer.porosity + 1e-9));
        }
      }
    });
  });
}
