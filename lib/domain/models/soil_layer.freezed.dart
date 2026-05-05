// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'soil_layer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoilLayer {

 String get id; double get depth;// m
 double get thickness;// m
// Physical properties
 double get kSat;// Hydraulic conductivity (m/s)
 double get porosity;// (0.0 - 1.0) - also thetaS
 double get thetaR;// Residual water content
 double get vgAlpha;// van Genuchten alpha (1/m)
 double get vgN;// van Genuchten n
 double get vgL;// Tortuosity parameter
 double get bulkDensity;// (kg/m^3)
 double get waterContent;// (m^3/m^3)
 double get previousWaterContent; double get verticalFlux;// m/s (Net flux within layer)
 double get temperature;// K
 double get heatCapacity;// J/(m^3*K) (volumetric heat capacity Cv)
// Chemical properties
 double get ph; double get ec;// Electrical conductivity (dS/m)
 double get redoxPotential;// Eh (mV)
 double get nitrateContent;// mg/kg
 double get ammoniumContent;// mg/kg
 double get phosphateContent;// mg/kg (solution pool)
 double get sorbedPhosphate;// mg/kg (solid pool)
 double get potassiumContent;// mg/kg (solution pool)
 double get exchangeablePotassium;// mg/kg
 double get solutionCalcium;// mg/kg
 double get exchangeableCalcium;// mg/kg
 double get solutionMagnesium;// mg/kg
 double get exchangeableMagnesium;// mg/kg
 double get exchangeableAluminium;// mg/kg
 double get cec;// cmol(+)/kg
 double get clayFraction;// (0.0 - 1.0)
 double get sandFraction;// (0.0 - 1.0)
 double get siltFraction;// (0.0 - 1.0)
 double get effectiveMacroPorosity;// (0.0 - 1.0)
 double get aggregateStability;// (0.0 - 1.0)
 double get oxygenContent;// mol/m^3 (approx 21% air at 20C)
 double get co2Content;// mol/m^3 (approx 400 ppm)
 double get methaneContent;// mol/m^3
 double get nitrousOxideContent;// mol/m^3
 double get thermalConductivity;// W/m*K
// Biological properties
 double get microbialBiomass;// (kg/m^3)
 double get epsContent;// Extracellular Polymeric Substances
 double get fungalHyphaeDensity; double get necromass;// Stabilized organic matter (MAOM)
// Carbon/Nutrients
 double get organicCarbon; double get particulateOrganicMatter;// Labile (POM) (kg/m^3)
 double get mineralAssociatedOrganicMatter;// Stable (MAOM) (kg/m^3)
// Cultivation / Tillage
 bool get isCultivated; double get cultivationDisturbance;// 0.0 to 1.0 (1.0 = fully disturbed)
 double get labileCarbon;// Alias/Specific pool for POM
 double get stableCarbon;// Alias/Specific pool for MAOM
 double get organicNitrogen;// mg/kg (POM-N pool)
 double get microbialNitrogen;// mg/kg (Mic-N pool)
 double get maomNitrogen;// mg/kg (MAOM-N pool)
 double get nitrogenContent;// === NEW DIAGNOSTIC FLUXES ===
 double get nitrificationRate;// mg/kg/s
 double get denitrificationRate;// mg/kg/s
 Map<String, double> get traceElements;
/// Create a copy of SoilLayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoilLayerCopyWith<SoilLayer> get copyWith => _$SoilLayerCopyWithImpl<SoilLayer>(this as SoilLayer, _$identity);

  /// Serializes this SoilLayer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoilLayer&&(identical(other.id, id) || other.id == id)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.thickness, thickness) || other.thickness == thickness)&&(identical(other.kSat, kSat) || other.kSat == kSat)&&(identical(other.porosity, porosity) || other.porosity == porosity)&&(identical(other.thetaR, thetaR) || other.thetaR == thetaR)&&(identical(other.vgAlpha, vgAlpha) || other.vgAlpha == vgAlpha)&&(identical(other.vgN, vgN) || other.vgN == vgN)&&(identical(other.vgL, vgL) || other.vgL == vgL)&&(identical(other.bulkDensity, bulkDensity) || other.bulkDensity == bulkDensity)&&(identical(other.waterContent, waterContent) || other.waterContent == waterContent)&&(identical(other.previousWaterContent, previousWaterContent) || other.previousWaterContent == previousWaterContent)&&(identical(other.verticalFlux, verticalFlux) || other.verticalFlux == verticalFlux)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.heatCapacity, heatCapacity) || other.heatCapacity == heatCapacity)&&(identical(other.ph, ph) || other.ph == ph)&&(identical(other.ec, ec) || other.ec == ec)&&(identical(other.redoxPotential, redoxPotential) || other.redoxPotential == redoxPotential)&&(identical(other.nitrateContent, nitrateContent) || other.nitrateContent == nitrateContent)&&(identical(other.ammoniumContent, ammoniumContent) || other.ammoniumContent == ammoniumContent)&&(identical(other.phosphateContent, phosphateContent) || other.phosphateContent == phosphateContent)&&(identical(other.sorbedPhosphate, sorbedPhosphate) || other.sorbedPhosphate == sorbedPhosphate)&&(identical(other.potassiumContent, potassiumContent) || other.potassiumContent == potassiumContent)&&(identical(other.exchangeablePotassium, exchangeablePotassium) || other.exchangeablePotassium == exchangeablePotassium)&&(identical(other.solutionCalcium, solutionCalcium) || other.solutionCalcium == solutionCalcium)&&(identical(other.exchangeableCalcium, exchangeableCalcium) || other.exchangeableCalcium == exchangeableCalcium)&&(identical(other.solutionMagnesium, solutionMagnesium) || other.solutionMagnesium == solutionMagnesium)&&(identical(other.exchangeableMagnesium, exchangeableMagnesium) || other.exchangeableMagnesium == exchangeableMagnesium)&&(identical(other.exchangeableAluminium, exchangeableAluminium) || other.exchangeableAluminium == exchangeableAluminium)&&(identical(other.cec, cec) || other.cec == cec)&&(identical(other.clayFraction, clayFraction) || other.clayFraction == clayFraction)&&(identical(other.sandFraction, sandFraction) || other.sandFraction == sandFraction)&&(identical(other.siltFraction, siltFraction) || other.siltFraction == siltFraction)&&(identical(other.effectiveMacroPorosity, effectiveMacroPorosity) || other.effectiveMacroPorosity == effectiveMacroPorosity)&&(identical(other.aggregateStability, aggregateStability) || other.aggregateStability == aggregateStability)&&(identical(other.oxygenContent, oxygenContent) || other.oxygenContent == oxygenContent)&&(identical(other.co2Content, co2Content) || other.co2Content == co2Content)&&(identical(other.methaneContent, methaneContent) || other.methaneContent == methaneContent)&&(identical(other.nitrousOxideContent, nitrousOxideContent) || other.nitrousOxideContent == nitrousOxideContent)&&(identical(other.thermalConductivity, thermalConductivity) || other.thermalConductivity == thermalConductivity)&&(identical(other.microbialBiomass, microbialBiomass) || other.microbialBiomass == microbialBiomass)&&(identical(other.epsContent, epsContent) || other.epsContent == epsContent)&&(identical(other.fungalHyphaeDensity, fungalHyphaeDensity) || other.fungalHyphaeDensity == fungalHyphaeDensity)&&(identical(other.necromass, necromass) || other.necromass == necromass)&&(identical(other.organicCarbon, organicCarbon) || other.organicCarbon == organicCarbon)&&(identical(other.particulateOrganicMatter, particulateOrganicMatter) || other.particulateOrganicMatter == particulateOrganicMatter)&&(identical(other.mineralAssociatedOrganicMatter, mineralAssociatedOrganicMatter) || other.mineralAssociatedOrganicMatter == mineralAssociatedOrganicMatter)&&(identical(other.isCultivated, isCultivated) || other.isCultivated == isCultivated)&&(identical(other.cultivationDisturbance, cultivationDisturbance) || other.cultivationDisturbance == cultivationDisturbance)&&(identical(other.labileCarbon, labileCarbon) || other.labileCarbon == labileCarbon)&&(identical(other.stableCarbon, stableCarbon) || other.stableCarbon == stableCarbon)&&(identical(other.organicNitrogen, organicNitrogen) || other.organicNitrogen == organicNitrogen)&&(identical(other.microbialNitrogen, microbialNitrogen) || other.microbialNitrogen == microbialNitrogen)&&(identical(other.maomNitrogen, maomNitrogen) || other.maomNitrogen == maomNitrogen)&&(identical(other.nitrogenContent, nitrogenContent) || other.nitrogenContent == nitrogenContent)&&(identical(other.nitrificationRate, nitrificationRate) || other.nitrificationRate == nitrificationRate)&&(identical(other.denitrificationRate, denitrificationRate) || other.denitrificationRate == denitrificationRate)&&const DeepCollectionEquality().equals(other.traceElements, traceElements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,depth,thickness,kSat,porosity,thetaR,vgAlpha,vgN,vgL,bulkDensity,waterContent,previousWaterContent,verticalFlux,temperature,heatCapacity,ph,ec,redoxPotential,nitrateContent,ammoniumContent,phosphateContent,sorbedPhosphate,potassiumContent,exchangeablePotassium,solutionCalcium,exchangeableCalcium,solutionMagnesium,exchangeableMagnesium,exchangeableAluminium,cec,clayFraction,sandFraction,siltFraction,effectiveMacroPorosity,aggregateStability,oxygenContent,co2Content,methaneContent,nitrousOxideContent,thermalConductivity,microbialBiomass,epsContent,fungalHyphaeDensity,necromass,organicCarbon,particulateOrganicMatter,mineralAssociatedOrganicMatter,isCultivated,cultivationDisturbance,labileCarbon,stableCarbon,organicNitrogen,microbialNitrogen,maomNitrogen,nitrogenContent,nitrificationRate,denitrificationRate,const DeepCollectionEquality().hash(traceElements)]);

@override
String toString() {
  return 'SoilLayer(id: $id, depth: $depth, thickness: $thickness, kSat: $kSat, porosity: $porosity, thetaR: $thetaR, vgAlpha: $vgAlpha, vgN: $vgN, vgL: $vgL, bulkDensity: $bulkDensity, waterContent: $waterContent, previousWaterContent: $previousWaterContent, verticalFlux: $verticalFlux, temperature: $temperature, heatCapacity: $heatCapacity, ph: $ph, ec: $ec, redoxPotential: $redoxPotential, nitrateContent: $nitrateContent, ammoniumContent: $ammoniumContent, phosphateContent: $phosphateContent, sorbedPhosphate: $sorbedPhosphate, potassiumContent: $potassiumContent, exchangeablePotassium: $exchangeablePotassium, solutionCalcium: $solutionCalcium, exchangeableCalcium: $exchangeableCalcium, solutionMagnesium: $solutionMagnesium, exchangeableMagnesium: $exchangeableMagnesium, exchangeableAluminium: $exchangeableAluminium, cec: $cec, clayFraction: $clayFraction, sandFraction: $sandFraction, siltFraction: $siltFraction, effectiveMacroPorosity: $effectiveMacroPorosity, aggregateStability: $aggregateStability, oxygenContent: $oxygenContent, co2Content: $co2Content, methaneContent: $methaneContent, nitrousOxideContent: $nitrousOxideContent, thermalConductivity: $thermalConductivity, microbialBiomass: $microbialBiomass, epsContent: $epsContent, fungalHyphaeDensity: $fungalHyphaeDensity, necromass: $necromass, organicCarbon: $organicCarbon, particulateOrganicMatter: $particulateOrganicMatter, mineralAssociatedOrganicMatter: $mineralAssociatedOrganicMatter, isCultivated: $isCultivated, cultivationDisturbance: $cultivationDisturbance, labileCarbon: $labileCarbon, stableCarbon: $stableCarbon, organicNitrogen: $organicNitrogen, microbialNitrogen: $microbialNitrogen, maomNitrogen: $maomNitrogen, nitrogenContent: $nitrogenContent, nitrificationRate: $nitrificationRate, denitrificationRate: $denitrificationRate, traceElements: $traceElements)';
}


}

/// @nodoc
abstract mixin class $SoilLayerCopyWith<$Res>  {
  factory $SoilLayerCopyWith(SoilLayer value, $Res Function(SoilLayer) _then) = _$SoilLayerCopyWithImpl;
@useResult
$Res call({
 String id, double depth, double thickness, double kSat, double porosity, double thetaR, double vgAlpha, double vgN, double vgL, double bulkDensity, double waterContent, double previousWaterContent, double verticalFlux, double temperature, double heatCapacity, double ph, double ec, double redoxPotential, double nitrateContent, double ammoniumContent, double phosphateContent, double sorbedPhosphate, double potassiumContent, double exchangeablePotassium, double solutionCalcium, double exchangeableCalcium, double solutionMagnesium, double exchangeableMagnesium, double exchangeableAluminium, double cec, double clayFraction, double sandFraction, double siltFraction, double effectiveMacroPorosity, double aggregateStability, double oxygenContent, double co2Content, double methaneContent, double nitrousOxideContent, double thermalConductivity, double microbialBiomass, double epsContent, double fungalHyphaeDensity, double necromass, double organicCarbon, double particulateOrganicMatter, double mineralAssociatedOrganicMatter, bool isCultivated, double cultivationDisturbance, double labileCarbon, double stableCarbon, double organicNitrogen, double microbialNitrogen, double maomNitrogen, double nitrogenContent, double nitrificationRate, double denitrificationRate, Map<String, double> traceElements
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? depth = null,Object? thickness = null,Object? kSat = null,Object? porosity = null,Object? thetaR = null,Object? vgAlpha = null,Object? vgN = null,Object? vgL = null,Object? bulkDensity = null,Object? waterContent = null,Object? previousWaterContent = null,Object? verticalFlux = null,Object? temperature = null,Object? heatCapacity = null,Object? ph = null,Object? ec = null,Object? redoxPotential = null,Object? nitrateContent = null,Object? ammoniumContent = null,Object? phosphateContent = null,Object? sorbedPhosphate = null,Object? potassiumContent = null,Object? exchangeablePotassium = null,Object? solutionCalcium = null,Object? exchangeableCalcium = null,Object? solutionMagnesium = null,Object? exchangeableMagnesium = null,Object? exchangeableAluminium = null,Object? cec = null,Object? clayFraction = null,Object? sandFraction = null,Object? siltFraction = null,Object? effectiveMacroPorosity = null,Object? aggregateStability = null,Object? oxygenContent = null,Object? co2Content = null,Object? methaneContent = null,Object? nitrousOxideContent = null,Object? thermalConductivity = null,Object? microbialBiomass = null,Object? epsContent = null,Object? fungalHyphaeDensity = null,Object? necromass = null,Object? organicCarbon = null,Object? particulateOrganicMatter = null,Object? mineralAssociatedOrganicMatter = null,Object? isCultivated = null,Object? cultivationDisturbance = null,Object? labileCarbon = null,Object? stableCarbon = null,Object? organicNitrogen = null,Object? microbialNitrogen = null,Object? maomNitrogen = null,Object? nitrogenContent = null,Object? nitrificationRate = null,Object? denitrificationRate = null,Object? traceElements = null,}) {
  return _then(_self.copyWith(
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
as double,nitrificationRate: null == nitrificationRate ? _self.nitrificationRate : nitrificationRate // ignore: cast_nullable_to_non_nullable
as double,denitrificationRate: null == denitrificationRate ? _self.denitrificationRate : denitrificationRate // ignore: cast_nullable_to_non_nullable
as double,traceElements: null == traceElements ? _self.traceElements : traceElements // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double depth,  double thickness,  double kSat,  double porosity,  double thetaR,  double vgAlpha,  double vgN,  double vgL,  double bulkDensity,  double waterContent,  double previousWaterContent,  double verticalFlux,  double temperature,  double heatCapacity,  double ph,  double ec,  double redoxPotential,  double nitrateContent,  double ammoniumContent,  double phosphateContent,  double sorbedPhosphate,  double potassiumContent,  double exchangeablePotassium,  double solutionCalcium,  double exchangeableCalcium,  double solutionMagnesium,  double exchangeableMagnesium,  double exchangeableAluminium,  double cec,  double clayFraction,  double sandFraction,  double siltFraction,  double effectiveMacroPorosity,  double aggregateStability,  double oxygenContent,  double co2Content,  double methaneContent,  double nitrousOxideContent,  double thermalConductivity,  double microbialBiomass,  double epsContent,  double fungalHyphaeDensity,  double necromass,  double organicCarbon,  double particulateOrganicMatter,  double mineralAssociatedOrganicMatter,  bool isCultivated,  double cultivationDisturbance,  double labileCarbon,  double stableCarbon,  double organicNitrogen,  double microbialNitrogen,  double maomNitrogen,  double nitrogenContent,  double nitrificationRate,  double denitrificationRate,  Map<String, double> traceElements)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoilLayer() when $default != null:
return $default(_that.id,_that.depth,_that.thickness,_that.kSat,_that.porosity,_that.thetaR,_that.vgAlpha,_that.vgN,_that.vgL,_that.bulkDensity,_that.waterContent,_that.previousWaterContent,_that.verticalFlux,_that.temperature,_that.heatCapacity,_that.ph,_that.ec,_that.redoxPotential,_that.nitrateContent,_that.ammoniumContent,_that.phosphateContent,_that.sorbedPhosphate,_that.potassiumContent,_that.exchangeablePotassium,_that.solutionCalcium,_that.exchangeableCalcium,_that.solutionMagnesium,_that.exchangeableMagnesium,_that.exchangeableAluminium,_that.cec,_that.clayFraction,_that.sandFraction,_that.siltFraction,_that.effectiveMacroPorosity,_that.aggregateStability,_that.oxygenContent,_that.co2Content,_that.methaneContent,_that.nitrousOxideContent,_that.thermalConductivity,_that.microbialBiomass,_that.epsContent,_that.fungalHyphaeDensity,_that.necromass,_that.organicCarbon,_that.particulateOrganicMatter,_that.mineralAssociatedOrganicMatter,_that.isCultivated,_that.cultivationDisturbance,_that.labileCarbon,_that.stableCarbon,_that.organicNitrogen,_that.microbialNitrogen,_that.maomNitrogen,_that.nitrogenContent,_that.nitrificationRate,_that.denitrificationRate,_that.traceElements);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double depth,  double thickness,  double kSat,  double porosity,  double thetaR,  double vgAlpha,  double vgN,  double vgL,  double bulkDensity,  double waterContent,  double previousWaterContent,  double verticalFlux,  double temperature,  double heatCapacity,  double ph,  double ec,  double redoxPotential,  double nitrateContent,  double ammoniumContent,  double phosphateContent,  double sorbedPhosphate,  double potassiumContent,  double exchangeablePotassium,  double solutionCalcium,  double exchangeableCalcium,  double solutionMagnesium,  double exchangeableMagnesium,  double exchangeableAluminium,  double cec,  double clayFraction,  double sandFraction,  double siltFraction,  double effectiveMacroPorosity,  double aggregateStability,  double oxygenContent,  double co2Content,  double methaneContent,  double nitrousOxideContent,  double thermalConductivity,  double microbialBiomass,  double epsContent,  double fungalHyphaeDensity,  double necromass,  double organicCarbon,  double particulateOrganicMatter,  double mineralAssociatedOrganicMatter,  bool isCultivated,  double cultivationDisturbance,  double labileCarbon,  double stableCarbon,  double organicNitrogen,  double microbialNitrogen,  double maomNitrogen,  double nitrogenContent,  double nitrificationRate,  double denitrificationRate,  Map<String, double> traceElements)  $default,) {final _that = this;
switch (_that) {
case _SoilLayer():
return $default(_that.id,_that.depth,_that.thickness,_that.kSat,_that.porosity,_that.thetaR,_that.vgAlpha,_that.vgN,_that.vgL,_that.bulkDensity,_that.waterContent,_that.previousWaterContent,_that.verticalFlux,_that.temperature,_that.heatCapacity,_that.ph,_that.ec,_that.redoxPotential,_that.nitrateContent,_that.ammoniumContent,_that.phosphateContent,_that.sorbedPhosphate,_that.potassiumContent,_that.exchangeablePotassium,_that.solutionCalcium,_that.exchangeableCalcium,_that.solutionMagnesium,_that.exchangeableMagnesium,_that.exchangeableAluminium,_that.cec,_that.clayFraction,_that.sandFraction,_that.siltFraction,_that.effectiveMacroPorosity,_that.aggregateStability,_that.oxygenContent,_that.co2Content,_that.methaneContent,_that.nitrousOxideContent,_that.thermalConductivity,_that.microbialBiomass,_that.epsContent,_that.fungalHyphaeDensity,_that.necromass,_that.organicCarbon,_that.particulateOrganicMatter,_that.mineralAssociatedOrganicMatter,_that.isCultivated,_that.cultivationDisturbance,_that.labileCarbon,_that.stableCarbon,_that.organicNitrogen,_that.microbialNitrogen,_that.maomNitrogen,_that.nitrogenContent,_that.nitrificationRate,_that.denitrificationRate,_that.traceElements);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double depth,  double thickness,  double kSat,  double porosity,  double thetaR,  double vgAlpha,  double vgN,  double vgL,  double bulkDensity,  double waterContent,  double previousWaterContent,  double verticalFlux,  double temperature,  double heatCapacity,  double ph,  double ec,  double redoxPotential,  double nitrateContent,  double ammoniumContent,  double phosphateContent,  double sorbedPhosphate,  double potassiumContent,  double exchangeablePotassium,  double solutionCalcium,  double exchangeableCalcium,  double solutionMagnesium,  double exchangeableMagnesium,  double exchangeableAluminium,  double cec,  double clayFraction,  double sandFraction,  double siltFraction,  double effectiveMacroPorosity,  double aggregateStability,  double oxygenContent,  double co2Content,  double methaneContent,  double nitrousOxideContent,  double thermalConductivity,  double microbialBiomass,  double epsContent,  double fungalHyphaeDensity,  double necromass,  double organicCarbon,  double particulateOrganicMatter,  double mineralAssociatedOrganicMatter,  bool isCultivated,  double cultivationDisturbance,  double labileCarbon,  double stableCarbon,  double organicNitrogen,  double microbialNitrogen,  double maomNitrogen,  double nitrogenContent,  double nitrificationRate,  double denitrificationRate,  Map<String, double> traceElements)?  $default,) {final _that = this;
switch (_that) {
case _SoilLayer() when $default != null:
return $default(_that.id,_that.depth,_that.thickness,_that.kSat,_that.porosity,_that.thetaR,_that.vgAlpha,_that.vgN,_that.vgL,_that.bulkDensity,_that.waterContent,_that.previousWaterContent,_that.verticalFlux,_that.temperature,_that.heatCapacity,_that.ph,_that.ec,_that.redoxPotential,_that.nitrateContent,_that.ammoniumContent,_that.phosphateContent,_that.sorbedPhosphate,_that.potassiumContent,_that.exchangeablePotassium,_that.solutionCalcium,_that.exchangeableCalcium,_that.solutionMagnesium,_that.exchangeableMagnesium,_that.exchangeableAluminium,_that.cec,_that.clayFraction,_that.sandFraction,_that.siltFraction,_that.effectiveMacroPorosity,_that.aggregateStability,_that.oxygenContent,_that.co2Content,_that.methaneContent,_that.nitrousOxideContent,_that.thermalConductivity,_that.microbialBiomass,_that.epsContent,_that.fungalHyphaeDensity,_that.necromass,_that.organicCarbon,_that.particulateOrganicMatter,_that.mineralAssociatedOrganicMatter,_that.isCultivated,_that.cultivationDisturbance,_that.labileCarbon,_that.stableCarbon,_that.organicNitrogen,_that.microbialNitrogen,_that.maomNitrogen,_that.nitrogenContent,_that.nitrificationRate,_that.denitrificationRate,_that.traceElements);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoilLayer extends SoilLayer {
  const _SoilLayer({required this.id, required this.depth, required this.thickness, required this.kSat, required this.porosity, required this.thetaR, required this.vgAlpha, required this.vgN, this.vgL = 0.5, required this.bulkDensity, required this.waterContent, this.previousWaterContent = 0.0, this.verticalFlux = 0.0, required this.temperature, required this.heatCapacity, required this.ph, required this.ec, required this.redoxPotential, required this.nitrateContent, required this.ammoniumContent, required this.phosphateContent, this.sorbedPhosphate = 0.0, this.potassiumContent = 5.0, this.exchangeablePotassium = 50.0, this.solutionCalcium = 100.0, this.exchangeableCalcium = 1000.0, this.solutionMagnesium = 20.0, this.exchangeableMagnesium = 200.0, this.exchangeableAluminium = 5.0, this.cec = 10.0, this.clayFraction = 0.2, this.sandFraction = 0.4, this.siltFraction = 0.4, this.effectiveMacroPorosity = 0.0, this.aggregateStability = 0.5, this.oxygenContent = 8.5, this.co2Content = 0.02, this.methaneContent = 0.0, this.nitrousOxideContent = 0.0, this.thermalConductivity = 1.0, required this.microbialBiomass, required this.epsContent, required this.fungalHyphaeDensity, required this.necromass, required this.organicCarbon, required this.particulateOrganicMatter, required this.mineralAssociatedOrganicMatter, this.isCultivated = false, this.cultivationDisturbance = 0.0, this.labileCarbon = 0.0, this.stableCarbon = 0.0, this.organicNitrogen = 100.0, this.microbialNitrogen = 10.0, this.maomNitrogen = 50.0, required this.nitrogenContent, this.nitrificationRate = 0.0, this.denitrificationRate = 0.0, final  Map<String, double> traceElements = const {}}): _traceElements = traceElements,super._();
  factory _SoilLayer.fromJson(Map<String, dynamic> json) => _$SoilLayerFromJson(json);

@override final  String id;
@override final  double depth;
// m
@override final  double thickness;
// m
// Physical properties
@override final  double kSat;
// Hydraulic conductivity (m/s)
@override final  double porosity;
// (0.0 - 1.0) - also thetaS
@override final  double thetaR;
// Residual water content
@override final  double vgAlpha;
// van Genuchten alpha (1/m)
@override final  double vgN;
// van Genuchten n
@override@JsonKey() final  double vgL;
// Tortuosity parameter
@override final  double bulkDensity;
// (kg/m^3)
@override final  double waterContent;
// (m^3/m^3)
@override@JsonKey() final  double previousWaterContent;
@override@JsonKey() final  double verticalFlux;
// m/s (Net flux within layer)
@override final  double temperature;
// K
@override final  double heatCapacity;
// J/(m^3*K) (volumetric heat capacity Cv)
// Chemical properties
@override final  double ph;
@override final  double ec;
// Electrical conductivity (dS/m)
@override final  double redoxPotential;
// Eh (mV)
@override final  double nitrateContent;
// mg/kg
@override final  double ammoniumContent;
// mg/kg
@override final  double phosphateContent;
// mg/kg (solution pool)
@override@JsonKey() final  double sorbedPhosphate;
// mg/kg (solid pool)
@override@JsonKey() final  double potassiumContent;
// mg/kg (solution pool)
@override@JsonKey() final  double exchangeablePotassium;
// mg/kg
@override@JsonKey() final  double solutionCalcium;
// mg/kg
@override@JsonKey() final  double exchangeableCalcium;
// mg/kg
@override@JsonKey() final  double solutionMagnesium;
// mg/kg
@override@JsonKey() final  double exchangeableMagnesium;
// mg/kg
@override@JsonKey() final  double exchangeableAluminium;
// mg/kg
@override@JsonKey() final  double cec;
// cmol(+)/kg
@override@JsonKey() final  double clayFraction;
// (0.0 - 1.0)
@override@JsonKey() final  double sandFraction;
// (0.0 - 1.0)
@override@JsonKey() final  double siltFraction;
// (0.0 - 1.0)
@override@JsonKey() final  double effectiveMacroPorosity;
// (0.0 - 1.0)
@override@JsonKey() final  double aggregateStability;
// (0.0 - 1.0)
@override@JsonKey() final  double oxygenContent;
// mol/m^3 (approx 21% air at 20C)
@override@JsonKey() final  double co2Content;
// mol/m^3 (approx 400 ppm)
@override@JsonKey() final  double methaneContent;
// mol/m^3
@override@JsonKey() final  double nitrousOxideContent;
// mol/m^3
@override@JsonKey() final  double thermalConductivity;
// W/m*K
// Biological properties
@override final  double microbialBiomass;
// (kg/m^3)
@override final  double epsContent;
// Extracellular Polymeric Substances
@override final  double fungalHyphaeDensity;
@override final  double necromass;
// Stabilized organic matter (MAOM)
// Carbon/Nutrients
@override final  double organicCarbon;
@override final  double particulateOrganicMatter;
// Labile (POM) (kg/m^3)
@override final  double mineralAssociatedOrganicMatter;
// Stable (MAOM) (kg/m^3)
// Cultivation / Tillage
@override@JsonKey() final  bool isCultivated;
@override@JsonKey() final  double cultivationDisturbance;
// 0.0 to 1.0 (1.0 = fully disturbed)
@override@JsonKey() final  double labileCarbon;
// Alias/Specific pool for POM
@override@JsonKey() final  double stableCarbon;
// Alias/Specific pool for MAOM
@override@JsonKey() final  double organicNitrogen;
// mg/kg (POM-N pool)
@override@JsonKey() final  double microbialNitrogen;
// mg/kg (Mic-N pool)
@override@JsonKey() final  double maomNitrogen;
// mg/kg (MAOM-N pool)
@override final  double nitrogenContent;
// === NEW DIAGNOSTIC FLUXES ===
@override@JsonKey() final  double nitrificationRate;
// mg/kg/s
@override@JsonKey() final  double denitrificationRate;
// mg/kg/s
 final  Map<String, double> _traceElements;
// mg/kg/s
@override@JsonKey() Map<String, double> get traceElements {
  if (_traceElements is EqualUnmodifiableMapView) return _traceElements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_traceElements);
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoilLayer&&(identical(other.id, id) || other.id == id)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.thickness, thickness) || other.thickness == thickness)&&(identical(other.kSat, kSat) || other.kSat == kSat)&&(identical(other.porosity, porosity) || other.porosity == porosity)&&(identical(other.thetaR, thetaR) || other.thetaR == thetaR)&&(identical(other.vgAlpha, vgAlpha) || other.vgAlpha == vgAlpha)&&(identical(other.vgN, vgN) || other.vgN == vgN)&&(identical(other.vgL, vgL) || other.vgL == vgL)&&(identical(other.bulkDensity, bulkDensity) || other.bulkDensity == bulkDensity)&&(identical(other.waterContent, waterContent) || other.waterContent == waterContent)&&(identical(other.previousWaterContent, previousWaterContent) || other.previousWaterContent == previousWaterContent)&&(identical(other.verticalFlux, verticalFlux) || other.verticalFlux == verticalFlux)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.heatCapacity, heatCapacity) || other.heatCapacity == heatCapacity)&&(identical(other.ph, ph) || other.ph == ph)&&(identical(other.ec, ec) || other.ec == ec)&&(identical(other.redoxPotential, redoxPotential) || other.redoxPotential == redoxPotential)&&(identical(other.nitrateContent, nitrateContent) || other.nitrateContent == nitrateContent)&&(identical(other.ammoniumContent, ammoniumContent) || other.ammoniumContent == ammoniumContent)&&(identical(other.phosphateContent, phosphateContent) || other.phosphateContent == phosphateContent)&&(identical(other.sorbedPhosphate, sorbedPhosphate) || other.sorbedPhosphate == sorbedPhosphate)&&(identical(other.potassiumContent, potassiumContent) || other.potassiumContent == potassiumContent)&&(identical(other.exchangeablePotassium, exchangeablePotassium) || other.exchangeablePotassium == exchangeablePotassium)&&(identical(other.solutionCalcium, solutionCalcium) || other.solutionCalcium == solutionCalcium)&&(identical(other.exchangeableCalcium, exchangeableCalcium) || other.exchangeableCalcium == exchangeableCalcium)&&(identical(other.solutionMagnesium, solutionMagnesium) || other.solutionMagnesium == solutionMagnesium)&&(identical(other.exchangeableMagnesium, exchangeableMagnesium) || other.exchangeableMagnesium == exchangeableMagnesium)&&(identical(other.exchangeableAluminium, exchangeableAluminium) || other.exchangeableAluminium == exchangeableAluminium)&&(identical(other.cec, cec) || other.cec == cec)&&(identical(other.clayFraction, clayFraction) || other.clayFraction == clayFraction)&&(identical(other.sandFraction, sandFraction) || other.sandFraction == sandFraction)&&(identical(other.siltFraction, siltFraction) || other.siltFraction == siltFraction)&&(identical(other.effectiveMacroPorosity, effectiveMacroPorosity) || other.effectiveMacroPorosity == effectiveMacroPorosity)&&(identical(other.aggregateStability, aggregateStability) || other.aggregateStability == aggregateStability)&&(identical(other.oxygenContent, oxygenContent) || other.oxygenContent == oxygenContent)&&(identical(other.co2Content, co2Content) || other.co2Content == co2Content)&&(identical(other.methaneContent, methaneContent) || other.methaneContent == methaneContent)&&(identical(other.nitrousOxideContent, nitrousOxideContent) || other.nitrousOxideContent == nitrousOxideContent)&&(identical(other.thermalConductivity, thermalConductivity) || other.thermalConductivity == thermalConductivity)&&(identical(other.microbialBiomass, microbialBiomass) || other.microbialBiomass == microbialBiomass)&&(identical(other.epsContent, epsContent) || other.epsContent == epsContent)&&(identical(other.fungalHyphaeDensity, fungalHyphaeDensity) || other.fungalHyphaeDensity == fungalHyphaeDensity)&&(identical(other.necromass, necromass) || other.necromass == necromass)&&(identical(other.organicCarbon, organicCarbon) || other.organicCarbon == organicCarbon)&&(identical(other.particulateOrganicMatter, particulateOrganicMatter) || other.particulateOrganicMatter == particulateOrganicMatter)&&(identical(other.mineralAssociatedOrganicMatter, mineralAssociatedOrganicMatter) || other.mineralAssociatedOrganicMatter == mineralAssociatedOrganicMatter)&&(identical(other.isCultivated, isCultivated) || other.isCultivated == isCultivated)&&(identical(other.cultivationDisturbance, cultivationDisturbance) || other.cultivationDisturbance == cultivationDisturbance)&&(identical(other.labileCarbon, labileCarbon) || other.labileCarbon == labileCarbon)&&(identical(other.stableCarbon, stableCarbon) || other.stableCarbon == stableCarbon)&&(identical(other.organicNitrogen, organicNitrogen) || other.organicNitrogen == organicNitrogen)&&(identical(other.microbialNitrogen, microbialNitrogen) || other.microbialNitrogen == microbialNitrogen)&&(identical(other.maomNitrogen, maomNitrogen) || other.maomNitrogen == maomNitrogen)&&(identical(other.nitrogenContent, nitrogenContent) || other.nitrogenContent == nitrogenContent)&&(identical(other.nitrificationRate, nitrificationRate) || other.nitrificationRate == nitrificationRate)&&(identical(other.denitrificationRate, denitrificationRate) || other.denitrificationRate == denitrificationRate)&&const DeepCollectionEquality().equals(other._traceElements, _traceElements));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,depth,thickness,kSat,porosity,thetaR,vgAlpha,vgN,vgL,bulkDensity,waterContent,previousWaterContent,verticalFlux,temperature,heatCapacity,ph,ec,redoxPotential,nitrateContent,ammoniumContent,phosphateContent,sorbedPhosphate,potassiumContent,exchangeablePotassium,solutionCalcium,exchangeableCalcium,solutionMagnesium,exchangeableMagnesium,exchangeableAluminium,cec,clayFraction,sandFraction,siltFraction,effectiveMacroPorosity,aggregateStability,oxygenContent,co2Content,methaneContent,nitrousOxideContent,thermalConductivity,microbialBiomass,epsContent,fungalHyphaeDensity,necromass,organicCarbon,particulateOrganicMatter,mineralAssociatedOrganicMatter,isCultivated,cultivationDisturbance,labileCarbon,stableCarbon,organicNitrogen,microbialNitrogen,maomNitrogen,nitrogenContent,nitrificationRate,denitrificationRate,const DeepCollectionEquality().hash(_traceElements)]);

@override
String toString() {
  return 'SoilLayer(id: $id, depth: $depth, thickness: $thickness, kSat: $kSat, porosity: $porosity, thetaR: $thetaR, vgAlpha: $vgAlpha, vgN: $vgN, vgL: $vgL, bulkDensity: $bulkDensity, waterContent: $waterContent, previousWaterContent: $previousWaterContent, verticalFlux: $verticalFlux, temperature: $temperature, heatCapacity: $heatCapacity, ph: $ph, ec: $ec, redoxPotential: $redoxPotential, nitrateContent: $nitrateContent, ammoniumContent: $ammoniumContent, phosphateContent: $phosphateContent, sorbedPhosphate: $sorbedPhosphate, potassiumContent: $potassiumContent, exchangeablePotassium: $exchangeablePotassium, solutionCalcium: $solutionCalcium, exchangeableCalcium: $exchangeableCalcium, solutionMagnesium: $solutionMagnesium, exchangeableMagnesium: $exchangeableMagnesium, exchangeableAluminium: $exchangeableAluminium, cec: $cec, clayFraction: $clayFraction, sandFraction: $sandFraction, siltFraction: $siltFraction, effectiveMacroPorosity: $effectiveMacroPorosity, aggregateStability: $aggregateStability, oxygenContent: $oxygenContent, co2Content: $co2Content, methaneContent: $methaneContent, nitrousOxideContent: $nitrousOxideContent, thermalConductivity: $thermalConductivity, microbialBiomass: $microbialBiomass, epsContent: $epsContent, fungalHyphaeDensity: $fungalHyphaeDensity, necromass: $necromass, organicCarbon: $organicCarbon, particulateOrganicMatter: $particulateOrganicMatter, mineralAssociatedOrganicMatter: $mineralAssociatedOrganicMatter, isCultivated: $isCultivated, cultivationDisturbance: $cultivationDisturbance, labileCarbon: $labileCarbon, stableCarbon: $stableCarbon, organicNitrogen: $organicNitrogen, microbialNitrogen: $microbialNitrogen, maomNitrogen: $maomNitrogen, nitrogenContent: $nitrogenContent, nitrificationRate: $nitrificationRate, denitrificationRate: $denitrificationRate, traceElements: $traceElements)';
}


}

/// @nodoc
abstract mixin class _$SoilLayerCopyWith<$Res> implements $SoilLayerCopyWith<$Res> {
  factory _$SoilLayerCopyWith(_SoilLayer value, $Res Function(_SoilLayer) _then) = __$SoilLayerCopyWithImpl;
@override @useResult
$Res call({
 String id, double depth, double thickness, double kSat, double porosity, double thetaR, double vgAlpha, double vgN, double vgL, double bulkDensity, double waterContent, double previousWaterContent, double verticalFlux, double temperature, double heatCapacity, double ph, double ec, double redoxPotential, double nitrateContent, double ammoniumContent, double phosphateContent, double sorbedPhosphate, double potassiumContent, double exchangeablePotassium, double solutionCalcium, double exchangeableCalcium, double solutionMagnesium, double exchangeableMagnesium, double exchangeableAluminium, double cec, double clayFraction, double sandFraction, double siltFraction, double effectiveMacroPorosity, double aggregateStability, double oxygenContent, double co2Content, double methaneContent, double nitrousOxideContent, double thermalConductivity, double microbialBiomass, double epsContent, double fungalHyphaeDensity, double necromass, double organicCarbon, double particulateOrganicMatter, double mineralAssociatedOrganicMatter, bool isCultivated, double cultivationDisturbance, double labileCarbon, double stableCarbon, double organicNitrogen, double microbialNitrogen, double maomNitrogen, double nitrogenContent, double nitrificationRate, double denitrificationRate, Map<String, double> traceElements
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? depth = null,Object? thickness = null,Object? kSat = null,Object? porosity = null,Object? thetaR = null,Object? vgAlpha = null,Object? vgN = null,Object? vgL = null,Object? bulkDensity = null,Object? waterContent = null,Object? previousWaterContent = null,Object? verticalFlux = null,Object? temperature = null,Object? heatCapacity = null,Object? ph = null,Object? ec = null,Object? redoxPotential = null,Object? nitrateContent = null,Object? ammoniumContent = null,Object? phosphateContent = null,Object? sorbedPhosphate = null,Object? potassiumContent = null,Object? exchangeablePotassium = null,Object? solutionCalcium = null,Object? exchangeableCalcium = null,Object? solutionMagnesium = null,Object? exchangeableMagnesium = null,Object? exchangeableAluminium = null,Object? cec = null,Object? clayFraction = null,Object? sandFraction = null,Object? siltFraction = null,Object? effectiveMacroPorosity = null,Object? aggregateStability = null,Object? oxygenContent = null,Object? co2Content = null,Object? methaneContent = null,Object? nitrousOxideContent = null,Object? thermalConductivity = null,Object? microbialBiomass = null,Object? epsContent = null,Object? fungalHyphaeDensity = null,Object? necromass = null,Object? organicCarbon = null,Object? particulateOrganicMatter = null,Object? mineralAssociatedOrganicMatter = null,Object? isCultivated = null,Object? cultivationDisturbance = null,Object? labileCarbon = null,Object? stableCarbon = null,Object? organicNitrogen = null,Object? microbialNitrogen = null,Object? maomNitrogen = null,Object? nitrogenContent = null,Object? nitrificationRate = null,Object? denitrificationRate = null,Object? traceElements = null,}) {
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
as double,nitrificationRate: null == nitrificationRate ? _self.nitrificationRate : nitrificationRate // ignore: cast_nullable_to_non_nullable
as double,denitrificationRate: null == denitrificationRate ? _self.denitrificationRate : denitrificationRate // ignore: cast_nullable_to_non_nullable
as double,traceElements: null == traceElements ? _self._traceElements : traceElements // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

// dart format on
