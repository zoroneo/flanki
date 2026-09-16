// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deck.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeckModel {

 String get id; String get title; String get description; int get dueCount; int get newCount; int get totalCount; DateTime? get lastStudied;
/// Create a copy of DeckModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeckModelCopyWith<DeckModel> get copyWith => _$DeckModelCopyWithImpl<DeckModel>(this as DeckModel, _$identity);

  /// Serializes this DeckModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DeckModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeckModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.dueCount, _this.dueCount) || other.dueCount == _this.dueCount)&&(identical(other.newCount, _this.newCount) || other.newCount == _this.newCount)&&(identical(other.totalCount, _this.totalCount) || other.totalCount == _this.totalCount)&&(identical(other.lastStudied, _this.lastStudied) || other.lastStudied == _this.lastStudied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DeckModel;
  return Object.hash(runtimeType,_this.id,_this.title,_this.description,_this.dueCount,_this.newCount,_this.totalCount,_this.lastStudied);
}

@override
String toString() {
  final _this = this as DeckModel;
  return 'DeckModel(id: ${_this.id}, title: ${_this.title}, description: ${_this.description}, dueCount: ${_this.dueCount}, newCount: ${_this.newCount}, totalCount: ${_this.totalCount}, lastStudied: ${_this.lastStudied})';
}


}

/// @nodoc
abstract mixin class $DeckModelCopyWith<$Res>  {
  factory $DeckModelCopyWith(DeckModel value, $Res Function(DeckModel) _then) = _$DeckModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, int dueCount, int newCount, int totalCount, DateTime? lastStudied
});




}
/// @nodoc
class _$DeckModelCopyWithImpl<$Res>
    implements $DeckModelCopyWith<$Res> {
  _$DeckModelCopyWithImpl(this._self, this._then);

  final DeckModel _self;
  final $Res Function(DeckModel) _then;

/// Create a copy of DeckModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? dueCount = null,Object? newCount = null,Object? totalCount = null,Object? lastStudied = freezed,}) {
  return _then(DeckModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,newCount: null == newCount ? _self.newCount : newCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,lastStudied: freezed == lastStudied ? _self.lastStudied : lastStudied // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DeckModel].
extension DeckModelPatterns on DeckModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeckModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeckModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeckModel value)  $default,){
final _that = this;
switch (_that) {
case _DeckModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeckModel value)?  $default,){
final _that = this;
switch (_that) {
case _DeckModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int dueCount,  int newCount,  int totalCount,  DateTime? lastStudied)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeckModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.dueCount,_that.newCount,_that.totalCount,_that.lastStudied);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  int dueCount,  int newCount,  int totalCount,  DateTime? lastStudied)  $default,) {final _that = this;
switch (_that) {
case _DeckModel():
return $default(_that.id,_that.title,_that.description,_that.dueCount,_that.newCount,_that.totalCount,_that.lastStudied);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  int dueCount,  int newCount,  int totalCount,  DateTime? lastStudied)?  $default,) {final _that = this;
switch (_that) {
case _DeckModel() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.dueCount,_that.newCount,_that.totalCount,_that.lastStudied);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _DeckModel extends DeckModel {
  const _DeckModel({required this.id, this.title = 'Untitled Deck', this.description = '', this.dueCount = 0, this.newCount = 0, this.totalCount = 0, this.lastStudied}): super._();
  factory _DeckModel.fromJson(Map<String, dynamic> json) => _$DeckModelFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  int dueCount;
@override@JsonKey() final  int newCount;
@override@JsonKey() final  int totalCount;
@override final  DateTime? lastStudied;

/// Create a copy of DeckModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeckModelCopyWith<_DeckModel> get copyWith => __$DeckModelCopyWithImpl<_DeckModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeckModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeckModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.dueCount, dueCount) || other.dueCount == dueCount)&&(identical(other.newCount, newCount) || other.newCount == newCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.lastStudied, lastStudied) || other.lastStudied == lastStudied));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,title,description,dueCount,newCount,totalCount,lastStudied);
}

@override
String toString() {
    return 'DeckModel(id: $id, title: $title, description: $description, dueCount: $dueCount, newCount: $newCount, totalCount: $totalCount, lastStudied: $lastStudied)';
}


}

/// @nodoc
abstract mixin class _$DeckModelCopyWith<$Res> implements $DeckModelCopyWith<$Res> {
  factory _$DeckModelCopyWith(_DeckModel value, $Res Function(_DeckModel) _then) = __$DeckModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, int dueCount, int newCount, int totalCount, DateTime? lastStudied
});




}
/// @nodoc
class __$DeckModelCopyWithImpl<$Res>
    implements _$DeckModelCopyWith<$Res> {
  __$DeckModelCopyWithImpl(this._self, this._then);

  final _DeckModel _self;
  final $Res Function(_DeckModel) _then;

/// Create a copy of DeckModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? dueCount = null,Object? newCount = null,Object? totalCount = null,Object? lastStudied = freezed,}) {
  return _then(_DeckModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,dueCount: null == dueCount ? _self.dueCount : dueCount // ignore: cast_nullable_to_non_nullable
as int,newCount: null == newCount ? _self.newCount : newCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,lastStudied: freezed == lastStudied ? _self.lastStudied : lastStudied // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
