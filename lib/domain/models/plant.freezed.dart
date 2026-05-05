// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Plant {

 String get id; String get species; double get age;// days
 double get height;// m
 double get lai;// Leaf Area Index
 double get turgorPressure;// MPa
 double get baseX; List<RootNode> get rootSystem; double get nitrogenUptake; double get waterUptake; double get phosphorusUptake; double get calciumUptake; double get magnesiumUptake; double get totalBiomass;// mg
 double get rootBiomass;// mg
// === NEW SPAC FIELDS (Soil-Plant-Atmosphere Continuum) ===
/// Leaf water potential [MPa] - key SPAC variable
/// Represents the water status of leaves, drives stomatal closure
/// Typical range: 0 (fully hydrated) to -2.0 (severely stressed)
/// Reference: Hsiao (1973)
 double get psiLeaf;/// Stomatal conductance [mol H2O m⁻² s⁻¹]
/// Controls gas exchange (CO2 in, H2O out)
/// Typical range: 0.05 (closed) to 0.4 (fully open)
/// Reference: Medlyn et al. (2011)
 double get stomatalConductance;/// Water stress index [0-1], where 0 = no stress, 1 = severe stress
/// Used for UI visualization and growth reduction
 double get waterStressIndex;/// Relative water content [0-1]
/// Useful for visualization of plant wilting
 double get relativeWaterContent;/// Actual transpiration rate [m³ H2O m⁻² leaf s⁻¹]
/// Distinct from potential - limited by soil water availability
 double get actualTranspiration;// === DIAGNOSTIC LIGHT FIELDS ===
 double get absorbedPAR;// W/m²
 double get lightTransmission;
/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlantCopyWith<Plant> get copyWith => _$PlantCopyWithImpl<Plant>(this as Plant, _$identity);

  /// Serializes this Plant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Plant&&(identical(other.id, id) || other.id == id)&&(identical(other.species, species) || other.species == species)&&(identical(other.age, age) || other.age == age)&&(identical(other.height, height) || other.height == height)&&(identical(other.lai, lai) || other.lai == lai)&&(identical(other.turgorPressure, turgorPressure) || other.turgorPressure == turgorPressure)&&(identical(other.baseX, baseX) || other.baseX == baseX)&&const DeepCollectionEquality().equals(other.rootSystem, rootSystem)&&(identical(other.nitrogenUptake, nitrogenUptake) || other.nitrogenUptake == nitrogenUptake)&&(identical(other.waterUptake, waterUptake) || other.waterUptake == waterUptake)&&(identical(other.phosphorusUptake, phosphorusUptake) || other.phosphorusUptake == phosphorusUptake)&&(identical(other.calciumUptake, calciumUptake) || other.calciumUptake == calciumUptake)&&(identical(other.magnesiumUptake, magnesiumUptake) || other.magnesiumUptake == magnesiumUptake)&&(identical(other.totalBiomass, totalBiomass) || other.totalBiomass == totalBiomass)&&(identical(other.rootBiomass, rootBiomass) || other.rootBiomass == rootBiomass)&&(identical(other.psiLeaf, psiLeaf) || other.psiLeaf == psiLeaf)&&(identical(other.stomatalConductance, stomatalConductance) || other.stomatalConductance == stomatalConductance)&&(identical(other.waterStressIndex, waterStressIndex) || other.waterStressIndex == waterStressIndex)&&(identical(other.relativeWaterContent, relativeWaterContent) || other.relativeWaterContent == relativeWaterContent)&&(identical(other.actualTranspiration, actualTranspiration) || other.actualTranspiration == actualTranspiration)&&(identical(other.absorbedPAR, absorbedPAR) || other.absorbedPAR == absorbedPAR)&&(identical(other.lightTransmission, lightTransmission) || other.lightTransmission == lightTransmission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,species,age,height,lai,turgorPressure,baseX,const DeepCollectionEquality().hash(rootSystem),nitrogenUptake,waterUptake,phosphorusUptake,calciumUptake,magnesiumUptake,totalBiomass,rootBiomass,psiLeaf,stomatalConductance,waterStressIndex,relativeWaterContent,actualTranspiration,absorbedPAR,lightTransmission]);

@override
String toString() {
  return 'Plant(id: $id, species: $species, age: $age, height: $height, lai: $lai, turgorPressure: $turgorPressure, baseX: $baseX, rootSystem: $rootSystem, nitrogenUptake: $nitrogenUptake, waterUptake: $waterUptake, phosphorusUptake: $phosphorusUptake, calciumUptake: $calciumUptake, magnesiumUptake: $magnesiumUptake, totalBiomass: $totalBiomass, rootBiomass: $rootBiomass, psiLeaf: $psiLeaf, stomatalConductance: $stomatalConductance, waterStressIndex: $waterStressIndex, relativeWaterContent: $relativeWaterContent, actualTranspiration: $actualTranspiration, absorbedPAR: $absorbedPAR, lightTransmission: $lightTransmission)';
}


}

/// @nodoc
abstract mixin class $PlantCopyWith<$Res>  {
  factory $PlantCopyWith(Plant value, $Res Function(Plant) _then) = _$PlantCopyWithImpl;
@useResult
$Res call({
 String id, String species, double age, double height, double lai, double turgorPressure, double baseX, List<RootNode> rootSystem, double nitrogenUptake, double waterUptake, double phosphorusUptake, double calciumUptake, double magnesiumUptake, double totalBiomass, double rootBiomass, double psiLeaf, double stomatalConductance, double waterStressIndex, double relativeWaterContent, double actualTranspiration, double absorbedPAR, double lightTransmission
});




}
/// @nodoc
class _$PlantCopyWithImpl<$Res>
    implements $PlantCopyWith<$Res> {
  _$PlantCopyWithImpl(this._self, this._then);

  final Plant _self;
  final $Res Function(Plant) _then;

/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? species = null,Object? age = null,Object? height = null,Object? lai = null,Object? turgorPressure = null,Object? baseX = null,Object? rootSystem = null,Object? nitrogenUptake = null,Object? waterUptake = null,Object? phosphorusUptake = null,Object? calciumUptake = null,Object? magnesiumUptake = null,Object? totalBiomass = null,Object? rootBiomass = null,Object? psiLeaf = null,Object? stomatalConductance = null,Object? waterStressIndex = null,Object? relativeWaterContent = null,Object? actualTranspiration = null,Object? absorbedPAR = null,Object? lightTransmission = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,lai: null == lai ? _self.lai : lai // ignore: cast_nullable_to_non_nullable
as double,turgorPressure: null == turgorPressure ? _self.turgorPressure : turgorPressure // ignore: cast_nullable_to_non_nullable
as double,baseX: null == baseX ? _self.baseX : baseX // ignore: cast_nullable_to_non_nullable
as double,rootSystem: null == rootSystem ? _self.rootSystem : rootSystem // ignore: cast_nullable_to_non_nullable
as List<RootNode>,nitrogenUptake: null == nitrogenUptake ? _self.nitrogenUptake : nitrogenUptake // ignore: cast_nullable_to_non_nullable
as double,waterUptake: null == waterUptake ? _self.waterUptake : waterUptake // ignore: cast_nullable_to_non_nullable
as double,phosphorusUptake: null == phosphorusUptake ? _self.phosphorusUptake : phosphorusUptake // ignore: cast_nullable_to_non_nullable
as double,calciumUptake: null == calciumUptake ? _self.calciumUptake : calciumUptake // ignore: cast_nullable_to_non_nullable
as double,magnesiumUptake: null == magnesiumUptake ? _self.magnesiumUptake : magnesiumUptake // ignore: cast_nullable_to_non_nullable
as double,totalBiomass: null == totalBiomass ? _self.totalBiomass : totalBiomass // ignore: cast_nullable_to_non_nullable
as double,rootBiomass: null == rootBiomass ? _self.rootBiomass : rootBiomass // ignore: cast_nullable_to_non_nullable
as double,psiLeaf: null == psiLeaf ? _self.psiLeaf : psiLeaf // ignore: cast_nullable_to_non_nullable
as double,stomatalConductance: null == stomatalConductance ? _self.stomatalConductance : stomatalConductance // ignore: cast_nullable_to_non_nullable
as double,waterStressIndex: null == waterStressIndex ? _self.waterStressIndex : waterStressIndex // ignore: cast_nullable_to_non_nullable
as double,relativeWaterContent: null == relativeWaterContent ? _self.relativeWaterContent : relativeWaterContent // ignore: cast_nullable_to_non_nullable
as double,actualTranspiration: null == actualTranspiration ? _self.actualTranspiration : actualTranspiration // ignore: cast_nullable_to_non_nullable
as double,absorbedPAR: null == absorbedPAR ? _self.absorbedPAR : absorbedPAR // ignore: cast_nullable_to_non_nullable
as double,lightTransmission: null == lightTransmission ? _self.lightTransmission : lightTransmission // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Plant].
extension PlantPatterns on Plant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Plant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Plant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Plant value)  $default,){
final _that = this;
switch (_that) {
case _Plant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Plant value)?  $default,){
final _that = this;
switch (_that) {
case _Plant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String species,  double age,  double height,  double lai,  double turgorPressure,  double baseX,  List<RootNode> rootSystem,  double nitrogenUptake,  double waterUptake,  double phosphorusUptake,  double calciumUptake,  double magnesiumUptake,  double totalBiomass,  double rootBiomass,  double psiLeaf,  double stomatalConductance,  double waterStressIndex,  double relativeWaterContent,  double actualTranspiration,  double absorbedPAR,  double lightTransmission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Plant() when $default != null:
return $default(_that.id,_that.species,_that.age,_that.height,_that.lai,_that.turgorPressure,_that.baseX,_that.rootSystem,_that.nitrogenUptake,_that.waterUptake,_that.phosphorusUptake,_that.calciumUptake,_that.magnesiumUptake,_that.totalBiomass,_that.rootBiomass,_that.psiLeaf,_that.stomatalConductance,_that.waterStressIndex,_that.relativeWaterContent,_that.actualTranspiration,_that.absorbedPAR,_that.lightTransmission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String species,  double age,  double height,  double lai,  double turgorPressure,  double baseX,  List<RootNode> rootSystem,  double nitrogenUptake,  double waterUptake,  double phosphorusUptake,  double calciumUptake,  double magnesiumUptake,  double totalBiomass,  double rootBiomass,  double psiLeaf,  double stomatalConductance,  double waterStressIndex,  double relativeWaterContent,  double actualTranspiration,  double absorbedPAR,  double lightTransmission)  $default,) {final _that = this;
switch (_that) {
case _Plant():
return $default(_that.id,_that.species,_that.age,_that.height,_that.lai,_that.turgorPressure,_that.baseX,_that.rootSystem,_that.nitrogenUptake,_that.waterUptake,_that.phosphorusUptake,_that.calciumUptake,_that.magnesiumUptake,_that.totalBiomass,_that.rootBiomass,_that.psiLeaf,_that.stomatalConductance,_that.waterStressIndex,_that.relativeWaterContent,_that.actualTranspiration,_that.absorbedPAR,_that.lightTransmission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String species,  double age,  double height,  double lai,  double turgorPressure,  double baseX,  List<RootNode> rootSystem,  double nitrogenUptake,  double waterUptake,  double phosphorusUptake,  double calciumUptake,  double magnesiumUptake,  double totalBiomass,  double rootBiomass,  double psiLeaf,  double stomatalConductance,  double waterStressIndex,  double relativeWaterContent,  double actualTranspiration,  double absorbedPAR,  double lightTransmission)?  $default,) {final _that = this;
switch (_that) {
case _Plant() when $default != null:
return $default(_that.id,_that.species,_that.age,_that.height,_that.lai,_that.turgorPressure,_that.baseX,_that.rootSystem,_that.nitrogenUptake,_that.waterUptake,_that.phosphorusUptake,_that.calciumUptake,_that.magnesiumUptake,_that.totalBiomass,_that.rootBiomass,_that.psiLeaf,_that.stomatalConductance,_that.waterStressIndex,_that.relativeWaterContent,_that.actualTranspiration,_that.absorbedPAR,_that.lightTransmission);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Plant implements Plant {
  const _Plant({required this.id, required this.species, required this.age, required this.height, required this.lai, required this.turgorPressure, this.baseX = 0.5, required final  List<RootNode> rootSystem, required this.nitrogenUptake, required this.waterUptake, this.phosphorusUptake = 0.0, this.calciumUptake = 0.0, this.magnesiumUptake = 0.0, this.totalBiomass = 100.0, this.rootBiomass = 50.0, this.psiLeaf = -0.3, this.stomatalConductance = 0.3, this.waterStressIndex = 0.0, this.relativeWaterContent = 0.9, this.actualTranspiration = 0.0, this.absorbedPAR = 0.0, this.lightTransmission = 1.0}): _rootSystem = rootSystem;
  factory _Plant.fromJson(Map<String, dynamic> json) => _$PlantFromJson(json);

@override final  String id;
@override final  String species;
@override final  double age;
// days
@override final  double height;
// m
@override final  double lai;
// Leaf Area Index
@override final  double turgorPressure;
// MPa
@override@JsonKey() final  double baseX;
 final  List<RootNode> _rootSystem;
@override List<RootNode> get rootSystem {
  if (_rootSystem is EqualUnmodifiableListView) return _rootSystem;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rootSystem);
}

@override final  double nitrogenUptake;
@override final  double waterUptake;
@override@JsonKey() final  double phosphorusUptake;
@override@JsonKey() final  double calciumUptake;
@override@JsonKey() final  double magnesiumUptake;
@override@JsonKey() final  double totalBiomass;
// mg
@override@JsonKey() final  double rootBiomass;
// mg
// === NEW SPAC FIELDS (Soil-Plant-Atmosphere Continuum) ===
/// Leaf water potential [MPa] - key SPAC variable
/// Represents the water status of leaves, drives stomatal closure
/// Typical range: 0 (fully hydrated) to -2.0 (severely stressed)
/// Reference: Hsiao (1973)
@override@JsonKey() final  double psiLeaf;
/// Stomatal conductance [mol H2O m⁻² s⁻¹]
/// Controls gas exchange (CO2 in, H2O out)
/// Typical range: 0.05 (closed) to 0.4 (fully open)
/// Reference: Medlyn et al. (2011)
@override@JsonKey() final  double stomatalConductance;
/// Water stress index [0-1], where 0 = no stress, 1 = severe stress
/// Used for UI visualization and growth reduction
@override@JsonKey() final  double waterStressIndex;
/// Relative water content [0-1]
/// Useful for visualization of plant wilting
@override@JsonKey() final  double relativeWaterContent;
/// Actual transpiration rate [m³ H2O m⁻² leaf s⁻¹]
/// Distinct from potential - limited by soil water availability
@override@JsonKey() final  double actualTranspiration;
// === DIAGNOSTIC LIGHT FIELDS ===
@override@JsonKey() final  double absorbedPAR;
// W/m²
@override@JsonKey() final  double lightTransmission;

/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlantCopyWith<_Plant> get copyWith => __$PlantCopyWithImpl<_Plant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Plant&&(identical(other.id, id) || other.id == id)&&(identical(other.species, species) || other.species == species)&&(identical(other.age, age) || other.age == age)&&(identical(other.height, height) || other.height == height)&&(identical(other.lai, lai) || other.lai == lai)&&(identical(other.turgorPressure, turgorPressure) || other.turgorPressure == turgorPressure)&&(identical(other.baseX, baseX) || other.baseX == baseX)&&const DeepCollectionEquality().equals(other._rootSystem, _rootSystem)&&(identical(other.nitrogenUptake, nitrogenUptake) || other.nitrogenUptake == nitrogenUptake)&&(identical(other.waterUptake, waterUptake) || other.waterUptake == waterUptake)&&(identical(other.phosphorusUptake, phosphorusUptake) || other.phosphorusUptake == phosphorusUptake)&&(identical(other.calciumUptake, calciumUptake) || other.calciumUptake == calciumUptake)&&(identical(other.magnesiumUptake, magnesiumUptake) || other.magnesiumUptake == magnesiumUptake)&&(identical(other.totalBiomass, totalBiomass) || other.totalBiomass == totalBiomass)&&(identical(other.rootBiomass, rootBiomass) || other.rootBiomass == rootBiomass)&&(identical(other.psiLeaf, psiLeaf) || other.psiLeaf == psiLeaf)&&(identical(other.stomatalConductance, stomatalConductance) || other.stomatalConductance == stomatalConductance)&&(identical(other.waterStressIndex, waterStressIndex) || other.waterStressIndex == waterStressIndex)&&(identical(other.relativeWaterContent, relativeWaterContent) || other.relativeWaterContent == relativeWaterContent)&&(identical(other.actualTranspiration, actualTranspiration) || other.actualTranspiration == actualTranspiration)&&(identical(other.absorbedPAR, absorbedPAR) || other.absorbedPAR == absorbedPAR)&&(identical(other.lightTransmission, lightTransmission) || other.lightTransmission == lightTransmission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,species,age,height,lai,turgorPressure,baseX,const DeepCollectionEquality().hash(_rootSystem),nitrogenUptake,waterUptake,phosphorusUptake,calciumUptake,magnesiumUptake,totalBiomass,rootBiomass,psiLeaf,stomatalConductance,waterStressIndex,relativeWaterContent,actualTranspiration,absorbedPAR,lightTransmission]);

@override
String toString() {
  return 'Plant(id: $id, species: $species, age: $age, height: $height, lai: $lai, turgorPressure: $turgorPressure, baseX: $baseX, rootSystem: $rootSystem, nitrogenUptake: $nitrogenUptake, waterUptake: $waterUptake, phosphorusUptake: $phosphorusUptake, calciumUptake: $calciumUptake, magnesiumUptake: $magnesiumUptake, totalBiomass: $totalBiomass, rootBiomass: $rootBiomass, psiLeaf: $psiLeaf, stomatalConductance: $stomatalConductance, waterStressIndex: $waterStressIndex, relativeWaterContent: $relativeWaterContent, actualTranspiration: $actualTranspiration, absorbedPAR: $absorbedPAR, lightTransmission: $lightTransmission)';
}


}

/// @nodoc
abstract mixin class _$PlantCopyWith<$Res> implements $PlantCopyWith<$Res> {
  factory _$PlantCopyWith(_Plant value, $Res Function(_Plant) _then) = __$PlantCopyWithImpl;
@override @useResult
$Res call({
 String id, String species, double age, double height, double lai, double turgorPressure, double baseX, List<RootNode> rootSystem, double nitrogenUptake, double waterUptake, double phosphorusUptake, double calciumUptake, double magnesiumUptake, double totalBiomass, double rootBiomass, double psiLeaf, double stomatalConductance, double waterStressIndex, double relativeWaterContent, double actualTranspiration, double absorbedPAR, double lightTransmission
});




}
/// @nodoc
class __$PlantCopyWithImpl<$Res>
    implements _$PlantCopyWith<$Res> {
  __$PlantCopyWithImpl(this._self, this._then);

  final _Plant _self;
  final $Res Function(_Plant) _then;

/// Create a copy of Plant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? species = null,Object? age = null,Object? height = null,Object? lai = null,Object? turgorPressure = null,Object? baseX = null,Object? rootSystem = null,Object? nitrogenUptake = null,Object? waterUptake = null,Object? phosphorusUptake = null,Object? calciumUptake = null,Object? magnesiumUptake = null,Object? totalBiomass = null,Object? rootBiomass = null,Object? psiLeaf = null,Object? stomatalConductance = null,Object? waterStressIndex = null,Object? relativeWaterContent = null,Object? actualTranspiration = null,Object? absorbedPAR = null,Object? lightTransmission = null,}) {
  return _then(_Plant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as double,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as double,lai: null == lai ? _self.lai : lai // ignore: cast_nullable_to_non_nullable
as double,turgorPressure: null == turgorPressure ? _self.turgorPressure : turgorPressure // ignore: cast_nullable_to_non_nullable
as double,baseX: null == baseX ? _self.baseX : baseX // ignore: cast_nullable_to_non_nullable
as double,rootSystem: null == rootSystem ? _self._rootSystem : rootSystem // ignore: cast_nullable_to_non_nullable
as List<RootNode>,nitrogenUptake: null == nitrogenUptake ? _self.nitrogenUptake : nitrogenUptake // ignore: cast_nullable_to_non_nullable
as double,waterUptake: null == waterUptake ? _self.waterUptake : waterUptake // ignore: cast_nullable_to_non_nullable
as double,phosphorusUptake: null == phosphorusUptake ? _self.phosphorusUptake : phosphorusUptake // ignore: cast_nullable_to_non_nullable
as double,calciumUptake: null == calciumUptake ? _self.calciumUptake : calciumUptake // ignore: cast_nullable_to_non_nullable
as double,magnesiumUptake: null == magnesiumUptake ? _self.magnesiumUptake : magnesiumUptake // ignore: cast_nullable_to_non_nullable
as double,totalBiomass: null == totalBiomass ? _self.totalBiomass : totalBiomass // ignore: cast_nullable_to_non_nullable
as double,rootBiomass: null == rootBiomass ? _self.rootBiomass : rootBiomass // ignore: cast_nullable_to_non_nullable
as double,psiLeaf: null == psiLeaf ? _self.psiLeaf : psiLeaf // ignore: cast_nullable_to_non_nullable
as double,stomatalConductance: null == stomatalConductance ? _self.stomatalConductance : stomatalConductance // ignore: cast_nullable_to_non_nullable
as double,waterStressIndex: null == waterStressIndex ? _self.waterStressIndex : waterStressIndex // ignore: cast_nullable_to_non_nullable
as double,relativeWaterContent: null == relativeWaterContent ? _self.relativeWaterContent : relativeWaterContent // ignore: cast_nullable_to_non_nullable
as double,actualTranspiration: null == actualTranspiration ? _self.actualTranspiration : actualTranspiration // ignore: cast_nullable_to_non_nullable
as double,absorbedPAR: null == absorbedPAR ? _self.absorbedPAR : absorbedPAR // ignore: cast_nullable_to_non_nullable
as double,lightTransmission: null == lightTransmission ? _self.lightTransmission : lightTransmission // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$RootNode {

 double get x; double get z;// depth
 double get radius; bool get isTip; int? get parentIndex;// Index in the rootSystem list
 int get branchLevel;// 0 = taproot, 1 = lateral, etc.
 int get branchSegmentCount;
/// Create a copy of RootNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RootNodeCopyWith<RootNode> get copyWith => _$RootNodeCopyWithImpl<RootNode>(this as RootNode, _$identity);

  /// Serializes this RootNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RootNode&&(identical(other.x, x) || other.x == x)&&(identical(other.z, z) || other.z == z)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.isTip, isTip) || other.isTip == isTip)&&(identical(other.parentIndex, parentIndex) || other.parentIndex == parentIndex)&&(identical(other.branchLevel, branchLevel) || other.branchLevel == branchLevel)&&(identical(other.branchSegmentCount, branchSegmentCount) || other.branchSegmentCount == branchSegmentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,z,radius,isTip,parentIndex,branchLevel,branchSegmentCount);

@override
String toString() {
  return 'RootNode(x: $x, z: $z, radius: $radius, isTip: $isTip, parentIndex: $parentIndex, branchLevel: $branchLevel, branchSegmentCount: $branchSegmentCount)';
}


}

/// @nodoc
abstract mixin class $RootNodeCopyWith<$Res>  {
  factory $RootNodeCopyWith(RootNode value, $Res Function(RootNode) _then) = _$RootNodeCopyWithImpl;
@useResult
$Res call({
 double x, double z, double radius, bool isTip, int? parentIndex, int branchLevel, int branchSegmentCount
});




}
/// @nodoc
class _$RootNodeCopyWithImpl<$Res>
    implements $RootNodeCopyWith<$Res> {
  _$RootNodeCopyWithImpl(this._self, this._then);

  final RootNode _self;
  final $Res Function(RootNode) _then;

/// Create a copy of RootNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? x = null,Object? z = null,Object? radius = null,Object? isTip = null,Object? parentIndex = freezed,Object? branchLevel = null,Object? branchSegmentCount = null,}) {
  return _then(_self.copyWith(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,z: null == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as double,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,isTip: null == isTip ? _self.isTip : isTip // ignore: cast_nullable_to_non_nullable
as bool,parentIndex: freezed == parentIndex ? _self.parentIndex : parentIndex // ignore: cast_nullable_to_non_nullable
as int?,branchLevel: null == branchLevel ? _self.branchLevel : branchLevel // ignore: cast_nullable_to_non_nullable
as int,branchSegmentCount: null == branchSegmentCount ? _self.branchSegmentCount : branchSegmentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RootNode].
extension RootNodePatterns on RootNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RootNode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RootNode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RootNode value)  $default,){
final _that = this;
switch (_that) {
case _RootNode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RootNode value)?  $default,){
final _that = this;
switch (_that) {
case _RootNode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double x,  double z,  double radius,  bool isTip,  int? parentIndex,  int branchLevel,  int branchSegmentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RootNode() when $default != null:
return $default(_that.x,_that.z,_that.radius,_that.isTip,_that.parentIndex,_that.branchLevel,_that.branchSegmentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double x,  double z,  double radius,  bool isTip,  int? parentIndex,  int branchLevel,  int branchSegmentCount)  $default,) {final _that = this;
switch (_that) {
case _RootNode():
return $default(_that.x,_that.z,_that.radius,_that.isTip,_that.parentIndex,_that.branchLevel,_that.branchSegmentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double x,  double z,  double radius,  bool isTip,  int? parentIndex,  int branchLevel,  int branchSegmentCount)?  $default,) {final _that = this;
switch (_that) {
case _RootNode() when $default != null:
return $default(_that.x,_that.z,_that.radius,_that.isTip,_that.parentIndex,_that.branchLevel,_that.branchSegmentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RootNode implements RootNode {
  const _RootNode({required this.x, required this.z, required this.radius, required this.isTip, this.parentIndex, this.branchLevel = 0, this.branchSegmentCount = 0});
  factory _RootNode.fromJson(Map<String, dynamic> json) => _$RootNodeFromJson(json);

@override final  double x;
@override final  double z;
// depth
@override final  double radius;
@override final  bool isTip;
@override final  int? parentIndex;
// Index in the rootSystem list
@override@JsonKey() final  int branchLevel;
// 0 = taproot, 1 = lateral, etc.
@override@JsonKey() final  int branchSegmentCount;

/// Create a copy of RootNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RootNodeCopyWith<_RootNode> get copyWith => __$RootNodeCopyWithImpl<_RootNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RootNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RootNode&&(identical(other.x, x) || other.x == x)&&(identical(other.z, z) || other.z == z)&&(identical(other.radius, radius) || other.radius == radius)&&(identical(other.isTip, isTip) || other.isTip == isTip)&&(identical(other.parentIndex, parentIndex) || other.parentIndex == parentIndex)&&(identical(other.branchLevel, branchLevel) || other.branchLevel == branchLevel)&&(identical(other.branchSegmentCount, branchSegmentCount) || other.branchSegmentCount == branchSegmentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,x,z,radius,isTip,parentIndex,branchLevel,branchSegmentCount);

@override
String toString() {
  return 'RootNode(x: $x, z: $z, radius: $radius, isTip: $isTip, parentIndex: $parentIndex, branchLevel: $branchLevel, branchSegmentCount: $branchSegmentCount)';
}


}

/// @nodoc
abstract mixin class _$RootNodeCopyWith<$Res> implements $RootNodeCopyWith<$Res> {
  factory _$RootNodeCopyWith(_RootNode value, $Res Function(_RootNode) _then) = __$RootNodeCopyWithImpl;
@override @useResult
$Res call({
 double x, double z, double radius, bool isTip, int? parentIndex, int branchLevel, int branchSegmentCount
});




}
/// @nodoc
class __$RootNodeCopyWithImpl<$Res>
    implements _$RootNodeCopyWith<$Res> {
  __$RootNodeCopyWithImpl(this._self, this._then);

  final _RootNode _self;
  final $Res Function(_RootNode) _then;

/// Create a copy of RootNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? x = null,Object? z = null,Object? radius = null,Object? isTip = null,Object? parentIndex = freezed,Object? branchLevel = null,Object? branchSegmentCount = null,}) {
  return _then(_RootNode(
x: null == x ? _self.x : x // ignore: cast_nullable_to_non_nullable
as double,z: null == z ? _self.z : z // ignore: cast_nullable_to_non_nullable
as double,radius: null == radius ? _self.radius : radius // ignore: cast_nullable_to_non_nullable
as double,isTip: null == isTip ? _self.isTip : isTip // ignore: cast_nullable_to_non_nullable
as bool,parentIndex: freezed == parentIndex ? _self.parentIndex : parentIndex // ignore: cast_nullable_to_non_nullable
as int?,branchLevel: null == branchLevel ? _self.branchLevel : branchLevel // ignore: cast_nullable_to_non_nullable
as int,branchSegmentCount: null == branchSegmentCount ? _self.branchSegmentCount : branchSegmentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
