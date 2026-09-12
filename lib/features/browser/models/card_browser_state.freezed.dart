// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_browser_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CardBrowserState {

 List<CardModel> get allCards; String get searchQuery; CardFilterType get filterType; String? get selectedDeckId;
/// Create a copy of CardBrowserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardBrowserStateCopyWith<CardBrowserState> get copyWith => _$CardBrowserStateCopyWithImpl<CardBrowserState>(this as CardBrowserState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CardBrowserState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardBrowserState&&const DeepCollectionEquality().equals(other.allCards, _this.allCards)&&(identical(other.searchQuery, _this.searchQuery) || other.searchQuery == _this.searchQuery)&&(identical(other.filterType, _this.filterType) || other.filterType == _this.filterType)&&(identical(other.selectedDeckId, _this.selectedDeckId) || other.selectedDeckId == _this.selectedDeckId));
}


@override
int get hashCode {
  final _this = this as CardBrowserState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.allCards),_this.searchQuery,_this.filterType,_this.selectedDeckId);
}

@override
String toString() {
  final _this = this as CardBrowserState;
  return 'CardBrowserState(allCards: ${_this.allCards}, searchQuery: ${_this.searchQuery}, filterType: ${_this.filterType}, selectedDeckId: ${_this.selectedDeckId})';
}


}

/// @nodoc
abstract mixin class $CardBrowserStateCopyWith<$Res>  {
  factory $CardBrowserStateCopyWith(CardBrowserState value, $Res Function(CardBrowserState) _then) = _$CardBrowserStateCopyWithImpl;
@useResult
$Res call({
 List<CardModel> allCards, String searchQuery, CardFilterType filterType, String? selectedDeckId
});




}
/// @nodoc
class _$CardBrowserStateCopyWithImpl<$Res>
    implements $CardBrowserStateCopyWith<$Res> {
  _$CardBrowserStateCopyWithImpl(this._self, this._then);

  final CardBrowserState _self;
  final $Res Function(CardBrowserState) _then;

/// Create a copy of CardBrowserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? allCards = null,Object? searchQuery = null,Object? filterType = null,Object? selectedDeckId = freezed,}) {
  return _then(CardBrowserState(
allCards: null == allCards ? _self.allCards : allCards // ignore: cast_nullable_to_non_nullable
as List<CardModel>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,filterType: null == filterType ? _self.filterType : filterType // ignore: cast_nullable_to_non_nullable
as CardFilterType,selectedDeckId: freezed == selectedDeckId ? _self.selectedDeckId : selectedDeckId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CardBrowserState].
extension CardBrowserStatePatterns on CardBrowserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardBrowserState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardBrowserState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardBrowserState value)  $default,){
final _that = this;
switch (_that) {
case _CardBrowserState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardBrowserState value)?  $default,){
final _that = this;
switch (_that) {
case _CardBrowserState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CardModel> allCards,  String searchQuery,  CardFilterType filterType,  String? selectedDeckId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardBrowserState() when $default != null:
return $default(_that.allCards,_that.searchQuery,_that.filterType,_that.selectedDeckId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CardModel> allCards,  String searchQuery,  CardFilterType filterType,  String? selectedDeckId)  $default,) {final _that = this;
switch (_that) {
case _CardBrowserState():
return $default(_that.allCards,_that.searchQuery,_that.filterType,_that.selectedDeckId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CardModel> allCards,  String searchQuery,  CardFilterType filterType,  String? selectedDeckId)?  $default,) {final _that = this;
switch (_that) {
case _CardBrowserState() when $default != null:
return $default(_that.allCards,_that.searchQuery,_that.filterType,_that.selectedDeckId);case _:
  return null;

}
}

}

/// @nodoc


class _CardBrowserState extends CardBrowserState {
  const _CardBrowserState({ List<CardModel> allCards = const [], this.searchQuery = '', this.filterType = CardFilterType.all, this.selectedDeckId}): _allCards = allCards,super._();
  

 final  List<CardModel> _allCards;
@override@JsonKey() List<CardModel> get allCards {
  if (_allCards is EqualUnmodifiableListView) return _allCards;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allCards);
}

@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  CardFilterType filterType;
@override final  String? selectedDeckId;

/// Create a copy of CardBrowserState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardBrowserStateCopyWith<_CardBrowserState> get copyWith => __$CardBrowserStateCopyWithImpl<_CardBrowserState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardBrowserState&&const DeepCollectionEquality().equals(other.allCards, _allCards)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.filterType, filterType) || other.filterType == filterType)&&(identical(other.selectedDeckId, selectedDeckId) || other.selectedDeckId == selectedDeckId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_allCards),searchQuery,filterType,selectedDeckId);
}

@override
String toString() {
    return 'CardBrowserState(allCards: $allCards, searchQuery: $searchQuery, filterType: $filterType, selectedDeckId: $selectedDeckId)';
}


}

/// @nodoc
abstract mixin class _$CardBrowserStateCopyWith<$Res> implements $CardBrowserStateCopyWith<$Res> {
  factory _$CardBrowserStateCopyWith(_CardBrowserState value, $Res Function(_CardBrowserState) _then) = __$CardBrowserStateCopyWithImpl;
@override @useResult
$Res call({
 List<CardModel> allCards, String searchQuery, CardFilterType filterType, String? selectedDeckId
});




}
/// @nodoc
class __$CardBrowserStateCopyWithImpl<$Res>
    implements _$CardBrowserStateCopyWith<$Res> {
  __$CardBrowserStateCopyWithImpl(this._self, this._then);

  final _CardBrowserState _self;
  final $Res Function(_CardBrowserState) _then;

/// Create a copy of CardBrowserState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? allCards = null,Object? searchQuery = null,Object? filterType = null,Object? selectedDeckId = freezed,}) {
  return _then(_CardBrowserState(
allCards: null == allCards ? _self._allCards : allCards // ignore: cast_nullable_to_non_nullable
as List<CardModel>,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,filterType: null == filterType ? _self.filterType : filterType // ignore: cast_nullable_to_non_nullable
as CardFilterType,selectedDeckId: freezed == selectedDeckId ? _self.selectedDeckId : selectedDeckId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
