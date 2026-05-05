// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MissionObjective _$MissionObjectiveFromJson(Map<String, dynamic> json) =>
    _MissionObjective(
      id: json['id'] as String,
      title: json['title'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      type: json['type'] as String,
      isMet: json['isMet'] as bool? ?? false,
    );

Map<String, dynamic> _$MissionObjectiveToJson(_MissionObjective instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'targetValue': instance.targetValue,
      'type': instance.type,
      'isMet': instance.isMet,
    };

_ScenarioTutorialStep _$ScenarioTutorialStepFromJson(
  Map<String, dynamic> json,
) => _ScenarioTutorialStep(
  triggerTime: (json['triggerTime'] as num).toDouble(),
  targetId: json['targetId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$ScenarioTutorialStepToJson(
  _ScenarioTutorialStep instance,
) => <String, dynamic>{
  'triggerTime': instance.triggerTime,
  'targetId': instance.targetId,
  'title': instance.title,
  'description': instance.description,
};

_CultivationEvent _$CultivationEventFromJson(Map<String, dynamic> json) =>
    _CultivationEvent(
      executionTime: (json['executionTime'] as num).toDouble(),
      type: json['type'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      layerId: json['layerId'] as String?,
      extraData: json['extraData'] as String?,
    );

Map<String, dynamic> _$CultivationEventToJson(_CultivationEvent instance) =>
    <String, dynamic>{
      'executionTime': instance.executionTime,
      'type': instance.type,
      'amount': instance.amount,
      'layerId': instance.layerId,
      'extraData': instance.extraData,
    };

_Scenario _$ScenarioFromJson(Map<String, dynamic> json) => _Scenario(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  initialProfile: SoilProfile.fromJson(
    json['initialProfile'] as Map<String, dynamic>,
  ),
  weatherData: json['weatherData'] as Map<String, dynamic>,
  objectives:
      (json['objectives'] as List<dynamic>?)
          ?.map((e) => MissionObjective.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  tutorialSteps:
      (json['tutorialSteps'] as List<dynamic>?)
          ?.map((e) => ScenarioTutorialStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  cultivationPlan:
      (json['cultivationPlan'] as List<dynamic>?)
          ?.map((e) => CultivationEvent.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ScenarioToJson(_Scenario instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'initialProfile': instance.initialProfile,
  'weatherData': instance.weatherData,
  'objectives': instance.objectives,
  'features': instance.features,
  'tutorialSteps': instance.tutorialSteps,
  'cultivationPlan': instance.cultivationPlan,
};
