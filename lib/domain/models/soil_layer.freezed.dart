// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'soil_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoilLayer {

 String get id; double get depth; double get thickness; double get kSat; double get porosity; double get thetaR; double get vgAlpha; double get vgN; double get vgL; double get bulkDensity; double get waterContent; double get previousWaterContent; double get verticalFlux; double get temperature; double get heatCapacity; double get ph; double get ec; double get redoxPotential; double get nitrateContent; double get ammoniumContent; double get phosphateContent; double get sorbedPhosphate; double get potassiumContent; double get exchangeablePotassium; double get solutionCalcium; double get exchangeableCalcium; double get solutionMagnesium; double get exchangeableMagnesium; double get exchangeableAluminium; double get cec; double get clayFraction; double get sandFraction; double get siltFraction; double get effectiveMacroPorosity; double get aggregateStability; double get oxygenContent; double get co2Content; double get methaneContent; double get nitrousOxideContent; double get thermalConductivity; double get microbialBiomass; double get epsContent; double get fungalHyphaeDensity; double get necromass; double get organicCarbon; double get particulateOrganicMatter; double get mineralAssociatedOrganicMatter; bool get isCultivated; double get cultivationDisturbance; double get labileCarbon; double get stableCarbon; double get organicNitrogen; double get microbialNitrogen; double get maomNitrogen; double get nitrogenContent; String get name; String get description; int get colorValue; double get nitrificationRate; double get denitrificationRate; Map<String, double> get traceElements; List<RhizosphereHotspot> get hotspots;
/// Create a copy of SoilLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoilLayerCopyWith<SoilLayer> get copyWith => _$SoilLayerCopyWithImpl<SoilLayer>(this as SoilLayer, _$identity);

  /// Serializes this SoilLayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SoilLayer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoilLayer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.depth, _this.depth) || other.depth == _this.depth)&&(identical(other.thickness, _this.thickness) || other.thickness == _this.thickness)&&(identical(other.kSat, _this.kSat) || other.kSat == _this.kSat)&&(identical(other.porosity, _this.porosity) || other.porosity == _this.porosity)&&(identical(other.thetaR, _this.thetaR) || other.thetaR == _this.thetaR)&&(identical(other.vgAlpha, _this.vgAlpha) || other.vgAlpha == _this.vgAlpha)&&(identical(other.vgN, _this.vgN) || other.vgN == _this.vgN)&&(identical(other.vgL, _this.vgL) || other.vgL == _this.vgL)&&(identical(other.bulkDensity, _this.bulkDensity) || other.bulkDensity == _this.bulkDensity)&&(identical(other.waterContent, _this.waterContent) || other.waterContent == _this.waterContent)&&(identical(other.previousWaterContent, _this.previousWaterContent) || other.previousWaterContent == _this.previousWaterContent)&&(identical(other.verticalFlux, _this.verticalFlux) || other.verticalFlux == _this.verticalFlux)&&(identical(other.temperature, _this.temperature) || other.temperature == _this.temperature)&&(identical(other.heatCapacity, _this.heatCapacity) || other.heatCapacity == _this.heatCapacity)&&(identical(other.ph, _this.ph) || other.ph == _this.ph)&&(identical(other.ec, _this.ec) || other.ec == _this.ec)&&(identical(other.redoxPotential, _this.redoxPotential) || other.redoxPotential == _this.redoxPotential)&&(identical(other.nitrateContent, _this.nitrateContent) || other.nitrateContent == _this.nitrateContent)&&(identical(other.ammoniumContent, _this.ammoniumContent) || other.ammoniumContent == _this.ammoniumContent)&&(identical(other.phosphateContent, _this.phosphateContent) || other.phosphateContent == _this.phosphateContent)&&(identical(other.sorbedPhosphate, _this.sorbedPhosphate) || other.sorbedPhosphate == _this.sorbedPhosphate)&&(identical(other.potassiumContent, _this.potassiumContent) || other.potassiumContent == _this.potassiumContent)&&(identical(other.exchangeablePotassium, _this.exchangeablePotassium) || other.exchangeablePotassium == _this.exchangeablePotassium)&&(identical(other.solutionCalcium, _this.solutionCalcium) || other.solutionCalcium == _this.solutionCalcium)&&(identical(other.exchangeableCalcium, _this.exchangeableCalcium) || other.exchangeableCalcium == _this.exchangeableCalcium)&&(identical(other.solutionMagnesium, _this.solutionMagnesium) || other.solutionMagnesium == _this.solutionMagnesium)&&(identical(other.exchangeableMagnesium, _this.exchangeableMagnesium) || other.exchangeableMagnesium == _this.exchangeableMagnesium)&&(identical(other.exchangeableAluminium, _this.exchangeableAluminium) || other.exchangeableAluminium == _this.exchangeableAluminium)&&(identical(other.cec, _this.cec) || other.cec == _this.cec)&&(identical(other.clayFraction, _this.clayFraction) || other.clayFraction == _this.clayFraction)&&(identical(other.sandFraction, _this.sandFraction) || other.sandFraction == _this.sandFraction)&&(identical(other.siltFraction, _this.siltFraction) || other.siltFraction == _this.siltFraction)&&(identical(other.effectiveMacroPorosity, _this.effectiveMacroPorosity) || other.effectiveMacroPorosity == _this.effectiveMacroPorosity)&&(identical(other.aggregateStability, _this.aggregateStability) || other.aggregateStability == _this.aggregateStability)&&(identical(other.oxygenContent, _this.oxygenContent) || other.oxygenContent == _this.oxygenContent)&&(identical(other.co2Content, _this.co2Content) || other.co2Content == _this.co2Content)&&(identical(other.methaneContent, _this.methaneContent) || other.methaneContent == _this.methaneContent)&&(identical(other.nitrousOxideContent, _this.nitrousOxideContent) || other.nitrousOxideContent == _this.nitrousOxideContent)&&(identical(other.thermalConductivity, _this.thermalConductivity) || other.thermalConductivity == _this.thermalConductivity)&&(identical(other.microbialBiomass, _this.microbialBiomass) || other.microbialBiomass == _this.microbialBiomass)&&(identical(other.epsContent, _this.epsContent) || other.epsContent == _this.epsContent)&&(identical(other.fungalHyphaeDensity, _this.fungalHyphaeDensity) || other.fungalHyphaeDensity == _this.fungalHyphaeDensity)&&(identical(other.necromass, _this.necromass) || other.necromass == _this.necromass)&&(identical(other.organicCarbon, _this.organicCarbon) || other.organicCarbon == _this.organicCarbon)&&(identical(other.particulateOrganicMatter, _this.particulateOrganicMatter) || other.particulateOrganicMatter == _this.particulateOrganicMatter)&&(identical(other.mineralAssociatedOrganicMatter, _this.mineralAssociatedOrganicMatter) || other.mineralAssociatedOrganicMatter == _this.mineralAssociatedOrganicMatter)&&(identical(other.isCultivated, _this.isCultivated) || other.isCultivated == _this.isCultivated)&&(identical(other.cultivationDisturbance, _this.cultivationDisturbance) || other.cultivationDisturbance == _this.cultivationDisturbance)&&(identical(other.labileCarbon, _this.labileCarbon) || other.labileCarbon == _this.labileCarbon)&&(identical(other.stableCarbon, _this.stableCarbon) || other.stableCarbon == _this.stableCarbon)&&(identical(other.organicNitrogen, _this.organicNitrogen) || other.organicNitrogen == _this.organicNitrogen)&&(identical(other.microbialNitrogen, _this.microbialNitrogen) || other.microbialNitrogen == _this.microbialNitrogen)&&(identical(other.maomNitrogen, _this.maomNitrogen) || other.maomNitrogen == _this.maomNitrogen)&&(identical(other.nitrogenContent, _this.nitrogenContent) || other.nitrogenContent == _this.nitrogenContent)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.colorValue, _this.colorValue) || other.colorValue == _this.colorValue)&&(identical(other.nitrificationRate, _this.nitrificationRate) || other.nitrificationRate == _this.nitrificationRate)&&(identical(other.denitrificationRate, _this.denitrificationRate) || other.denitrificationRate == _this.denitrificationRate)&&const DeepCollectionEquality().equals(other.traceElements, _this.traceElements)&&const DeepCollectionEquality().equals(other.hotspots, _this.hotspots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SoilLayer;
  return Object.hashAll([runtimeType,_this.id,_this.depth,_this.thickness,_this.kSat,_this.porosity,_this.thetaR,_this.vgAlpha,_this.vgN,_this.vgL,_this.bulkDensity,_this.waterContent,_this.previousWaterContent,_this.verticalFlux,_this.temperature,_this.heatCapacity,_this.ph,_this.ec,_this.redoxPotential,_this.nitrateContent,_this.ammoniumContent,_this.phosphateContent,_this.sorbedPhosphate,_this.potassiumContent,_this.exchangeablePotassium,_this.solutionCalcium,_this.exchangeableCalcium,_this.solutionMagnesium,_this.exchangeableMagnesium,_this.exchangeableAluminium,_this.cec,_this.clayFraction,_this.sandFraction,_this.siltFraction,_this.effectiveMacroPorosity,_this.aggregateStability,_this.oxygenContent,_this.co2Content,_this.methaneContent,_this.nitrousOxideContent,_this.thermalConductivity,_this.microbialBiomass,_this.epsContent,_this.fungalHyphaeDensity,_this.necromass,_this.organicCarbon,_this.particulateOrganicMatter,_this.mineralAssociatedOrganicMatter,_this.isCultivated,_this.cultivationDisturbance,_this.labileCarbon,_this.stableCarbon,_this.organicNitrogen,_this.microbialNitrogen,_this.maomNitrogen,_this.nitrogenContent,_this.name,_this.description,_this.colorValue,_this.nitrificationRate,_this.denitrificationRate,const DeepCollectionEquality().hash(_this.traceElements),const DeepCollectionEquality().hash(_this.hotspots)]);
}

@override
String toString() {
  final _this = this as SoilLayer;
  return 'SoilLayer(id: ${_this.id}, depth: ${_this.depth}, thickness: ${_this.thickness}, kSat: ${_this.kSat}, porosity: ${_this.porosity}, thetaR: ${_this.thetaR}, vgAlpha: ${_this.vgAlpha}, vgN: ${_this.vgN}, vgL: ${_this.vgL}, bulkDensity: ${_this.bulkDensity}, waterContent: ${_this.waterContent}, previousWaterContent: ${_this.previousWaterContent}, verticalFlux: ${_this.verticalFlux}, temperature: ${_this.temperature}, heatCapacity: ${_this.heatCapacity}, ph: ${_this.ph}, ec: ${_this.ec}, redoxPotential: ${_this.redoxPotential}, nitrateContent: ${_this.nitrateContent}, ammoniumContent: ${_this.ammoniumContent}, phosphateContent: ${_this.phosphateContent}, sorbedPhosphate: ${_this.sorbedPhosphate}, potassiumContent: ${_this.potassiumContent}, exchangeablePotassium: ${_this.exchangeablePotassium}, solutionCalcium: ${_this.solutionCalcium}, exchangeableCalcium: ${_this.exchangeableCalcium}, solutionMagnesium: ${_this.solutionMagnesium}, exchangeableMagnesium: ${_this.exchangeableMagnesium}, exchangeableAluminium: ${_this.exchangeableAluminium}, cec: ${_this.cec}, clayFraction: ${_this.clayFraction}, sandFraction: ${_this.sandFraction}, siltFraction: ${_this.siltFraction}, effectiveMacroPorosity: ${_this.effectiveMacroPorosity}, aggregateStability: ${_this.aggregateStability}, oxygenContent: ${_this.oxygenContent}, co2Content: ${_this.co2Content}, methaneContent: ${_this.methaneContent}, nitrousOxideContent: ${_this.nitrousOxideContent}, thermalConductivity: ${_this.thermalConductivity}, microbialBiomass: ${_this.microbialBiomass}, epsContent: ${_this.epsContent}, fungalHyphaeDensity: ${_this.fungalHyphaeDensity}, necromass: ${_this.necromass}, organicCarbon: ${_this.organicCarbon}, particulateOrganicMatter: ${_this.particulateOrganicMatter}, mineralAssociatedOrganicMatter: ${_this.mineralAssociatedOrganicMatter}, isCultivated: ${_this.isCultivated}, cultivationDisturbance: ${_this.cultivationDisturbance}, labileCarbon: ${_this.labileCarbon}, stableCarbon: ${_this.stableCarbon}, organicNitrogen: ${_this.organicNitrogen}, microbialNitrogen: ${_this.microbialNitrogen}, maomNitrogen: ${_this.maomNitrogen}, nitrogenContent: ${_this.nitrogenContent}, name: ${_this.name}, description: ${_this.description}, colorValue: ${_this.colorValue}, nitrificationRate: ${_this.nitrificationRate}, denitrificationRate: ${_this.denitrificationRate}, traceElements: ${_this.traceElements}, hotspots: ${_this.hotspots})';
}


}

/// @nodoc
abstract mixin class $SoilLayerCopyWith<$Res>  {
  factory $SoilLayerCopyWith(SoilLayer value, $Res Function(SoilLayer) _then) = _$SoilLayerCopyWithImpl;
@useResult
$Res call({
 String id, double depth, double thickness, double kSat, double porosity, double thetaR, double vgAlpha, double vgN, double vgL, double bulkDensity, double waterContent, double previousWaterContent, double verticalFlux, double temperature, double heatCapacity, double ph, double ec, double redoxPotential, double nitrateContent, double ammoniumContent, double phosphateContent, double sorbedPhosphate, double potassiumContent, double exchangeablePotassium, double solutionCalcium, double exchangeableCalcium, double solutionMagnesium, double exchangeableMagnesium, double exchangeableAluminium, double cec, double clayFraction, double sandFraction, double siltFraction, double effectiveMacroPorosity, double aggregateStability, double oxygenContent, double co2Content, double methaneContent, double nitrousOxideContent, double thermalConductivity, double microbialBiomass, double epsContent, double fungalHyphaeDensity, double necromass, double organicCarbon, double particulateOrganicMatter, double mineralAssociatedOrganicMatter, bool isCultivated, double cultivationDisturbance, double labileCarbon, double stableCarbon, double organicNitrogen, double microbialNitrogen, double maomNitrogen, double nitrogenContent, String name, String description, int colorValue, double nitrificationRate, double denitrificationRate, Map<String, double> traceElements, List<RhizosphereHotspot> hotspots
});




}
/// @nodoc
class _$SoilLayerCopyWithImpl<$Res>
    implements $SoilLayerCopyWith<$Res> {
  _$SoilLayerCopyWithImpl(this._self, this._then);

  final SoilLayer _self;
  final $Res Function(SoilLayer) _then;

/// Create a copy of SoilLayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? depth = null,Object? thickness = null,Object? kSat = null,Object? porosity = null,Object? thetaR = null,Object? vgAlpha = null,Object? vgN = null,Object? vgL = null,Object? bulkDensity = null,Object? waterContent = null,Object? previousWaterContent = null,Object? verticalFlux = null,Object? temperature = null,Object? heatCapacity = null,Object? ph = null,Object? ec = null,Object? redoxPotential = null,Object? nitrateContent = null,Object? ammoniumContent = null,Object? phosphateContent = null,Object? sorbedPhosphate = null,Object? potassiumContent = null,Object? exchangeablePotassium = null,Object? solutionCalcium = null,Object? exchangeableCalcium = null,Object? solutionMagnesium = null,Object? exchangeableMagnesium = null,Object? exchangeableAluminium = null,Object? cec = null,Object? clayFraction = null,Object? sandFraction = null,Object? siltFraction = null,Object? effectiveMacroPorosity = null,Object? aggregateStability = null,Object? oxygenContent = null,Object? co2Content = null,Object? methaneContent = null,Object? nitrousOxideContent = null,Object? thermalConductivity = null,Object? microbialBiomass = null,Object? epsContent = null,Object? fungalHyphaeDensity = null,Object? necromass = null,Object? organicCarbon = null,Object? particulateOrganicMatter = null,Object? mineralAssociatedOrganicMatter = null,Object? isCultivated = null,Object? cultivationDisturbance = null,Object? labileCarbon = null,Object? stableCarbon = null,Object? organicNitrogen = null,Object? microbialNitrogen = null,Object? maomNitrogen = null,Object? nitrogenContent = null,Object? name = null,Object? description = null,Object? colorValue = null,Object? nitrificationRate = null,Object? denitrificationRate = null,Object? traceElements = null,Object? hotspots = null,}) {
  return _then(SoilLayer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as double,thickness: null == thickness ? _self.thickness : thickness // ignore: cast_nullable_to_non_nullable
as double,kSat: null == kSat ? _self.kSat : kSat // ignore: cast_nullable_to_non_nullable
as double,porosity: null == porosity ? _self.porosity : porosity // ignore: cast_nullable_to_non_nullable
as double,thetaR: null == thetaR ? _self.thetaR : thetaR // ignore: cast_nullable_to_non_nullable
as double,vgAlpha: null == vgAlpha ? _self.vgAlpha : vgAlpha // ignore: cast_nullable_to_non_nullable
as double,vgN: null == vgN ? _self.vgN : vgN // ignore: cast_nullable_to_non_nullable
as double,vgL: null == vgL ? _self.vgL : vgL // ignore: cast_nullable_to_non_nullable
as double,bulkDensity: null == bulkDensity ? _self.bulkDensity : bulkDensity // ignore: cast_nullable_to_non_nullable
as double,waterContent: null == waterContent ? _self.waterContent : waterContent // ignore: cast_nullable_to_non_nullable
as double,previousWaterContent: null == previousWaterContent ? _self.previousWaterContent : previousWaterContent // ignore: cast_nullable_to_non_nullable
as double,verticalFlux: null == verticalFlux ? _self.verticalFlux : verticalFlux // ignore: cast_nullable_to_non_nullable
as double,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,heatCapacity: null == heatCapacity ? _self.heatCapacity : heatCapacity // ignore: cast_nullable_to_non_nullable
as double,ph: null == ph ? _self.ph : ph // ignore: cast_nullable_to_non_nullable
as double,ec: null == ec ? _self.ec : ec // ignore: cast_nullable_to_non_nullable
as double,redoxPotential: null == redoxPotential ? _self.redoxPotential : redoxPotential // ignore: cast_nullable_to_non_nullable
as double,nitrateContent: null == nitrateContent ? _self.nitrateContent : nitrateContent // ignore: cast_nullable_to_non_nullable
as double,ammoniumContent: null == ammoniumContent ? _self.ammoniumContent : ammoniumContent // ignore: cast_nullable_to_non_nullable
as double,phosphateContent: null == phosphateContent ? _self.phosphateContent : phosphateContent // ignore: cast_nullable_to_non_nullable
as double,sorbedPhosphate: null == sorbedPhosphate ? _self.sorbedPhosphate : sorbedPhosphate // ignore: cast_nullable_to_non_nullable
as double,potassiumContent: null == potassiumContent ? _self.potassiumContent : potassiumContent // ignore: cast_nullable_to_non_nullable
as double,exchangeablePotassium: null == exchangeablePotassium ? _self.exchangeablePotassium : exchangeablePotassium // ignore: cast_nullable_to_non_nullable
as double,solutionCalcium: null == solutionCalcium ? _self.solutionCalcium : solutionCalcium // ignore: cast_nullable_to_non_nullable
as double,exchangeableCalcium: null == exchangeableCalcium ? _self.exchangeableCalcium : exchangeableCalcium // ignore: cast_nullable_to_non_nullable
as double,solutionMagnesium: null == solutionMagnesium ? _self.solutionMagnesium : solutionMagnesium // ignore: cast_nullable_to_non_nullable
as double,exchangeableMagnesium: null == exchangeableMagnesium ? _self.exchangeableMagnesium : exchangeableMagnesium // ignore: cast_nullable_to_non_nullable
as double,exchangeableAluminium: null == exchangeableAluminium ? _self.exchangeableAluminium : exchangeableAluminium // ignore: cast_nullable_to_non_nullable
as double,cec: null == cec ? _self.cec : cec // ignore: cast_nullable_to_non_nullable
as double,clayFraction: null == clayFraction ? _self.clayFraction : clayFraction // ignore: cast_nullable_to_non_nullable
as double,sandFraction: null == sandFraction ? _self.sandFraction : sandFraction // ignore: cast_nullable_to_non_nullable
as double,siltFraction: null == siltFraction ? _self.siltFraction : siltFraction // ignore: cast_nullable_to_non_nullable
as double,effectiveMacroPorosity: null == effectiveMacroPorosity ? _self.effectiveMacroPorosity : effectiveMacroPorosity // ignore: cast_nullable_to_non_nullable
as double,aggregateStability: null == aggregateStability ? _self.aggregateStability : aggregateStability // ignore: cast_nullable_to_non_nullable
as double,oxygenContent: null == oxygenContent ? _self.oxygenContent : oxygenContent // ignore: cast_nullable_to_non_nullable
as double,co2Content: null == co2Content ? _self.co2Content : co2Content // ignore: cast_nullable_to_non_nullable
as double,methaneContent: null == methaneContent ? _self.methaneContent : methaneContent // ignore: cast_nullable_to_non_nullable
as double,nitrousOxideContent: null == nitrousOxideContent ? _self.nitrousOxideContent : nitrousOxideContent // ignore: cast_nullable_to_non_nullable
as double,thermalConductivity: null == thermalConductivity ? _self.thermalConductivity : thermalConductivity // ignore: cast_nullable_to_non_nullable
as double,microbialBiomass: null == microbialBiomass ? _self.microbialBiomass : microbialBiomass // ignore: cast_nullable_to_non_nullable
as double,epsContent: null == epsContent ? _self.epsContent : epsContent // ignore: cast_nullable_to_non_nullable
as double,fungalHyphaeDensity: null == fungalHyphaeDensity ? _self.fungalHyphaeDensity : fungalHyphaeDensity // ignore: cast_nullable_to_non_nullable
as double,necromass: null == necromass ? _self.necromass : necromass // ignore: cast_nullable_to_non_nullable
as double,organicCarbon: null == organicCarbon ? _self.organicCarbon : organicCarbon // ignore: cast_nullable_to_non_nullable
as double,particulateOrganicMatter: null == particulateOrganicMatter ? _self.particulateOrganicMatter : particulateOrganicMatter // ignore: cast_nullable_to_non_nullable
as double,mineralAssociatedOrganicMatter: null == mineralAssociatedOrganicMatter ? _self.mineralAssociatedOrganicMatter : mineralAssociatedOrganicMatter // ignore: cast_nullable_to_non_nullable
as double,isCultivated: null == isCultivated ? _self.isCultivated : isCultivated // ignore: cast_nullable_to_non_nullable
as bool,cultivationDisturbance: null == cultivationDisturbance ? _self.cultivationDisturbance : cultivationDisturbance // ignore: cast_nullable_to_non_nullable
as double,labileCarbon: null == labileCarbon ? _self.labileCarbon : labileCarbon // ignore: cast_nullable_to_non_nullable
as double,stableCarbon: null == stableCarbon ? _self.stableCarbon : stableCarbon // ignore: cast_nullable_to_non_nullable
as double,organicNitrogen: null == organicNitrogen ? _self.organicNitrogen : organicNitrogen // ignore: cast_nullable_to_non_nullable
as double,microbialNitrogen: null == microbialNitrogen ? _self.microbialNitrogen : microbialNitrogen // ignore: cast_nullable_to_non_nullable
as double,maomNitrogen: null == maomNitrogen ? _self.maomNitrogen : maomNitrogen // ignore: cast_nullable_to_non_nullable
as double,nitrogenContent: null == nitrogenContent ? _self.nitrogenContent : nitrogenContent // ignore: cast_nullable_to_non_nullable
as double,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,nitrificationRate: null == nitrificationRate ? _self.nitrificationRate : nitrificationRate // ignore: cast_nullable_to_non_nullable
as double,denitrificationRate: null == denitrificationRate ? _self.denitrificationRate : denitrificationRate // ignore: cast_nullable_to_non_nullable
as double,traceElements: null == traceElements ? _self.traceElements : traceElements // ignore: cast_nullable_to_non_nullable
as Map<String, double>,hotspots: null == hotspots ? _self.hotspots : hotspots // ignore: cast_nullable_to_non_nullable
as List<RhizosphereHotspot>,
  ));
}

}


/// Adds pattern-matching-related methods to [SoilLayer].
extension SoilLayerPatterns on SoilLayer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoilLayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoilLayer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoilLayer value)  $default,){
final _that = this;
switch (_that) {
case _SoilLayer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoilLayer value)?  $default,){
final _that = this;
switch (_that) {
case _SoilLayer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double depth,  double thickness,  double kSat,  double porosity,  double thetaR,  double vgAlpha,  double vgN,  double vgL,  double bulkDensity,  double waterContent,  double previousWaterContent,  double verticalFlux,  double temperature,  double heatCapacity,  double ph,  double ec,  double redoxPotential,  double nitrateContent,  double ammoniumContent,  double phosphateContent,  double sorbedPhosphate,  double potassiumContent,  double exchangeablePotassium,  double solutionCalcium,  double exchangeableCalcium,  double solutionMagnesium,  double exchangeableMagnesium,  double exchangeableAluminium,  double cec,  double clayFraction,  double sandFraction,  double siltFraction,  double effectiveMacroPorosity,  double aggregateStability,  double oxygenContent,  double co2Content,  double methaneContent,  double nitrousOxideContent,  double thermalConductivity,  double microbialBiomass,  double epsContent,  double fungalHyphaeDensity,  double necromass,  double organicCarbon,  double particulateOrganicMatter,  double mineralAssociatedOrganicMatter,  bool isCultivated,  double cultivationDisturbance,  double labileCarbon,  double stableCarbon,  double organicNitrogen,  double microbialNitrogen,  double maomNitrogen,  double nitrogenContent,  String name,  String description,  int colorValue,  double nitrificationRate,  double denitrificationRate,  Map<String, double> traceElements,  List<RhizosphereHotspot> hotspots)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoilLayer() when $default != null:
return $default(_that.id,_that.depth,_that.thickness,_that.kSat,_that.porosity,_that.thetaR,_that.vgAlpha,_that.vgN,_that.vgL,_that.bulkDensity,_that.waterContent,_that.previousWaterContent,_that.verticalFlux,_that.temperature,_that.heatCapacity,_that.ph,_that.ec,_that.redoxPotential,_that.nitrateContent,_that.ammoniumContent,_that.phosphateContent,_that.sorbedPhosphate,_that.potassiumContent,_that.exchangeablePotassium,_that.solutionCalcium,_that.exchangeableCalcium,_that.solutionMagnesium,_that.exchangeableMagnesium,_that.exchangeableAluminium,_that.cec,_that.clayFraction,_that.sandFraction,_that.siltFraction,_that.effectiveMacroPorosity,_that.aggregateStability,_that.oxygenContent,_that.co2Content,_that.methaneContent,_that.nitrousOxideContent,_that.thermalConductivity,_that.microbialBiomass,_that.epsContent,_that.fungalHyphaeDensity,_that.necromass,_that.organicCarbon,_that.particulateOrganicMatter,_that.mineralAssociatedOrganicMatter,_that.isCultivated,_that.cultivationDisturbance,_that.labileCarbon,_that.stableCarbon,_that.organicNitrogen,_that.microbialNitrogen,_that.maomNitrogen,_that.nitrogenContent,_that.name,_that.description,_that.colorValue,_that.nitrificationRate,_that.denitrificationRate,_that.traceElements,_that.hotspots);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double depth,  double thickness,  double kSat,  double porosity,  double thetaR,  double vgAlpha,  double vgN,  double vgL,  double bulkDensity,  double waterContent,  double previousWaterContent,  double verticalFlux,  double temperature,  double heatCapacity,  double ph,  double ec,  double redoxPotential,  double nitrateContent,  double ammoniumContent,  double phosphateContent,  double sorbedPhosphate,  double potassiumContent,  double exchangeablePotassium,  double solutionCalcium,  double exchangeableCalcium,  double solutionMagnesium,  double exchangeableMagnesium,  double exchangeableAluminium,  double cec,  double clayFraction,  double sandFraction,  double siltFraction,  double effectiveMacroPorosity,  double aggregateStability,  double oxygenContent,  double co2Content,  double methaneContent,  double nitrousOxideContent,  double thermalConductivity,  double microbialBiomass,  double epsContent,  double fungalHyphaeDensity,  double necromass,  double organicCarbon,  double particulateOrganicMatter,  double mineralAssociatedOrganicMatter,  bool isCultivated,  double cultivationDisturbance,  double labileCarbon,  double stableCarbon,  double organicNitrogen,  double microbialNitrogen,  double maomNitrogen,  double nitrogenContent,  String name,  String description,  int colorValue,  double nitrificationRate,  double denitrificationRate,  Map<String, double> traceElements,  List<RhizosphereHotspot> hotspots)  $default,) {final _that = this;
switch (_that) {
case _SoilLayer():
return $default(_that.id,_that.depth,_that.thickness,_that.kSat,_that.porosity,_that.thetaR,_that.vgAlpha,_that.vgN,_that.vgL,_that.bulkDensity,_that.waterContent,_that.previousWaterContent,_that.verticalFlux,_that.temperature,_that.heatCapacity,_that.ph,_that.ec,_that.redoxPotential,_that.nitrateContent,_that.ammoniumContent,_that.phosphateContent,_that.sorbedPhosphate,_that.potassiumContent,_that.exchangeablePotassium,_that.solutionCalcium,_that.exchangeableCalcium,_that.solutionMagnesium,_that.exchangeableMagnesium,_that.exchangeableAluminium,_that.cec,_that.clayFraction,_that.sandFraction,_that.siltFraction,_that.effectiveMacroPorosity,_that.aggregateStability,_that.oxygenContent,_that.co2Content,_that.methaneContent,_that.nitrousOxideContent,_that.thermalConductivity,_that.microbialBiomass,_that.epsContent,_that.fungalHyphaeDensity,_that.necromass,_that.organicCarbon,_that.particulateOrganicMatter,_that.mineralAssociatedOrganicMatter,_that.isCultivated,_that.cultivationDisturbance,_that.labileCarbon,_that.stableCarbon,_that.organicNitrogen,_that.microbialNitrogen,_that.maomNitrogen,_that.nitrogenContent,_that.name,_that.description,_that.colorValue,_that.nitrificationRate,_that.denitrificationRate,_that.traceElements,_that.hotspots);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double depth,  double thickness,  double kSat,  double porosity,  double thetaR,  double vgAlpha,  double vgN,  double vgL,  double bulkDensity,  double waterContent,  double previousWaterContent,  double verticalFlux,  double temperature,  double heatCapacity,  double ph,  double ec,  double redoxPotential,  double nitrateContent,  double ammoniumContent,  double phosphateContent,  double sorbedPhosphate,  double potassiumContent,  double exchangeablePotassium,  double solutionCalcium,  double exchangeableCalcium,  double solutionMagnesium,  double exchangeableMagnesium,  double exchangeableAluminium,  double cec,  double clayFraction,  double sandFraction,  double siltFraction,  double effectiveMacroPorosity,  double aggregateStability,  double oxygenContent,  double co2Content,  double methaneContent,  double nitrousOxideContent,  double thermalConductivity,  double microbialBiomass,  double epsContent,  double fungalHyphaeDensity,  double necromass,  double organicCarbon,  double particulateOrganicMatter,  double mineralAssociatedOrganicMatter,  bool isCultivated,  double cultivationDisturbance,  double labileCarbon,  double stableCarbon,  double organicNitrogen,  double microbialNitrogen,  double maomNitrogen,  double nitrogenContent,  String name,  String description,  int colorValue,  double nitrificationRate,  double denitrificationRate,  Map<String, double> traceElements,  List<RhizosphereHotspot> hotspots)?  $default,) {final _that = this;
switch (_that) {
case _SoilLayer() when $default != null:
return $default(_that.id,_that.depth,_that.thickness,_that.kSat,_that.porosity,_that.thetaR,_that.vgAlpha,_that.vgN,_that.vgL,_that.bulkDensity,_that.waterContent,_that.previousWaterContent,_that.verticalFlux,_that.temperature,_that.heatCapacity,_that.ph,_that.ec,_that.redoxPotential,_that.nitrateContent,_that.ammoniumContent,_that.phosphateContent,_that.sorbedPhosphate,_that.potassiumContent,_that.exchangeablePotassium,_that.solutionCalcium,_that.exchangeableCalcium,_that.solutionMagnesium,_that.exchangeableMagnesium,_that.exchangeableAluminium,_that.cec,_that.clayFraction,_that.sandFraction,_that.siltFraction,_that.effectiveMacroPorosity,_that.aggregateStability,_that.oxygenContent,_that.co2Content,_that.methaneContent,_that.nitrousOxideContent,_that.thermalConductivity,_that.microbialBiomass,_that.epsContent,_that.fungalHyphaeDensity,_that.necromass,_that.organicCarbon,_that.particulateOrganicMatter,_that.mineralAssociatedOrganicMatter,_that.isCultivated,_that.cultivationDisturbance,_that.labileCarbon,_that.stableCarbon,_that.organicNitrogen,_that.microbialNitrogen,_that.maomNitrogen,_that.nitrogenContent,_that.name,_that.description,_that.colorValue,_that.nitrificationRate,_that.denitrificationRate,_that.traceElements,_that.hotspots);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoilLayer extends SoilLayer {
  const _SoilLayer({required this.id, required this.depth, required this.thickness, required this.kSat, required this.porosity, required this.thetaR, required this.vgAlpha, required this.vgN, this.vgL = 0.5, required this.bulkDensity, required this.waterContent, this.previousWaterContent = 0.0, this.verticalFlux = 0.0, required this.temperature, required this.heatCapacity, required this.ph, required this.ec, required this.redoxPotential, required this.nitrateContent, required this.ammoniumContent, required this.phosphateContent, this.sorbedPhosphate = 0.0, this.potassiumContent = 5.0, this.exchangeablePotassium = 50.0, this.solutionCalcium = 100.0, this.exchangeableCalcium = 1000.0, this.solutionMagnesium = 20.0, this.exchangeableMagnesium = 200.0, this.exchangeableAluminium = 5.0, this.cec = 10.0, this.clayFraction = 0.2, this.sandFraction = 0.4, this.siltFraction = 0.4, this.effectiveMacroPorosity = 0.0, this.aggregateStability = 0.5, this.oxygenContent = 8.5, this.co2Content = 0.02, this.methaneContent = 0.0, this.nitrousOxideContent = 0.0, this.thermalConductivity = 1.0, required this.microbialBiomass, required this.epsContent, required this.fungalHyphaeDensity, required this.necromass, required this.organicCarbon, required this.particulateOrganicMatter, required this.mineralAssociatedOrganicMatter, this.isCultivated = false, this.cultivationDisturbance = 0.0, this.labileCarbon = 0.0, this.stableCarbon = 0.0, this.organicNitrogen = 100.0, this.microbialNitrogen = 10.0, this.maomNitrogen = 50.0, required this.nitrogenContent, this.name = '', this.description = '', this.colorValue = 0xFF795548, this.nitrificationRate = 0.0, this.denitrificationRate = 0.0,  Map<String, double> traceElements = const {},  List<RhizosphereHotspot> hotspots = const []}): _traceElements = traceElements,_hotspots = hotspots,super._();
  factory _SoilLayer.fromJson(Map<String, dynamic> json) => _$SoilLayerFromJson(json);

@override final  String id;
@override final  double depth;
@override final  double thickness;
@override final  double kSat;
@override final  double porosity;
@override final  double thetaR;
@override final  double vgAlpha;
@override final  double vgN;
@override@JsonKey() final  double vgL;
@override final  double bulkDensity;
@override final  double waterContent;
@override@JsonKey() final  double previousWaterContent;
@override@JsonKey() final  double verticalFlux;
@override final  double temperature;
@override final  double heatCapacity;
@override final  double ph;
@override final  double ec;
@override final  double redoxPotential;
@override final  double nitrateContent;
@override final  double ammoniumContent;
@override final  double phosphateContent;
@override@JsonKey() final  double sorbedPhosphate;
@override@JsonKey() final  double potassiumContent;
@override@JsonKey() final  double exchangeablePotassium;
@override@JsonKey() final  double solutionCalcium;
@override@JsonKey() final  double exchangeableCalcium;
@override@JsonKey() final  double solutionMagnesium;
@override@JsonKey() final  double exchangeableMagnesium;
@override@JsonKey() final  double exchangeableAluminium;
@override@JsonKey() final  double cec;
@override@JsonKey() final  double clayFraction;
@override@JsonKey() final  double sandFraction;
@override@JsonKey() final  double siltFraction;
@override@JsonKey() final  double effectiveMacroPorosity;
@override@JsonKey() final  double aggregateStability;
@override@JsonKey() final  double oxygenContent;
@override@JsonKey() final  double co2Content;
@override@JsonKey() final  double methaneContent;
@override@JsonKey() final  double nitrousOxideContent;
@override@JsonKey() final  double thermalConductivity;
@override final  double microbialBiomass;
@override final  double epsContent;
@override final  double fungalHyphaeDensity;
@override final  double necromass;
@override final  double organicCarbon;
@override final  double particulateOrganicMatter;
@override final  double mineralAssociatedOrganicMatter;
@override@JsonKey() final  bool isCultivated;
@override@JsonKey() final  double cultivationDisturbance;
@override@JsonKey() final  double labileCarbon;
@override@JsonKey() final  double stableCarbon;
@override@JsonKey() final  double organicNitrogen;
@override@JsonKey() final  double microbialNitrogen;
@override@JsonKey() final  double maomNitrogen;
@override final  double nitrogenContent;
@override@JsonKey() final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  int colorValue;
@override@JsonKey() final  double nitrificationRate;
@override@JsonKey() final  double denitrificationRate;
 final  Map<String, double> _traceElements;
@override@JsonKey() Map<String, double> get traceElements {
  if (_traceElements is EqualUnmodifiableMapView) return _traceElements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_traceElements);
}

 final  List<RhizosphereHotspot> _hotspots;
@override@JsonKey() List<RhizosphereHotspot> get hotspots {
  if (_hotspots is EqualUnmodifiableListView) return _hotspots;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hotspots);
}


/// Create a copy of SoilLayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoilLayerCopyWith<_SoilLayer> get copyWith => __$SoilLayerCopyWithImpl<_SoilLayer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoilLayerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoilLayer&&(identical(other.id, id) || other.id == id)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.thickness, thickness) || other.thickness == thickness)&&(identical(other.kSat, kSat) || other.kSat == kSat)&&(identical(other.porosity, porosity) || other.porosity == porosity)&&(identical(other.thetaR, thetaR) || other.thetaR == thetaR)&&(identical(other.vgAlpha, vgAlpha) || other.vgAlpha == vgAlpha)&&(identical(other.vgN, vgN) || other.vgN == vgN)&&(identical(other.vgL, vgL) || other.vgL == vgL)&&(identical(other.bulkDensity, bulkDensity) || other.bulkDensity == bulkDensity)&&(identical(other.waterContent, waterContent) || other.waterContent == waterContent)&&(identical(other.previousWaterContent, previousWaterContent) || other.previousWaterContent == previousWaterContent)&&(identical(other.verticalFlux, verticalFlux) || other.verticalFlux == verticalFlux)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.heatCapacity, heatCapacity) || other.heatCapacity == heatCapacity)&&(identical(other.ph, ph) || other.ph == ph)&&(identical(other.ec, ec) || other.ec == ec)&&(identical(other.redoxPotential, redoxPotential) || other.redoxPotential == redoxPotential)&&(identical(other.nitrateContent, nitrateContent) || other.nitrateContent == nitrateContent)&&(identical(other.ammoniumContent, ammoniumContent) || other.ammoniumContent == ammoniumContent)&&(identical(other.phosphateContent, phosphateContent) || other.phosphateContent == phosphateContent)&&(identical(other.sorbedPhosphate, sorbedPhosphate) || other.sorbedPhosphate == sorbedPhosphate)&&(identical(other.potassiumContent, potassiumContent) || other.potassiumContent == potassiumContent)&&(identical(other.exchangeablePotassium, exchangeablePotassium) || other.exchangeablePotassium == exchangeablePotassium)&&(identical(other.solutionCalcium, solutionCalcium) || other.solutionCalcium == solutionCalcium)&&(identical(other.exchangeableCalcium, exchangeableCalcium) || other.exchangeableCalcium == exchangeableCalcium)&&(identical(other.solutionMagnesium, solutionMagnesium) || other.solutionMagnesium == solutionMagnesium)&&(identical(other.exchangeableMagnesium, exchangeableMagnesium) || other.exchangeableMagnesium == exchangeableMagnesium)&&(identical(other.exchangeableAluminium, exchangeableAluminium) || other.exchangeableAluminium == exchangeableAluminium)&&(identical(other.cec, cec) || other.cec == cec)&&(identical(other.clayFraction, clayFraction) || other.clayFraction == clayFraction)&&(identical(other.sandFraction, sandFraction) || other.sandFraction == sandFraction)&&(identical(other.siltFraction, siltFraction) || other.siltFraction == siltFraction)&&(identical(other.effectiveMacroPorosity, effectiveMacroPorosity) || other.effectiveMacroPorosity == effectiveMacroPorosity)&&(identical(other.aggregateStability, aggregateStability) || other.aggregateStability == aggregateStability)&&(identical(other.oxygenContent, oxygenContent) || other.oxygenContent == oxygenContent)&&(identical(other.co2Content, co2Content) || other.co2Content == co2Content)&&(identical(other.methaneContent, methaneContent) || other.methaneContent == methaneContent)&&(identical(other.nitrousOxideContent, nitrousOxideContent) || other.nitrousOxideContent == nitrousOxideContent)&&(identical(other.thermalConductivity, thermalConductivity) || other.thermalConductivity == thermalConductivity)&&(identical(other.microbialBiomass, microbialBiomass) || other.microbialBiomass == microbialBiomass)&&(identical(other.epsContent, epsContent) || other.epsContent == epsContent)&&(identical(other.fungalHyphaeDensity, fungalHyphaeDensity) || other.fungalHyphaeDensity == fungalHyphaeDensity)&&(identical(other.necromass, necromass) || other.necromass == necromass)&&(identical(other.organicCarbon, organicCarbon) || other.organicCarbon == organicCarbon)&&(identical(other.particulateOrganicMatter, particulateOrganicMatter) || other.particulateOrganicMatter == particulateOrganicMatter)&&(identical(other.mineralAssociatedOrganicMatter, mineralAssociatedOrganicMatter) || other.mineralAssociatedOrganicMatter == mineralAssociatedOrganicMatter)&&(identical(other.isCultivated, isCultivated) || other.isCultivated == isCultivated)&&(identical(other.cultivationDisturbance, cultivationDisturbance) || other.cultivationDisturbance == cultivationDisturbance)&&(identical(other.labileCarbon, labileCarbon) || other.labileCarbon == labileCarbon)&&(identical(other.stableCarbon, stableCarbon) || other.stableCarbon == stableCarbon)&&(identical(other.organicNitrogen, organicNitrogen) || other.organicNitrogen == organicNitrogen)&&(identical(other.microbialNitrogen, microbialNitrogen) || other.microbialNitrogen == microbialNitrogen)&&(identical(other.maomNitrogen, maomNitrogen) || other.maomNitrogen == maomNitrogen)&&(identical(other.nitrogenContent, nitrogenContent) || other.nitrogenContent == nitrogenContent)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.colorValue, colorValue) || other.colorValue == colorValue)&&(identical(other.nitrificationRate, nitrificationRate) || other.nitrificationRate == nitrificationRate)&&(identical(other.denitrificationRate, denitrificationRate) || other.denitrificationRate == denitrificationRate)&&const DeepCollectionEquality().equals(other.traceElements, _traceElements)&&const DeepCollectionEquality().equals(other.hotspots, _hotspots));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,depth,thickness,kSat,porosity,thetaR,vgAlpha,vgN,vgL,bulkDensity,waterContent,previousWaterContent,verticalFlux,temperature,heatCapacity,ph,ec,redoxPotential,nitrateContent,ammoniumContent,phosphateContent,sorbedPhosphate,potassiumContent,exchangeablePotassium,solutionCalcium,exchangeableCalcium,solutionMagnesium,exchangeableMagnesium,exchangeableAluminium,cec,clayFraction,sandFraction,siltFraction,effectiveMacroPorosity,aggregateStability,oxygenContent,co2Content,methaneContent,nitrousOxideContent,thermalConductivity,microbialBiomass,epsContent,fungalHyphaeDensity,necromass,organicCarbon,particulateOrganicMatter,mineralAssociatedOrganicMatter,isCultivated,cultivationDisturbance,labileCarbon,stableCarbon,organicNitrogen,microbialNitrogen,maomNitrogen,nitrogenContent,name,description,colorValue,nitrificationRate,denitrificationRate,const DeepCollectionEquality().hash(_traceElements),const DeepCollectionEquality().hash(_hotspots)]);
}

@override
String toString() {
    return 'SoilLayer(id: $id, depth: $depth, thickness: $thickness, kSat: $kSat, porosity: $porosity, thetaR: $thetaR, vgAlpha: $vgAlpha, vgN: $vgN, vgL: $vgL, bulkDensity: $bulkDensity, waterContent: $waterContent, previousWaterContent: $previousWaterContent, verticalFlux: $verticalFlux, temperature: $temperature, heatCapacity: $heatCapacity, ph: $ph, ec: $ec, redoxPotential: $redoxPotential, nitrateContent: $nitrateContent, ammoniumContent: $ammoniumContent, phosphateContent: $phosphateContent, sorbedPhosphate: $sorbedPhosphate, potassiumContent: $potassiumContent, exchangeablePotassium: $exchangeablePotassium, solutionCalcium: $solutionCalcium, exchangeableCalcium: $exchangeableCalcium, solutionMagnesium: $solutionMagnesium, exchangeableMagnesium: $exchangeableMagnesium, exchangeableAluminium: $exchangeableAluminium, cec: $cec, clayFraction: $clayFraction, sandFraction: $sandFraction, siltFraction: $siltFraction, effectiveMacroPorosity: $effectiveMacroPorosity, aggregateStability: $aggregateStability, oxygenContent: $oxygenContent, co2Content: $co2Content, methaneContent: $methaneContent, nitrousOxideContent: $nitrousOxideContent, thermalConductivity: $thermalConductivity, microbialBiomass: $microbialBiomass, epsContent: $epsContent, fungalHyphaeDensity: $fungalHyphaeDensity, necromass: $necromass, organicCarbon: $organicCarbon, particulateOrganicMatter: $particulateOrganicMatter, mineralAssociatedOrganicMatter: $mineralAssociatedOrganicMatter, isCultivated: $isCultivated, cultivationDisturbance: $cultivationDisturbance, labileCarbon: $labileCarbon, stableCarbon: $stableCarbon, organicNitrogen: $organicNitrogen, microbialNitrogen: $microbialNitrogen, maomNitrogen: $maomNitrogen, nitrogenContent: $nitrogenContent, name: $name, description: $description, colorValue: $colorValue, nitrificationRate: $nitrificationRate, denitrificationRate: $denitrificationRate, traceElements: $traceElements, hotspots: $hotspots)';
}


}

/// @nodoc
abstract mixin class _$SoilLayerCopyWith<$Res> implements $SoilLayerCopyWith<$Res> {
  factory _$SoilLayerCopyWith(_SoilLayer value, $Res Function(_SoilLayer) _then) = __$SoilLayerCopyWithImpl;
@override @useResult
$Res call({
 String id, double depth, double thickness, double kSat, double porosity, double thetaR, double vgAlpha, double vgN, double vgL, double bulkDensity, double waterContent, double previousWaterContent, double verticalFlux, double temperature, double heatCapacity, double ph, double ec, double redoxPotential, double nitrateContent, double ammoniumContent, double phosphateContent, double sorbedPhosphate, double potassiumContent, double exchangeablePotassium, double solutionCalcium, double exchangeableCalcium, double solutionMagnesium, double exchangeableMagnesium, double exchangeableAluminium, double cec, double clayFraction, double sandFraction, double siltFraction, double effectiveMacroPorosity, double aggregateStability, double oxygenContent, double co2Content, double methaneContent, double nitrousOxideContent, double thermalConductivity, double microbialBiomass, double epsContent, double fungalHyphaeDensity, double necromass, double organicCarbon, double particulateOrganicMatter, double mineralAssociatedOrganicMatter, bool isCultivated, double cultivationDisturbance, double labileCarbon, double stableCarbon, double organicNitrogen, double microbialNitrogen, double maomNitrogen, double nitrogenContent, String name, String description, int colorValue, double nitrificationRate, double denitrificationRate, Map<String, double> traceElements, List<RhizosphereHotspot> hotspots
});




}
/// @nodoc
class __$SoilLayerCopyWithImpl<$Res>
    implements _$SoilLayerCopyWith<$Res> {
  __$SoilLayerCopyWithImpl(this._self, this._then);

  final _SoilLayer _self;
  final $Res Function(_SoilLayer) _then;

/// Create a copy of SoilLayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? depth = null,Object? thickness = null,Object? kSat = null,Object? porosity = null,Object? thetaR = null,Object? vgAlpha = null,Object? vgN = null,Object? vgL = null,Object? bulkDensity = null,Object? waterContent = null,Object? previousWaterContent = null,Object? verticalFlux = null,Object? temperature = null,Object? heatCapacity = null,Object? ph = null,Object? ec = null,Object? redoxPotential = null,Object? nitrateContent = null,Object? ammoniumContent = null,Object? phosphateContent = null,Object? sorbedPhosphate = null,Object? potassiumContent = null,Object? exchangeablePotassium = null,Object? solutionCalcium = null,Object? exchangeableCalcium = null,Object? solutionMagnesium = null,Object? exchangeableMagnesium = null,Object? exchangeableAluminium = null,Object? cec = null,Object? clayFraction = null,Object? sandFraction = null,Object? siltFraction = null,Object? effectiveMacroPorosity = null,Object? aggregateStability = null,Object? oxygenContent = null,Object? co2Content = null,Object? methaneContent = null,Object? nitrousOxideContent = null,Object? thermalConductivity = null,Object? microbialBiomass = null,Object? epsContent = null,Object? fungalHyphaeDensity = null,Object? necromass = null,Object? organicCarbon = null,Object? particulateOrganicMatter = null,Object? mineralAssociatedOrganicMatter = null,Object? isCultivated = null,Object? cultivationDisturbance = null,Object? labileCarbon = null,Object? stableCarbon = null,Object? organicNitrogen = null,Object? microbialNitrogen = null,Object? maomNitrogen = null,Object? nitrogenContent = null,Object? name = null,Object? description = null,Object? colorValue = null,Object? nitrificationRate = null,Object? denitrificationRate = null,Object? traceElements = null,Object? hotspots = null,}) {
  return _then(_SoilLayer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as double,thickness: null == thickness ? _self.thickness : thickness // ignore: cast_nullable_to_non_nullable
as double,kSat: null == kSat ? _self.kSat : kSat // ignore: cast_nullable_to_non_nullable
as double,porosity: null == porosity ? _self.porosity : porosity // ignore: cast_nullable_to_non_nullable
as double,thetaR: null == thetaR ? _self.thetaR : thetaR // ignore: cast_nullable_to_non_nullable
as double,vgAlpha: null == vgAlpha ? _self.vgAlpha : vgAlpha // ignore: cast_nullable_to_non_nullable
as double,vgN: null == vgN ? _self.vgN : vgN // ignore: cast_nullable_to_non_nullable
as double,vgL: null == vgL ? _self.vgL : vgL // ignore: cast_nullable_to_non_nullable
as double,bulkDensity: null == bulkDensity ? _self.bulkDensity : bulkDensity // ignore: cast_nullable_to_non_nullable
as double,waterContent: null == waterContent ? _self.waterContent : waterContent // ignore: cast_nullable_to_non_nullable
as double,previousWaterContent: null == previousWaterContent ? _self.previousWaterContent : previousWaterContent // ignore: cast_nullable_to_non_nullable
as double,verticalFlux: null == verticalFlux ? _self.verticalFlux : verticalFlux // ignore: cast_nullable_to_non_nullable
as double,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,heatCapacity: null == heatCapacity ? _self.heatCapacity : heatCapacity // ignore: cast_nullable_to_non_nullable
as double,ph: null == ph ? _self.ph : ph // ignore: cast_nullable_to_non_nullable
as double,ec: null == ec ? _self.ec : ec // ignore: cast_nullable_to_non_nullable
as double,redoxPotential: null == redoxPotential ? _self.redoxPotential : redoxPotential // ignore: cast_nullable_to_non_nullable
as double,nitrateContent: null == nitrateContent ? _self.nitrateContent : nitrateContent // ignore: cast_nullable_to_non_nullable
as double,ammoniumContent: null == ammoniumContent ? _self.ammoniumContent : ammoniumContent // ignore: cast_nullable_to_non_nullable
as double,phosphateContent: null == phosphateContent ? _self.phosphateContent : phosphateContent // ignore: cast_nullable_to_non_nullable
as double,sorbedPhosphate: null == sorbedPhosphate ? _self.sorbedPhosphate : sorbedPhosphate // ignore: cast_nullable_to_non_nullable
as double,potassiumContent: null == potassiumContent ? _self.potassiumContent : potassiumContent // ignore: cast_nullable_to_non_nullable
as double,exchangeablePotassium: null == exchangeablePotassium ? _self.exchangeablePotassium : exchangeablePotassium // ignore: cast_nullable_to_non_nullable
as double,solutionCalcium: null == solutionCalcium ? _self.solutionCalcium : solutionCalcium // ignore: cast_nullable_to_non_nullable
as double,exchangeableCalcium: null == exchangeableCalcium ? _self.exchangeableCalcium : exchangeableCalcium // ignore: cast_nullable_to_non_nullable
as double,solutionMagnesium: null == solutionMagnesium ? _self.solutionMagnesium : solutionMagnesium // ignore: cast_nullable_to_non_nullable
as double,exchangeableMagnesium: null == exchangeableMagnesium ? _self.exchangeableMagnesium : exchangeableMagnesium // ignore: cast_nullable_to_non_nullable
as double,exchangeableAluminium: null == exchangeableAluminium ? _self.exchangeableAluminium : exchangeableAluminium // ignore: cast_nullable_to_non_nullable
as double,cec: null == cec ? _self.cec : cec // ignore: cast_nullable_to_non_nullable
as double,clayFraction: null == clayFraction ? _self.clayFraction : clayFraction // ignore: cast_nullable_to_non_nullable
as double,sandFraction: null == sandFraction ? _self.sandFraction : sandFraction // ignore: cast_nullable_to_non_nullable
as double,siltFraction: null == siltFraction ? _self.siltFraction : siltFraction // ignore: cast_nullable_to_non_nullable
as double,effectiveMacroPorosity: null == effectiveMacroPorosity ? _self.effectiveMacroPorosity : effectiveMacroPorosity // ignore: cast_nullable_to_non_nullable
as double,aggregateStability: null == aggregateStability ? _self.aggregateStability : aggregateStability // ignore: cast_nullable_to_non_nullable
as double,oxygenContent: null == oxygenContent ? _self.oxygenContent : oxygenContent // ignore: cast_nullable_to_non_nullable
as double,co2Content: null == co2Content ? _self.co2Content : co2Content // ignore: cast_nullable_to_non_nullable
as double,methaneContent: null == methaneContent ? _self.methaneContent : methaneContent // ignore: cast_nullable_to_non_nullable
as double,nitrousOxideContent: null == nitrousOxideContent ? _self.nitrousOxideContent : nitrousOxideContent // ignore: cast_nullable_to_non_nullable
as double,thermalConductivity: null == thermalConductivity ? _self.thermalConductivity : thermalConductivity // ignore: cast_nullable_to_non_nullable
as double,microbialBiomass: null == microbialBiomass ? _self.microbialBiomass : microbialBiomass // ignore: cast_nullable_to_non_nullable
as double,epsContent: null == epsContent ? _self.epsContent : epsContent // ignore: cast_nullable_to_non_nullable
as double,fungalHyphaeDensity: null == fungalHyphaeDensity ? _self.fungalHyphaeDensity : fungalHyphaeDensity // ignore: cast_nullable_to_non_nullable
as double,necromass: null == necromass ? _self.necromass : necromass // ignore: cast_nullable_to_non_nullable
as double,organicCarbon: null == organicCarbon ? _self.organicCarbon : organicCarbon // ignore: cast_nullable_to_non_nullable
as double,particulateOrganicMatter: null == particulateOrganicMatter ? _self.particulateOrganicMatter : particulateOrganicMatter // ignore: cast_nullable_to_non_nullable
as double,mineralAssociatedOrganicMatter: null == mineralAssociatedOrganicMatter ? _self.mineralAssociatedOrganicMatter : mineralAssociatedOrganicMatter // ignore: cast_nullable_to_non_nullable
as double,isCultivated: null == isCultivated ? _self.isCultivated : isCultivated // ignore: cast_nullable_to_non_nullable
as bool,cultivationDisturbance: null == cultivationDisturbance ? _self.cultivationDisturbance : cultivationDisturbance // ignore: cast_nullable_to_non_nullable
as double,labileCarbon: null == labileCarbon ? _self.labileCarbon : labileCarbon // ignore: cast_nullable_to_non_nullable
as double,stableCarbon: null == stableCarbon ? _self.stableCarbon : stableCarbon // ignore: cast_nullable_to_non_nullable
as double,organicNitrogen: null == organicNitrogen ? _self.organicNitrogen : organicNitrogen // ignore: cast_nullable_to_non_nullable
as double,microbialNitrogen: null == microbialNitrogen ? _self.microbialNitrogen : microbialNitrogen // ignore: cast_nullable_to_non_nullable
as double,maomNitrogen: null == maomNitrogen ? _self.maomNitrogen : maomNitrogen // ignore: cast_nullable_to_non_nullable
as double,nitrogenContent: null == nitrogenContent ? _self.nitrogenContent : nitrogenContent // ignore: cast_nullable_to_non_nullable
as double,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,colorValue: null == colorValue ? _self.colorValue : colorValue // ignore: cast_nullable_to_non_nullable
as int,nitrificationRate: null == nitrificationRate ? _self.nitrificationRate : nitrificationRate // ignore: cast_nullable_to_non_nullable
as double,denitrificationRate: null == denitrificationRate ? _self.denitrificationRate : denitrificationRate // ignore: cast_nullable_to_non_nullable
as double,traceElements: null == traceElements ? _self._traceElements : traceElements // ignore: cast_nullable_to_non_nullable
as Map<String, double>,hotspots: null == hotspots ? _self._hotspots : hotspots // ignore: cast_nullable_to_non_nullable
as List<RhizosphereHotspot>,
  ));
}


}


/// @nodoc
mixin _$RhizosphereHotspot {

 String get id; double get x; double get z; double get intensity; double get radius; double get age; HotspotType get type;
/// Create a copy of RhizosphereHotspot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RhizosphereHotspotCopyWith<RhizosphereHotspot> get copyWith => _$RhizosphereHotspotCopyWithImpl<RhizosphereHotspot>(this as RhizosphereHotspot, _$identity);

  /// Serializes this RhizosphereHotspot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as RhizosphereHotspot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RhizosphereHotspot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.x, _this.x) || other.x == _this.x)&&(identical(other.z, _this.z) || other.z == _this.z)&&(identical(other.intensity, _this.intensity) || other.intensity == _this.intensity)&&(identical(other.radius, _this.radius) || other.radius == _this.radius)&&(identical(other.age, _this.age) || other.age == _this.age)&&(identical(other.type, _this.type) || other.type == _this.type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as RhizosphereHotspot;
  return Object.hash(runtimeType,_this.id,_this.x,_this.z,_this.intensity,_this.radius,_this.age,_this.type);
}

@override
String toString() {
  final _this = this as RhizosphereHotspot;
  return 'RhizosphereHotspot(id: ${_this.id}, x: ${_this.x}, z: ${_this.z}, intensity: ${_this.intensity}, radius: ${_this.radius}, age: ${_this.age}, type: ${_this.type})';
}


}

/// @nodoc
abstract mixin class $RhizosphereHotspotCopyWith<$Res>  {
  factory $RhizosphereHotspotCopyWith(RhizosphereHotspot value, $Res Function(RhizosphereHotspot) _then) = _$RhizosphereHotspotCopyWithImpl;
@useResult
$Res call({
 String id, double x, double z, double intensity, double radius, double age, HotspotType type
});




}
/// @nodoc
class _$RhizosphereHotspotCopyWithImpl<$Res>
    implements $RhizosphereHotspotCopyWith<$Res> {
  _$RhizosphereHotspotCopyWithImpl(this._self, this._then);

  final RhizosphereHotspot _self;
  final $Res Function(RhizosphereHotspot) _then;

/// Create a copy of RhizosphereHotspot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? x = null,Object? z = null,Object? intensity = null,Object? radius = null,Object? age = null,Object? type = null,}) {
  return _then(RhizosphereHotspot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,z: null == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as double,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as double,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HotspotType,
  ));
}

}


/// Adds pattern-matching-related methods to [RhizosphereHotspot].
extension RhizosphereHotspotPatterns on RhizosphereHotspot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RhizosphereHotspot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RhizosphereHotspot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RhizosphereHotspot value)  $default,){
final _that = this;
switch (_that) {
case _RhizosphereHotspot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RhizosphereHotspot value)?  $default,){
final _that = this;
switch (_that) {
case _RhizosphereHotspot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double x,  double z,  double intensity,  double radius,  double age,  HotspotType type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RhizosphereHotspot() when $default != null:
return $default(_that.id,_that.x,_that.z,_that.intensity,_that.radius,_that.age,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double x,  double z,  double intensity,  double radius,  double age,  HotspotType type)  $default,) {final _that = this;
switch (_that) {
case _RhizosphereHotspot():
return $default(_that.id,_that.x,_that.z,_that.intensity,_that.radius,_that.age,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double x,  double z,  double intensity,  double radius,  double age,  HotspotType type)?  $default,) {final _that = this;
switch (_that) {
case _RhizosphereHotspot() when $default != null:
return $default(_that.id,_that.x,_that.z,_that.intensity,_that.radius,_that.age,_that.type);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RhizosphereHotspot implements RhizosphereHotspot {
  const _RhizosphereHotspot({required this.id, required this.x, required this.z, required this.intensity, this.radius = 0.05, this.age = 0.0, this.type = HotspotType.rhizosphere});
  factory _RhizosphereHotspot.fromJson(Map<String, dynamic> json) => _$RhizosphereHotspotFromJson(json);

@override final  String id;
@override final  double x;
@override final  double z;
@override final  double intensity;
@override@JsonKey() final  double radius;
@override@JsonKey() final  double age;
@override@JsonKey() final  HotspotType type;

/// Create a copy of RhizosphereHotspot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RhizosphereHotspotCopyWith<_RhizosphereHotspot> get copyWith => __$RhizosphereHotspotCopyWithImpl<_RhizosphereHotspot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RhizosphereHotspotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RhizosphereHotspot&&(identical(other.id, id) || other.id == id)&&(identical(other.x, x) || other.x == x)&&(identical(other.z, z) || other.z == z)&&(identical(other.intensity, intensity) || other.intensity == intensity)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.age, age) || other.age == age)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,x,z,intensity,radius,age,type);
}

@override
String toString() {
    return 'RhizosphereHotspot(id: $id, x: $x, z: $z, intensity: $intensity, radius: $radius, age: $age, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RhizosphereHotspotCopyWith<$Res> implements $RhizosphereHotspotCopyWith<$Res> {
  factory _$RhizosphereHotspotCopyWith(_RhizosphereHotspot value, $Res Function(_RhizosphereHotspot) _then) = __$RhizosphereHotspotCopyWithImpl;
@override @useResult
$Res call({
 String id, double x, double z, double intensity, double radius, double age, HotspotType type
});




}
/// @nodoc
class __$RhizosphereHotspotCopyWithImpl<$Res>
    implements _$RhizosphereHotspotCopyWith<$Res> {
  __$RhizosphereHotspotCopyWithImpl(this._self, this._then);

  final _RhizosphereHotspot _self;
  final $Res Function(_RhizosphereHotspot) _then;

/// Create a copy of RhizosphereHotspot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? x = null,Object? z = null,Object? intensity = null,Object? radius = null,Object? age = null,Object? type = null,}) {
  return _then(_RhizosphereHotspot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,z: null == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as double,intensity: null == intensity ? _self.intensity : intensity // ignore: cast_nullable_to_non_nullable
as double,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as HotspotType,
  ));
}


}

// dart format on
