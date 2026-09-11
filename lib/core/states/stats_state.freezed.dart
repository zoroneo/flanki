// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StatsData {

 double get retentionRate; int get reviewedToday; int get totalReviews; int get studyTimeMinutes; int get streakDays; List<List<int>> get heatmapLevels;
/// Create a copy of StatsData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsDataCopyWith<StatsData> get copyWith => _$StatsDataCopyWithImpl<StatsData>(this as StatsData, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as StatsData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsData&&(identical(other.retentionRate, _this.retentionRate) || other.retentionRate == _this.retentionRate)&&(identical(other.reviewedToday, _this.reviewedToday) || other.reviewedToday == _this.reviewedToday)&&(identical(other.totalReviews, _this.totalReviews) || other.totalReviews == _this.totalReviews)&&(identical(other.studyTimeMinutes, _this.studyTimeMinutes) || other.studyTimeMinutes == _this.studyTimeMinutes)&&(identical(other.streakDays, _this.streakDays) || other.streakDays == _this.streakDays)&&const DeepCollectionEquality().equals(other.heatmapLevels, _this.heatmapLevels));
}


@override
int get hashCode {
  final _this = this as StatsData;
  return Object.hash(runtimeType,_this.retentionRate,_this.reviewedToday,_this.totalReviews,_this.studyTimeMinutes,_this.streakDays,const DeepCollectionEquality().hash(_this.heatmapLevels));
}

@override
String toString() {
  final _this = this as StatsData;
  return 'StatsData(retentionRate: ${_this.retentionRate}, reviewedToday: ${_this.reviewedToday}, totalReviews: ${_this.totalReviews}, studyTimeMinutes: ${_this.studyTimeMinutes}, streakDays: ${_this.streakDays}, heatmapLevels: ${_this.heatmapLevels})';
}


}

/// @nodoc
abstract mixin class $StatsDataCopyWith<$Res>  {
  factory $StatsDataCopyWith(StatsData value, $Res Function(StatsData) _then) = _$StatsDataCopyWithImpl;
@useResult
$Res call({
 double retentionRate, int reviewedToday, int totalReviews, int studyTimeMinutes, int streakDays, List<List<int>> heatmapLevels
});




}
/// @nodoc
class _$StatsDataCopyWithImpl<$Res>
    implements $StatsDataCopyWith<$Res> {
  _$StatsDataCopyWithImpl(this._self, this._then);

  final StatsData _self;
  final $Res Function(StatsData) _then;

/// Create a copy of StatsData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? retentionRate = null,Object? reviewedToday = null,Object? totalReviews = null,Object? studyTimeMinutes = null,Object? streakDays = null,Object? heatmapLevels = null,}) {
  return _then(StatsData(
retentionRate: null == retentionRate ? _self.retentionRate : retentionRate // ignore: cast_nullable_to_non_nullable
as double,reviewedToday: null == reviewedToday ? _self.reviewedToday : reviewedToday // ignore: cast_nullable_to_non_nullable
as int,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,studyTimeMinutes: null == studyTimeMinutes ? _self.studyTimeMinutes : studyTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,heatmapLevels: null == heatmapLevels ? _self.heatmapLevels : heatmapLevels // ignore: cast_nullable_to_non_nullable
as List<List<int>>,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsData].
extension StatsDataPatterns on StatsData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsData value)  $default,){
final _that = this;
switch (_that) {
case _StatsData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsData value)?  $default,){
final _that = this;
switch (_that) {
case _StatsData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double retentionRate,  int reviewedToday,  int totalReviews,  int studyTimeMinutes,  int streakDays,  List<List<int>> heatmapLevels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsData() when $default != null:
return $default(_that.retentionRate,_that.reviewedToday,_that.totalReviews,_that.studyTimeMinutes,_that.streakDays,_that.heatmapLevels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double retentionRate,  int reviewedToday,  int totalReviews,  int studyTimeMinutes,  int streakDays,  List<List<int>> heatmapLevels)  $default,) {final _that = this;
switch (_that) {
case _StatsData():
return $default(_that.retentionRate,_that.reviewedToday,_that.totalReviews,_that.studyTimeMinutes,_that.streakDays,_that.heatmapLevels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double retentionRate,  int reviewedToday,  int totalReviews,  int studyTimeMinutes,  int streakDays,  List<List<int>> heatmapLevels)?  $default,) {final _that = this;
switch (_that) {
case _StatsData() when $default != null:
return $default(_that.retentionRate,_that.reviewedToday,_that.totalReviews,_that.studyTimeMinutes,_that.streakDays,_that.heatmapLevels);case _:
  return null;

}
}

}

/// @nodoc


class _StatsData extends StatsData {
  const _StatsData({required this.retentionRate, required this.reviewedToday, required this.totalReviews, required this.studyTimeMinutes, required this.streakDays, required  List<List<int>> heatmapLevels}): _heatmapLevels = heatmapLevels,super._();
  

@override final  double retentionRate;
@override final  int reviewedToday;
@override final  int totalReviews;
@override final  int studyTimeMinutes;
@override final  int streakDays;
 final  List<List<int>> _heatmapLevels;
@override List<List<int>> get heatmapLevels {
  if (_heatmapLevels is EqualUnmodifiableListView) return _heatmapLevels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_heatmapLevels);
}


/// Create a copy of StatsData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsDataCopyWith<_StatsData> get copyWith => __$StatsDataCopyWithImpl<_StatsData>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsData&&(identical(other.retentionRate, retentionRate) || other.retentionRate == retentionRate)&&(identical(other.reviewedToday, reviewedToday) || other.reviewedToday == reviewedToday)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.studyTimeMinutes, studyTimeMinutes) || other.studyTimeMinutes == studyTimeMinutes)&&(identical(other.streakDays, streakDays) || other.streakDays == streakDays)&&const DeepCollectionEquality().equals(other.heatmapLevels, _heatmapLevels));
}


@override
int get hashCode {
    return Object.hash(runtimeType,retentionRate,reviewedToday,totalReviews,studyTimeMinutes,streakDays,const DeepCollectionEquality().hash(_heatmapLevels));
}

@override
String toString() {
    return 'StatsData(retentionRate: $retentionRate, reviewedToday: $reviewedToday, totalReviews: $totalReviews, studyTimeMinutes: $studyTimeMinutes, streakDays: $streakDays, heatmapLevels: $heatmapLevels)';
}


}

/// @nodoc
abstract mixin class _$StatsDataCopyWith<$Res> implements $StatsDataCopyWith<$Res> {
  factory _$StatsDataCopyWith(_StatsData value, $Res Function(_StatsData) _then) = __$StatsDataCopyWithImpl;
@override @useResult
$Res call({
 double retentionRate, int reviewedToday, int totalReviews, int studyTimeMinutes, int streakDays, List<List<int>> heatmapLevels
});




}
/// @nodoc
class __$StatsDataCopyWithImpl<$Res>
    implements _$StatsDataCopyWith<$Res> {
  __$StatsDataCopyWithImpl(this._self, this._then);

  final _StatsData _self;
  final $Res Function(_StatsData) _then;

/// Create a copy of StatsData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? retentionRate = null,Object? reviewedToday = null,Object? totalReviews = null,Object? studyTimeMinutes = null,Object? streakDays = null,Object? heatmapLevels = null,}) {
  return _then(_StatsData(
retentionRate: null == retentionRate ? _self.retentionRate : retentionRate // ignore: cast_nullable_to_non_nullable
as double,reviewedToday: null == reviewedToday ? _self.reviewedToday : reviewedToday // ignore: cast_nullable_to_non_nullable
as int,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,studyTimeMinutes: null == studyTimeMinutes ? _self.studyTimeMinutes : studyTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,streakDays: null == streakDays ? _self.streakDays : streakDays // ignore: cast_nullable_to_non_nullable
as int,heatmapLevels: null == heatmapLevels ? _self._heatmapLevels : heatmapLevels // ignore: cast_nullable_to_non_nullable
as List<List<int>>,
  ));
}


}

// dart format on
