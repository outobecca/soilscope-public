// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sustainability_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SustainabilityScore _$SustainabilityScoreFromJson(Map<String, dynamic> json) =>
    _SustainabilityScore(
      yieldScore: (json['yieldScore'] as num?)?.toDouble() ?? 0.0,
      carbonScore: (json['carbonScore'] as num?)?.toDouble() ?? 0.0,
      biodiversityScore: (json['biodiversityScore'] as num?)?.toDouble() ?? 0.0,
      environmentalImpact:
          (json['environmentalImpact'] as num?)?.toDouble() ?? 0.0,
      totalSoilHealth: (json['totalSoilHealth'] as num?)?.toDouble() ?? 0.0,
      metObjectiveIds:
          (json['metObjectiveIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SustainabilityScoreToJson(
  _SustainabilityScore instance,
) => <String, dynamic>{
  'yieldScore': instance.yieldScore,
  'carbonScore': instance.carbonScore,
  'biodiversityScore': instance.biodiversityScore,
  'environmentalImpact': instance.environmentalImpact,
  'totalSoilHealth': instance.totalSoilHealth,
  'metObjectiveIds': instance.metObjectiveIds,
};
