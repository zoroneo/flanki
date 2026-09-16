// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_ui_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SyncUiState {

 SyncStatus get status; DateTime? get lastSyncedAt; int get pendingCount; String? get errorMessage;
/// Create a copy of SyncUiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncUiStateCopyWith<SyncUiState> get copyWith => _$SyncUiStateCopyWithImpl<SyncUiState>(this as SyncUiState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SyncUiState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncUiState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastSyncedAt, _this.lastSyncedAt) || other.lastSyncedAt == _this.lastSyncedAt)&&(identical(other.pendingCount, _this.pendingCount) || other.pendingCount == _this.pendingCount)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as SyncUiState;
  return Object.hash(runtimeType,_this.status,_this.lastSyncedAt,_this.pendingCount,_this.errorMessage);
}

@override
String toString() {
  final _this = this as SyncUiState;
  return 'SyncUiState(status: ${_this.status}, lastSyncedAt: ${_this.lastSyncedAt}, pendingCount: ${_this.pendingCount}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $SyncUiStateCopyWith<$Res>  {
  factory $SyncUiStateCopyWith(SyncUiState value, $Res Function(SyncUiState) _then) = _$SyncUiStateCopyWithImpl;
@useResult
$Res call({
 SyncStatus status, DateTime? lastSyncedAt, int pendingCount, String? errorMessage
});




}
/// @nodoc
class _$SyncUiStateCopyWithImpl<$Res>
    implements $SyncUiStateCopyWith<$Res> {
  _$SyncUiStateCopyWithImpl(this._self, this._then);

  final SyncUiState _self;
  final $Res Function(SyncUiState) _then;

/// Create a copy of SyncUiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? lastSyncedAt = freezed,Object? pendingCount = null,Object? errorMessage = freezed,}) {
  return _then(SyncUiState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncUiState].
extension SyncUiStatePatterns on SyncUiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncUiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncUiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncUiState value)  $default,){
final _that = this;
switch (_that) {
case _SyncUiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncUiState value)?  $default,){
final _that = this;
switch (_that) {
case _SyncUiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SyncStatus status,  DateTime? lastSyncedAt,  int pendingCount,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncUiState() when $default != null:
return $default(_that.status,_that.lastSyncedAt,_that.pendingCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SyncStatus status,  DateTime? lastSyncedAt,  int pendingCount,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SyncUiState():
return $default(_that.status,_that.lastSyncedAt,_that.pendingCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SyncStatus status,  DateTime? lastSyncedAt,  int pendingCount,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SyncUiState() when $default != null:
return $default(_that.status,_that.lastSyncedAt,_that.pendingCount,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SyncUiState extends SyncUiState {
  const _SyncUiState({this.status = SyncStatus.idle, this.lastSyncedAt, this.pendingCount = 0, this.errorMessage}): super._();
  

@override@JsonKey() final  SyncStatus status;
@override final  DateTime? lastSyncedAt;
@override@JsonKey() final  int pendingCount;
@override final  String? errorMessage;

/// Create a copy of SyncUiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncUiStateCopyWith<_SyncUiState> get copyWith => __$SyncUiStateCopyWithImpl<_SyncUiState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncUiState&&(identical(other.status, status) || other.status == status)&&(identical(other.lastSyncedAt, lastSyncedAt) || other.lastSyncedAt == lastSyncedAt)&&(identical(other.pendingCount, pendingCount) || other.pendingCount == pendingCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,lastSyncedAt,pendingCount,errorMessage);
}

@override
String toString() {
    return 'SyncUiState(status: $status, lastSyncedAt: $lastSyncedAt, pendingCount: $pendingCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SyncUiStateCopyWith<$Res> implements $SyncUiStateCopyWith<$Res> {
  factory _$SyncUiStateCopyWith(_SyncUiState value, $Res Function(_SyncUiState) _then) = __$SyncUiStateCopyWithImpl;
@override @useResult
$Res call({
 SyncStatus status, DateTime? lastSyncedAt, int pendingCount, String? errorMessage
});




}
/// @nodoc
class __$SyncUiStateCopyWithImpl<$Res>
    implements _$SyncUiStateCopyWith<$Res> {
  __$SyncUiStateCopyWithImpl(this._self, this._then);

  final _SyncUiState _self;
  final $Res Function(_SyncUiState) _then;

/// Create a copy of SyncUiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? lastSyncedAt = freezed,Object? pendingCount = null,Object? errorMessage = freezed,}) {
  return _then(_SyncUiState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncStatus,lastSyncedAt: freezed == lastSyncedAt ? _self.lastSyncedAt : lastSyncedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,pendingCount: null == pendingCount ? _self.pendingCount : pendingCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
