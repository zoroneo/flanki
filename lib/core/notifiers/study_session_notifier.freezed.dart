// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_session_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StudySessionSnapshot {

 List<CardModel> get queue; CardModel? get currentCard; bool get isFlipped; int get completedCount; bool get isFinished;
/// Create a copy of StudySessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudySessionSnapshotCopyWith<StudySessionSnapshot> get copyWith => _$StudySessionSnapshotCopyWithImpl<StudySessionSnapshot>(this as StudySessionSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StudySessionSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudySessionSnapshot&&const DeepCollectionEquality().equals(other.queue, _this.queue)&&(identical(other.currentCard, _this.currentCard) || other.currentCard == _this.currentCard)&&(identical(other.isFlipped, _this.isFlipped) || other.isFlipped == _this.isFlipped)&&(identical(other.completedCount, _this.completedCount) || other.completedCount == _this.completedCount)&&(identical(other.isFinished, _this.isFinished) || other.isFinished == _this.isFinished));
}


@override
int get hashCode {
  final _this = this as StudySessionSnapshot;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.queue),_this.currentCard,_this.isFlipped,_this.completedCount,_this.isFinished);
}

@override
String toString() {
  final _this = this as StudySessionSnapshot;
  return 'StudySessionSnapshot(queue: ${_this.queue}, currentCard: ${_this.currentCard}, isFlipped: ${_this.isFlipped}, completedCount: ${_this.completedCount}, isFinished: ${_this.isFinished})';
}


}

/// @nodoc
abstract mixin class $StudySessionSnapshotCopyWith<$Res>  {
  factory $StudySessionSnapshotCopyWith(StudySessionSnapshot value, $Res Function(StudySessionSnapshot) _then) = _$StudySessionSnapshotCopyWithImpl;
@useResult
$Res call({
 List<CardModel> queue, CardModel? currentCard, bool isFlipped, int completedCount, bool isFinished
});




}
/// @nodoc
class _$StudySessionSnapshotCopyWithImpl<$Res>
    implements $StudySessionSnapshotCopyWith<$Res> {
  _$StudySessionSnapshotCopyWithImpl(this._self, this._then);

  final StudySessionSnapshot _self;
  final $Res Function(StudySessionSnapshot) _then;

/// Create a copy of StudySessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? queue = null,Object? currentCard = freezed,Object? isFlipped = null,Object? completedCount = null,Object? isFinished = null,}) {
  return _then(StudySessionSnapshot(
queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<CardModel>,currentCard: freezed == currentCard ? _self.currentCard : currentCard // ignore: cast_nullable_to_non_nullable
as CardModel?,isFlipped: null == isFlipped ? _self.isFlipped : isFlipped // ignore: cast_nullable_to_non_nullable
as bool,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StudySessionSnapshot].
extension StudySessionSnapshotPatterns on StudySessionSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudySessionSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudySessionSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudySessionSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _StudySessionSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudySessionSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _StudySessionSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CardModel> queue,  CardModel? currentCard,  bool isFlipped,  int completedCount,  bool isFinished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudySessionSnapshot() when $default != null:
return $default(_that.queue,_that.currentCard,_that.isFlipped,_that.completedCount,_that.isFinished);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CardModel> queue,  CardModel? currentCard,  bool isFlipped,  int completedCount,  bool isFinished)  $default,) {final _that = this;
switch (_that) {
case _StudySessionSnapshot():
return $default(_that.queue,_that.currentCard,_that.isFlipped,_that.completedCount,_that.isFinished);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CardModel> queue,  CardModel? currentCard,  bool isFlipped,  int completedCount,  bool isFinished)?  $default,) {final _that = this;
switch (_that) {
case _StudySessionSnapshot() when $default != null:
return $default(_that.queue,_that.currentCard,_that.isFlipped,_that.completedCount,_that.isFinished);case _:
  return null;

}
}

}

/// @nodoc


class _StudySessionSnapshot implements StudySessionSnapshot {
  const _StudySessionSnapshot({required  List<CardModel> queue, required this.currentCard, required this.isFlipped, required this.completedCount, required this.isFinished}): _queue = queue;
  

 final  List<CardModel> _queue;
@override List<CardModel> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override final  CardModel? currentCard;
@override final  bool isFlipped;
@override final  int completedCount;
@override final  bool isFinished;

/// Create a copy of StudySessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudySessionSnapshotCopyWith<_StudySessionSnapshot> get copyWith => __$StudySessionSnapshotCopyWithImpl<_StudySessionSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudySessionSnapshot&&const DeepCollectionEquality().equals(other.queue, _queue)&&(identical(other.currentCard, currentCard) || other.currentCard == currentCard)&&(identical(other.isFlipped, isFlipped) || other.isFlipped == isFlipped)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_queue),currentCard,isFlipped,completedCount,isFinished);
}

@override
String toString() {
    return 'StudySessionSnapshot(queue: $queue, currentCard: $currentCard, isFlipped: $isFlipped, completedCount: $completedCount, isFinished: $isFinished)';
}


}

/// @nodoc
abstract mixin class _$StudySessionSnapshotCopyWith<$Res> implements $StudySessionSnapshotCopyWith<$Res> {
  factory _$StudySessionSnapshotCopyWith(_StudySessionSnapshot value, $Res Function(_StudySessionSnapshot) _then) = __$StudySessionSnapshotCopyWithImpl;
@override @useResult
$Res call({
 List<CardModel> queue, CardModel? currentCard, bool isFlipped, int completedCount, bool isFinished
});




}
/// @nodoc
class __$StudySessionSnapshotCopyWithImpl<$Res>
    implements _$StudySessionSnapshotCopyWith<$Res> {
  __$StudySessionSnapshotCopyWithImpl(this._self, this._then);

  final _StudySessionSnapshot _self;
  final $Res Function(_StudySessionSnapshot) _then;

/// Create a copy of StudySessionSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? queue = null,Object? currentCard = freezed,Object? isFlipped = null,Object? completedCount = null,Object? isFinished = null,}) {
  return _then(_StudySessionSnapshot(
queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<CardModel>,currentCard: freezed == currentCard ? _self.currentCard : currentCard // ignore: cast_nullable_to_non_nullable
as CardModel?,isFlipped: null == isFlipped ? _self.isFlipped : isFlipped // ignore: cast_nullable_to_non_nullable
as bool,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$StudySessionState {

 String get deckId; List<CardModel> get queue; CardModel? get currentCard; bool get isFlipped; int get completedCount; int get initialCount; bool get isFinished; List<StudySessionSnapshot> get history; DateTime? get cardPresentedAt;
/// Create a copy of StudySessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudySessionStateCopyWith<StudySessionState> get copyWith => _$StudySessionStateCopyWithImpl<StudySessionState>(this as StudySessionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StudySessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudySessionState&&(identical(other.deckId, _this.deckId) || other.deckId == _this.deckId)&&const DeepCollectionEquality().equals(other.queue, _this.queue)&&(identical(other.currentCard, _this.currentCard) || other.currentCard == _this.currentCard)&&(identical(other.isFlipped, _this.isFlipped) || other.isFlipped == _this.isFlipped)&&(identical(other.completedCount, _this.completedCount) || other.completedCount == _this.completedCount)&&(identical(other.initialCount, _this.initialCount) || other.initialCount == _this.initialCount)&&(identical(other.isFinished, _this.isFinished) || other.isFinished == _this.isFinished)&&const DeepCollectionEquality().equals(other.history, _this.history)&&(identical(other.cardPresentedAt, _this.cardPresentedAt) || other.cardPresentedAt == _this.cardPresentedAt));
}


@override
int get hashCode {
  final _this = this as StudySessionState;
  return Object.hash(runtimeType,_this.deckId,const DeepCollectionEquality().hash(_this.queue),_this.currentCard,_this.isFlipped,_this.completedCount,_this.initialCount,_this.isFinished,const DeepCollectionEquality().hash(_this.history),_this.cardPresentedAt);
}

@override
String toString() {
  final _this = this as StudySessionState;
  return 'StudySessionState(deckId: ${_this.deckId}, queue: ${_this.queue}, currentCard: ${_this.currentCard}, isFlipped: ${_this.isFlipped}, completedCount: ${_this.completedCount}, initialCount: ${_this.initialCount}, isFinished: ${_this.isFinished}, history: ${_this.history}, cardPresentedAt: ${_this.cardPresentedAt})';
}


}

/// @nodoc
abstract mixin class $StudySessionStateCopyWith<$Res>  {
  factory $StudySessionStateCopyWith(StudySessionState value, $Res Function(StudySessionState) _then) = _$StudySessionStateCopyWithImpl;
@useResult
$Res call({
 String deckId, List<CardModel> queue, CardModel? currentCard, bool isFlipped, int completedCount, int initialCount, bool isFinished, List<StudySessionSnapshot> history, DateTime? cardPresentedAt
});




}
/// @nodoc
class _$StudySessionStateCopyWithImpl<$Res>
    implements $StudySessionStateCopyWith<$Res> {
  _$StudySessionStateCopyWithImpl(this._self, this._then);

  final StudySessionState _self;
  final $Res Function(StudySessionState) _then;

/// Create a copy of StudySessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deckId = null,Object? queue = null,Object? currentCard = freezed,Object? isFlipped = null,Object? completedCount = null,Object? initialCount = null,Object? isFinished = null,Object? history = null,Object? cardPresentedAt = freezed,}) {
  return _then(StudySessionState(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,queue: null == queue ? _self.queue : queue // ignore: cast_nullable_to_non_nullable
as List<CardModel>,currentCard: freezed == currentCard ? _self.currentCard : currentCard // ignore: cast_nullable_to_non_nullable
as CardModel?,isFlipped: null == isFlipped ? _self.isFlipped : isFlipped // ignore: cast_nullable_to_non_nullable
as bool,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,initialCount: null == initialCount ? _self.initialCount : initialCount // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as List<StudySessionSnapshot>,cardPresentedAt: freezed == cardPresentedAt ? _self.cardPresentedAt : cardPresentedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [StudySessionState].
extension StudySessionStatePatterns on StudySessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudySessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudySessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudySessionState value)  $default,){
final _that = this;
switch (_that) {
case _StudySessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudySessionState value)?  $default,){
final _that = this;
switch (_that) {
case _StudySessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deckId,  List<CardModel> queue,  CardModel? currentCard,  bool isFlipped,  int completedCount,  int initialCount,  bool isFinished,  List<StudySessionSnapshot> history,  DateTime? cardPresentedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudySessionState() when $default != null:
return $default(_that.deckId,_that.queue,_that.currentCard,_that.isFlipped,_that.completedCount,_that.initialCount,_that.isFinished,_that.history,_that.cardPresentedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deckId,  List<CardModel> queue,  CardModel? currentCard,  bool isFlipped,  int completedCount,  int initialCount,  bool isFinished,  List<StudySessionSnapshot> history,  DateTime? cardPresentedAt)  $default,) {final _that = this;
switch (_that) {
case _StudySessionState():
return $default(_that.deckId,_that.queue,_that.currentCard,_that.isFlipped,_that.completedCount,_that.initialCount,_that.isFinished,_that.history,_that.cardPresentedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deckId,  List<CardModel> queue,  CardModel? currentCard,  bool isFlipped,  int completedCount,  int initialCount,  bool isFinished,  List<StudySessionSnapshot> history,  DateTime? cardPresentedAt)?  $default,) {final _that = this;
switch (_that) {
case _StudySessionState() when $default != null:
return $default(_that.deckId,_that.queue,_that.currentCard,_that.isFlipped,_that.completedCount,_that.initialCount,_that.isFinished,_that.history,_that.cardPresentedAt);case _:
  return null;

}
}

}

/// @nodoc


class _StudySessionState extends StudySessionState {
  const _StudySessionState({required this.deckId, required  List<CardModel> queue, this.currentCard, this.isFlipped = false, this.completedCount = 0, this.initialCount = 0, this.isFinished = false,  List<StudySessionSnapshot> history = const [], this.cardPresentedAt}): _queue = queue,_history = history,super._();
  

@override final  String deckId;
 final  List<CardModel> _queue;
@override List<CardModel> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}

@override final  CardModel? currentCard;
@override@JsonKey() final  bool isFlipped;
@override@JsonKey() final  int completedCount;
@override@JsonKey() final  int initialCount;
@override@JsonKey() final  bool isFinished;
 final  List<StudySessionSnapshot> _history;
@override@JsonKey() List<StudySessionSnapshot> get history {
  if (_history is EqualUnmodifiableListView) return _history;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_history);
}

@override final  DateTime? cardPresentedAt;

/// Create a copy of StudySessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudySessionStateCopyWith<_StudySessionState> get copyWith => __$StudySessionStateCopyWithImpl<_StudySessionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudySessionState&&(identical(other.deckId, deckId) || other.deckId == deckId)&&const DeepCollectionEquality().equals(other.queue, _queue)&&(identical(other.currentCard, currentCard) || other.currentCard == currentCard)&&(identical(other.isFlipped, isFlipped) || other.isFlipped == isFlipped)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.initialCount, initialCount) || other.initialCount == initialCount)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&const DeepCollectionEquality().equals(other.history, _history)&&(identical(other.cardPresentedAt, cardPresentedAt) || other.cardPresentedAt == cardPresentedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,deckId,const DeepCollectionEquality().hash(_queue),currentCard,isFlipped,completedCount,initialCount,isFinished,const DeepCollectionEquality().hash(_history),cardPresentedAt);
}

@override
String toString() {
    return 'StudySessionState(deckId: $deckId, queue: $queue, currentCard: $currentCard, isFlipped: $isFlipped, completedCount: $completedCount, initialCount: $initialCount, isFinished: $isFinished, history: $history, cardPresentedAt: $cardPresentedAt)';
}


}

/// @nodoc
abstract mixin class _$StudySessionStateCopyWith<$Res> implements $StudySessionStateCopyWith<$Res> {
  factory _$StudySessionStateCopyWith(_StudySessionState value, $Res Function(_StudySessionState) _then) = __$StudySessionStateCopyWithImpl;
@override @useResult
$Res call({
 String deckId, List<CardModel> queue, CardModel? currentCard, bool isFlipped, int completedCount, int initialCount, bool isFinished, List<StudySessionSnapshot> history, DateTime? cardPresentedAt
});




}
/// @nodoc
class __$StudySessionStateCopyWithImpl<$Res>
    implements _$StudySessionStateCopyWith<$Res> {
  __$StudySessionStateCopyWithImpl(this._self, this._then);

  final _StudySessionState _self;
  final $Res Function(_StudySessionState) _then;

/// Create a copy of StudySessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deckId = null,Object? queue = null,Object? currentCard = freezed,Object? isFlipped = null,Object? completedCount = null,Object? initialCount = null,Object? isFinished = null,Object? history = null,Object? cardPresentedAt = freezed,}) {
  return _then(_StudySessionState(
deckId: null == deckId ? _self.deckId : deckId // ignore: cast_nullable_to_non_nullable
as String,queue: null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<CardModel>,currentCard: freezed == currentCard ? _self.currentCard : currentCard // ignore: cast_nullable_to_non_nullable
as CardModel?,isFlipped: null == isFlipped ? _self.isFlipped : isFlipped // ignore: cast_nullable_to_non_nullable
as bool,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,initialCount: null == initialCount ? _self.initialCount : initialCount // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,history: null == history ? _self._history : history // ignore: cast_nullable_to_non_nullable
as List<StudySessionSnapshot>,cardPresentedAt: freezed == cardPresentedAt ? _self.cardPresentedAt : cardPresentedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
