// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Plant _$PlantFromJson(Map<String, dynamic> json) => _Plant(
  id: json['id'] as String,
  species: json['species'] as String,
  age: (json['age'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  lai: (json['lai'] as num).toDouble(),
  turgorPressure: (json['turgorPressure'] as num).toDouble(),
  baseX: (json['baseX'] as num?)?.toDouble() ?? 0.5,
  rootSystem: (json['rootSystem'] as List<dynamic>)
      .map((e) => RootNode.fromJson(e as Map<String, dynamic>))
      .toList(),
  nitrogenUptake: (json['nitrogenUptake'] as num).toDouble(),
  waterUptake: (json['waterUptake'] as num).toDouble(),
  phosphorusUptake: (json['phosphorusUptake'] as num?)?.toDouble() ?? 0.0,
  calciumUptake: (json['calciumUptake'] as num?)?.toDouble() ?? 0.0,
  magnesiumUptake: (json['magnesiumUptake'] as num?)?.toDouble() ?? 0.0,
  totalBiomass: (json['totalBiomass'] as num?)?.toDouble() ?? 100.0,
  rootBiomass: (json['rootBiomass'] as num?)?.toDouble() ?? 50.0,
  psiLeaf: (json['psiLeaf'] as num?)?.toDouble() ?? -0.3,
  stomatalConductance: (json['stomatalConductance'] as num?)?.toDouble() ?? 0.3,
  waterStressIndex: (json['waterStressIndex'] as num?)?.toDouble() ?? 0.0,
  relativeWaterContent:
      (json['relativeWaterContent'] as num?)?.toDouble() ?? 0.9,
  actualTranspiration: (json['actualTranspiration'] as num?)?.toDouble() ?? 0.0,
  absorbedPAR: (json['absorbedPAR'] as num?)?.toDouble() ?? 0.0,
  lightTransmission: (json['lightTransmission'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$PlantToJson(_Plant instance) => <String, dynamic>{
  'id': instance.id,
  'species': instance.species,
  'age': instance.age,
  'height': instance.height,
  'lai': instance.lai,
  'turgorPressure': instance.turgorPressure,
  'baseX': instance.baseX,
  'rootSystem': instance.rootSystem,
  'nitrogenUptake': instance.nitrogenUptake,
  'waterUptake': instance.waterUptake,
  'phosphorusUptake': instance.phosphorusUptake,
  'calciumUptake': instance.calciumUptake,
  'magnesiumUptake': instance.magnesiumUptake,
  'totalBiomass': instance.totalBiomass,
  'rootBiomass': instance.rootBiomass,
  'psiLeaf': instance.psiLeaf,
  'stomatalConductance': instance.stomatalConductance,
  'waterStressIndex': instance.waterStressIndex,
  'relativeWaterContent': instance.relativeWaterContent,
  'actualTranspiration': instance.actualTranspiration,
  'absorbedPAR': instance.absorbedPAR,
  'lightTransmission': instance.lightTransmission,
};

_RootNode _$RootNodeFromJson(Map<String, dynamic> json) => _RootNode(
  x: (json['x'] as num).toDouble(),
  z: (json['z'] as num).toDouble(),
  radius: (json['radius'] as num).toDouble(),
  isTip: json['isTip'] as bool,
  parentIndex: (json['parentIndex'] as num?)?.toInt(),
  branchLevel: (json['branchLevel'] as num?)?.toInt() ?? 0,
  branchSegmentCount: (json['branchSegmentCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$RootNodeToJson(_RootNode instance) => <String, dynamic>{
  'x': instance.x,
  'z': instance.z,
  'radius': instance.radius,
  'isTip': instance.isTip,
  'parentIndex': instance.parentIndex,
  'branchLevel': instance.branchLevel,
  'branchSegmentCount': instance.branchSegmentCount,
};
