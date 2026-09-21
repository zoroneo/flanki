// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StudySettings {

 bool get fsrsEnabled; double get desiredRetention; int get newCardsPerDay; int get maxReviewsPerDay; bool get reminderEnabled; int get reminderHour; int get reminderMinute; bool get streakSaverEnabled; bool get minimizeToTrayOnClose; bool get launchAtStartup;
/// Create a copy of StudySettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StudySettingsCopyWith<StudySettings> get copyWith => _$StudySettingsCopyWithImpl<StudySettings>(this as StudySettings, _$identity);

  /// Serializes this StudySettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StudySettings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StudySettings&&(identical(other.fsrsEnabled, _this.fsrsEnabled) || other.fsrsEnabled == _this.fsrsEnabled)&&(identical(other.desiredRetention, _this.desiredRetention) || other.desiredRetention == _this.desiredRetention)&&(identical(other.newCardsPerDay, _this.newCardsPerDay) || other.newCardsPerDay == _this.newCardsPerDay)&&(identical(other.maxReviewsPerDay, _this.maxReviewsPerDay) || other.maxReviewsPerDay == _this.maxReviewsPerDay)&&(identical(other.reminderEnabled, _this.reminderEnabled) || other.reminderEnabled == _this.reminderEnabled)&&(identical(other.reminderHour, _this.reminderHour) || other.reminderHour == _this.reminderHour)&&(identical(other.reminderMinute, _this.reminderMinute) || other.reminderMinute == _this.reminderMinute)&&(identical(other.streakSaverEnabled, _this.streakSaverEnabled) || other.streakSaverEnabled == _this.streakSaverEnabled)&&(identical(other.minimizeToTrayOnClose, _this.minimizeToTrayOnClose) || other.minimizeToTrayOnClose == _this.minimizeToTrayOnClose)&&(identical(other.launchAtStartup, _this.launchAtStartup) || other.launchAtStartup == _this.launchAtStartup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StudySettings;
  return Object.hash(runtimeType,_this.fsrsEnabled,_this.desiredRetention,_this.newCardsPerDay,_this.maxReviewsPerDay,_this.reminderEnabled,_this.reminderHour,_this.reminderMinute,_this.streakSaverEnabled,_this.minimizeToTrayOnClose,_this.launchAtStartup);
}

@override
String toString() {
  final _this = this as StudySettings;
  return 'StudySettings(fsrsEnabled: ${_this.fsrsEnabled}, desiredRetention: ${_this.desiredRetention}, newCardsPerDay: ${_this.newCardsPerDay}, maxReviewsPerDay: ${_this.maxReviewsPerDay}, reminderEnabled: ${_this.reminderEnabled}, reminderHour: ${_this.reminderHour}, reminderMinute: ${_this.reminderMinute}, streakSaverEnabled: ${_this.streakSaverEnabled}, minimizeToTrayOnClose: ${_this.minimizeToTrayOnClose}, launchAtStartup: ${_this.launchAtStartup})';
}


}

/// @nodoc
abstract mixin class $StudySettingsCopyWith<$Res>  {
  factory $StudySettingsCopyWith(StudySettings value, $Res Function(StudySettings) _then) = _$StudySettingsCopyWithImpl;
@useResult
$Res call({
 bool fsrsEnabled, double desiredRetention, int newCardsPerDay, int maxReviewsPerDay, bool reminderEnabled, int reminderHour, int reminderMinute, bool streakSaverEnabled, bool minimizeToTrayOnClose, bool launchAtStartup
});




}
/// @nodoc
class _$StudySettingsCopyWithImpl<$Res>
    implements $StudySettingsCopyWith<$Res> {
  _$StudySettingsCopyWithImpl(this._self, this._then);

  final StudySettings _self;
  final $Res Function(StudySettings) _then;

/// Create a copy of StudySettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fsrsEnabled = null,Object? desiredRetention = null,Object? newCardsPerDay = null,Object? maxReviewsPerDay = null,Object? reminderEnabled = null,Object? reminderHour = null,Object? reminderMinute = null,Object? streakSaverEnabled = null,Object? minimizeToTrayOnClose = null,Object? launchAtStartup = null,}) {
  return _then(StudySettings(
fsrsEnabled: null == fsrsEnabled ? _self.fsrsEnabled : fsrsEnabled // ignore: cast_nullable_to_non_nullable
as bool,desiredRetention: null == desiredRetention ? _self.desiredRetention : desiredRetention // ignore: cast_nullable_to_non_nullable
as double,newCardsPerDay: null == newCardsPerDay ? _self.newCardsPerDay : newCardsPerDay // ignore: cast_nullable_to_non_nullable
as int,maxReviewsPerDay: null == maxReviewsPerDay ? _self.maxReviewsPerDay : maxReviewsPerDay // ignore: cast_nullable_to_non_nullable
as int,reminderEnabled: null == reminderEnabled ? _self.reminderEnabled : reminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,streakSaverEnabled: null == streakSaverEnabled ? _self.streakSaverEnabled : streakSaverEnabled // ignore: cast_nullable_to_non_nullable
as bool,minimizeToTrayOnClose: null == minimizeToTrayOnClose ? _self.minimizeToTrayOnClose : minimizeToTrayOnClose // ignore: cast_nullable_to_non_nullable
as bool,launchAtStartup: null == launchAtStartup ? _self.launchAtStartup : launchAtStartup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StudySettings].
extension StudySettingsPatterns on StudySettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StudySettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StudySettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StudySettings value)  $default,){
final _that = this;
switch (_that) {
case _StudySettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StudySettings value)?  $default,){
final _that = this;
switch (_that) {
case _StudySettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool fsrsEnabled,  double desiredRetention,  int newCardsPerDay,  int maxReviewsPerDay,  bool reminderEnabled,  int reminderHour,  int reminderMinute,  bool streakSaverEnabled,  bool minimizeToTrayOnClose,  bool launchAtStartup)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StudySettings() when $default != null:
return $default(_that.fsrsEnabled,_that.desiredRetention,_that.newCardsPerDay,_that.maxReviewsPerDay,_that.reminderEnabled,_that.reminderHour,_that.reminderMinute,_that.streakSaverEnabled,_that.minimizeToTrayOnClose,_that.launchAtStartup);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool fsrsEnabled,  double desiredRetention,  int newCardsPerDay,  int maxReviewsPerDay,  bool reminderEnabled,  int reminderHour,  int reminderMinute,  bool streakSaverEnabled,  bool minimizeToTrayOnClose,  bool launchAtStartup)  $default,) {final _that = this;
switch (_that) {
case _StudySettings():
return $default(_that.fsrsEnabled,_that.desiredRetention,_that.newCardsPerDay,_that.maxReviewsPerDay,_that.reminderEnabled,_that.reminderHour,_that.reminderMinute,_that.streakSaverEnabled,_that.minimizeToTrayOnClose,_that.launchAtStartup);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool fsrsEnabled,  double desiredRetention,  int newCardsPerDay,  int maxReviewsPerDay,  bool reminderEnabled,  int reminderHour,  int reminderMinute,  bool streakSaverEnabled,  bool minimizeToTrayOnClose,  bool launchAtStartup)?  $default,) {final _that = this;
switch (_that) {
case _StudySettings() when $default != null:
return $default(_that.fsrsEnabled,_that.desiredRetention,_that.newCardsPerDay,_that.maxReviewsPerDay,_that.reminderEnabled,_that.reminderHour,_that.reminderMinute,_that.streakSaverEnabled,_that.minimizeToTrayOnClose,_that.launchAtStartup);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StudySettings extends StudySettings {
  const _StudySettings({this.fsrsEnabled = true, this.desiredRetention = AppConfig.defaultDesiredRetention, this.newCardsPerDay = AppConfig.defaultNewCardsPerDay, this.maxReviewsPerDay = AppConfig.defaultReviewsPerDay, this.reminderEnabled = true, this.reminderHour = AppConfig.defaultReminderHour, this.reminderMinute = AppConfig.defaultReminderMinute, this.streakSaverEnabled = true, this.minimizeToTrayOnClose = true, this.launchAtStartup = false}): super._();
  factory _StudySettings.fromJson(Map<String, dynamic> json) => _$StudySettingsFromJson(json);

@override@JsonKey() final  bool fsrsEnabled;
@override@JsonKey() final  double desiredRetention;
@override@JsonKey() final  int newCardsPerDay;
@override@JsonKey() final  int maxReviewsPerDay;
@override@JsonKey() final  bool reminderEnabled;
@override@JsonKey() final  int reminderHour;
@override@JsonKey() final  int reminderMinute;
@override@JsonKey() final  bool streakSaverEnabled;
@override@JsonKey() final  bool minimizeToTrayOnClose;
@override@JsonKey() final  bool launchAtStartup;

/// Create a copy of StudySettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StudySettingsCopyWith<_StudySettings> get copyWith => __$StudySettingsCopyWithImpl<_StudySettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StudySettingsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StudySettings&&(identical(other.fsrsEnabled, fsrsEnabled) || other.fsrsEnabled == fsrsEnabled)&&(identical(other.desiredRetention, desiredRetention) || other.desiredRetention == desiredRetention)&&(identical(other.newCardsPerDay, newCardsPerDay) || other.newCardsPerDay == newCardsPerDay)&&(identical(other.maxReviewsPerDay, maxReviewsPerDay) || other.maxReviewsPerDay == maxReviewsPerDay)&&(identical(other.reminderEnabled, reminderEnabled) || other.reminderEnabled == reminderEnabled)&&(identical(other.reminderHour, reminderHour) || other.reminderHour == reminderHour)&&(identical(other.reminderMinute, reminderMinute) || other.reminderMinute == reminderMinute)&&(identical(other.streakSaverEnabled, streakSaverEnabled) || other.streakSaverEnabled == streakSaverEnabled)&&(identical(other.minimizeToTrayOnClose, minimizeToTrayOnClose) || other.minimizeToTrayOnClose == minimizeToTrayOnClose)&&(identical(other.launchAtStartup, launchAtStartup) || other.launchAtStartup == launchAtStartup));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,fsrsEnabled,desiredRetention,newCardsPerDay,maxReviewsPerDay,reminderEnabled,reminderHour,reminderMinute,streakSaverEnabled,minimizeToTrayOnClose,launchAtStartup);
}

@override
String toString() {
    return 'StudySettings(fsrsEnabled: $fsrsEnabled, desiredRetention: $desiredRetention, newCardsPerDay: $newCardsPerDay, maxReviewsPerDay: $maxReviewsPerDay, reminderEnabled: $reminderEnabled, reminderHour: $reminderHour, reminderMinute: $reminderMinute, streakSaverEnabled: $streakSaverEnabled, minimizeToTrayOnClose: $minimizeToTrayOnClose, launchAtStartup: $launchAtStartup)';
}


}

/// @nodoc
abstract mixin class _$StudySettingsCopyWith<$Res> implements $StudySettingsCopyWith<$Res> {
  factory _$StudySettingsCopyWith(_StudySettings value, $Res Function(_StudySettings) _then) = __$StudySettingsCopyWithImpl;
@override @useResult
$Res call({
 bool fsrsEnabled, double desiredRetention, int newCardsPerDay, int maxReviewsPerDay, bool reminderEnabled, int reminderHour, int reminderMinute, bool streakSaverEnabled, bool minimizeToTrayOnClose, bool launchAtStartup
});




}
/// @nodoc
class __$StudySettingsCopyWithImpl<$Res>
    implements _$StudySettingsCopyWith<$Res> {
  __$StudySettingsCopyWithImpl(this._self, this._then);

  final _StudySettings _self;
  final $Res Function(_StudySettings) _then;

/// Create a copy of StudySettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fsrsEnabled = null,Object? desiredRetention = null,Object? newCardsPerDay = null,Object? maxReviewsPerDay = null,Object? reminderEnabled = null,Object? reminderHour = null,Object? reminderMinute = null,Object? streakSaverEnabled = null,Object? minimizeToTrayOnClose = null,Object? launchAtStartup = null,}) {
  return _then(_StudySettings(
fsrsEnabled: null == fsrsEnabled ? _self.fsrsEnabled : fsrsEnabled // ignore: cast_nullable_to_non_nullable
as bool,desiredRetention: null == desiredRetention ? _self.desiredRetention : desiredRetention // ignore: cast_nullable_to_non_nullable
as double,newCardsPerDay: null == newCardsPerDay ? _self.newCardsPerDay : newCardsPerDay // ignore: cast_nullable_to_non_nullable
as int,maxReviewsPerDay: null == maxReviewsPerDay ? _self.maxReviewsPerDay : maxReviewsPerDay // ignore: cast_nullable_to_non_nullable
as int,reminderEnabled: null == reminderEnabled ? _self.reminderEnabled : reminderEnabled // ignore: cast_nullable_to_non_nullable
as bool,reminderHour: null == reminderHour ? _self.reminderHour : reminderHour // ignore: cast_nullable_to_non_nullable
as int,reminderMinute: null == reminderMinute ? _self.reminderMinute : reminderMinute // ignore: cast_nullable_to_non_nullable
as int,streakSaverEnabled: null == streakSaverEnabled ? _self.streakSaverEnabled : streakSaverEnabled // ignore: cast_nullable_to_non_nullable
as bool,minimizeToTrayOnClose: null == minimizeToTrayOnClose ? _self.minimizeToTrayOnClose : minimizeToTrayOnClose // ignore: cast_nullable_to_non_nullable
as bool,launchAtStartup: null == launchAtStartup ? _self.launchAtStartup : launchAtStartup // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
