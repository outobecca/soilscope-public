// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soil_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoilProfile _$SoilProfileFromJson(Map<String, dynamic> json) => _SoilProfile(
  id: json['id'] as String,
  name: json['name'] as String,
  layers: (json['layers'] as List<dynamic>)
      .map((e) => SoilLayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  surfaceAlbedo: (json['surfaceAlbedo'] as num).toDouble(),
  slope: (json['slope'] as num).toDouble(),
);

Map<String, dynamic> _$SoilProfileToJson(_SoilProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'layers': instance.layers,
      'surfaceAlbedo': instance.surfaceAlbedo,
      'slope': instance.slope,
    };
