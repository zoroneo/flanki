// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_payloads.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncIdPayload {

 String get id;
/// Create a copy of SyncIdPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncIdPayloadCopyWith<SyncIdPayload> get copyWith => _$SyncIdPayloadCopyWithImpl<SyncIdPayload>(this as SyncIdPayload, _$identity);

  /// Serializes this SyncIdPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SyncIdPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncIdPayload&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SyncIdPayload;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as SyncIdPayload;
  return 'SyncIdPayload(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $SyncIdPayloadCopyWith<$Res>  {
  factory $SyncIdPayloadCopyWith(SyncIdPayload value, $Res Function(SyncIdPayload) _then) = _$SyncIdPayloadCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$SyncIdPayloadCopyWithImpl<$Res>
    implements $SyncIdPayloadCopyWith<$Res> {
  _$SyncIdPayloadCopyWithImpl(this._self, this._then);

  final SyncIdPayload _self;
  final $Res Function(SyncIdPayload) _then;

/// Create a copy of SyncIdPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(SyncIdPayload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncIdPayload].
extension SyncIdPayloadPatterns on SyncIdPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncIdPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncIdPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncIdPayload value)  $default,){
final _that = this;
switch (_that) {
case _SyncIdPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncIdPayload value)?  $default,){
final _that = this;
switch (_that) {
case _SyncIdPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncIdPayload() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id)  $default,) {final _that = this;
switch (_that) {
case _SyncIdPayload():
return $default(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id)?  $default,) {final _that = this;
switch (_that) {
case _SyncIdPayload() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _SyncIdPayload extends SyncIdPayload {
  const _SyncIdPayload({required this.id}): super._();
  factory _SyncIdPayload.fromJson(Map<String, dynamic> json) => _$SyncIdPayloadFromJson(json);

@override final  String id;

/// Create a copy of SyncIdPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncIdPayloadCopyWith<_SyncIdPayload> get copyWith => __$SyncIdPayloadCopyWithImpl<_SyncIdPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncIdPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncIdPayload&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'SyncIdPayload(id: $id)';
}


}

/// @nodoc
abstract mixin class _$SyncIdPayloadCopyWith<$Res> implements $SyncIdPayloadCopyWith<$Res> {
  factory _$SyncIdPayloadCopyWith(_SyncIdPayload value, $Res Function(_SyncIdPayload) _then) = __$SyncIdPayloadCopyWithImpl;
@override @useResult
$Res call({
 String id
});




}
/// @nodoc
class __$SyncIdPayloadCopyWithImpl<$Res>
    implements _$SyncIdPayloadCopyWith<$Res> {
  __$SyncIdPayloadCopyWithImpl(this._self, this._then);

  final _SyncIdPayload _self;
  final $Res Function(_SyncIdPayload) _then;

/// Create a copy of SyncIdPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_SyncIdPayload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GrammarUnitDeletePayload {

 String get unitId; String get exerciseId;
/// Create a copy of GrammarUnitDeletePayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrammarUnitDeletePayloadCopyWith<GrammarUnitDeletePayload> get copyWith => _$GrammarUnitDeletePayloadCopyWithImpl<GrammarUnitDeletePayload>(this as GrammarUnitDeletePayload, _$identity);

  /// Serializes this GrammarUnitDeletePayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as GrammarUnitDeletePayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrammarUnitDeletePayload&&(identical(other.unitId, _this.unitId) || other.unitId == _this.unitId)&&(identical(other.exerciseId, _this.exerciseId) || other.exerciseId == _this.exerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as GrammarUnitDeletePayload;
  return Object.hash(runtimeType,_this.unitId,_this.exerciseId);
}

@override
String toString() {
  final _this = this as GrammarUnitDeletePayload;
  return 'GrammarUnitDeletePayload(unitId: ${_this.unitId}, exerciseId: ${_this.exerciseId})';
}


}

/// @nodoc
abstract mixin class $GrammarUnitDeletePayloadCopyWith<$Res>  {
  factory $GrammarUnitDeletePayloadCopyWith(GrammarUnitDeletePayload value, $Res Function(GrammarUnitDeletePayload) _then) = _$GrammarUnitDeletePayloadCopyWithImpl;
@useResult
$Res call({
 String unitId, String exerciseId
});




}
/// @nodoc
class _$GrammarUnitDeletePayloadCopyWithImpl<$Res>
    implements $GrammarUnitDeletePayloadCopyWith<$Res> {
  _$GrammarUnitDeletePayloadCopyWithImpl(this._self, this._then);

  final GrammarUnitDeletePayload _self;
  final $Res Function(GrammarUnitDeletePayload) _then;

/// Create a copy of GrammarUnitDeletePayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? unitId = null,Object? exerciseId = null,}) {
  return _then(GrammarUnitDeletePayload(
unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GrammarUnitDeletePayload].
extension GrammarUnitDeletePayloadPatterns on GrammarUnitDeletePayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrammarUnitDeletePayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrammarUnitDeletePayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrammarUnitDeletePayload value)  $default,){
final _that = this;
switch (_that) {
case _GrammarUnitDeletePayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrammarUnitDeletePayload value)?  $default,){
final _that = this;
switch (_that) {
case _GrammarUnitDeletePayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String unitId,  String exerciseId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrammarUnitDeletePayload() when $default != null:
return $default(_that.unitId,_that.exerciseId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String unitId,  String exerciseId)  $default,) {final _that = this;
switch (_that) {
case _GrammarUnitDeletePayload():
return $default(_that.unitId,_that.exerciseId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String unitId,  String exerciseId)?  $default,) {final _that = this;
switch (_that) {
case _GrammarUnitDeletePayload() when $default != null:
return $default(_that.unitId,_that.exerciseId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _GrammarUnitDeletePayload extends GrammarUnitDeletePayload {
  const _GrammarUnitDeletePayload({required this.unitId, required this.exerciseId}): super._();
  factory _GrammarUnitDeletePayload.fromJson(Map<String, dynamic> json) => _$GrammarUnitDeletePayloadFromJson(json);

@override final  String unitId;
@override final  String exerciseId;

/// Create a copy of GrammarUnitDeletePayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrammarUnitDeletePayloadCopyWith<_GrammarUnitDeletePayload> get copyWith => __$GrammarUnitDeletePayloadCopyWithImpl<_GrammarUnitDeletePayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrammarUnitDeletePayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrammarUnitDeletePayload&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.exerciseId, exerciseId) || other.exerciseId == exerciseId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,unitId,exerciseId);
}

@override
String toString() {
    return 'GrammarUnitDeletePayload(unitId: $unitId, exerciseId: $exerciseId)';
}


}

/// @nodoc
abstract mixin class _$GrammarUnitDeletePayloadCopyWith<$Res> implements $GrammarUnitDeletePayloadCopyWith<$Res> {
  factory _$GrammarUnitDeletePayloadCopyWith(_GrammarUnitDeletePayload value, $Res Function(_GrammarUnitDeletePayload) _then) = __$GrammarUnitDeletePayloadCopyWithImpl;
@override @useResult
$Res call({
 String unitId, String exerciseId
});




}
/// @nodoc
class __$GrammarUnitDeletePayloadCopyWithImpl<$Res>
    implements _$GrammarUnitDeletePayloadCopyWith<$Res> {
  __$GrammarUnitDeletePayloadCopyWithImpl(this._self, this._then);

  final _GrammarUnitDeletePayload _self;
  final $Res Function(_GrammarUnitDeletePayload) _then;

/// Create a copy of GrammarUnitDeletePayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? unitId = null,Object? exerciseId = null,}) {
  return _then(_GrammarUnitDeletePayload(
unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,exerciseId: null == exerciseId ? _self.exerciseId : exerciseId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WrongQuestionStatusPayload {

 String get id; String get status; String get updatedAt; String? get explanation; String? get notes;
/// Create a copy of WrongQuestionStatusPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WrongQuestionStatusPayloadCopyWith<WrongQuestionStatusPayload> get copyWith => _$WrongQuestionStatusPayloadCopyWithImpl<WrongQuestionStatusPayload>(this as WrongQuestionStatusPayload, _$identity);

  /// Serializes this WrongQuestionStatusPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WrongQuestionStatusPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WrongQuestionStatusPayload&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.explanation, _this.explanation) || other.explanation == _this.explanation)&&(identical(other.notes, _this.notes) || other.notes == _this.notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WrongQuestionStatusPayload;
  return Object.hash(runtimeType,_this.id,_this.status,_this.updatedAt,_this.explanation,_this.notes);
}

@override
String toString() {
  final _this = this as WrongQuestionStatusPayload;
  return 'WrongQuestionStatusPayload(id: ${_this.id}, status: ${_this.status}, updatedAt: ${_this.updatedAt}, explanation: ${_this.explanation}, notes: ${_this.notes})';
}


}

/// @nodoc
abstract mixin class $WrongQuestionStatusPayloadCopyWith<$Res>  {
  factory $WrongQuestionStatusPayloadCopyWith(WrongQuestionStatusPayload value, $Res Function(WrongQuestionStatusPayload) _then) = _$WrongQuestionStatusPayloadCopyWithImpl;
@useResult
$Res call({
 String id, String status, String updatedAt, String? explanation, String? notes
});




}
/// @nodoc
class _$WrongQuestionStatusPayloadCopyWithImpl<$Res>
    implements $WrongQuestionStatusPayloadCopyWith<$Res> {
  _$WrongQuestionStatusPayloadCopyWithImpl(this._self, this._then);

  final WrongQuestionStatusPayload _self;
  final $Res Function(WrongQuestionStatusPayload) _then;

/// Create a copy of WrongQuestionStatusPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? status = null,Object? updatedAt = null,Object? explanation = freezed,Object? notes = freezed,}) {
  return _then(WrongQuestionStatusPayload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WrongQuestionStatusPayload].
extension WrongQuestionStatusPayloadPatterns on WrongQuestionStatusPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WrongQuestionStatusPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WrongQuestionStatusPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WrongQuestionStatusPayload value)  $default,){
final _that = this;
switch (_that) {
case _WrongQuestionStatusPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WrongQuestionStatusPayload value)?  $default,){
final _that = this;
switch (_that) {
case _WrongQuestionStatusPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String status,  String updatedAt,  String? explanation,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WrongQuestionStatusPayload() when $default != null:
return $default(_that.id,_that.status,_that.updatedAt,_that.explanation,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String status,  String updatedAt,  String? explanation,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _WrongQuestionStatusPayload():
return $default(_that.id,_that.status,_that.updatedAt,_that.explanation,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String status,  String updatedAt,  String? explanation,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _WrongQuestionStatusPayload() when $default != null:
return $default(_that.id,_that.status,_that.updatedAt,_that.explanation,_that.notes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _WrongQuestionStatusPayload extends WrongQuestionStatusPayload {
  const _WrongQuestionStatusPayload({required this.id, required this.status, required this.updatedAt, this.explanation, this.notes}): super._();
  factory _WrongQuestionStatusPayload.fromJson(Map<String, dynamic> json) => _$WrongQuestionStatusPayloadFromJson(json);

@override final  String id;
@override final  String status;
@override final  String updatedAt;
@override final  String? explanation;
@override final  String? notes;

/// Create a copy of WrongQuestionStatusPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WrongQuestionStatusPayloadCopyWith<_WrongQuestionStatusPayload> get copyWith => __$WrongQuestionStatusPayloadCopyWithImpl<_WrongQuestionStatusPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WrongQuestionStatusPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WrongQuestionStatusPayload&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.explanation, explanation) || other.explanation == explanation)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,status,updatedAt,explanation,notes);
}

@override
String toString() {
    return 'WrongQuestionStatusPayload(id: $id, status: $status, updatedAt: $updatedAt, explanation: $explanation, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$WrongQuestionStatusPayloadCopyWith<$Res> implements $WrongQuestionStatusPayloadCopyWith<$Res> {
  factory _$WrongQuestionStatusPayloadCopyWith(_WrongQuestionStatusPayload value, $Res Function(_WrongQuestionStatusPayload) _then) = __$WrongQuestionStatusPayloadCopyWithImpl;
@override @useResult
$Res call({
 String id, String status, String updatedAt, String? explanation, String? notes
});




}
/// @nodoc
class __$WrongQuestionStatusPayloadCopyWithImpl<$Res>
    implements _$WrongQuestionStatusPayloadCopyWith<$Res> {
  __$WrongQuestionStatusPayloadCopyWithImpl(this._self, this._then);

  final _WrongQuestionStatusPayload _self;
  final $Res Function(_WrongQuestionStatusPayload) _then;

/// Create a copy of WrongQuestionStatusPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,Object? updatedAt = null,Object? explanation = freezed,Object? notes = freezed,}) {
  return _then(_WrongQuestionStatusPayload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,explanation: freezed == explanation ? _self.explanation : explanation // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$OutboxItemPayload {

 String get id; String get entityType; String get entityId; String get op; bool get isDeleted; dynamic get payload; String get hlc;
/// Create a copy of OutboxItemPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutboxItemPayloadCopyWith<OutboxItemPayload> get copyWith => _$OutboxItemPayloadCopyWithImpl<OutboxItemPayload>(this as OutboxItemPayload, _$identity);

  /// Serializes this OutboxItemPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OutboxItemPayload;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutboxItemPayload&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.entityType, _this.entityType) || other.entityType == _this.entityType)&&(identical(other.entityId, _this.entityId) || other.entityId == _this.entityId)&&(identical(other.op, _this.op) || other.op == _this.op)&&(identical(other.isDeleted, _this.isDeleted) || other.isDeleted == _this.isDeleted)&&const DeepCollectionEquality().equals(other.payload, _this.payload)&&(identical(other.hlc, _this.hlc) || other.hlc == _this.hlc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OutboxItemPayload;
  return Object.hash(runtimeType,_this.id,_this.entityType,_this.entityId,_this.op,_this.isDeleted,const DeepCollectionEquality().hash(_this.payload),_this.hlc);
}

@override
String toString() {
  final _this = this as OutboxItemPayload;
  return 'OutboxItemPayload(id: ${_this.id}, entityType: ${_this.entityType}, entityId: ${_this.entityId}, op: ${_this.op}, isDeleted: ${_this.isDeleted}, payload: ${_this.payload}, hlc: ${_this.hlc})';
}


}

/// @nodoc
abstract mixin class $OutboxItemPayloadCopyWith<$Res>  {
  factory $OutboxItemPayloadCopyWith(OutboxItemPayload value, $Res Function(OutboxItemPayload) _then) = _$OutboxItemPayloadCopyWithImpl;
@useResult
$Res call({
 String id, String entityType, String entityId, String op, bool isDeleted, dynamic payload, String hlc
});




}
/// @nodoc
class _$OutboxItemPayloadCopyWithImpl<$Res>
    implements $OutboxItemPayloadCopyWith<$Res> {
  _$OutboxItemPayloadCopyWithImpl(this._self, this._then);

  final OutboxItemPayload _self;
  final $Res Function(OutboxItemPayload) _then;

/// Create a copy of OutboxItemPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entityType = null,Object? entityId = null,Object? op = null,Object? isDeleted = null,Object? payload = freezed,Object? hlc = null,}) {
  return _then(OutboxItemPayload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as dynamic,hlc: null == hlc ? _self.hlc : hlc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OutboxItemPayload].
extension OutboxItemPayloadPatterns on OutboxItemPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutboxItemPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutboxItemPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutboxItemPayload value)  $default,){
final _that = this;
switch (_that) {
case _OutboxItemPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutboxItemPayload value)?  $default,){
final _that = this;
switch (_that) {
case _OutboxItemPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String entityType,  String entityId,  String op,  bool isDeleted,  dynamic payload,  String hlc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutboxItemPayload() when $default != null:
return $default(_that.id,_that.entityType,_that.entityId,_that.op,_that.isDeleted,_that.payload,_that.hlc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String entityType,  String entityId,  String op,  bool isDeleted,  dynamic payload,  String hlc)  $default,) {final _that = this;
switch (_that) {
case _OutboxItemPayload():
return $default(_that.id,_that.entityType,_that.entityId,_that.op,_that.isDeleted,_that.payload,_that.hlc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String entityType,  String entityId,  String op,  bool isDeleted,  dynamic payload,  String hlc)?  $default,) {final _that = this;
switch (_that) {
case _OutboxItemPayload() when $default != null:
return $default(_that.id,_that.entityType,_that.entityId,_that.op,_that.isDeleted,_that.payload,_that.hlc);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _OutboxItemPayload extends OutboxItemPayload {
  const _OutboxItemPayload({required this.id, required this.entityType, required this.entityId, required this.op, required this.isDeleted, required this.payload, required this.hlc}): super._();
  factory _OutboxItemPayload.fromJson(Map<String, dynamic> json) => _$OutboxItemPayloadFromJson(json);

@override final  String id;
@override final  String entityType;
@override final  String entityId;
@override final  String op;
@override final  bool isDeleted;
@override final  dynamic payload;
@override final  String hlc;

/// Create a copy of OutboxItemPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutboxItemPayloadCopyWith<_OutboxItemPayload> get copyWith => __$OutboxItemPayloadCopyWithImpl<_OutboxItemPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutboxItemPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutboxItemPayload&&(identical(other.id, id) || other.id == id)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.op, op) || other.op == op)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.hlc, hlc) || other.hlc == hlc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,entityType,entityId,op,isDeleted,const DeepCollectionEquality().hash(payload),hlc);
}

@override
String toString() {
    return 'OutboxItemPayload(id: $id, entityType: $entityType, entityId: $entityId, op: $op, isDeleted: $isDeleted, payload: $payload, hlc: $hlc)';
}


}

/// @nodoc
abstract mixin class _$OutboxItemPayloadCopyWith<$Res> implements $OutboxItemPayloadCopyWith<$Res> {
  factory _$OutboxItemPayloadCopyWith(_OutboxItemPayload value, $Res Function(_OutboxItemPayload) _then) = __$OutboxItemPayloadCopyWithImpl;
@override @useResult
$Res call({
 String id, String entityType, String entityId, String op, bool isDeleted, dynamic payload, String hlc
});




}
/// @nodoc
class __$OutboxItemPayloadCopyWithImpl<$Res>
    implements _$OutboxItemPayloadCopyWith<$Res> {
  __$OutboxItemPayloadCopyWithImpl(this._self, this._then);

  final _OutboxItemPayload _self;
  final $Res Function(_OutboxItemPayload) _then;

/// Create a copy of OutboxItemPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entityType = null,Object? entityId = null,Object? op = null,Object? isDeleted = null,Object? payload = freezed,Object? hlc = null,}) {
  return _then(_OutboxItemPayload(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String,op: null == op ? _self.op : op // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,payload: freezed == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as dynamic,hlc: null == hlc ? _self.hlc : hlc // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
