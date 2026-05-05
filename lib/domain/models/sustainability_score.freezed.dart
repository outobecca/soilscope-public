// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sustainability_score.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SustainabilityScore {

 double get yieldScore; double get carbonScore; double get biodiversityScore; double get environmentalImpact; double get totalSoilHealth; List<String> get metObjectiveIds;
/// Create a copy of SustainabilityScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SustainabilityScoreCopyWith<SustainabilityScore> get copyWith => _$SustainabilityScoreCopyWithImpl<SustainabilityScore>(this as SustainabilityScore, _$identity);

  /// Serializes this SustainabilityScore to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SustainabilityScore&&(identical(other.yieldScore, yieldScore) || other.yieldScore == yieldScore)&&(identical(other.carbonScore, carbonScore) || other.carbonScore == carbonScore)&&(identical(other.biodiversityScore, biodiversityScore) || other.biodiversityScore == biodiversityScore)&&(identical(other.environmentalImpact, environmentalImpact) || other.environmentalImpact == environmentalImpact)&&(identical(other.totalSoilHealth, totalSoilHealth) || other.totalSoilHealth == totalSoilHealth)&&const DeepCollectionEquality().equals(other.metObjectiveIds, metObjectiveIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,yieldScore,carbonScore,biodiversityScore,environmentalImpact,totalSoilHealth,const DeepCollectionEquality().hash(metObjectiveIds));

@override
String toString() {
  return 'SustainabilityScore(yieldScore: $yieldScore, carbonScore: $carbonScore, biodiversityScore: $biodiversityScore, environmentalImpact: $environmentalImpact, totalSoilHealth: $totalSoilHealth, metObjectiveIds: $metObjectiveIds)';
}


}

/// @nodoc
abstract mixin class $SustainabilityScoreCopyWith<$Res>  {
  factory $SustainabilityScoreCopyWith(SustainabilityScore value, $Res Function(SustainabilityScore) _then) = _$SustainabilityScoreCopyWithImpl;
@useResult
$Res call({
 double yieldScore, double carbonScore, double biodiversityScore, double environmentalImpact, double totalSoilHealth, List<String> metObjectiveIds
});




}
/// @nodoc
class _$SustainabilityScoreCopyWithImpl<$Res>
    implements $SustainabilityScoreCopyWith<$Res> {
  _$SustainabilityScoreCopyWithImpl(this._self, this._then);

  final SustainabilityScore _self;
  final $Res Function(SustainabilityScore) _then;

/// Create a copy of SustainabilityScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? yieldScore = null,Object? carbonScore = null,Object? biodiversityScore = null,Object? environmentalImpact = null,Object? totalSoilHealth = null,Object? metObjectiveIds = null,}) {
  return _then(_self.copyWith(
yieldScore: null == yieldScore ? _self.yieldScore : yieldScore // ignore: cast_nullable_to_non_nullable
as double,carbonScore: null == carbonScore ? _self.carbonScore : carbonScore // ignore: cast_nullable_to_non_nullable
as double,biodiversityScore: null == biodiversityScore ? _self.biodiversityScore : biodiversityScore // ignore: cast_nullable_to_non_nullable
as double,environmentalImpact: null == environmentalImpact ? _self.environmentalImpact : environmentalImpact // ignore: cast_nullable_to_non_nullable
as double,totalSoilHealth: null == totalSoilHealth ? _self.totalSoilHealth : totalSoilHealth // ignore: cast_nullable_to_non_nullable
as double,metObjectiveIds: null == metObjectiveIds ? _self.metObjectiveIds : metObjectiveIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SustainabilityScore].
extension SustainabilityScorePatterns on SustainabilityScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SustainabilityScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SustainabilityScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SustainabilityScore value)  $default,){
final _that = this;
switch (_that) {
case _SustainabilityScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SustainabilityScore value)?  $default,){
final _that = this;
switch (_that) {
case _SustainabilityScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double yieldScore,  double carbonScore,  double biodiversityScore,  double environmentalImpact,  double totalSoilHealth,  List<String> metObjectiveIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SustainabilityScore() when $default != null:
return $default(_that.yieldScore,_that.carbonScore,_that.biodiversityScore,_that.environmentalImpact,_that.totalSoilHealth,_that.metObjectiveIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double yieldScore,  double carbonScore,  double biodiversityScore,  double environmentalImpact,  double totalSoilHealth,  List<String> metObjectiveIds)  $default,) {final _that = this;
switch (_that) {
case _SustainabilityScore():
return $default(_that.yieldScore,_that.carbonScore,_that.biodiversityScore,_that.environmentalImpact,_that.totalSoilHealth,_that.metObjectiveIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double yieldScore,  double carbonScore,  double biodiversityScore,  double environmentalImpact,  double totalSoilHealth,  List<String> metObjectiveIds)?  $default,) {final _that = this;
switch (_that) {
case _SustainabilityScore() when $default != null:
return $default(_that.yieldScore,_that.carbonScore,_that.biodiversityScore,_that.environmentalImpact,_that.totalSoilHealth,_that.metObjectiveIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SustainabilityScore implements SustainabilityScore {
  const _SustainabilityScore({this.yieldScore = 0.0, this.carbonScore = 0.0, this.biodiversityScore = 0.0, this.environmentalImpact = 0.0, this.totalSoilHealth = 0.0, final  List<String> metObjectiveIds = const []}): _metObjectiveIds = metObjectiveIds;
  factory _SustainabilityScore.fromJson(Map<String, dynamic> json) => _$SustainabilityScoreFromJson(json);

@override@JsonKey() final  double yieldScore;
@override@JsonKey() final  double carbonScore;
@override@JsonKey() final  double biodiversityScore;
@override@JsonKey() final  double environmentalImpact;
@override@JsonKey() final  double totalSoilHealth;
 final  List<String> _metObjectiveIds;
@override@JsonKey() List<String> get metObjectiveIds {
  if (_metObjectiveIds is EqualUnmodifiableListView) return _metObjectiveIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_metObjectiveIds);
}


/// Create a copy of SustainabilityScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SustainabilityScoreCopyWith<_SustainabilityScore> get copyWith => __$SustainabilityScoreCopyWithImpl<_SustainabilityScore>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SustainabilityScoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SustainabilityScore&&(identical(other.yieldScore, yieldScore) || other.yieldScore == yieldScore)&&(identical(other.carbonScore, carbonScore) || other.carbonScore == carbonScore)&&(identical(other.biodiversityScore, biodiversityScore) || other.biodiversityScore == biodiversityScore)&&(identical(other.environmentalImpact, environmentalImpact) || other.environmentalImpact == environmentalImpact)&&(identical(other.totalSoilHealth, totalSoilHealth) || other.totalSoilHealth == totalSoilHealth)&&const DeepCollectionEquality().equals(other._metObjectiveIds, _metObjectiveIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,yieldScore,carbonScore,biodiversityScore,environmentalImpact,totalSoilHealth,const DeepCollectionEquality().hash(_metObjectiveIds));

@override
String toString() {
  return 'SustainabilityScore(yieldScore: $yieldScore, carbonScore: $carbonScore, biodiversityScore: $biodiversityScore, environmentalImpact: $environmentalImpact, totalSoilHealth: $totalSoilHealth, metObjectiveIds: $metObjectiveIds)';
}


}

/// @nodoc
abstract mixin class _$SustainabilityScoreCopyWith<$Res> implements $SustainabilityScoreCopyWith<$Res> {
  factory _$SustainabilityScoreCopyWith(_SustainabilityScore value, $Res Function(_SustainabilityScore) _then) = __$SustainabilityScoreCopyWithImpl;
@override @useResult
$Res call({
 double yieldScore, double carbonScore, double biodiversityScore, double environmentalImpact, double totalSoilHealth, List<String> metObjectiveIds
});




}
/// @nodoc
class __$SustainabilityScoreCopyWithImpl<$Res>
    implements _$SustainabilityScoreCopyWith<$Res> {
  __$SustainabilityScoreCopyWithImpl(this._self, this._then);

  final _SustainabilityScore _self;
  final $Res Function(_SustainabilityScore) _then;

/// Create a copy of SustainabilityScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? yieldScore = null,Object? carbonScore = null,Object? biodiversityScore = null,Object? environmentalImpact = null,Object? totalSoilHealth = null,Object? metObjectiveIds = null,}) {
  return _then(_SustainabilityScore(
yieldScore: null == yieldScore ? _self.yieldScore : yieldScore // ignore: cast_nullable_to_non_nullable
as double,carbonScore: null == carbonScore ? _self.carbonScore : carbonScore // ignore: cast_nullable_to_non_nullable
as double,biodiversityScore: null == biodiversityScore ? _self.biodiversityScore : biodiversityScore // ignore: cast_nullable_to_non_nullable
as double,environmentalImpact: null == environmentalImpact ? _self.environmentalImpact : environmentalImpact // ignore: cast_nullable_to_non_nullable
as double,totalSoilHealth: null == totalSoilHealth ? _self.totalSoilHealth : totalSoilHealth // ignore: cast_nullable_to_non_nullable
as double,metObjectiveIds: null == metObjectiveIds ? _self._metObjectiveIds : metObjectiveIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
