// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    _Recommendation(
      action: $enumDecode(_$ActionTypeEnumMap, json['action']),
      title: json['title'] as String,
      rationale: json['rationale'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      priority: (json['priority'] as num).toDouble(),
    );

Map<String, dynamic> _$RecommendationToJson(_Recommendation instance) =>
    <String, dynamic>{
      'action': _$ActionTypeEnumMap[instance.action]!,
      'title': instance.title,
      'rationale': instance.rationale,
      'confidence': instance.confidence,
      'priority': instance.priority,
    };

const _$ActionTypeEnumMap = {
  ActionType.irrigate: 'irrigate',
  ActionType.fertilize: 'fertilize',
  ActionType.tillage: 'tillage',
  ActionType.coverCrop: 'coverCrop',
  ActionType.wait: 'wait',
  ActionType.drain: 'drain',
};
