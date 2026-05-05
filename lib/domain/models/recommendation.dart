import 'package:freezed_annotation/freezed_annotation.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

enum ActionType { irrigate, fertilize, tillage, coverCrop, wait, drain }

@Freezed(fromJson: true, toJson: true)
abstract class Recommendation with _$Recommendation {
  const factory Recommendation({
    required ActionType action,
    required String title,
    required String rationale,
    required double confidence, // 0.0 - 1.0
    required double priority, // 0.0 - 1.0
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}
