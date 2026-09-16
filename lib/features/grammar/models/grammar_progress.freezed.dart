// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grammar_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GrammarProgressModel {

 String get unitId; String get exerciseId; double get stability; double get difficulty; DateTime? get due; DateTime? get lastStudied; int get reps; int get lapses; CardState get state; bool get isGhost; bool get isCompleted; String? get lastUserAnswer; DateTime get updatedAt;
/// Create a copy of GrammarProgressModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrammarProgressModelCopyWith<GrammarProgressModel> get copyWith => _$GrammarProgressModelCopyWithImpl<GrammarProgressModel>(this as GrammarProgressModel, _$identity);

  /// Serializes this GrammarProgressModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GrammarProgressModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrammarProgressModel&&(identical(other.unitId, _this.unitId) || other.unitId == _this.unitId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId)&&(identical(other.stability, _this.stability) || other.stability == _this.stability)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&(identical(other.due, _this.due) || other.due == _this.due)&&(identical(other.lastStudied, _this.lastStudied) || other.lastStudied == _this.lastStudied)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.lapses, _this.lapses) || other.lapses == _this.lapses)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.isGhost, _this.isGhost) || other.isGhost == _this.isGhost)&&(identical(other.isCompleted, _this.isCompleted) || other.isCompleted == _this.isCompleted)&&(identical(other.lastUserAnswer, _this.lastUserAnswer) || other.lastUserAnswer == _this.lastUserAnswer)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GrammarProgressModel;
  return Object.hash(runtimeType,_this.unitId,_this.exerciseId,_this.stability,_this.difficulty,_this.due,_this.lastStudied,_this.reps,_this.lapses,_this.state,_this.isGhost,_this.isCompleted,_this.lastUserAnswer,_this.updatedAt);
}

@override
String toString() {
  final _this = this as GrammarProgressModel;
  return 'GrammarProgressModel(unitId: ${_this.unitId}, exerciseId: ${_this.exerciseId}, stability: ${_this.stability}, difficulty: ${_this.difficulty}, due: ${_this.due}, lastStudied: ${_this.lastStudied}, reps: ${_this.reps}, lapses: ${_this.lapses}, state: ${_this.state}, isGhost: ${_this.isGhost}, isCompleted: ${_this.isCompleted}, lastUserAnswer: ${_this.lastUserAnswer}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $GrammarProgressModelCopyWith<$Res>  {
  factory $GrammarProgressModelCopyWith(GrammarProgressModel value, $Res Function(GrammarProgressModel) _then) = _$GrammarProgressModelCopyWithImpl;
@useResult
$Res call({
 String unitId, String exerciseId, double stability, double difficulty, DateTime? due, DateTime? lastStudied, int reps, int lapses, CardState state, bool isGhost, bool isCompleted, String? lastUserAnswer, DateTime updatedAt
});




}
/// @nodoc
class _$GrammarProgressModelCopyWithImpl<$Res>
    implements $GrammarProgressModelCopyWith<$Res> {
  _$GrammarProgressModelCopyWithImpl(this._self, this._then);

  final GrammarProgressModel _self;
  final $Res Function(GrammarProgressModel) _then;

/// Create a copy of GrammarProgressModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unitId = null,Object? exerciseId = null,Object? stability = null,Object? difficulty = null,Object? due = freezed,Object? lastStudied = freezed,Object? reps = null,Object? lapses = null,Object? state = null,Object? isGhost = null,Object? isCompleted = null,Object? lastUserAnswer = freezed,Object? updatedAt = null,}) {
  return _then(GrammarProgressModel(
unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStudied: freezed == lastStudied ? _self.lastStudied : lastStudied // ignore: cast_nullable_to_non_nullable
as DateTime?,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CardState,isGhost: null == isGhost ? _self.isGhost : isGhost // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,lastUserAnswer: freezed == lastUserAnswer ? _self.lastUserAnswer : lastUserAnswer // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [GrammarProgressModel].
extension GrammarProgressModelPatterns on GrammarProgressModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrammarProgressModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrammarProgressModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrammarProgressModel value)  $default,){
final _that = this;
switch (_that) {
case _GrammarProgressModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrammarProgressModel value)?  $default,){
final _that = this;
switch (_that) {
case _GrammarProgressModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String unitId,  String exerciseId,  double stability,  double difficulty,  DateTime? due,  DateTime? lastStudied,  int reps,  int lapses,  CardState state,  bool isGhost,  bool isCompleted,  String? lastUserAnswer,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrammarProgressModel() when $default != null:
return $default(_that.unitId,_that.exerciseId,_that.stability,_that.difficulty,_that.due,_that.lastStudied,_that.reps,_that.lapses,_that.state,_that.isGhost,_that.isCompleted,_that.lastUserAnswer,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String unitId,  String exerciseId,  double stability,  double difficulty,  DateTime? due,  DateTime? lastStudied,  int reps,  int lapses,  CardState state,  bool isGhost,  bool isCompleted,  String? lastUserAnswer,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _GrammarProgressModel():
return $default(_that.unitId,_that.exerciseId,_that.stability,_that.difficulty,_that.due,_that.lastStudied,_that.reps,_that.lapses,_that.state,_that.isGhost,_that.isCompleted,_that.lastUserAnswer,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String unitId,  String exerciseId,  double stability,  double difficulty,  DateTime? due,  DateTime? lastStudied,  int reps,  int lapses,  CardState state,  bool isGhost,  bool isCompleted,  String? lastUserAnswer,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _GrammarProgressModel() when $default != null:
return $default(_that.unitId,_that.exerciseId,_that.stability,_that.difficulty,_that.due,_that.lastStudied,_that.reps,_that.lapses,_that.state,_that.isGhost,_that.isCompleted,_that.lastUserAnswer,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _GrammarProgressModel extends GrammarProgressModel {
  const _GrammarProgressModel({required this.unitId, required this.exerciseId, this.stability = 0.0, this.difficulty = 0.0, this.due, this.lastStudied, this.reps = 0, this.lapses = 0, this.state = CardState.newCard, this.isGhost = false, this.isCompleted = false, this.lastUserAnswer, required this.updatedAt}): super._();
  factory _GrammarProgressModel.fromJson(Map<String, dynamic> json) => _$GrammarProgressModelFromJson(json);

@override final  String unitId;
@override final  String exerciseId;
@override@JsonKey() final  double stability;
@override@JsonKey() final  double difficulty;
@override final  DateTime? due;
@override final  DateTime? lastStudied;
@override@JsonKey() final  int reps;
@override@JsonKey() final  int lapses;
@override@JsonKey() final  CardState state;
@override@JsonKey() final  bool isGhost;
@override@JsonKey() final  bool isCompleted;
@override final  String? lastUserAnswer;
@override final  DateTime updatedAt;

/// Create a copy of GrammarProgressModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrammarProgressModelCopyWith<_GrammarProgressModel> get copyWith => __$GrammarProgressModelCopyWithImpl<_GrammarProgressModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrammarProgressModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrammarProgressModel&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId)&&(identical(other.stability, stability) || other.stability == stability)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.due, due) || other.due == due)&&(identical(other.lastStudied, lastStudied) || other.lastStudied == lastStudied)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.state, state) || other.state == state)&&(identical(other.isGhost, isGhost) || other.isGhost == isGhost)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.lastUserAnswer, lastUserAnswer) || other.lastUserAnswer == lastUserAnswer)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,unitId,exerciseId,stability,difficulty,due,lastStudied,reps,lapses,state,isGhost,isCompleted,lastUserAnswer,updatedAt);
}

@override
String toString() {
    return 'GrammarProgressModel(unitId: $unitId, exerciseId: $exerciseId, stability: $stability, difficulty: $difficulty, due: $due, lastStudied: $lastStudied, reps: $reps, lapses: $lapses, state: $state, isGhost: $isGhost, isCompleted: $isCompleted, lastUserAnswer: $lastUserAnswer, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$GrammarProgressModelCopyWith<$Res> implements $GrammarProgressModelCopyWith<$Res> {
  factory _$GrammarProgressModelCopyWith(_GrammarProgressModel value, $Res Function(_GrammarProgressModel) _then) = __$GrammarProgressModelCopyWithImpl;
@override @useResult
$Res call({
 String unitId, String exerciseId, double stability, double difficulty, DateTime? due, DateTime? lastStudied, int reps, int lapses, CardState state, bool isGhost, bool isCompleted, String? lastUserAnswer, DateTime updatedAt
});




}
/// @nodoc
class __$GrammarProgressModelCopyWithImpl<$Res>
    implements _$GrammarProgressModelCopyWith<$Res> {
  __$GrammarProgressModelCopyWithImpl(this._self, this._then);

  final _GrammarProgressModel _self;
  final $Res Function(_GrammarProgressModel) _then;

/// Create a copy of GrammarProgressModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unitId = null,Object? exerciseId = null,Object? stability = null,Object? difficulty = null,Object? due = freezed,Object? lastStudied = freezed,Object? reps = null,Object? lapses = null,Object? state = null,Object? isGhost = null,Object? isCompleted = null,Object? lastUserAnswer = freezed,Object? updatedAt = null,}) {
  return _then(_GrammarProgressModel(
unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStudied: freezed == lastStudied ? _self.lastStudied : lastStudied // ignore: cast_nullable_to_non_nullable
as DateTime?,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as CardState,isGhost: null == isGhost ? _self.isGhost : isGhost // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,lastUserAnswer: freezed == lastUserAnswer ? _self.lastUserAnswer : lastUserAnswer // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
