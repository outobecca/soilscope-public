// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biophysical_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BiophysicalState _$BiophysicalStateFromJson(Map<String, dynamic> json) =>
    _BiophysicalState(
      profile: SoilProfile.fromJson(json['profile'] as Map<String, dynamic>),
      plants: (json['plants'] as List<dynamic>)
          .map((e) => Plant.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeElapsed: (json['timeElapsed'] as num).toDouble(),
      currentScenario: json['currentScenario'] == null
          ? null
          : Scenario.fromJson(json['currentScenario'] as Map<String, dynamic>),
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      soilEvaporation: (json['soilEvaporation'] as num?)?.toDouble() ?? 0.0,
      airTemperature: (json['airTemperature'] as num?)?.toDouble() ?? 293.15,
      relativeHumidity: (json['relativeHumidity'] as num?)?.toDouble() ?? 0.5,
      atmCO2: (json['atmCO2'] as num?)?.toDouble() ?? 0.017,
      autoWeather: json['autoWeather'] as bool? ?? false,
      timeScale: (json['timeScale'] as num?)?.toDouble() ?? 1.0,
      hasCoverCrop: json['hasCoverCrop'] as bool? ?? false,
      isRunning: json['isRunning'] as bool? ?? false,
      isInitializing: json['isInitializing'] as bool? ?? true,
      score: json['score'] == null
          ? const SustainabilityScore()
          : SustainabilityScore.fromJson(json['score'] as Map<String, dynamic>),
      solarRadiationOverride: (json['solarRadiationOverride'] as num?)
          ?.toDouble(),
    );

Map<String, dynamic> _$BiophysicalStateToJson(_BiophysicalState instance) =>
    <String, dynamic>{
      'profile': instance.profile,
      'plants': instance.plants,
      'timeElapsed': instance.timeElapsed,
      'currentScenario': instance.currentScenario,
      'precipitation': instance.precipitation,
      'soilEvaporation': instance.soilEvaporation,
      'airTemperature': instance.airTemperature,
      'relativeHumidity': instance.relativeHumidity,
      'atmCO2': instance.atmCO2,
      'autoWeather': instance.autoWeather,
      'timeScale': instance.timeScale,
      'hasCoverCrop': instance.hasCoverCrop,
      'isRunning': instance.isRunning,
      'isInitializing': instance.isInitializing,
      'score': instance.score,
      'solarRadiationOverride': instance.solarRadiationOverride,
    };
