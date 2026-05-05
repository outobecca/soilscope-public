import 'package:freezed_annotation/freezed_annotation.dart';
import 'soil_layer.dart';

part 'soil_profile.freezed.dart';
part 'soil_profile.g.dart';

@Freezed(fromJson: true, toJson: true)
abstract class SoilProfile with _$SoilProfile {
  const factory SoilProfile({
    required String id,
    required String name,
    required List<SoilLayer> layers,
    required double surfaceAlbedo,
    required double slope, // %
  }) = _SoilProfile;

  factory SoilProfile.fromJson(Map<String, dynamic> json) =>
      _$SoilProfileFromJson(json);
}
