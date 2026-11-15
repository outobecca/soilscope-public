import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/domain/models/biophysical_state.dart';
import 'package:soilscope/domain/models/soil_layer.dart';
import 'package:soilscope/domain/models/soil_profile.dart';
import 'package:soilscope/domain/services/simulation_tick_processor.dart';

SoilProfile _profile() => const SoilProfile(
  id: 'p',
  name: 'p',
  layers: [
    SoilLayer(
      id: 'A1',
      depth: 0,
      thickness: 0.3,
      kSat: 1e-6,
      porosity: 0.45,
      thetaR: 0.05,
      vgAlpha: 1.5,
      vgN: 1.5,
      bulkDensity: 1400,
      waterContent: 0.25,
      temperature: 293.15,
      heatCapacity: 800,
      ph: 6.5,
      ec: 0.2,
      redoxPotential: 500,
      nitrateContent: 15,
      ammoniumContent: 5,
      phosphateContent: 5,
      potassiumContent: 25,
      aggregateStability: 0.5,
      microbialBiomass: 40,
      epsContent: 0,
      fungalHyphaeDensity: 0,
      necromass: 0,
      organicCarbon: 10,
      mineralAssociatedOrganicMatter: 10,
      particulateOrganicMatter: 0.5,
      nitrogenContent: 0.2,
    ),
  ],
  surfaceAlbedo: 0.2,
  slope: 0,
);

BiophysicalState _state({
  required double time,
  double airTemperature = 293.15,
  bool autoWeather = false,
  bool isRunning = true,
}) => BiophysicalState(
  profile: _profile(),
  plants: const [],
  timeElapsed: time,
  airTemperature: airTemperature,
  autoWeather: autoWeather,
  isRunning: isRunning,
);

void main() {
  group('SimulationTickProcessor', () {
    test('UI-owned atmospheric values win while auto weather is off', () {
      final merged = mergeSimulationState(
        _state(time: 10, airTemperature: 300, autoWeather: true),
        _state(time: 10, airTemperature: 280),
      );
      expect(merged.airTemperature, 280);
      expect(merged.isRunning, isTrue);
    });

    test('engine atmospheric values win while auto weather is on', () {
      final merged = mergeSimulationState(
        _state(time: 10, airTemperature: 300, autoWeather: true),
        _state(time: 10, airTemperature: 280, autoWeather: true),
      );
      expect(merged.airTemperature, 300);
    });

    test('snapshots follow simulation time, not tick count', () {
      final history = <BiophysicalState>[_state(time: 0)];
      final processor = SimulationTickProcessor(history: history);

      final atSixHundred = processor.process(
        engineState: _state(time: 600),
        uiState: _state(time: 600),
      );
      expect(atSixHundred.snapshotAdded, isTrue);
      expect(history.last.timeElapsed, 600);
      expect(history.last.history, isEmpty);

      final atNineHundred = processor.process(
        engineState: _state(time: 900),
        uiState: _state(time: 900),
      );
      expect(atNineHundred.snapshotAdded, isFalse);
      expect(history.last.timeElapsed, 600);
    });

    test('event state is returned before UI overrides are merged', () {
      final processor = SimulationTickProcessor(
        history: <BiophysicalState>[_state(time: 0)],
      );
      final result = processor.process(
        engineState: _state(time: 10, airTemperature: 300, autoWeather: true),
        uiState: _state(time: 0, airTemperature: 280),
      );

      expect(result.entry.airTemperature, 280);
      expect(result.eventState.airTemperature, 300);
    });
  });
}
