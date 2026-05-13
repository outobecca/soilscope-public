// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soil_layer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SoilLayer _$SoilLayerFromJson(Map<String, dynamic> json) => _SoilLayer(
  id: json['id'] as String,
  depth: (json['depth'] as num).toDouble(),
  thickness: (json['thickness'] as num).toDouble(),
  kSat: (json['kSat'] as num).toDouble(),
  porosity: (json['porosity'] as num).toDouble(),
  thetaR: (json['thetaR'] as num).toDouble(),
  vgAlpha: (json['vgAlpha'] as num).toDouble(),
  vgN: (json['vgN'] as num).toDouble(),
  vgL: (json['vgL'] as num?)?.toDouble() ?? 0.5,
  bulkDensity: (json['bulkDensity'] as num).toDouble(),
  waterContent: (json['waterContent'] as num).toDouble(),
  previousWaterContent:
      (json['previousWaterContent'] as num?)?.toDouble() ?? 0.0,
  verticalFlux: (json['verticalFlux'] as num?)?.toDouble() ?? 0.0,
  temperature: (json['temperature'] as num).toDouble(),
  heatCapacity: (json['heatCapacity'] as num).toDouble(),
  ph: (json['ph'] as num).toDouble(),
  ec: (json['ec'] as num).toDouble(),
  redoxPotential: (json['redoxPotential'] as num).toDouble(),
  nitrateContent: (json['nitrateContent'] as num).toDouble(),
  ammoniumContent: (json['ammoniumContent'] as num).toDouble(),
  phosphateContent: (json['phosphateContent'] as num).toDouble(),
  sorbedPhosphate: (json['sorbedPhosphate'] as num?)?.toDouble() ?? 0.0,
  potassiumContent: (json['potassiumContent'] as num?)?.toDouble() ?? 5.0,
  exchangeablePotassium:
      (json['exchangeablePotassium'] as num?)?.toDouble() ?? 50.0,
  solutionCalcium: (json['solutionCalcium'] as num?)?.toDouble() ?? 100.0,
  exchangeableCalcium:
      (json['exchangeableCalcium'] as num?)?.toDouble() ?? 1000.0,
  solutionMagnesium: (json['solutionMagnesium'] as num?)?.toDouble() ?? 20.0,
  exchangeableMagnesium:
      (json['exchangeableMagnesium'] as num?)?.toDouble() ?? 200.0,
  exchangeableAluminium:
      (json['exchangeableAluminium'] as num?)?.toDouble() ?? 5.0,
  cec: (json['cec'] as num?)?.toDouble() ?? 10.0,
  clayFraction: (json['clayFraction'] as num?)?.toDouble() ?? 0.2,
  sandFraction: (json['sandFraction'] as num?)?.toDouble() ?? 0.4,
  siltFraction: (json['siltFraction'] as num?)?.toDouble() ?? 0.4,
  effectiveMacroPorosity:
      (json['effectiveMacroPorosity'] as num?)?.toDouble() ?? 0.0,
  aggregateStability: (json['aggregateStability'] as num?)?.toDouble() ?? 0.5,
  oxygenContent: (json['oxygenContent'] as num?)?.toDouble() ?? 8.5,
  co2Content: (json['co2Content'] as num?)?.toDouble() ?? 0.02,
  methaneContent: (json['methaneContent'] as num?)?.toDouble() ?? 0.0,
  nitrousOxideContent: (json['nitrousOxideContent'] as num?)?.toDouble() ?? 0.0,
  thermalConductivity: (json['thermalConductivity'] as num?)?.toDouble() ?? 1.0,
  microbialBiomass: (json['microbialBiomass'] as num).toDouble(),
  epsContent: (json['epsContent'] as num).toDouble(),
  fungalHyphaeDensity: (json['fungalHyphaeDensity'] as num).toDouble(),
  necromass: (json['necromass'] as num).toDouble(),
  organicCarbon: (json['organicCarbon'] as num).toDouble(),
  particulateOrganicMatter: (json['particulateOrganicMatter'] as num)
      .toDouble(),
  mineralAssociatedOrganicMatter:
      (json['mineralAssociatedOrganicMatter'] as num).toDouble(),
  isCultivated: json['isCultivated'] as bool? ?? false,
  cultivationDisturbance:
      (json['cultivationDisturbance'] as num?)?.toDouble() ?? 0.0,
  labileCarbon: (json['labileCarbon'] as num?)?.toDouble() ?? 0.0,
  stableCarbon: (json['stableCarbon'] as num?)?.toDouble() ?? 0.0,
  organicNitrogen: (json['organicNitrogen'] as num?)?.toDouble() ?? 100.0,
  microbialNitrogen: (json['microbialNitrogen'] as num?)?.toDouble() ?? 10.0,
  maomNitrogen: (json['maomNitrogen'] as num?)?.toDouble() ?? 50.0,
  nitrogenContent: (json['nitrogenContent'] as num).toDouble(),
  nitrificationRate: (json['nitrificationRate'] as num?)?.toDouble() ?? 0.0,
  denitrificationRate: (json['denitrificationRate'] as num?)?.toDouble() ?? 0.0,
  traceElements:
      (json['traceElements'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
  hotspots:
      (json['hotspots'] as List<dynamic>?)
          ?.map((e) => RhizosphereHotspot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SoilLayerToJson(_SoilLayer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'depth': instance.depth,
      'thickness': instance.thickness,
      'kSat': instance.kSat,
      'porosity': instance.porosity,
      'thetaR': instance.thetaR,
      'vgAlpha': instance.vgAlpha,
      'vgN': instance.vgN,
      'vgL': instance.vgL,
      'bulkDensity': instance.bulkDensity,
      'waterContent': instance.waterContent,
      'previousWaterContent': instance.previousWaterContent,
      'verticalFlux': instance.verticalFlux,
      'temperature': instance.temperature,
      'heatCapacity': instance.heatCapacity,
      'ph': instance.ph,
      'ec': instance.ec,
      'redoxPotential': instance.redoxPotential,
      'nitrateContent': instance.nitrateContent,
      'ammoniumContent': instance.ammoniumContent,
      'phosphateContent': instance.phosphateContent,
      'sorbedPhosphate': instance.sorbedPhosphate,
      'potassiumContent': instance.potassiumContent,
      'exchangeablePotassium': instance.exchangeablePotassium,
      'solutionCalcium': instance.solutionCalcium,
      'exchangeableCalcium': instance.exchangeableCalcium,
      'solutionMagnesium': instance.solutionMagnesium,
      'exchangeableMagnesium': instance.exchangeableMagnesium,
      'exchangeableAluminium': instance.exchangeableAluminium,
      'cec': instance.cec,
      'clayFraction': instance.clayFraction,
      'sandFraction': instance.sandFraction,
      'siltFraction': instance.siltFraction,
      'effectiveMacroPorosity': instance.effectiveMacroPorosity,
      'aggregateStability': instance.aggregateStability,
      'oxygenContent': instance.oxygenContent,
      'co2Content': instance.co2Content,
      'methaneContent': instance.methaneContent,
      'nitrousOxideContent': instance.nitrousOxideContent,
      'thermalConductivity': instance.thermalConductivity,
      'microbialBiomass': instance.microbialBiomass,
      'epsContent': instance.epsContent,
      'fungalHyphaeDensity': instance.fungalHyphaeDensity,
      'necromass': instance.necromass,
      'organicCarbon': instance.organicCarbon,
      'particulateOrganicMatter': instance.particulateOrganicMatter,
      'mineralAssociatedOrganicMatter': instance.mineralAssociatedOrganicMatter,
      'isCultivated': instance.isCultivated,
      'cultivationDisturbance': instance.cultivationDisturbance,
      'labileCarbon': instance.labileCarbon,
      'stableCarbon': instance.stableCarbon,
      'organicNitrogen': instance.organicNitrogen,
      'microbialNitrogen': instance.microbialNitrogen,
      'maomNitrogen': instance.maomNitrogen,
      'nitrogenContent': instance.nitrogenContent,
      'nitrificationRate': instance.nitrificationRate,
      'denitrificationRate': instance.denitrificationRate,
      'traceElements': instance.traceElements,
      'hotspots': instance.hotspots,
    };

_RhizosphereHotspot _$RhizosphereHotspotFromJson(Map<String, dynamic> json) =>
    _RhizosphereHotspot(
      id: json['id'] as String,
      x: (json['x'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
      radius: (json['radius'] as num?)?.toDouble() ?? 0.05,
      age: (json['age'] as num?)?.toDouble() ?? 0.0,
      type:
          $enumDecodeNullable(_$HotspotTypeEnumMap, json['type']) ??
          HotspotType.rhizosphere,
    );

Map<String, dynamic> _$RhizosphereHotspotToJson(_RhizosphereHotspot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'x': instance.x,
      'z': instance.z,
      'intensity': instance.intensity,
      'radius': instance.radius,
      'age': instance.age,
      'type': _$HotspotTypeEnumMap[instance.type]!,
    };

const _$HotspotTypeEnumMap = {
  HotspotType.rhizosphere: 'rhizosphere',
  HotspotType.decomposition: 'decomposition',
  HotspotType.fungalHub: 'fungalHub',
};
