// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scenario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MissionObjective {

 String get id; String get title; double get targetValue; String get type;// 'yield', 'carbon', 'structure', 'pollution'
 bool get isMet;
/// Create a copy of MissionObjective
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionObjectiveCopyWith<MissionObjective> get copyWith => _$MissionObjectiveCopyWithImpl<MissionObjective>(this as MissionObjective, _$identity);

  /// Serializes this MissionObjective to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionObjective&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.type, type) || other.type == type)&&(identical(other.isMet, isMet) || other.isMet == isMet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetValue,type,isMet);

@override
String toString() {
  return 'MissionObjective(id: $id, title: $title, targetValue: $targetValue, type: $type, isMet: $isMet)';
}


}

/// @nodoc
abstract mixin class $MissionObjectiveCopyWith<$Res>  {
  factory $MissionObjectiveCopyWith(MissionObjective value, $Res Function(MissionObjective) _then) = _$MissionObjectiveCopyWithImpl;
@useResult
$Res call({
 String id, String title, double targetValue, String type, bool isMet
});




}
/// @nodoc
class _$MissionObjectiveCopyWithImpl<$Res>
    implements $MissionObjectiveCopyWith<$Res> {
  _$MissionObjectiveCopyWithImpl(this._self, this._then);

  final MissionObjective _self;
  final $Res Function(MissionObjective) _then;

/// Create a copy of MissionObjective
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? targetValue = null,Object? type = null,Object? isMet = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isMet: null == isMet ? _self.isMet : isMet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MissionObjective].
extension MissionObjectivePatterns on MissionObjective {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionObjective value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionObjective() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionObjective value)  $default,){
final _that = this;
switch (_that) {
case _MissionObjective():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionObjective value)?  $default,){
final _that = this;
switch (_that) {
case _MissionObjective() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double targetValue,  String type,  bool isMet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionObjective() when $default != null:
return $default(_that.id,_that.title,_that.targetValue,_that.type,_that.isMet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double targetValue,  String type,  bool isMet)  $default,) {final _that = this;
switch (_that) {
case _MissionObjective():
return $default(_that.id,_that.title,_that.targetValue,_that.type,_that.isMet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double targetValue,  String type,  bool isMet)?  $default,) {final _that = this;
switch (_that) {
case _MissionObjective() when $default != null:
return $default(_that.id,_that.title,_that.targetValue,_that.type,_that.isMet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MissionObjective implements MissionObjective {
  const _MissionObjective({required this.id, required this.title, required this.targetValue, required this.type, this.isMet = false});
  factory _MissionObjective.fromJson(Map<String, dynamic> json) => _$MissionObjectiveFromJson(json);

@override final  String id;
@override final  String title;
@override final  double targetValue;
@override final  String type;
// 'yield', 'carbon', 'structure', 'pollution'
@override@JsonKey() final  bool isMet;

/// Create a copy of MissionObjective
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionObjectiveCopyWith<_MissionObjective> get copyWith => __$MissionObjectiveCopyWithImpl<_MissionObjective>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MissionObjectiveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionObjective&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.type, type) || other.type == type)&&(identical(other.isMet, isMet) || other.isMet == isMet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,targetValue,type,isMet);

@override
String toString() {
  return 'MissionObjective(id: $id, title: $title, targetValue: $targetValue, type: $type, isMet: $isMet)';
}


}

/// @nodoc
abstract mixin class _$MissionObjectiveCopyWith<$Res> implements $MissionObjectiveCopyWith<$Res> {
  factory _$MissionObjectiveCopyWith(_MissionObjective value, $Res Function(_MissionObjective) _then) = __$MissionObjectiveCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double targetValue, String type, bool isMet
});




}
/// @nodoc
class __$MissionObjectiveCopyWithImpl<$Res>
    implements _$MissionObjectiveCopyWith<$Res> {
  __$MissionObjectiveCopyWithImpl(this._self, this._then);

  final _MissionObjective _self;
  final $Res Function(_MissionObjective) _then;

/// Create a copy of MissionObjective
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? targetValue = null,Object? type = null,Object? isMet = null,}) {
  return _then(_MissionObjective(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,targetValue: null == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isMet: null == isMet ? _self.isMet : isMet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$ScenarioTutorialStep {

 double get triggerTime;// Seconds or simulated ticks
 String get targetId;// UI or Engine component to highlight
 String get title; String get description;
/// Create a copy of ScenarioTutorialStep
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScenarioTutorialStepCopyWith<ScenarioTutorialStep> get copyWith => _$ScenarioTutorialStepCopyWithImpl<ScenarioTutorialStep>(this as ScenarioTutorialStep, _$identity);

  /// Serializes this ScenarioTutorialStep to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ScenarioTutorialStep&&(identical(other.triggerTime, triggerTime) || other.triggerTime == triggerTime)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,triggerTime,targetId,title,description);

@override
String toString() {
  return 'ScenarioTutorialStep(triggerTime: $triggerTime, targetId: $targetId, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class $ScenarioTutorialStepCopyWith<$Res>  {
  factory $ScenarioTutorialStepCopyWith(ScenarioTutorialStep value, $Res Function(ScenarioTutorialStep) _then) = _$ScenarioTutorialStepCopyWithImpl;
@useResult
$Res call({
 double triggerTime, String targetId, String title, String description
});




}
/// @nodoc
class _$ScenarioTutorialStepCopyWithImpl<$Res>
    implements $ScenarioTutorialStepCopyWith<$Res> {
  _$ScenarioTutorialStepCopyWithImpl(this._self, this._then);

  final ScenarioTutorialStep _self;
  final $Res Function(ScenarioTutorialStep) _then;

/// Create a copy of ScenarioTutorialStep
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? triggerTime = null,Object? targetId = null,Object? title = null,Object? description = null,}) {
  return _then(_self.copyWith(
triggerTime: null == triggerTime ? _self.triggerTime : triggerTime // ignore: cast_nullable_to_non_nullable
as double,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ScenarioTutorialStep].
extension ScenarioTutorialStepPatterns on ScenarioTutorialStep {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ScenarioTutorialStep value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ScenarioTutorialStep() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ScenarioTutorialStep value)  $default,){
final _that = this;
switch (_that) {
case _ScenarioTutorialStep():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ScenarioTutorialStep value)?  $default,){
final _that = this;
switch (_that) {
case _ScenarioTutorialStep() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double triggerTime,  String targetId,  String title,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ScenarioTutorialStep() when $default != null:
return $default(_that.triggerTime,_that.targetId,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double triggerTime,  String targetId,  String title,  String description)  $default,) {final _that = this;
switch (_that) {
case _ScenarioTutorialStep():
return $default(_that.triggerTime,_that.targetId,_that.title,_that.description);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double triggerTime,  String targetId,  String title,  String description)?  $default,) {final _that = this;
switch (_that) {
case _ScenarioTutorialStep() when $default != null:
return $default(_that.triggerTime,_that.targetId,_that.title,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ScenarioTutorialStep implements ScenarioTutorialStep {
  const _ScenarioTutorialStep({required this.triggerTime, required this.targetId, required this.title, required this.description});
  factory _ScenarioTutorialStep.fromJson(Map<String, dynamic> json) => _$ScenarioTutorialStepFromJson(json);

@override final  double triggerTime;
// Seconds or simulated ticks
@override final  String targetId;
// UI or Engine component to highlight
@override final  String title;
@override final  String description;

/// Create a copy of ScenarioTutorialStep
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScenarioTutorialStepCopyWith<_ScenarioTutorialStep> get copyWith => __$ScenarioTutorialStepCopyWithImpl<_ScenarioTutorialStep>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScenarioTutorialStepToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ScenarioTutorialStep&&(identical(other.triggerTime, triggerTime) || other.triggerTime == triggerTime)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,triggerTime,targetId,title,description);

@override
String toString() {
  return 'ScenarioTutorialStep(triggerTime: $triggerTime, targetId: $targetId, title: $title, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ScenarioTutorialStepCopyWith<$Res> implements $ScenarioTutorialStepCopyWith<$Res> {
  factory _$ScenarioTutorialStepCopyWith(_ScenarioTutorialStep value, $Res Function(_ScenarioTutorialStep) _then) = __$ScenarioTutorialStepCopyWithImpl;
@override @useResult
$Res call({
 double triggerTime, String targetId, String title, String description
});




}
/// @nodoc
class __$ScenarioTutorialStepCopyWithImpl<$Res>
    implements _$ScenarioTutorialStepCopyWith<$Res> {
  __$ScenarioTutorialStepCopyWithImpl(this._self, this._then);

  final _ScenarioTutorialStep _self;
  final $Res Function(_ScenarioTutorialStep) _then;

/// Create a copy of ScenarioTutorialStep
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? triggerTime = null,Object? targetId = null,Object? title = null,Object? description = null,}) {
  return _then(_ScenarioTutorialStep(
triggerTime: null == triggerTime ? _self.triggerTime : triggerTime // ignore: cast_nullable_to_non_nullable
as double,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CultivationEvent {

 double get executionTime; String get type;// 'fertilize', 'till', 'water'
 double get amount; String? get layerId; String? get extraData;
/// Create a copy of CultivationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CultivationEventCopyWith<CultivationEvent> get copyWith => _$CultivationEventCopyWithImpl<CultivationEvent>(this as CultivationEvent, _$identity);

  /// Serializes this CultivationEvent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CultivationEvent&&(identical(other.executionTime, executionTime) || other.executionTime == executionTime)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.extraData, extraData) || other.extraData == extraData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,executionTime,type,amount,layerId,extraData);

@override
String toString() {
  return 'CultivationEvent(executionTime: $executionTime, type: $type, amount: $amount, layerId: $layerId, extraData: $extraData)';
}


}

/// @nodoc
abstract mixin class $CultivationEventCopyWith<$Res>  {
  factory $CultivationEventCopyWith(CultivationEvent value, $Res Function(CultivationEvent) _then) = _$CultivationEventCopyWithImpl;
@useResult
$Res call({
 double executionTime, String type, double amount, String? layerId, String? extraData
});




}
/// @nodoc
class _$CultivationEventCopyWithImpl<$Res>
    implements $CultivationEventCopyWith<$Res> {
  _$CultivationEventCopyWithImpl(this._self, this._then);

  final CultivationEvent _self;
  final $Res Function(CultivationEvent) _then;

/// Create a copy of CultivationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? executionTime = null,Object? type = null,Object? amount = null,Object? layerId = freezed,Object? extraData = freezed,}) {
  return _then(_self.copyWith(
executionTime: null == executionTime ? _self.executionTime : executionTime // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,layerId: freezed == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String?,extraData: freezed == extraData ? _self.extraData : extraData // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CultivationEvent].
extension CultivationEventPatterns on CultivationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CultivationEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CultivationEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CultivationEvent value)  $default,){
final _that = this;
switch (_that) {
case _CultivationEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CultivationEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CultivationEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double executionTime,  String type,  double amount,  String? layerId,  String? extraData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CultivationEvent() when $default != null:
return $default(_that.executionTime,_that.type,_that.amount,_that.layerId,_that.extraData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double executionTime,  String type,  double amount,  String? layerId,  String? extraData)  $default,) {final _that = this;
switch (_that) {
case _CultivationEvent():
return $default(_that.executionTime,_that.type,_that.amount,_that.layerId,_that.extraData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double executionTime,  String type,  double amount,  String? layerId,  String? extraData)?  $default,) {final _that = this;
switch (_that) {
case _CultivationEvent() when $default != null:
return $default(_that.executionTime,_that.type,_that.amount,_that.layerId,_that.extraData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CultivationEvent implements CultivationEvent {
  const _CultivationEvent({required this.executionTime, required this.type, this.amount = 0.0, this.layerId, this.extraData});
  factory _CultivationEvent.fromJson(Map<String, dynamic> json) => _$CultivationEventFromJson(json);

@override final  double executionTime;
@override final  String type;
// 'fertilize', 'till', 'water'
@override@JsonKey() final  double amount;
@override final  String? layerId;
@override final  String? extraData;

/// Create a copy of CultivationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CultivationEventCopyWith<_CultivationEvent> get copyWith => __$CultivationEventCopyWithImpl<_CultivationEvent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CultivationEventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CultivationEvent&&(identical(other.executionTime, executionTime) || other.executionTime == executionTime)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.layerId, layerId) || other.layerId == layerId)&&(identical(other.extraData, extraData) || other.extraData == extraData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,executionTime,type,amount,layerId,extraData);

@override
String toString() {
  return 'CultivationEvent(executionTime: $executionTime, type: $type, amount: $amount, layerId: $layerId, extraData: $extraData)';
}


}

/// @nodoc
abstract mixin class _$CultivationEventCopyWith<$Res> implements $CultivationEventCopyWith<$Res> {
  factory _$CultivationEventCopyWith(_CultivationEvent value, $Res Function(_CultivationEvent) _then) = __$CultivationEventCopyWithImpl;
@override @useResult
$Res call({
 double executionTime, String type, double amount, String? layerId, String? extraData
});




}
/// @nodoc
class __$CultivationEventCopyWithImpl<$Res>
    implements _$CultivationEventCopyWith<$Res> {
  __$CultivationEventCopyWithImpl(this._self, this._then);

  final _CultivationEvent _self;
  final $Res Function(_CultivationEvent) _then;

/// Create a copy of CultivationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? executionTime = null,Object? type = null,Object? amount = null,Object? layerId = freezed,Object? extraData = freezed,}) {
  return _then(_CultivationEvent(
executionTime: null == executionTime ? _self.executionTime : executionTime // ignore: cast_nullable_to_non_nullable
as double,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,layerId: freezed == layerId ? _self.layerId : layerId // ignore: cast_nullable_to_non_nullable
as String?,extraData: freezed == extraData ? _self.extraData : extraData // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Scenario {

 String get id; String get title; String get description; SoilProfile get initialProfile; Map<String, dynamic> get weatherData; List<MissionObjective> get objectives; List<String> get features; List<ScenarioTutorialStep> get tutorialSteps; List<CultivationEvent> get cultivationPlan;
/// Create a copy of Scenario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ScenarioCopyWith<Scenario> get copyWith => _$ScenarioCopyWithImpl<Scenario>(this as Scenario, _$identity);

  /// Serializes this Scenario to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Scenario&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.initialProfile, initialProfile) || other.initialProfile == initialProfile)&&const DeepCollectionEquality().equals(other.weatherData, weatherData)&&const DeepCollectionEquality().equals(other.objectives, objectives)&&const DeepCollectionEquality().equals(other.features, features)&&const DeepCollectionEquality().equals(other.tutorialSteps, tutorialSteps)&&const DeepCollectionEquality().equals(other.cultivationPlan, cultivationPlan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,initialProfile,const DeepCollectionEquality().hash(weatherData),const DeepCollectionEquality().hash(objectives),const DeepCollectionEquality().hash(features),const DeepCollectionEquality().hash(tutorialSteps),const DeepCollectionEquality().hash(cultivationPlan));

@override
String toString() {
  return 'Scenario(id: $id, title: $title, description: $description, initialProfile: $initialProfile, weatherData: $weatherData, objectives: $objectives, features: $features, tutorialSteps: $tutorialSteps, cultivationPlan: $cultivationPlan)';
}


}

/// @nodoc
abstract mixin class $ScenarioCopyWith<$Res>  {
  factory $ScenarioCopyWith(Scenario value, $Res Function(Scenario) _then) = _$ScenarioCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, SoilProfile initialProfile, Map<String, dynamic> weatherData, List<MissionObjective> objectives, List<String> features, List<ScenarioTutorialStep> tutorialSteps, List<CultivationEvent> cultivationPlan
});


$SoilProfileCopyWith<$Res> get initialProfile;

}
/// @nodoc
class _$ScenarioCopyWithImpl<$Res>
    implements $ScenarioCopyWith<$Res> {
  _$ScenarioCopyWithImpl(this._self, this._then);

  final Scenario _self;
  final $Res Function(Scenario) _then;

/// Create a copy of Scenario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? initialProfile = null,Object? weatherData = null,Object? objectives = null,Object? features = null,Object? tutorialSteps = null,Object? cultivationPlan = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,initialProfile: null == initialProfile ? _self.initialProfile : initialProfile // ignore: cast_nullable_to_non_nullable
as SoilProfile,weatherData: null == weatherData ? _self.weatherData : weatherData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,objectives: null == objectives ? _self.objectives : objectives // ignore: cast_nullable_to_non_nullable
as List<MissionObjective>,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<String>,tutorialSteps: null == tutorialSteps ? _self.tutorialSteps : tutorialSteps // ignore: cast_nullable_to_non_nullable
as List<ScenarioTutorialStep>,cultivationPlan: null == cultivationPlan ? _self.cultivationPlan : cultivationPlan // ignore: cast_nullable_to_non_nullable
as List<CultivationEvent>,
  ));
}
/// Create a copy of Scenario
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoilProfileCopyWith<$Res> get initialProfile {
  
  return $SoilProfileCopyWith<$Res>(_self.initialProfile, (value) {
    return _then(_self.copyWith(initialProfile: value));
  });
}
}


/// Adds pattern-matching-related methods to [Scenario].
extension ScenarioPatterns on Scenario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Scenario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Scenario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Scenario value)  $default,){
final _that = this;
switch (_that) {
case _Scenario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Scenario value)?  $default,){
final _that = this;
switch (_that) {
case _Scenario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  SoilProfile initialProfile,  Map<String, dynamic> weatherData,  List<MissionObjective> objectives,  List<String> features,  List<ScenarioTutorialStep> tutorialSteps,  List<CultivationEvent> cultivationPlan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Scenario() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.initialProfile,_that.weatherData,_that.objectives,_that.features,_that.tutorialSteps,_that.cultivationPlan);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  SoilProfile initialProfile,  Map<String, dynamic> weatherData,  List<MissionObjective> objectives,  List<String> features,  List<ScenarioTutorialStep> tutorialSteps,  List<CultivationEvent> cultivationPlan)  $default,) {final _that = this;
switch (_that) {
case _Scenario():
return $default(_that.id,_that.title,_that.description,_that.initialProfile,_that.weatherData,_that.objectives,_that.features,_that.tutorialSteps,_that.cultivationPlan);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  SoilProfile initialProfile,  Map<String, dynamic> weatherData,  List<MissionObjective> objectives,  List<String> features,  List<ScenarioTutorialStep> tutorialSteps,  List<CultivationEvent> cultivationPlan)?  $default,) {final _that = this;
switch (_that) {
case _Scenario() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.initialProfile,_that.weatherData,_that.objectives,_that.features,_that.tutorialSteps,_that.cultivationPlan);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Scenario implements Scenario {
  const _Scenario({required this.id, required this.title, required this.description, required this.initialProfile, required final  Map<String, dynamic> weatherData, final  List<MissionObjective> objectives = const [], final  List<String> features = const [], final  List<ScenarioTutorialStep> tutorialSteps = const [], final  List<CultivationEvent> cultivationPlan = const []}): _weatherData = weatherData,_objectives = objectives,_features = features,_tutorialSteps = tutorialSteps,_cultivationPlan = cultivationPlan;
  factory _Scenario.fromJson(Map<String, dynamic> json) => _$ScenarioFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  SoilProfile initialProfile;
 final  Map<String, dynamic> _weatherData;
@override Map<String, dynamic> get weatherData {
  if (_weatherData is EqualUnmodifiableMapView) return _weatherData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_weatherData);
}

 final  List<MissionObjective> _objectives;
@override@JsonKey() List<MissionObjective> get objectives {
  if (_objectives is EqualUnmodifiableListView) return _objectives;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objectives);
}

 final  List<String> _features;
@override@JsonKey() List<String> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

 final  List<ScenarioTutorialStep> _tutorialSteps;
@override@JsonKey() List<ScenarioTutorialStep> get tutorialSteps {
  if (_tutorialSteps is EqualUnmodifiableListView) return _tutorialSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tutorialSteps);
}

 final  List<CultivationEvent> _cultivationPlan;
@override@JsonKey() List<CultivationEvent> get cultivationPlan {
  if (_cultivationPlan is EqualUnmodifiableListView) return _cultivationPlan;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cultivationPlan);
}


/// Create a copy of Scenario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ScenarioCopyWith<_Scenario> get copyWith => __$ScenarioCopyWithImpl<_Scenario>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ScenarioToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Scenario&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.initialProfile, initialProfile) || other.initialProfile == initialProfile)&&const DeepCollectionEquality().equals(other._weatherData, _weatherData)&&const DeepCollectionEquality().equals(other._objectives, _objectives)&&const DeepCollectionEquality().equals(other._features, _features)&&const DeepCollectionEquality().equals(other._tutorialSteps, _tutorialSteps)&&const DeepCollectionEquality().equals(other._cultivationPlan, _cultivationPlan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,initialProfile,const DeepCollectionEquality().hash(_weatherData),const DeepCollectionEquality().hash(_objectives),const DeepCollectionEquality().hash(_features),const DeepCollectionEquality().hash(_tutorialSteps),const DeepCollectionEquality().hash(_cultivationPlan));

@override
String toString() {
  return 'Scenario(id: $id, title: $title, description: $description, initialProfile: $initialProfile, weatherData: $weatherData, objectives: $objectives, features: $features, tutorialSteps: $tutorialSteps, cultivationPlan: $cultivationPlan)';
}


}

/// @nodoc
abstract mixin class _$ScenarioCopyWith<$Res> implements $ScenarioCopyWith<$Res> {
  factory _$ScenarioCopyWith(_Scenario value, $Res Function(_Scenario) _then) = __$ScenarioCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, SoilProfile initialProfile, Map<String, dynamic> weatherData, List<MissionObjective> objectives, List<String> features, List<ScenarioTutorialStep> tutorialSteps, List<CultivationEvent> cultivationPlan
});


@override $SoilProfileCopyWith<$Res> get initialProfile;

}
/// @nodoc
class __$ScenarioCopyWithImpl<$Res>
    implements _$ScenarioCopyWith<$Res> {
  __$ScenarioCopyWithImpl(this._self, this._then);

  final _Scenario _self;
  final $Res Function(_Scenario) _then;

/// Create a copy of Scenario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? initialProfile = null,Object? weatherData = null,Object? objectives = null,Object? features = null,Object? tutorialSteps = null,Object? cultivationPlan = null,}) {
  return _then(_Scenario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,initialProfile: null == initialProfile ? _self.initialProfile : initialProfile // ignore: cast_nullable_to_non_nullable
as SoilProfile,weatherData: null == weatherData ? _self._weatherData : weatherData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,objectives: null == objectives ? _self._objectives : objectives // ignore: cast_nullable_to_non_nullable
as List<MissionObjective>,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<String>,tutorialSteps: null == tutorialSteps ? _self._tutorialSteps : tutorialSteps // ignore: cast_nullable_to_non_nullable
as List<ScenarioTutorialStep>,cultivationPlan: null == cultivationPlan ? _self._cultivationPlan : cultivationPlan // ignore: cast_nullable_to_non_nullable
as List<CultivationEvent>,
  ));
}

/// Create a copy of Scenario
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SoilProfileCopyWith<$Res> get initialProfile {
  
  return $SoilProfileCopyWith<$Res>(_self.initialProfile, (value) {
    return _then(_self.copyWith(initialProfile: value));
  });
}
}

// dart format on
