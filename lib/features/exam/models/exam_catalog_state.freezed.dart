// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_catalog_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExamCatalogState {

 bool get isLoading; List<ExamPaperModel> get papers; ExamCategory? get selectedCategory; String? get selectedLevel; String? get error;
/// Create a copy of ExamCatalogState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamCatalogStateCopyWith<ExamCatalogState> get copyWith => _$ExamCatalogStateCopyWithImpl<ExamCatalogState>(this as ExamCatalogState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExamCatalogState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamCatalogState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&const DeepCollectionEquality().equals(other.papers, _this.papers)&&(identical(other.selectedCategory, _this.selectedCategory) || other.selectedCategory == _this.selectedCategory)&&(identical(other.selectedLevel, _this.selectedLevel) || other.selectedLevel == _this.selectedLevel)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ExamCatalogState;
  return Object.hash(runtimeType,_this.isLoading,const DeepCollectionEquality().hash(_this.papers),_this.selectedCategory,_this.selectedLevel,_this.error);
}

@override
String toString() {
  final _this = this as ExamCatalogState;
  return 'ExamCatalogState(isLoading: ${_this.isLoading}, papers: ${_this.papers}, selectedCategory: ${_this.selectedCategory}, selectedLevel: ${_this.selectedLevel}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ExamCatalogStateCopyWith<$Res>  {
  factory $ExamCatalogStateCopyWith(ExamCatalogState value, $Res Function(ExamCatalogState) _then) = _$ExamCatalogStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, List<ExamPaperModel> papers, ExamCategory? selectedCategory, String? selectedLevel, String? error
});




}
/// @nodoc
class _$ExamCatalogStateCopyWithImpl<$Res>
    implements $ExamCatalogStateCopyWith<$Res> {
  _$ExamCatalogStateCopyWithImpl(this._self, this._then);

  final ExamCatalogState _self;
  final $Res Function(ExamCatalogState) _then;

/// Create a copy of ExamCatalogState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? papers = null,Object? selectedCategory = freezed,Object? selectedLevel = freezed,Object? error = freezed,}) {
  return _then(ExamCatalogState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,papers: null == papers ? _self.papers : papers // ignore: cast_nullable_to_non_nullable
as List<ExamPaperModel>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as ExamCategory?,selectedLevel: freezed == selectedLevel ? _self.selectedLevel : selectedLevel // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamCatalogState].
extension ExamCatalogStatePatterns on ExamCatalogState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamCatalogState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamCatalogState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamCatalogState value)  $default,){
final _that = this;
switch (_that) {
case _ExamCatalogState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamCatalogState value)?  $default,){
final _that = this;
switch (_that) {
case _ExamCatalogState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  List<ExamPaperModel> papers,  ExamCategory? selectedCategory,  String? selectedLevel,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamCatalogState() when $default != null:
return $default(_that.isLoading,_that.papers,_that.selectedCategory,_that.selectedLevel,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  List<ExamPaperModel> papers,  ExamCategory? selectedCategory,  String? selectedLevel,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ExamCatalogState():
return $default(_that.isLoading,_that.papers,_that.selectedCategory,_that.selectedLevel,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  List<ExamPaperModel> papers,  ExamCategory? selectedCategory,  String? selectedLevel,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ExamCatalogState() when $default != null:
return $default(_that.isLoading,_that.papers,_that.selectedCategory,_that.selectedLevel,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ExamCatalogState extends ExamCatalogState {
  const _ExamCatalogState({this.isLoading = false,  List<ExamPaperModel> papers = const [], this.selectedCategory, this.selectedLevel, this.error}): _papers = papers,super._();
  

@override@JsonKey() final  bool isLoading;
 final  List<ExamPaperModel> _papers;
@override@JsonKey() List<ExamPaperModel> get papers {
  if (_papers is EqualUnmodifiableListView) return _papers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_papers);
}

@override final  ExamCategory? selectedCategory;
@override final  String? selectedLevel;
@override final  String? error;

/// Create a copy of ExamCatalogState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamCatalogStateCopyWith<_ExamCatalogState> get copyWith => __$ExamCatalogStateCopyWithImpl<_ExamCatalogState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamCatalogState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&const DeepCollectionEquality().equals(other.papers, _papers)&&(identical(other.selectedCategory, selectedCategory) || other.selectedCategory == selectedCategory)&&(identical(other.selectedLevel, selectedLevel) || other.selectedLevel == selectedLevel)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,const DeepCollectionEquality().hash(_papers),selectedCategory,selectedLevel,error);
}

@override
String toString() {
    return 'ExamCatalogState(isLoading: $isLoading, papers: $papers, selectedCategory: $selectedCategory, selectedLevel: $selectedLevel, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ExamCatalogStateCopyWith<$Res> implements $ExamCatalogStateCopyWith<$Res> {
  factory _$ExamCatalogStateCopyWith(_ExamCatalogState value, $Res Function(_ExamCatalogState) _then) = __$ExamCatalogStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, List<ExamPaperModel> papers, ExamCategory? selectedCategory, String? selectedLevel, String? error
});




}
/// @nodoc
class __$ExamCatalogStateCopyWithImpl<$Res>
    implements _$ExamCatalogStateCopyWith<$Res> {
  __$ExamCatalogStateCopyWithImpl(this._self, this._then);

  final _ExamCatalogState _self;
  final $Res Function(_ExamCatalogState) _then;

/// Create a copy of ExamCatalogState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? papers = null,Object? selectedCategory = freezed,Object? selectedLevel = freezed,Object? error = freezed,}) {
  return _then(_ExamCatalogState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,papers: null == papers ? _self._papers : papers // ignore: cast_nullable_to_non_nullable
as List<ExamPaperModel>,selectedCategory: freezed == selectedCategory ? _self.selectedCategory : selectedCategory // ignore: cast_nullable_to_non_nullable
as ExamCategory?,selectedLevel: freezed == selectedLevel ? _self.selectedLevel : selectedLevel // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
