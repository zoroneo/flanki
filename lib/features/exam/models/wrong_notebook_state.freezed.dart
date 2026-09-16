// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wrong_notebook_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WrongNotebookState {

 bool get isLoading; List<WrongQuestionModel> get questions; WrongQuestionStatus? get filterStatus; String? get error;
/// Create a copy of WrongNotebookState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WrongNotebookStateCopyWith<WrongNotebookState> get copyWith => _$WrongNotebookStateCopyWithImpl<WrongNotebookState>(this as WrongNotebookState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WrongNotebookState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WrongNotebookState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.questions, _this.questions)&&(identical(other.filterStatus, _this.filterStatus) || other.filterStatus == _this.filterStatus)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as WrongNotebookState;
  return Object.hash(runtimeType,_this.isLoading,const DeepCollectionEquality().hash(_this.questions),_this.filterStatus,_this.error);
}

@override
String toString() {
  final _this = this as WrongNotebookState;
  return 'WrongNotebookState(isLoading: ${_this.isLoading}, questions: ${_this.questions}, filterStatus: ${_this.filterStatus}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $WrongNotebookStateCopyWith<$Res>  {
  factory $WrongNotebookStateCopyWith(WrongNotebookState value, $Res Function(WrongNotebookState) _then) = _$WrongNotebookStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<WrongQuestionModel> questions, WrongQuestionStatus? filterStatus, String? error
});




}
/// @nodoc
class _$WrongNotebookStateCopyWithImpl<$Res>
    implements $WrongNotebookStateCopyWith<$Res> {
  _$WrongNotebookStateCopyWithImpl(this._self, this._then);

  final WrongNotebookState _self;
  final $Res Function(WrongNotebookState) _then;

/// Create a copy of WrongNotebookState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? questions = null,Object? filterStatus = freezed,Object? error = freezed,}) {
  return _then(WrongNotebookState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<WrongQuestionModel>,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as WrongQuestionStatus?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WrongNotebookState].
extension WrongNotebookStatePatterns on WrongNotebookState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WrongNotebookState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WrongNotebookState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WrongNotebookState value)  $default,){
final _that = this;
switch (_that) {
case _WrongNotebookState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WrongNotebookState value)?  $default,){
final _that = this;
switch (_that) {
case _WrongNotebookState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<WrongQuestionModel> questions,  WrongQuestionStatus? filterStatus,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WrongNotebookState() when $default != null:
return $default(_that.isLoading,_that.questions,_that.filterStatus,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<WrongQuestionModel> questions,  WrongQuestionStatus? filterStatus,  String? error)  $default,) {final _that = this;
switch (_that) {
case _WrongNotebookState():
return $default(_that.isLoading,_that.questions,_that.filterStatus,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<WrongQuestionModel> questions,  WrongQuestionStatus? filterStatus,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _WrongNotebookState() when $default != null:
return $default(_that.isLoading,_that.questions,_that.filterStatus,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _WrongNotebookState extends WrongNotebookState {
  const _WrongNotebookState({this.isLoading = false,  List<WrongQuestionModel> questions = const [], this.filterStatus, this.error}): _questions = questions,super._();
  

@override@JsonKey() final  bool isLoading;
 final  List<WrongQuestionModel> _questions;
@override@JsonKey() List<WrongQuestionModel> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override final  WrongQuestionStatus? filterStatus;
@override final  String? error;

/// Create a copy of WrongNotebookState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WrongNotebookStateCopyWith<_WrongNotebookState> get copyWith => __$WrongNotebookStateCopyWithImpl<_WrongNotebookState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WrongNotebookState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.questions, _questions)&&(identical(other.filterStatus, filterStatus) || other.filterStatus == filterStatus)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_questions),filterStatus,error);
}

@override
String toString() {
    return 'WrongNotebookState(isLoading: $isLoading, questions: $questions, filterStatus: $filterStatus, error: $error)';
}


}

/// @nodoc
abstract mixin class _$WrongNotebookStateCopyWith<$Res> implements $WrongNotebookStateCopyWith<$Res> {
  factory _$WrongNotebookStateCopyWith(_WrongNotebookState value, $Res Function(_WrongNotebookState) _then) = __$WrongNotebookStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<WrongQuestionModel> questions, WrongQuestionStatus? filterStatus, String? error
});




}
/// @nodoc
class __$WrongNotebookStateCopyWithImpl<$Res>
    implements _$WrongNotebookStateCopyWith<$Res> {
  __$WrongNotebookStateCopyWithImpl(this._self, this._then);

  final _WrongNotebookState _self;
  final $Res Function(_WrongNotebookState) _then;

/// Create a copy of WrongNotebookState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? questions = null,Object? filterStatus = freezed,Object? error = freezed,}) {
  return _then(_WrongNotebookState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<WrongQuestionModel>,filterStatus: freezed == filterStatus ? _self.filterStatus : filterStatus // ignore: cast_nullable_to_non_nullable
as WrongQuestionStatus?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
