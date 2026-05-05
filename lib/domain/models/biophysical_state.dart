import 'dart:math' as math;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'soil_profile.dart';
import 'plant.dart';
import 'sustainability_score.dart';
import 'scenario.dart';
import '../solvers/mycorrhiza_solver.dart';

part 'biophysical_state.freezed.dart';
part 'biophysical_state.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class BiophysicalState with _$BiophysicalState {
  const BiophysicalState._();

  const factory BiophysicalState({
    required SoilProfile profile,
    required List<Plant> plants,
    required double timeElapsed,
    Scenario? currentScenario,
    @Default(0.0) double precipitation,
    @Default(0.0) double soilEvaporation,
    @Default(293.15) double airTemperature,
    @Default(0.5) double relativeHumidity,
    @Default(0.017) double atmCO2, // mol/m3 (approx 415 ppm)
    @Default(false) bool autoWeather,
    @Default(1.0) double timeScale,
    @Default(false) bool hasCoverCrop,
    @Default(false) bool isRunning,
    @Default([])
    @JsonKey(includeFromJson: false, includeToJson: false)
    List<BiophysicalState> history,
    @Default(SustainabilityScore()) SustainabilityScore score,
    double? solarRadiationOverride,

    /// Mycorrhizal symbiosis state tracking colonization and nutrient exchange
    @JsonKey(includeFromJson: false, includeToJson: false)
    MycorrhizaState? mycorrhizaState,
  }) = _BiophysicalState;

  /// Convenience getter for the primary plant in the collection
  Plant get plant => plants.isNotEmpty ? plants.first : const Plant(
    id: "stub",
    species: "None",
    age: 0,
    height: 0,
    lai: 0,
    turgorPressure: 0,
    rootSystem: [],
    nitrogenUptake: 0,
    waterUptake: 0,
  );

  factory BiophysicalState.fromJson(Map<String, dynamic> json) =>
      _$BiophysicalStateFromJson(json);

  double get solarRadiation {
    if (solarRadiationOverride != null) return solarRadiationOverride!;
    const double solarConstant = 800.0;
    final double dayTime = timeElapsed % 86400.0;
    final double hourAngle = (dayTime / 86400.0) * 2.0 * math.pi;
    return math.max(0.0, math.sin(hourAngle - math.pi / 2.0)) * solarConstant;
  }

  /// Photosynthetically Active Radiation [µmol/m²/s]
  double get par {
    // Conversion factor from solar radiation (W/m2) to PAR (umol/m2/s)
    // Roughly 2.1 for daylight spectrum
    return solarRadiation * 2.1;
  }
}
