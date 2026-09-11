// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateState {

 UpdateStatus get status; UpdateInfo? get updateInfo; double get downloadProgress; String? get downloadedFilePath; String? get errorMessage; UpdateErrorType? get errorType; DateTime? get lastChecked; bool get isBackgroundCheck;
/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateStateCopyWith<UpdateState> get copyWith => _$UpdateStateCopyWithImpl<UpdateState>(this as UpdateState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as UpdateState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.updateInfo, _this.updateInfo) || other.updateInfo == _this.updateInfo)&&(identical(other.downloadProgress, _this.downloadProgress) || other.downloadProgress == _this.downloadProgress)&&(identical(other.downloadedFilePath, _this.downloadedFilePath) || other.downloadedFilePath == _this.downloadedFilePath)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.errorType, _this.errorType) || other.errorType == _this.errorType)&&(identical(other.lastChecked, _this.lastChecked) || other.lastChecked == _this.lastChecked)&&(identical(other.isBackgroundCheck, _this.isBackgroundCheck) || other.isBackgroundCheck == _this.isBackgroundCheck));
}


@override
int get hashCode {
  final _this = this as UpdateState;
  return Object.hash(runtimeType,_this.status,_this.updateInfo,_this.downloadProgress,_this.downloadedFilePath,_this.errorMessage,_this.errorType,_this.lastChecked,_this.isBackgroundCheck);
}

@override
String toString() {
  final _this = this as UpdateState;
  return 'UpdateState(status: ${_this.status}, updateInfo: ${_this.updateInfo}, downloadProgress: ${_this.downloadProgress}, downloadedFilePath: ${_this.downloadedFilePath}, errorMessage: ${_this.errorMessage}, errorType: ${_this.errorType}, lastChecked: ${_this.lastChecked}, isBackgroundCheck: ${_this.isBackgroundCheck})';
}


}

/// @nodoc
abstract mixin class $UpdateStateCopyWith<$Res>  {
  factory $UpdateStateCopyWith(UpdateState value, $Res Function(UpdateState) _then) = _$UpdateStateCopyWithImpl;
@useResult
$Res call({
 UpdateStatus status, UpdateInfo? updateInfo, double downloadProgress, String? downloadedFilePath, String? errorMessage, UpdateErrorType? errorType, DateTime? lastChecked, bool isBackgroundCheck
});




}
/// @nodoc
class _$UpdateStateCopyWithImpl<$Res>
    implements $UpdateStateCopyWith<$Res> {
  _$UpdateStateCopyWithImpl(this._self, this._then);

  final UpdateState _self;
  final $Res Function(UpdateState) _then;

/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? updateInfo = freezed,Object? downloadProgress = null,Object? downloadedFilePath = freezed,Object? errorMessage = freezed,Object? errorType = freezed,Object? lastChecked = freezed,Object? isBackgroundCheck = null,}) {
  return _then(UpdateState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UpdateStatus,updateInfo: freezed == updateInfo ? _self.updateInfo : updateInfo // ignore: cast_nullable_to_non_nullable
as UpdateInfo?,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,downloadedFilePath: freezed == downloadedFilePath ? _self.downloadedFilePath : downloadedFilePath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as UpdateErrorType?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,isBackgroundCheck: null == isBackgroundCheck ? _self.isBackgroundCheck : isBackgroundCheck // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateState].
extension UpdateStatePatterns on UpdateState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateState value)  $default,){
final _that = this;
switch (_that) {
case _UpdateState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateState value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( UpdateStatus status,  UpdateInfo? updateInfo,  double downloadProgress,  String? downloadedFilePath,  String? errorMessage,  UpdateErrorType? errorType,  DateTime? lastChecked,  bool isBackgroundCheck)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
return $default(_that.status,_that.updateInfo,_that.downloadProgress,_that.downloadedFilePath,_that.errorMessage,_that.errorType,_that.lastChecked,_that.isBackgroundCheck);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( UpdateStatus status,  UpdateInfo? updateInfo,  double downloadProgress,  String? downloadedFilePath,  String? errorMessage,  UpdateErrorType? errorType,  DateTime? lastChecked,  bool isBackgroundCheck)  $default,) {final _that = this;
switch (_that) {
case _UpdateState():
return $default(_that.status,_that.updateInfo,_that.downloadProgress,_that.downloadedFilePath,_that.errorMessage,_that.errorType,_that.lastChecked,_that.isBackgroundCheck);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( UpdateStatus status,  UpdateInfo? updateInfo,  double downloadProgress,  String? downloadedFilePath,  String? errorMessage,  UpdateErrorType? errorType,  DateTime? lastChecked,  bool isBackgroundCheck)?  $default,) {final _that = this;
switch (_that) {
case _UpdateState() when $default != null:
return $default(_that.status,_that.updateInfo,_that.downloadProgress,_that.downloadedFilePath,_that.errorMessage,_that.errorType,_that.lastChecked,_that.isBackgroundCheck);case _:
  return null;

}
}

}

/// @nodoc


class _UpdateState implements UpdateState {
  const _UpdateState({this.status = UpdateStatus.idle, this.updateInfo, this.downloadProgress = 0.0, this.downloadedFilePath, this.errorMessage, this.errorType, this.lastChecked, this.isBackgroundCheck = false});
  

@override@JsonKey() final  UpdateStatus status;
@override final  UpdateInfo? updateInfo;
@override@JsonKey() final  double downloadProgress;
@override final  String? downloadedFilePath;
@override final  String? errorMessage;
@override final  UpdateErrorType? errorType;
@override final  DateTime? lastChecked;
@override@JsonKey() final  bool isBackgroundCheck;

/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateStateCopyWith<_UpdateState> get copyWith => __$UpdateStateCopyWithImpl<_UpdateState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateState&&(identical(other.status, status) || other.status == status)&&(identical(other.updateInfo, updateInfo) || other.updateInfo == updateInfo)&&(identical(other.downloadProgress, downloadProgress) || other.downloadProgress == downloadProgress)&&(identical(other.downloadedFilePath, downloadedFilePath) || other.downloadedFilePath == downloadedFilePath)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.errorType, errorType) || other.errorType == errorType)&&(identical(other.lastChecked, lastChecked) || other.lastChecked == lastChecked)&&(identical(other.isBackgroundCheck, isBackgroundCheck) || other.isBackgroundCheck == isBackgroundCheck));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,updateInfo,downloadProgress,downloadedFilePath,errorMessage,errorType,lastChecked,isBackgroundCheck);
}

@override
String toString() {
    return 'UpdateState(status: $status, updateInfo: $updateInfo, downloadProgress: $downloadProgress, downloadedFilePath: $downloadedFilePath, errorMessage: $errorMessage, errorType: $errorType, lastChecked: $lastChecked, isBackgroundCheck: $isBackgroundCheck)';
}


}

/// @nodoc
abstract mixin class _$UpdateStateCopyWith<$Res> implements $UpdateStateCopyWith<$Res> {
  factory _$UpdateStateCopyWith(_UpdateState value, $Res Function(_UpdateState) _then) = __$UpdateStateCopyWithImpl;
@override @useResult
$Res call({
 UpdateStatus status, UpdateInfo? updateInfo, double downloadProgress, String? downloadedFilePath, String? errorMessage, UpdateErrorType? errorType, DateTime? lastChecked, bool isBackgroundCheck
});




}
/// @nodoc
class __$UpdateStateCopyWithImpl<$Res>
    implements _$UpdateStateCopyWith<$Res> {
  __$UpdateStateCopyWithImpl(this._self, this._then);

  final _UpdateState _self;
  final $Res Function(_UpdateState) _then;

/// Create a copy of UpdateState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? updateInfo = freezed,Object? downloadProgress = null,Object? downloadedFilePath = freezed,Object? errorMessage = freezed,Object? errorType = freezed,Object? lastChecked = freezed,Object? isBackgroundCheck = null,}) {
  return _then(_UpdateState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UpdateStatus,updateInfo: freezed == updateInfo ? _self.updateInfo : updateInfo // ignore: cast_nullable_to_non_nullable
as UpdateInfo?,downloadProgress: null == downloadProgress ? _self.downloadProgress : downloadProgress // ignore: cast_nullable_to_non_nullable
as double,downloadedFilePath: freezed == downloadedFilePath ? _self.downloadedFilePath : downloadedFilePath // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,errorType: freezed == errorType ? _self.errorType : errorType // ignore: cast_nullable_to_non_nullable
as UpdateErrorType?,lastChecked: freezed == lastChecked ? _self.lastChecked : lastChecked // ignore: cast_nullable_to_non_nullable
as DateTime?,isBackgroundCheck: null == isBackgroundCheck ? _self.isBackgroundCheck : isBackgroundCheck // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
