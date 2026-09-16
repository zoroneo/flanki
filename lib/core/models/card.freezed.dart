// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CardModel {

 String get id; String get deckId; String get front; String get back; String? get hint; NoteType get noteType; CardFlag get flag; bool get isSuspended; bool get isBuried;@CardTagsConverter() List<String> get tags; int get intervalDays; double get stability; double get difficulty; int get reps; int get lapses; DateTime? get due; DateTime? get lastStudied; DateTime? get createdAt;
/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardModelCopyWith<CardModel> get copyWith => _$CardModelCopyWithImpl<CardModel>(this as CardModel, _$identity);

  /// Serializes this CardModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardModel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardModel&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&(identical(other.front, _this.front) || other.front == _this.front)&&(identical(other.back, _this.back) || other.back == _this.back)&&(identical(other.hint, _this.hint) || other.hint == _this.hint)&&(identical(other.noteType, _this.noteType) || other.noteType == _this.noteType)&&(identical(other.flag, _this.flag) || other.flag == _this.flag)&&(identical(other.isSuspended, _this.isSuspended) || other.isSuspended == _this.isSuspended)&&(identical(other.isBuried, _this.isBuried) || other.isBuried == _this.isBuried)&&const DeepCollectionEquality().equals(other.tags, _this.tags)&&(identical(other.intervalDays, _this.intervalDays) || other.intervalDays == _this.intervalDays)&&(identical(other.stability, _this.stability) || other.stability == _this.stability)&&(identical(other.difficulty, _this.difficulty) || other.difficulty == _this.difficulty)&&(identical(other.reps, _this.reps) || other.reps == _this.reps)&&(identical(other.lapses, _this.lapses) || other.lapses == _this.lapses)&&(identical(other.due, _this.due) || other.due == _this.due)&&(identical(other.lastStudied, _this.lastStudied) || other.lastStudied == _this.lastStudied)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardModel;
  return Object.hash(runtimeType,_this.id,_this.deckId,_this.front,_this.back,_this.hint,_this.noteType,_this.flag,_this.isSuspended,_this.isBuried,const DeepCollectionEquality().hash(_this.tags),_this.intervalDays,_this.stability,_this.difficulty,_this.reps,_this.lapses,_this.due,_this.lastStudied,_this.createdAt);
}

@override
String toString() {
  final _this = this as CardModel;
  return 'CardModel(id: ${_this.id}, deckId: ${_this.deckId}, front: ${_this.front}, back: ${_this.back}, hint: ${_this.hint}, noteType: ${_this.noteType}, flag: ${_this.flag}, isSuspended: ${_this.isSuspended}, isBuried: ${_this.isBuried}, tags: ${_this.tags}, intervalDays: ${_this.intervalDays}, stability: ${_this.stability}, difficulty: ${_this.difficulty}, reps: ${_this.reps}, lapses: ${_this.lapses}, due: ${_this.due}, lastStudied: ${_this.lastStudied}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $CardModelCopyWith<$Res>  {
  factory $CardModelCopyWith(CardModel value, $Res Function(CardModel) _then) = _$CardModelCopyWithImpl;
@useResult
$Res call({
 String id, String deckId, String front, String back, String? hint, NoteType noteType, CardFlag flag, bool isSuspended, bool isBuried,@CardTagsConverter() List<String> tags, int intervalDays, double stability, double difficulty, int reps, int lapses, DateTime? due, DateTime? lastStudied, DateTime? createdAt
});




}
/// @nodoc
class _$CardModelCopyWithImpl<$Res>
    implements $CardModelCopyWith<$Res> {
  _$CardModelCopyWithImpl(this._self, this._then);

  final CardModel _self;
  final $Res Function(CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? deckId = null,Object? front = null,Object? back = null,Object? hint = freezed,Object? noteType = null,Object? flag = null,Object? isSuspended = null,Object? isBuried = null,Object? tags = null,Object? intervalDays = null,Object? stability = null,Object? difficulty = null,Object? reps = null,Object? lapses = null,Object? due = freezed,Object? lastStudied = freezed,Object? createdAt = freezed,}) {
  return _then(CardModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,noteType: null == noteType ? _self.noteType : noteType // ignore: cast_nullable_to_non_nullable
as NoteType,flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as CardFlag,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isBuried: null == isBuried ? _self.isBuried : isBuried // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStudied: freezed == lastStudied ? _self.lastStudied : lastStudied // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardModel].
extension CardModelPatterns on CardModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardModel value)  $default,){
final _that = this;
switch (_that) {
case _CardModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardModel value)?  $default,){
final _that = this;
switch (_that) {
case _CardModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String deckId,  String front,  String back,  String? hint,  NoteType noteType,  CardFlag flag,  bool isSuspended,  bool isBuried, @CardTagsConverter()  List<String> tags,  int intervalDays,  double stability,  double difficulty,  int reps,  int lapses,  DateTime? due,  DateTime? lastStudied,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.deckId,_that.front,_that.back,_that.hint,_that.noteType,_that.flag,_that.isSuspended,_that.isBuried,_that.tags,_that.intervalDays,_that.stability,_that.difficulty,_that.reps,_that.lapses,_that.due,_that.lastStudied,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String deckId,  String front,  String back,  String? hint,  NoteType noteType,  CardFlag flag,  bool isSuspended,  bool isBuried, @CardTagsConverter()  List<String> tags,  int intervalDays,  double stability,  double difficulty,  int reps,  int lapses,  DateTime? due,  DateTime? lastStudied,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _CardModel():
return $default(_that.id,_that.deckId,_that.front,_that.back,_that.hint,_that.noteType,_that.flag,_that.isSuspended,_that.isBuried,_that.tags,_that.intervalDays,_that.stability,_that.difficulty,_that.reps,_that.lapses,_that.due,_that.lastStudied,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String deckId,  String front,  String back,  String? hint,  NoteType noteType,  CardFlag flag,  bool isSuspended,  bool isBuried, @CardTagsConverter()  List<String> tags,  int intervalDays,  double stability,  double difficulty,  int reps,  int lapses,  DateTime? due,  DateTime? lastStudied,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _CardModel() when $default != null:
return $default(_that.id,_that.deckId,_that.front,_that.back,_that.hint,_that.noteType,_that.flag,_that.isSuspended,_that.isBuried,_that.tags,_that.intervalDays,_that.stability,_that.difficulty,_that.reps,_that.lapses,_that.due,_that.lastStudied,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _CardModel extends CardModel {
  const _CardModel({required this.id, this.deckId = '', this.front = '', this.back = '', this.hint, this.noteType = NoteType.basic, this.flag = CardFlag.none, this.isSuspended = false, this.isBuried = false, @CardTagsConverter()  List<String> tags = const [], this.intervalDays = 0, this.stability = 0.0, this.difficulty = 0.0, this.reps = 0, this.lapses = 0, this.due, this.lastStudied, this.createdAt}): _tags = tags,super._();
  factory _CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);

@override final  String id;
@override@JsonKey() final  String deckId;
@override@JsonKey() final  String front;
@override@JsonKey() final  String back;
@override final  String? hint;
@override@JsonKey() final  NoteType noteType;
@override@JsonKey() final  CardFlag flag;
@override@JsonKey() final  bool isSuspended;
@override@JsonKey() final  bool isBuried;
 final  List<String> _tags;
@override@JsonKey()@CardTagsConverter() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  int intervalDays;
@override@JsonKey() final  double stability;
@override@JsonKey() final  double difficulty;
@override@JsonKey() final  int reps;
@override@JsonKey() final  int lapses;
@override final  DateTime? due;
@override final  DateTime? lastStudied;
@override final  DateTime? createdAt;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardModelCopyWith<_CardModel> get copyWith => __$CardModelCopyWithImpl<_CardModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardModelToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardModel&&(identical(other.id, id) || other.id == id)&&(identical(other.deckId, deckId) || other.deckId == deckId)&&(identical(other.front, front) || other.front == front)&&(identical(other.back, back) || other.back == back)&&(identical(other.hint, hint) || other.hint == hint)&&(identical(other.noteType, noteType) || other.noteType == noteType)&&(identical(other.flag, flag) || other.flag == flag)&&(identical(other.isSuspended, isSuspended) || other.isSuspended == isSuspended)&&(identical(other.isBuried, isBuried) || other.isBuried == isBuried)&&const DeepCollectionEquality().equals(other.tags, _tags)&&(identical(other.intervalDays, intervalDays) || other.intervalDays == intervalDays)&&(identical(other.stability, stability) || other.stability == stability)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.lapses, lapses) || other.lapses == lapses)&&(identical(other.due, due) || other.due == due)&&(identical(other.lastStudied, lastStudied) || other.lastStudied == lastStudied)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,deckId,front,back,hint,noteType,flag,isSuspended,isBuried,const DeepCollectionEquality().hash(_tags),intervalDays,stability,difficulty,reps,lapses,due,lastStudied,createdAt);
}

@override
String toString() {
    return 'CardModel(id: $id, deckId: $deckId, front: $front, back: $back, hint: $hint, noteType: $noteType, flag: $flag, isSuspended: $isSuspended, isBuried: $isBuried, tags: $tags, intervalDays: $intervalDays, stability: $stability, difficulty: $difficulty, reps: $reps, lapses: $lapses, due: $due, lastStudied: $lastStudied, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$CardModelCopyWith<$Res> implements $CardModelCopyWith<$Res> {
  factory _$CardModelCopyWith(_CardModel value, $Res Function(_CardModel) _then) = __$CardModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String deckId, String front, String back, String? hint, NoteType noteType, CardFlag flag, bool isSuspended, bool isBuried,@CardTagsConverter() List<String> tags, int intervalDays, double stability, double difficulty, int reps, int lapses, DateTime? due, DateTime? lastStudied, DateTime? createdAt
});




}
/// @nodoc
class __$CardModelCopyWithImpl<$Res>
    implements _$CardModelCopyWith<$Res> {
  __$CardModelCopyWithImpl(this._self, this._then);

  final _CardModel _self;
  final $Res Function(_CardModel) _then;

/// Create a copy of CardModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? deckId = null,Object? front = null,Object? back = null,Object? hint = freezed,Object? noteType = null,Object? flag = null,Object? isSuspended = null,Object? isBuried = null,Object? tags = null,Object? intervalDays = null,Object? stability = null,Object? difficulty = null,Object? reps = null,Object? lapses = null,Object? due = freezed,Object? lastStudied = freezed,Object? createdAt = freezed,}) {
  return _then(_CardModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,front: null == front ? _self.front : front // ignore: cast_nullable_to_non_nullable
as String,back: null == back ? _self.back : back // ignore: cast_nullable_to_non_nullable
as String,hint: freezed == hint ? _self.hint : hint // ignore: cast_nullable_to_non_nullable
as String?,noteType: null == noteType ? _self.noteType : noteType // ignore: cast_nullable_to_non_nullable
as NoteType,flag: null == flag ? _self.flag : flag // ignore: cast_nullable_to_non_nullable
as CardFlag,isSuspended: null == isSuspended ? _self.isSuspended : isSuspended // ignore: cast_nullable_to_non_nullable
as bool,isBuried: null == isBuried ? _self.isBuried : isBuried // ignore: cast_nullable_to_non_nullable
as bool,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,intervalDays: null == intervalDays ? _self.intervalDays : intervalDays // ignore: cast_nullable_to_non_nullable
as int,stability: null == stability ? _self.stability : stability // ignore: cast_nullable_to_non_nullable
as double,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as double,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,lapses: null == lapses ? _self.lapses : lapses // ignore: cast_nullable_to_non_nullable
as int,due: freezed == due ? _self.due : due // ignore: cast_nullable_to_non_nullable
as DateTime?,lastStudied: freezed == lastStudied ? _self.lastStudied : lastStudied // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
