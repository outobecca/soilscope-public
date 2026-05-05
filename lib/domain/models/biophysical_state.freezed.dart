// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'biophysical_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BiophysicalState {

 SoilProfile get profile; List<Plant> get plants; double get timeElapsed; Scenario? get currentScenario; double get precipitation; double get soilEvaporation; double get airTemperature; double get relativeHumidity; double get atmCO2;// mol/m3 (approx 415 ppm)
 bool get autoWeather; double get timeScale; bool get hasCoverCrop; bool get isRunning;@JsonKey(includeFromJson: false, includeToJson: false) List<BiophysicalState> get history; SustainabilityScore get score; double? get solarRadiationOverride;/// Mycorrhizal symbiosis state tracking colonization and nutrient exchange
@JsonKey(includeFromJson: false, includeToJson: false) MycorrhizaState? get mycorrhizaState;
/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BiophysicalStateCopyWith<BiophysicalState> get copyWith => _$BiophysicalStateCopyWithImpl<BiophysicalState>(this as BiophysicalState, _$identity);

  /// Serializes this BiophysicalState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BiophysicalState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other.plants, plants)&&(identical(other.timeElapsed, timeElapsed) || other.timeElapsed == timeElapsed)&&(identical(other.currentScenario, currentScenario) || other.currentScenario == currentScenario)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.soilEvaporation, soilEvaporation) || other.soilEvaporation == soilEvaporation)&&(identical(other.airTemperature, airTemperature) || other.airTemperature == airTemperature)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity)&&(identical(other.atmCO2, atmCO2) || other.atmCO2 == atmCO2)&&(identical(other.autoWeather, autoWeather) || other.autoWeather == autoWeather)&&(identical(other.timeScale, timeScale) || other.timeScale == timeScale)&&(identical(other.hasCoverCrop, hasCoverCrop) || other.hasCoverCrop == hasCoverCrop)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&const DeepCollectionEquality().equals(other.history, history)&&(identical(other.score, score) || other.score == score)&&(identical(other.solarRadiationOverride, solarRadiationOverride) || other.solarRadiationOverride == solarRadiationOverride)&&(identical(other.mycorrhizaState, mycorrhizaState) || other.mycorrhizaState == mycorrhizaState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(plants),timeElapsed,currentScenario,precipitation,soilEvaporation,airTemperature,relativeHumidity,atmCO2,autoWeather,timeScale,hasCoverCrop,isRunning,const DeepCollectionEquality().hash(history),score,solarRadiationOverride,mycorrhizaState);

@override
String toString() {
  return 'BiophysicalState(profile: $profile, plants: $plants, timeElapsed: $timeElapsed, currentScenario: $currentScenario, precipitation: $precipitation, soilEvaporation: $soilEvaporation, airTemperature: $airTemperature, relativeHumidity: $relativeHumidity, atmCO2: $atmCO2, autoWeather: $autoWeather, timeScale: $timeScale, hasCoverCrop: $hasCoverCrop, isRunning: $isRunning, history: $history, score: $score, solarRadiationOverride: $solarRadiationOverride, mycorrhizaState: $mycorrhizaState)';
}


}

/// @nodoc
abstract mixin class $BiophysicalStateCopyWith<$Res>  {
  factory $BiophysicalStateCopyWith(BiophysicalState value, $Res Function(BiophysicalState) _then) = _$BiophysicalStateCopyWithImpl;
@useResult
$Res call({
 SoilProfile profile, List<Plant> plants, double timeElapsed, Scenario? currentScenario, double precipitation, double soilEvaporation, double airTemperature, double relativeHumidity, double atmCO2, bool autoWeather, double timeScale, bool hasCoverCrop, bool isRunning,@JsonKey(includeFromJson: false, includeToJson: false) List<BiophysicalState> history, SustainabilityScore score, double? solarRadiationOverride,@JsonKey(includeFromJson: false, includeToJson: false) MycorrhizaState? mycorrhizaState
});


$SoilProfileCopyWith<$Res> get profile;$ScenarioCopyWith<$Res>? get currentScenario;$SustainabilityScoreCopyWith<$Res> get score;

}
/// @nodoc
class _$BiophysicalStateCopyWithImpl<$Res>
    implements $BiophysicalStateCopyWith<$Res> {
  _$BiophysicalStateCopyWithImpl(this._self, this._then);

  final BiophysicalState _self;
  final $Res Function(BiophysicalState) _then;

/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? profile = null,Object? plants = null,Object? timeElapsed = null,Object? currentScenario = freezed,Object? precipitation = null,Object? soilEvaporation = null,Object? airTemperature = null,Object? relativeHumidity = null,Object? atmCO2 = null,Object? autoWeather = null,Object? timeScale = null,Object? hasCoverCrop = null,Object? isRunning = null,Object? history = null,Object? score = null,Object? solarRadiationOverride = freezed,Object? mycorrhizaState = freezed,}) {
  return _then(_self.copyWith(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SoilProfile,plants: null == plants ? _self.plants : plants // ignore: cast_nullable_to_non_nullable
as List<Plant>,timeElapsed: null == timeElapsed ? _self.timeElapsed : timeElapsed // ignore: cast_nullable_to_non_nullable
as double,currentScenario: freezed == currentScenario ? _self.currentScenario : currentScenario // ignore: cast_nullable_to_non_nullable
as Scenario?,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,soilEvaporation: null == soilEvaporation ? _self.soilEvaporation : soilEvaporation // ignore: cast_nullable_to_non_nullable
as double,airTemperature: null == airTemperature ? _self.airTemperature : airTemperature // ignore: cast_nullable_to_non_nullable
as double,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as double,atmCO2: null == atmCO2 ? _self.atmCO2 : atmCO2 // ignore: cast_nullable_to_non_nullable
as double,autoWeather: null == autoWeather ? _self.autoWeather : autoWeather // ignore: cast_nullable_to_non_nullable
as bool,timeScale: null == timeScale ? _self.timeScale : timeScale // ignore: cast_nullable_to_non_nullable
as double,hasCoverCrop: null == hasCoverCrop ? _self.hasCoverCrop : hasCoverCrop // ignore: cast_nullable_to_non_nullable
as bool,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<BiophysicalState>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as SustainabilityScore,solarRadiationOverride: freezed == solarRadiationOverride ? _self.solarRadiationOverride : solarRadiationOverride // ignore: cast_nullable_to_non_nullable
as double?,mycorrhizaState: freezed == mycorrhizaState ? _self.mycorrhizaState : mycorrhizaState // ignore: cast_nullable_to_non_nullable
as MycorrhizaState?,
  ));
}
/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoilProfileCopyWith<$Res> get profile {
  
  return $SoilProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioCopyWith<$Res>? get currentScenario {
    if (_self.currentScenario == null) {
    return null;
  }

  return $ScenarioCopyWith<$Res>(_self.currentScenario!, (value) {
    return _then(_self.copyWith(currentScenario: value));
  });
}/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SustainabilityScoreCopyWith<$Res> get score {
  
  return $SustainabilityScoreCopyWith<$Res>(_self.score, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}


/// Adds pattern-matching-related methods to [BiophysicalState].
extension BiophysicalStatePatterns on BiophysicalState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BiophysicalState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BiophysicalState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BiophysicalState value)  $default,){
final _that = this;
switch (_that) {
case _BiophysicalState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BiophysicalState value)?  $default,){
final _that = this;
switch (_that) {
case _BiophysicalState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SoilProfile profile,  List<Plant> plants,  double timeElapsed,  Scenario? currentScenario,  double precipitation,  double soilEvaporation,  double airTemperature,  double relativeHumidity,  double atmCO2,  bool autoWeather,  double timeScale,  bool hasCoverCrop,  bool isRunning, @JsonKey(includeFromJson: false, includeToJson: false)  List<BiophysicalState> history,  SustainabilityScore score,  double? solarRadiationOverride, @JsonKey(includeFromJson: false, includeToJson: false)  MycorrhizaState? mycorrhizaState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BiophysicalState() when $default != null:
return $default(_that.profile,_that.plants,_that.timeElapsed,_that.currentScenario,_that.precipitation,_that.soilEvaporation,_that.airTemperature,_that.relativeHumidity,_that.atmCO2,_that.autoWeather,_that.timeScale,_that.hasCoverCrop,_that.isRunning,_that.history,_that.score,_that.solarRadiationOverride,_that.mycorrhizaState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SoilProfile profile,  List<Plant> plants,  double timeElapsed,  Scenario? currentScenario,  double precipitation,  double soilEvaporation,  double airTemperature,  double relativeHumidity,  double atmCO2,  bool autoWeather,  double timeScale,  bool hasCoverCrop,  bool isRunning, @JsonKey(includeFromJson: false, includeToJson: false)  List<BiophysicalState> history,  SustainabilityScore score,  double? solarRadiationOverride, @JsonKey(includeFromJson: false, includeToJson: false)  MycorrhizaState? mycorrhizaState)  $default,) {final _that = this;
switch (_that) {
case _BiophysicalState():
return $default(_that.profile,_that.plants,_that.timeElapsed,_that.currentScenario,_that.precipitation,_that.soilEvaporation,_that.airTemperature,_that.relativeHumidity,_that.atmCO2,_that.autoWeather,_that.timeScale,_that.hasCoverCrop,_that.isRunning,_that.history,_that.score,_that.solarRadiationOverride,_that.mycorrhizaState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SoilProfile profile,  List<Plant> plants,  double timeElapsed,  Scenario? currentScenario,  double precipitation,  double soilEvaporation,  double airTemperature,  double relativeHumidity,  double atmCO2,  bool autoWeather,  double timeScale,  bool hasCoverCrop,  bool isRunning, @JsonKey(includeFromJson: false, includeToJson: false)  List<BiophysicalState> history,  SustainabilityScore score,  double? solarRadiationOverride, @JsonKey(includeFromJson: false, includeToJson: false)  MycorrhizaState? mycorrhizaState)?  $default,) {final _that = this;
switch (_that) {
case _BiophysicalState() when $default != null:
return $default(_that.profile,_that.plants,_that.timeElapsed,_that.currentScenario,_that.precipitation,_that.soilEvaporation,_that.airTemperature,_that.relativeHumidity,_that.atmCO2,_that.autoWeather,_that.timeScale,_that.hasCoverCrop,_that.isRunning,_that.history,_that.score,_that.solarRadiationOverride,_that.mycorrhizaState);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BiophysicalState extends BiophysicalState {
  const _BiophysicalState({required this.profile, required final  List<Plant> plants, required this.timeElapsed, this.currentScenario, this.precipitation = 0.0, this.soilEvaporation = 0.0, this.airTemperature = 293.15, this.relativeHumidity = 0.5, this.atmCO2 = 0.017, this.autoWeather = false, this.timeScale = 1.0, this.hasCoverCrop = false, this.isRunning = false, @JsonKey(includeFromJson: false, includeToJson: false) final  List<BiophysicalState> history = const [], this.score = const SustainabilityScore(), this.solarRadiationOverride, @JsonKey(includeFromJson: false, includeToJson: false) this.mycorrhizaState}): _plants = plants,_history = history,super._();
  factory _BiophysicalState.fromJson(Map<String, dynamic> json) => _$BiophysicalStateFromJson(json);

@override final  SoilProfile profile;
 final  List<Plant> _plants;
@override List<Plant> get plants {
  if (_plants is EqualUnmodifiableListView) return _plants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_plants);
}

@override final  double timeElapsed;
@override final  Scenario? currentScenario;
@override@JsonKey() final  double precipitation;
@override@JsonKey() final  double soilEvaporation;
@override@JsonKey() final  double airTemperature;
@override@JsonKey() final  double relativeHumidity;
@override@JsonKey() final  double atmCO2;
// mol/m3 (approx 415 ppm)
@override@JsonKey() final  bool autoWeather;
@override@JsonKey() final  double timeScale;
@override@JsonKey() final  bool hasCoverCrop;
@override@JsonKey() final  bool isRunning;
 final  List<BiophysicalState> _history;
@override@JsonKey(includeFromJson: false, includeToJson: false) List<BiophysicalState> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override@JsonKey() final  SustainabilityScore score;
@override final  double? solarRadiationOverride;
/// Mycorrhizal symbiosis state tracking colonization and nutrient exchange
@override@JsonKey(includeFromJson: false, includeToJson: false) final  MycorrhizaState? mycorrhizaState;

/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BiophysicalStateCopyWith<_BiophysicalState> get copyWith => __$BiophysicalStateCopyWithImpl<_BiophysicalState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BiophysicalStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BiophysicalState&&(identical(other.profile, profile) || other.profile == profile)&&const DeepCollectionEquality().equals(other._plants, _plants)&&(identical(other.timeElapsed, timeElapsed) || other.timeElapsed == timeElapsed)&&(identical(other.currentScenario, currentScenario) || other.currentScenario == currentScenario)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.soilEvaporation, soilEvaporation) || other.soilEvaporation == soilEvaporation)&&(identical(other.airTemperature, airTemperature) || other.airTemperature == airTemperature)&&(identical(other.relativeHumidity, relativeHumidity) || other.relativeHumidity == relativeHumidity)&&(identical(other.atmCO2, atmCO2) || other.atmCO2 == atmCO2)&&(identical(other.autoWeather, autoWeather) || other.autoWeather == autoWeather)&&(identical(other.timeScale, timeScale) || other.timeScale == timeScale)&&(identical(other.hasCoverCrop, hasCoverCrop) || other.hasCoverCrop == hasCoverCrop)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&const DeepCollectionEquality().equals(other._history, _history)&&(identical(other.score, score) || other.score == score)&&(identical(other.solarRadiationOverride, solarRadiationOverride) || other.solarRadiationOverride == solarRadiationOverride)&&(identical(other.mycorrhizaState, mycorrhizaState) || other.mycorrhizaState == mycorrhizaState));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,profile,const DeepCollectionEquality().hash(_plants),timeElapsed,currentScenario,precipitation,soilEvaporation,airTemperature,relativeHumidity,atmCO2,autoWeather,timeScale,hasCoverCrop,isRunning,const DeepCollectionEquality().hash(_history),score,solarRadiationOverride,mycorrhizaState);

@override
String toString() {
  return 'BiophysicalState(profile: $profile, plants: $plants, timeElapsed: $timeElapsed, currentScenario: $currentScenario, precipitation: $precipitation, soilEvaporation: $soilEvaporation, airTemperature: $airTemperature, relativeHumidity: $relativeHumidity, atmCO2: $atmCO2, autoWeather: $autoWeather, timeScale: $timeScale, hasCoverCrop: $hasCoverCrop, isRunning: $isRunning, history: $history, score: $score, solarRadiationOverride: $solarRadiationOverride, mycorrhizaState: $mycorrhizaState)';
}


}

/// @nodoc
abstract mixin class _$BiophysicalStateCopyWith<$Res> implements $BiophysicalStateCopyWith<$Res> {
  factory _$BiophysicalStateCopyWith(_BiophysicalState value, $Res Function(_BiophysicalState) _then) = __$BiophysicalStateCopyWithImpl;
@override @useResult
$Res call({
 SoilProfile profile, List<Plant> plants, double timeElapsed, Scenario? currentScenario, double precipitation, double soilEvaporation, double airTemperature, double relativeHumidity, double atmCO2, bool autoWeather, double timeScale, bool hasCoverCrop, bool isRunning,@JsonKey(includeFromJson: false, includeToJson: false) List<BiophysicalState> history, SustainabilityScore score, double? solarRadiationOverride,@JsonKey(includeFromJson: false, includeToJson: false) MycorrhizaState? mycorrhizaState
});


@override $SoilProfileCopyWith<$Res> get profile;@override $ScenarioCopyWith<$Res>? get currentScenario;@override $SustainabilityScoreCopyWith<$Res> get score;

}
/// @nodoc
class __$BiophysicalStateCopyWithImpl<$Res>
    implements _$BiophysicalStateCopyWith<$Res> {
  __$BiophysicalStateCopyWithImpl(this._self, this._then);

  final _BiophysicalState _self;
  final $Res Function(_BiophysicalState) _then;

/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? plants = null,Object? timeElapsed = null,Object? currentScenario = freezed,Object? precipitation = null,Object? soilEvaporation = null,Object? airTemperature = null,Object? relativeHumidity = null,Object? atmCO2 = null,Object? autoWeather = null,Object? timeScale = null,Object? hasCoverCrop = null,Object? isRunning = null,Object? history = null,Object? score = null,Object? solarRadiationOverride = freezed,Object? mycorrhizaState = freezed,}) {
  return _then(_BiophysicalState(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as SoilProfile,plants: null == plants ? _self._plants : plants // ignore: cast_nullable_to_non_nullable
as List<Plant>,timeElapsed: null == timeElapsed ? _self.timeElapsed : timeElapsed // ignore: cast_nullable_to_non_nullable
as double,currentScenario: freezed == currentScenario ? _self.currentScenario : currentScenario // ignore: cast_nullable_to_non_nullable
as Scenario?,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,soilEvaporation: null == soilEvaporation ? _self.soilEvaporation : soilEvaporation // ignore: cast_nullable_to_non_nullable
as double,airTemperature: null == airTemperature ? _self.airTemperature : airTemperature // ignore: cast_nullable_to_non_nullable
as double,relativeHumidity: null == relativeHumidity ? _self.relativeHumidity : relativeHumidity // ignore: cast_nullable_to_non_nullable
as double,atmCO2: null == atmCO2 ? _self.atmCO2 : atmCO2 // ignore: cast_nullable_to_non_nullable
as double,autoWeather: null == autoWeather ? _self.autoWeather : autoWeather // ignore: cast_nullable_to_non_nullable
as bool,timeScale: null == timeScale ? _self.timeScale : timeScale // ignore: cast_nullable_to_non_nullable
as double,hasCoverCrop: null == hasCoverCrop ? _self.hasCoverCrop : hasCoverCrop // ignore: cast_nullable_to_non_nullable
as bool,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<BiophysicalState>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as SustainabilityScore,solarRadiationOverride: freezed == solarRadiationOverride ? _self.solarRadiationOverride : solarRadiationOverride // ignore: cast_nullable_to_non_nullable
as double?,mycorrhizaState: freezed == mycorrhizaState ? _self.mycorrhizaState : mycorrhizaState // ignore: cast_nullable_to_non_nullable
as MycorrhizaState?,
  ));
}

/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoilProfileCopyWith<$Res> get profile {
  
  return $SoilProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ScenarioCopyWith<$Res>? get currentScenario {
    if (_self.currentScenario == null) {
    return null;
  }

  return $ScenarioCopyWith<$Res>(_self.currentScenario!, (value) {
    return _then(_self.copyWith(currentScenario: value));
  });
}/// Create a copy of BiophysicalState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SustainabilityScoreCopyWith<$Res> get score {
  
  return $SustainabilityScoreCopyWith<$Res>(_self.score, (value) {
    return _then(_self.copyWith(score: value));
  });
}
}

// dart format on
