// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grammar_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GrammarSessionState {

 GrammarUnit? get unit; List<GrammarExercise> get exercises; int get currentIndex; String? get selectedAnswer; Map<String, String> get userAnswers; Map<String, bool> get results; bool get isSubmitted; bool? get isCurrentCorrect; List<GrammarExercise> get ghostChallengeQueue; bool get isGhostChallenge; bool get isFinished; DateTime? get startTime; DateTime? get questionStartTime;
/// Create a copy of GrammarSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrammarSessionStateCopyWith<GrammarSessionState> get copyWith => _$GrammarSessionStateCopyWithImpl<GrammarSessionState>(this as GrammarSessionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as GrammarSessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrammarSessionState&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&const DeepCollectionEquality().equals(other.exercises, _this.exercises)&&(identical(other.currentIndex, _this.currentIndex) || other.currentIndex == _this.currentIndex)&&(identical(other.selectedAnswer, _this.selectedAnswer) || other.selectedAnswer == _this.selectedAnswer)&&const DeepCollectionEquality().equals(other.userAnswers, _this.userAnswers)&&const DeepCollectionEquality().equals(other.results, _this.results)&&(identical(other.isSubmitted, _this.isSubmitted) || other.isSubmitted == _this.isSubmitted)&&(identical(other.isCurrentCorrect, _this.isCurrentCorrect) || other.isCurrentCorrect == _this.isCurrentCorrect)&&const DeepCollectionEquality().equals(other.ghostChallengeQueue, _this.ghostChallengeQueue)&&(identical(other.isGhostChallenge, _this.isGhostChallenge) || other.isGhostChallenge == _this.isGhostChallenge)&&(identical(other.isFinished, _this.isFinished) || other.isFinished == _this.isFinished)&&(identical(other.startTime, _this.startTime) || other.startTime == _this.startTime)&&(identical(other.questionStartTime, _this.questionStartTime) || other.questionStartTime == _this.questionStartTime));
}


@override
int get hashCode {
  final _this = this as GrammarSessionState;
  return Object.hash(runtimeType,_this.unit,const DeepCollectionEquality().hash(_this.exercises),_this.currentIndex,_this.selectedAnswer,const DeepCollectionEquality().hash(_this.userAnswers),const DeepCollectionEquality().hash(_this.results),_this.isSubmitted,_this.isCurrentCorrect,const DeepCollectionEquality().hash(_this.ghostChallengeQueue),_this.isGhostChallenge,_this.isFinished,_this.startTime,_this.questionStartTime);
}

@override
String toString() {
  final _this = this as GrammarSessionState;
  return 'GrammarSessionState(unit: ${_this.unit}, exercises: ${_this.exercises}, currentIndex: ${_this.currentIndex}, selectedAnswer: ${_this.selectedAnswer}, userAnswers: ${_this.userAnswers}, results: ${_this.results}, isSubmitted: ${_this.isSubmitted}, isCurrentCorrect: ${_this.isCurrentCorrect}, ghostChallengeQueue: ${_this.ghostChallengeQueue}, isGhostChallenge: ${_this.isGhostChallenge}, isFinished: ${_this.isFinished}, startTime: ${_this.startTime}, questionStartTime: ${_this.questionStartTime})';
}


}

/// @nodoc
abstract mixin class $GrammarSessionStateCopyWith<$Res>  {
  factory $GrammarSessionStateCopyWith(GrammarSessionState value, $Res Function(GrammarSessionState) _then) = _$GrammarSessionStateCopyWithImpl;
@useResult
$Res call({
 GrammarUnit? unit, List<GrammarExercise> exercises, int currentIndex, String? selectedAnswer, Map<String, String> userAnswers, Map<String, bool> results, bool isSubmitted, bool? isCurrentCorrect, List<GrammarExercise> ghostChallengeQueue, bool isGhostChallenge, bool isFinished, DateTime? startTime, DateTime? questionStartTime
});




}
/// @nodoc
class _$GrammarSessionStateCopyWithImpl<$Res>
    implements $GrammarSessionStateCopyWith<$Res> {
  _$GrammarSessionStateCopyWithImpl(this._self, this._then);

  final GrammarSessionState _self;
  final $Res Function(GrammarSessionState) _then;

/// Create a copy of GrammarSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unit = freezed,Object? exercises = null,Object? currentIndex = null,Object? selectedAnswer = freezed,Object? userAnswers = null,Object? results = null,Object? isSubmitted = null,Object? isCurrentCorrect = freezed,Object? ghostChallengeQueue = null,Object? isGhostChallenge = null,Object? isFinished = null,Object? startTime = freezed,Object? questionStartTime = freezed,}) {
  return _then(GrammarSessionState(
unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as GrammarUnit?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<GrammarExercise>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,selectedAnswer: freezed == selectedAnswer ? _self.selectedAnswer : selectedAnswer // ignore: cast_nullable_to_non_nullable
as String?,userAnswers: null == userAnswers ? _self.userAnswers : userAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,isSubmitted: null == isSubmitted ? _self.isSubmitted : isSubmitted // ignore: cast_nullable_to_non_nullable
as bool,isCurrentCorrect: freezed == isCurrentCorrect ? _self.isCurrentCorrect : isCurrentCorrect // ignore: cast_nullable_to_non_nullable
as bool?,ghostChallengeQueue: null == ghostChallengeQueue ? _self.ghostChallengeQueue : ghostChallengeQueue // ignore: cast_nullable_to_non_nullable
as List<GrammarExercise>,isGhostChallenge: null == isGhostChallenge ? _self.isGhostChallenge : isGhostChallenge // ignore: cast_nullable_to_non_nullable
as bool,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,questionStartTime: freezed == questionStartTime ? _self.questionStartTime : questionStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [GrammarSessionState].
extension GrammarSessionStatePatterns on GrammarSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrammarSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrammarSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrammarSessionState value)  $default,){
final _that = this;
switch (_that) {
case _GrammarSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrammarSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _GrammarSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GrammarUnit? unit,  List<GrammarExercise> exercises,  int currentIndex,  String? selectedAnswer,  Map<String, String> userAnswers,  Map<String, bool> results,  bool isSubmitted,  bool? isCurrentCorrect,  List<GrammarExercise> ghostChallengeQueue,  bool isGhostChallenge,  bool isFinished,  DateTime? startTime,  DateTime? questionStartTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrammarSessionState() when $default != null:
return $default(_that.unit,_that.exercises,_that.currentIndex,_that.selectedAnswer,_that.userAnswers,_that.results,_that.isSubmitted,_that.isCurrentCorrect,_that.ghostChallengeQueue,_that.isGhostChallenge,_that.isFinished,_that.startTime,_that.questionStartTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GrammarUnit? unit,  List<GrammarExercise> exercises,  int currentIndex,  String? selectedAnswer,  Map<String, String> userAnswers,  Map<String, bool> results,  bool isSubmitted,  bool? isCurrentCorrect,  List<GrammarExercise> ghostChallengeQueue,  bool isGhostChallenge,  bool isFinished,  DateTime? startTime,  DateTime? questionStartTime)  $default,) {final _that = this;
switch (_that) {
case _GrammarSessionState():
return $default(_that.unit,_that.exercises,_that.currentIndex,_that.selectedAnswer,_that.userAnswers,_that.results,_that.isSubmitted,_that.isCurrentCorrect,_that.ghostChallengeQueue,_that.isGhostChallenge,_that.isFinished,_that.startTime,_that.questionStartTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GrammarUnit? unit,  List<GrammarExercise> exercises,  int currentIndex,  String? selectedAnswer,  Map<String, String> userAnswers,  Map<String, bool> results,  bool isSubmitted,  bool? isCurrentCorrect,  List<GrammarExercise> ghostChallengeQueue,  bool isGhostChallenge,  bool isFinished,  DateTime? startTime,  DateTime? questionStartTime)?  $default,) {final _that = this;
switch (_that) {
case _GrammarSessionState() when $default != null:
return $default(_that.unit,_that.exercises,_that.currentIndex,_that.selectedAnswer,_that.userAnswers,_that.results,_that.isSubmitted,_that.isCurrentCorrect,_that.ghostChallengeQueue,_that.isGhostChallenge,_that.isFinished,_that.startTime,_that.questionStartTime);case _:
  return null;

}
}

}

/// @nodoc


class _GrammarSessionState extends GrammarSessionState {
  const _GrammarSessionState({this.unit,  List<GrammarExercise> exercises = const [], this.currentIndex = 0, this.selectedAnswer,  Map<String, String> userAnswers = const {},  Map<String, bool> results = const {}, this.isSubmitted = false, this.isCurrentCorrect,  List<GrammarExercise> ghostChallengeQueue = const [], this.isGhostChallenge = false, this.isFinished = false, this.startTime, this.questionStartTime}): _exercises = exercises,_userAnswers = userAnswers,_results = results,_ghostChallengeQueue = ghostChallengeQueue,super._();
  

@override final  GrammarUnit? unit;
 final  List<GrammarExercise> _exercises;
@override@JsonKey() List<GrammarExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

@override@JsonKey() final  int currentIndex;
@override final  String? selectedAnswer;
 final  Map<String, String> _userAnswers;
@override@JsonKey() Map<String, String> get userAnswers {
  if (_userAnswers is EqualUnmodifiableMapView) return _userAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userAnswers);
}

 final  Map<String, bool> _results;
@override@JsonKey() Map<String, bool> get results {
  if (_results is EqualUnmodifiableMapView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_results);
}

@override@JsonKey() final  bool isSubmitted;
@override final  bool? isCurrentCorrect;
 final  List<GrammarExercise> _ghostChallengeQueue;
@override@JsonKey() List<GrammarExercise> get ghostChallengeQueue {
  if (_ghostChallengeQueue is EqualUnmodifiableListView) return _ghostChallengeQueue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ghostChallengeQueue);
}

@override@JsonKey() final  bool isGhostChallenge;
@override@JsonKey() final  bool isFinished;
@override final  DateTime? startTime;
@override final  DateTime? questionStartTime;

/// Create a copy of GrammarSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrammarSessionStateCopyWith<_GrammarSessionState> get copyWith => __$GrammarSessionStateCopyWithImpl<_GrammarSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrammarSessionState&&(identical(other.unit, unit) || other.unit == unit)&&const DeepCollectionEquality().equals(other.exercises, _exercises)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&(identical(other.selectedAnswer, selectedAnswer) || other.selectedAnswer == selectedAnswer)&&const DeepCollectionEquality().equals(other.userAnswers, _userAnswers)&&const DeepCollectionEquality().equals(other.results, _results)&&(identical(other.isSubmitted, isSubmitted) || other.isSubmitted == isSubmitted)&&(identical(other.isCurrentCorrect, isCurrentCorrect) || other.isCurrentCorrect == isCurrentCorrect)&&const DeepCollectionEquality().equals(other.ghostChallengeQueue, _ghostChallengeQueue)&&(identical(other.isGhostChallenge, isGhostChallenge) || other.isGhostChallenge == isGhostChallenge)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.questionStartTime, questionStartTime) || other.questionStartTime == questionStartTime));
}


@override
int get hashCode {
    return Object.hash(runtimeType,unit,const DeepCollectionEquality().hash(_exercises),currentIndex,selectedAnswer,const DeepCollectionEquality().hash(_userAnswers),const DeepCollectionEquality().hash(_results),isSubmitted,isCurrentCorrect,const DeepCollectionEquality().hash(_ghostChallengeQueue),isGhostChallenge,isFinished,startTime,questionStartTime);
}

@override
String toString() {
    return 'GrammarSessionState(unit: $unit, exercises: $exercises, currentIndex: $currentIndex, selectedAnswer: $selectedAnswer, userAnswers: $userAnswers, results: $results, isSubmitted: $isSubmitted, isCurrentCorrect: $isCurrentCorrect, ghostChallengeQueue: $ghostChallengeQueue, isGhostChallenge: $isGhostChallenge, isFinished: $isFinished, startTime: $startTime, questionStartTime: $questionStartTime)';
}


}

/// @nodoc
abstract mixin class _$GrammarSessionStateCopyWith<$Res> implements $GrammarSessionStateCopyWith<$Res> {
  factory _$GrammarSessionStateCopyWith(_GrammarSessionState value, $Res Function(_GrammarSessionState) _then) = __$GrammarSessionStateCopyWithImpl;
@override @useResult
$Res call({
 GrammarUnit? unit, List<GrammarExercise> exercises, int currentIndex, String? selectedAnswer, Map<String, String> userAnswers, Map<String, bool> results, bool isSubmitted, bool? isCurrentCorrect, List<GrammarExercise> ghostChallengeQueue, bool isGhostChallenge, bool isFinished, DateTime? startTime, DateTime? questionStartTime
});




}
/// @nodoc
class __$GrammarSessionStateCopyWithImpl<$Res>
    implements _$GrammarSessionStateCopyWith<$Res> {
  __$GrammarSessionStateCopyWithImpl(this._self, this._then);

  final _GrammarSessionState _self;
  final $Res Function(_GrammarSessionState) _then;

/// Create a copy of GrammarSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unit = freezed,Object? exercises = null,Object? currentIndex = null,Object? selectedAnswer = freezed,Object? userAnswers = null,Object? results = null,Object? isSubmitted = null,Object? isCurrentCorrect = freezed,Object? ghostChallengeQueue = null,Object? isGhostChallenge = null,Object? isFinished = null,Object? startTime = freezed,Object? questionStartTime = freezed,}) {
  return _then(_GrammarSessionState(
unit: freezed == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as GrammarUnit?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<GrammarExercise>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,selectedAnswer: freezed == selectedAnswer ? _self.selectedAnswer : selectedAnswer // ignore: cast_nullable_to_non_nullable
as String?,userAnswers: null == userAnswers ? _self._userAnswers : userAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,isSubmitted: null == isSubmitted ? _self.isSubmitted : isSubmitted // ignore: cast_nullable_to_non_nullable
as bool,isCurrentCorrect: freezed == isCurrentCorrect ? _self.isCurrentCorrect : isCurrentCorrect // ignore: cast_nullable_to_non_nullable
as bool?,ghostChallengeQueue: null == ghostChallengeQueue ? _self._ghostChallengeQueue : ghostChallengeQueue // ignore: cast_nullable_to_non_nullable
as List<GrammarExercise>,isGhostChallenge: null == isGhostChallenge ? _self.isGhostChallenge : isGhostChallenge // ignore: cast_nullable_to_non_nullable
as bool,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,questionStartTime: freezed == questionStartTime ? _self.questionStartTime : questionStartTime // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
