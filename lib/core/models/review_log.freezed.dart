// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReviewLogModel {

 int get id; String get cardId; ReviewRating get rating; DateTime get reviewTime; int get scheduledDays; int get elapsedDays; String get clientLogId;
/// Create a copy of ReviewLogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReviewLogModelCopyWith<ReviewLogModel> get copyWith => _$ReviewLogModelCopyWithImpl<ReviewLogModel>(this as ReviewLogModel, _$identity);

  /// Serializes this ReviewLogModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReviewLogModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReviewLogModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.cardId, _this.cardId) || other.cardId == _this.cardId)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.reviewTime, _this.reviewTime) || other.reviewTime == _this.reviewTime)&&(identical(other.scheduledDays, _this.scheduledDays) || other.scheduledDays == _this.scheduledDays)&&(identical(other.elapsedDays, _this.elapsedDays) || other.elapsedDays == _this.elapsedDays)&&(identical(other.clientLogId, _this.clientLogId) || other.clientLogId == _this.clientLogId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReviewLogModel;
  return Object.hash(runtimeType,_this.id,_this.cardId,_this.rating,_this.reviewTime,_this.scheduledDays,_this.elapsedDays,_this.clientLogId);
}

@override
String toString() {
  final _this = this as ReviewLogModel;
  return 'ReviewLogModel(id: ${_this.id}, cardId: ${_this.cardId}, rating: ${_this.rating}, reviewTime: ${_this.reviewTime}, scheduledDays: ${_this.scheduledDays}, elapsedDays: ${_this.elapsedDays}, clientLogId: ${_this.clientLogId})';
}


}

/// @nodoc
abstract mixin class $ReviewLogModelCopyWith<$Res>  {
  factory $ReviewLogModelCopyWith(ReviewLogModel value, $Res Function(ReviewLogModel) _then) = _$ReviewLogModelCopyWithImpl;
@useResult
$Res call({
 int id, String cardId, ReviewRating rating, DateTime reviewTime, int scheduledDays, int elapsedDays, String clientLogId
});




}
/// @nodoc
class _$ReviewLogModelCopyWithImpl<$Res>
    implements $ReviewLogModelCopyWith<$Res> {
  _$ReviewLogModelCopyWithImpl(this._self, this._then);

  final ReviewLogModel _self;
  final $Res Function(ReviewLogModel) _then;

/// Create a copy of ReviewLogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? cardId = null,Object? rating = null,Object? reviewTime = null,Object? scheduledDays = null,Object? elapsedDays = null,Object? clientLogId = null,}) {
  return _then(ReviewLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as ReviewRating,reviewTime: null == reviewTime ? _self.reviewTime : reviewTime // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledDays: null == scheduledDays ? _self.scheduledDays : scheduledDays // ignore: cast_nullable_to_non_nullable
as int,elapsedDays: null == elapsedDays ? _self.elapsedDays : elapsedDays // ignore: cast_nullable_to_non_nullable
as int,clientLogId: null == clientLogId ? _self.clientLogId : clientLogId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReviewLogModel].
extension ReviewLogModelPatterns on ReviewLogModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReviewLogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReviewLogModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReviewLogModel value)  $default,){
final _that = this;
switch (_that) {
case _ReviewLogModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReviewLogModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReviewLogModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String cardId,  ReviewRating rating,  DateTime reviewTime,  int scheduledDays,  int elapsedDays,  String clientLogId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReviewLogModel() when $default != null:
return $default(_that.id,_that.cardId,_that.rating,_that.reviewTime,_that.scheduledDays,_that.elapsedDays,_that.clientLogId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String cardId,  ReviewRating rating,  DateTime reviewTime,  int scheduledDays,  int elapsedDays,  String clientLogId)  $default,) {final _that = this;
switch (_that) {
case _ReviewLogModel():
return $default(_that.id,_that.cardId,_that.rating,_that.reviewTime,_that.scheduledDays,_that.elapsedDays,_that.clientLogId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String cardId,  ReviewRating rating,  DateTime reviewTime,  int scheduledDays,  int elapsedDays,  String clientLogId)?  $default,) {final _that = this;
switch (_that) {
case _ReviewLogModel() when $default != null:
return $default(_that.id,_that.cardId,_that.rating,_that.reviewTime,_that.scheduledDays,_that.elapsedDays,_that.clientLogId);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ReviewLogModel extends ReviewLogModel {
  const _ReviewLogModel({this.id = 0, required this.cardId, required this.rating, required this.reviewTime, this.scheduledDays = 0, this.elapsedDays = 0, this.clientLogId = ''}): super._();
  factory _ReviewLogModel.fromJson(Map<String, dynamic> json) => _$ReviewLogModelFromJson(json);

@override@JsonKey() final  int id;
@override final  String cardId;
@override final  ReviewRating rating;
@override final  DateTime reviewTime;
@override@JsonKey() final  int scheduledDays;
@override@JsonKey() final  int elapsedDays;
@override@JsonKey() final  String clientLogId;

/// Create a copy of ReviewLogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReviewLogModelCopyWith<_ReviewLogModel> get copyWith => __$ReviewLogModelCopyWithImpl<_ReviewLogModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReviewLogModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReviewLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.cardId, cardId) || other.cardId == cardId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewTime, reviewTime) || other.reviewTime == reviewTime)&&(identical(other.scheduledDays, scheduledDays) || other.scheduledDays == scheduledDays)&&(identical(other.elapsedDays, elapsedDays) || other.elapsedDays == elapsedDays)&&(identical(other.clientLogId, clientLogId) || other.clientLogId == clientLogId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,cardId,rating,reviewTime,scheduledDays,elapsedDays,clientLogId);
}

@override
String toString() {
    return 'ReviewLogModel(id: $id, cardId: $cardId, rating: $rating, reviewTime: $reviewTime, scheduledDays: $scheduledDays, elapsedDays: $elapsedDays, clientLogId: $clientLogId)';
}


}

/// @nodoc
abstract mixin class _$ReviewLogModelCopyWith<$Res> implements $ReviewLogModelCopyWith<$Res> {
  factory _$ReviewLogModelCopyWith(_ReviewLogModel value, $Res Function(_ReviewLogModel) _then) = __$ReviewLogModelCopyWithImpl;
@override @useResult
$Res call({
 int id, String cardId, ReviewRating rating, DateTime reviewTime, int scheduledDays, int elapsedDays, String clientLogId
});




}
/// @nodoc
class __$ReviewLogModelCopyWithImpl<$Res>
    implements _$ReviewLogModelCopyWith<$Res> {
  __$ReviewLogModelCopyWithImpl(this._self, this._then);

  final _ReviewLogModel _self;
  final $Res Function(_ReviewLogModel) _then;

/// Create a copy of ReviewLogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? cardId = null,Object? rating = null,Object? reviewTime = null,Object? scheduledDays = null,Object? elapsedDays = null,Object? clientLogId = null,}) {
  return _then(_ReviewLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,cardId: null == cardId ? _self.cardId : cardId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as ReviewRating,reviewTime: null == reviewTime ? _self.reviewTime : reviewTime // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledDays: null == scheduledDays ? _self.scheduledDays : scheduledDays // ignore: cast_nullable_to_non_nullable
as int,elapsedDays: null == elapsedDays ? _self.elapsedDays : elapsedDays // ignore: cast_nullable_to_non_nullable
as int,clientLogId: null == clientLogId ? _self.clientLogId : clientLogId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
