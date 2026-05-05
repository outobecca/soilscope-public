import 'package:freezed_annotation/freezed_annotation.dart';

part 'sustainability_score.freezed.dart';
part 'sustainability_score.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class SustainabilityScore with _$SustainabilityScore {
  const factory SustainabilityScore({
    @Default(0.0) double yieldScore,
    @Default(0.0) double carbonScore,
    @Default(0.0) double biodiversityScore,
    @Default(0.0) double environmentalImpact,
    @Default(0.0) double totalSoilHealth,
    @Default([]) List<String> metObjectiveIds,
  }) = _SustainabilityScore;

  factory SustainabilityScore.fromJson(Map<String, dynamic> json) =>
      _$SustainabilityScoreFromJson(json);
}
