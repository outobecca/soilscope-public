import 'package:freezed_annotation/freezed_annotation.dart';
import 'soil_profile.dart';

part 'scenario.freezed.dart';
part 'scenario.g.dart';

@freezed
abstract class MissionObjective with _$MissionObjective {
  const factory MissionObjective({
    required String id,
    required String title,
    required double targetValue,
    required String type, // 'yield', 'carbon', 'structure', 'pollution'
    @Default(false) bool isMet,
  }) = _MissionObjective;

  factory MissionObjective.fromJson(Map<String, dynamic> json) =>
      _$MissionObjectiveFromJson(json);
}

@freezed
abstract class ScenarioTutorialStep with _$ScenarioTutorialStep {
  const factory ScenarioTutorialStep({
    required double triggerTime, // Seconds or simulated ticks
    required String targetId, // UI or Engine component to highlight
    required String title,
    required String description,
  }) = _ScenarioTutorialStep;

  factory ScenarioTutorialStep.fromJson(Map<String, dynamic> json) =>
      _$ScenarioTutorialStepFromJson(json);
}

@freezed
abstract class CultivationEvent with _$CultivationEvent {
  const factory CultivationEvent({
    required double executionTime,
    required String type, // 'fertilize', 'till', 'water'
    @Default(0.0) double amount,
    String? layerId,
    String? extraData,
  }) = _CultivationEvent;

  factory CultivationEvent.fromJson(Map<String, dynamic> json) =>
      _$CultivationEventFromJson(json);
}

@freezed
abstract class Scenario with _$Scenario {
  const factory Scenario({
    required String id,
    required String title,
    required String description,
    required SoilProfile initialProfile,
    required Map<String, dynamic> weatherData,
    @Default([]) List<MissionObjective> objectives,
    @Default([]) List<String> features,
    @Default([]) List<ScenarioTutorialStep> tutorialSteps,
    @Default([]) List<CultivationEvent> cultivationPlan,
  }) = _Scenario;

  factory Scenario.fromJson(Map<String, dynamic> json) =>
      _$ScenarioFromJson(json);
}

