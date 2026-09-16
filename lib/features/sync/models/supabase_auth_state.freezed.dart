// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supabase_auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SupabaseAuthState {

 SupabaseAuthStatus get status; User? get user; String? get errorMessage;
/// Create a copy of SupabaseAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SupabaseAuthStateCopyWith<SupabaseAuthState> get copyWith => _$SupabaseAuthStateCopyWithImpl<SupabaseAuthState>(this as SupabaseAuthState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as SupabaseAuthState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SupabaseAuthState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.user, _this.user) || other.user == _this.user)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as SupabaseAuthState;
  return Object.hash(runtimeType,_this.status,_this.user,_this.errorMessage);
}

@override
String toString() {
  final _this = this as SupabaseAuthState;
  return 'SupabaseAuthState(status: ${_this.status}, user: ${_this.user}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $SupabaseAuthStateCopyWith<$Res>  {
  factory $SupabaseAuthStateCopyWith(SupabaseAuthState value, $Res Function(SupabaseAuthState) _then) = _$SupabaseAuthStateCopyWithImpl;
@useResult
$Res call({
 SupabaseAuthStatus status, User? user, String? errorMessage
});




}
/// @nodoc
class _$SupabaseAuthStateCopyWithImpl<$Res>
    implements $SupabaseAuthStateCopyWith<$Res> {
  _$SupabaseAuthStateCopyWithImpl(this._self, this._then);

  final SupabaseAuthState _self;
  final $Res Function(SupabaseAuthState) _then;

/// Create a copy of SupabaseAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? user = freezed,Object? errorMessage = freezed,}) {
  return _then(SupabaseAuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupabaseAuthStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SupabaseAuthState].
extension SupabaseAuthStatePatterns on SupabaseAuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SupabaseAuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SupabaseAuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SupabaseAuthState value)  $default,){
final _that = this;
switch (_that) {
case _SupabaseAuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SupabaseAuthState value)?  $default,){
final _that = this;
switch (_that) {
case _SupabaseAuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SupabaseAuthStatus status,  User? user,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SupabaseAuthState() when $default != null:
return $default(_that.status,_that.user,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SupabaseAuthStatus status,  User? user,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SupabaseAuthState():
return $default(_that.status,_that.user,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SupabaseAuthStatus status,  User? user,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SupabaseAuthState() when $default != null:
return $default(_that.status,_that.user,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _SupabaseAuthState extends SupabaseAuthState {
  const _SupabaseAuthState({this.status = SupabaseAuthStatus.initial, this.user, this.errorMessage}): super._();
  

@override@JsonKey() final  SupabaseAuthStatus status;
@override final  User? user;
@override final  String? errorMessage;

/// Create a copy of SupabaseAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SupabaseAuthStateCopyWith<_SupabaseAuthState> get copyWith => __$SupabaseAuthStateCopyWithImpl<_SupabaseAuthState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SupabaseAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.user, user) || other.user == user)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,user,errorMessage);
}

@override
String toString() {
    return 'SupabaseAuthState(status: $status, user: $user, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SupabaseAuthStateCopyWith<$Res> implements $SupabaseAuthStateCopyWith<$Res> {
  factory _$SupabaseAuthStateCopyWith(_SupabaseAuthState value, $Res Function(_SupabaseAuthState) _then) = __$SupabaseAuthStateCopyWithImpl;
@override @useResult
$Res call({
 SupabaseAuthStatus status, User? user, String? errorMessage
});




}
/// @nodoc
class __$SupabaseAuthStateCopyWithImpl<$Res>
    implements _$SupabaseAuthStateCopyWith<$Res> {
  __$SupabaseAuthStateCopyWithImpl(this._self, this._then);

  final _SupabaseAuthState _self;
  final $Res Function(_SupabaseAuthState) _then;

/// Create a copy of SupabaseAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? user = freezed,Object? errorMessage = freezed,}) {
  return _then(_SupabaseAuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SupabaseAuthStatus,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as User?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
