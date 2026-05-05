// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'soil_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SoilProfile {

 String get id; String get name; List<SoilLayer> get layers; double get surfaceAlbedo; double get slope;
/// Create a copy of SoilProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoilProfileCopyWith<SoilProfile> get copyWith => _$SoilProfileCopyWithImpl<SoilProfile>(this as SoilProfile, _$identity);

  /// Serializes this SoilProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoilProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.layers, layers)&&(identical(other.surfaceAlbedo, surfaceAlbedo) || other.surfaceAlbedo == surfaceAlbedo)&&(identical(other.slope, slope) || other.slope == slope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(layers),surfaceAlbedo,slope);

@override
String toString() {
  return 'SoilProfile(id: $id, name: $name, layers: $layers, surfaceAlbedo: $surfaceAlbedo, slope: $slope)';
}


}

/// @nodoc
abstract mixin class $SoilProfileCopyWith<$Res>  {
  factory $SoilProfileCopyWith(SoilProfile value, $Res Function(SoilProfile) _then) = _$SoilProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, List<SoilLayer> layers, double surfaceAlbedo, double slope
});




}
/// @nodoc
class _$SoilProfileCopyWithImpl<$Res>
    implements $SoilProfileCopyWith<$Res> {
  _$SoilProfileCopyWithImpl(this._self, this._then);

  final SoilProfile _self;
  final $Res Function(SoilProfile) _then;

/// Create a copy of SoilProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? layers = null,Object? surfaceAlbedo = null,Object? slope = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layers: null == layers ? _self.layers : layers // ignore: cast_nullable_to_non_nullable
as List<SoilLayer>,surfaceAlbedo: null == surfaceAlbedo ? _self.surfaceAlbedo : surfaceAlbedo // ignore: cast_nullable_to_non_nullable
as double,slope: null == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [SoilProfile].
extension SoilProfilePatterns on SoilProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SoilProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SoilProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SoilProfile value)  $default,){
final _that = this;
switch (_that) {
case _SoilProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SoilProfile value)?  $default,){
final _that = this;
switch (_that) {
case _SoilProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  List<SoilLayer> layers,  double surfaceAlbedo,  double slope)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SoilProfile() when $default != null:
return $default(_that.id,_that.name,_that.layers,_that.surfaceAlbedo,_that.slope);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  List<SoilLayer> layers,  double surfaceAlbedo,  double slope)  $default,) {final _that = this;
switch (_that) {
case _SoilProfile():
return $default(_that.id,_that.name,_that.layers,_that.surfaceAlbedo,_that.slope);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  List<SoilLayer> layers,  double surfaceAlbedo,  double slope)?  $default,) {final _that = this;
switch (_that) {
case _SoilProfile() when $default != null:
return $default(_that.id,_that.name,_that.layers,_that.surfaceAlbedo,_that.slope);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SoilProfile implements SoilProfile {
  const _SoilProfile({required this.id, required this.name, required final  List<SoilLayer> layers, required this.surfaceAlbedo, required this.slope}): _layers = layers;
  factory _SoilProfile.fromJson(Map<String, dynamic> json) => _$SoilProfileFromJson(json);

@override final  String id;
@override final  String name;
 final  List<SoilLayer> _layers;
@override List<SoilLayer> get layers {
  if (_layers is EqualUnmodifiableListView) return _layers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_layers);
}

@override final  double surfaceAlbedo;
@override final  double slope;

/// Create a copy of SoilProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoilProfileCopyWith<_SoilProfile> get copyWith => __$SoilProfileCopyWithImpl<_SoilProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoilProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SoilProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other._layers, _layers)&&(identical(other.surfaceAlbedo, surfaceAlbedo) || other.surfaceAlbedo == surfaceAlbedo)&&(identical(other.slope, slope) || other.slope == slope));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,const DeepCollectionEquality().hash(_layers),surfaceAlbedo,slope);

@override
String toString() {
  return 'SoilProfile(id: $id, name: $name, layers: $layers, surfaceAlbedo: $surfaceAlbedo, slope: $slope)';
}


}

/// @nodoc
abstract mixin class _$SoilProfileCopyWith<$Res> implements $SoilProfileCopyWith<$Res> {
  factory _$SoilProfileCopyWith(_SoilProfile value, $Res Function(_SoilProfile) _then) = __$SoilProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, List<SoilLayer> layers, double surfaceAlbedo, double slope
});




}
/// @nodoc
class __$SoilProfileCopyWithImpl<$Res>
    implements _$SoilProfileCopyWith<$Res> {
  __$SoilProfileCopyWithImpl(this._self, this._then);

  final _SoilProfile _self;
  final $Res Function(_SoilProfile) _then;

/// Create a copy of SoilProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? layers = null,Object? surfaceAlbedo = null,Object? slope = null,}) {
  return _then(_SoilProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,layers: null == layers ? _self._layers : layers // ignore: cast_nullable_to_non_nullable
as List<SoilLayer>,surfaceAlbedo: null == surfaceAlbedo ? _self.surfaceAlbedo : surfaceAlbedo // ignore: cast_nullable_to_non_nullable
as double,slope: null == slope ? _self.slope : slope // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
