// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exam_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExamSessionState {

 bool get isLoading; ExamPaperModel? get paper; List<ExamSectionModel> get sections; List<ExamQuestionModel> get questions; int get currentIndex; Map<String, String> get selectedAnswers; Set<String> get flaggedQuestionIds; int get remainingSeconds; int get totalDurationSeconds; bool get isFinished; bool get isSubmitting; ExamSubmissionModel? get submission; List<WrongQuestionModel> get wrongQuestions; String? get error;
/// Create a copy of ExamSessionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExamSessionStateCopyWith<ExamSessionState> get copyWith => _$ExamSessionStateCopyWithImpl<ExamSessionState>(this as ExamSessionState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ExamSessionState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExamSessionState&&(identical(other.isLoading, _this.isLoading) || other.isLoading == _this.isLoading)&&(identical(other.paper, _this.paper) || other.paper == _this.paper)&&const DeepCollectionEquality().equals(other.sections, _this.sections)&&const DeepCollectionEquality().equals(other.questions, _this.questions)&&(identical(other.currentIndex, _this.currentIndex) || other.currentIndex == _this.currentIndex)&&const DeepCollectionEquality().equals(other.selectedAnswers, _this.selectedAnswers)&&const DeepCollectionEquality().equals(other.flaggedQuestionIds, _this.flaggedQuestionIds)&&(identical(other.remainingSeconds, _this.remainingSeconds) || other.remainingSeconds == _this.remainingSeconds)&&(identical(other.totalDurationSeconds, _this.totalDurationSeconds) || other.totalDurationSeconds == _this.totalDurationSeconds)&&(identical(other.isFinished, _this.isFinished) || other.isFinished == _this.isFinished)&&(identical(other.isSubmitting, _this.isSubmitting) || other.isSubmitting == _this.isSubmitting)&&(identical(other.submission, _this.submission) || other.submission == _this.submission)&&const DeepCollectionEquality().equals(other.wrongQuestions, _this.wrongQuestions)&&(identical(other.error, _this.error) || other.error == _this.error));
}


@override
int get hashCode {
  final _this = this as ExamSessionState;
  return Object.hash(runtimeType,_this.isLoading,_this.paper,const DeepCollectionEquality().hash(_this.sections),const DeepCollectionEquality().hash(_this.questions),_this.currentIndex,const DeepCollectionEquality().hash(_this.selectedAnswers),const DeepCollectionEquality().hash(_this.flaggedQuestionIds),_this.remainingSeconds,_this.totalDurationSeconds,_this.isFinished,_this.isSubmitting,_this.submission,const DeepCollectionEquality().hash(_this.wrongQuestions),_this.error);
}

@override
String toString() {
  final _this = this as ExamSessionState;
  return 'ExamSessionState(isLoading: ${_this.isLoading}, paper: ${_this.paper}, sections: ${_this.sections}, questions: ${_this.questions}, currentIndex: ${_this.currentIndex}, selectedAnswers: ${_this.selectedAnswers}, flaggedQuestionIds: ${_this.flaggedQuestionIds}, remainingSeconds: ${_this.remainingSeconds}, totalDurationSeconds: ${_this.totalDurationSeconds}, isFinished: ${_this.isFinished}, isSubmitting: ${_this.isSubmitting}, submission: ${_this.submission}, wrongQuestions: ${_this.wrongQuestions}, error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ExamSessionStateCopyWith<$Res>  {
  factory $ExamSessionStateCopyWith(ExamSessionState value, $Res Function(ExamSessionState) _then) = _$ExamSessionStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, ExamPaperModel? paper, List<ExamSectionModel> sections, List<ExamQuestionModel> questions, int currentIndex, Map<String, String> selectedAnswers, Set<String> flaggedQuestionIds, int remainingSeconds, int totalDurationSeconds, bool isFinished, bool isSubmitting, ExamSubmissionModel? submission, List<WrongQuestionModel> wrongQuestions, String? error
});




}
/// @nodoc
class _$ExamSessionStateCopyWithImpl<$Res>
    implements $ExamSessionStateCopyWith<$Res> {
  _$ExamSessionStateCopyWithImpl(this._self, this._then);

  final ExamSessionState _self;
  final $Res Function(ExamSessionState) _then;

/// Create a copy of ExamSessionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? paper = freezed,Object? sections = null,Object? questions = null,Object? currentIndex = null,Object? selectedAnswers = null,Object? flaggedQuestionIds = null,Object? remainingSeconds = null,Object? totalDurationSeconds = null,Object? isFinished = null,Object? isSubmitting = null,Object? submission = freezed,Object? wrongQuestions = null,Object? error = freezed,}) {
  return _then(ExamSessionState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,paper: freezed == paper ? _self.paper : paper // ignore: cast_nullable_to_non_nullable
as ExamPaperModel?,sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<ExamSectionModel>,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<ExamQuestionModel>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,selectedAnswers: null == selectedAnswers ? _self.selectedAnswers : selectedAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,flaggedQuestionIds: null == flaggedQuestionIds ? _self.flaggedQuestionIds : flaggedQuestionIds // ignore: cast_nullable_to_non_nullable
as Set<String>,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submission: freezed == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ExamSubmissionModel?,wrongQuestions: null == wrongQuestions ? _self.wrongQuestions : wrongQuestions // ignore: cast_nullable_to_non_nullable
as List<WrongQuestionModel>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExamSessionState].
extension ExamSessionStatePatterns on ExamSessionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExamSessionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExamSessionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExamSessionState value)  $default,){
final _that = this;
switch (_that) {
case _ExamSessionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExamSessionState value)?  $default,){
final _that = this;
switch (_that) {
case _ExamSessionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  ExamPaperModel? paper,  List<ExamSectionModel> sections,  List<ExamQuestionModel> questions,  int currentIndex,  Map<String, String> selectedAnswers,  Set<String> flaggedQuestionIds,  int remainingSeconds,  int totalDurationSeconds,  bool isFinished,  bool isSubmitting,  ExamSubmissionModel? submission,  List<WrongQuestionModel> wrongQuestions,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExamSessionState() when $default != null:
return $default(_that.isLoading,_that.paper,_that.sections,_that.questions,_that.currentIndex,_that.selectedAnswers,_that.flaggedQuestionIds,_that.remainingSeconds,_that.totalDurationSeconds,_that.isFinished,_that.isSubmitting,_that.submission,_that.wrongQuestions,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  ExamPaperModel? paper,  List<ExamSectionModel> sections,  List<ExamQuestionModel> questions,  int currentIndex,  Map<String, String> selectedAnswers,  Set<String> flaggedQuestionIds,  int remainingSeconds,  int totalDurationSeconds,  bool isFinished,  bool isSubmitting,  ExamSubmissionModel? submission,  List<WrongQuestionModel> wrongQuestions,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ExamSessionState():
return $default(_that.isLoading,_that.paper,_that.sections,_that.questions,_that.currentIndex,_that.selectedAnswers,_that.flaggedQuestionIds,_that.remainingSeconds,_that.totalDurationSeconds,_that.isFinished,_that.isSubmitting,_that.submission,_that.wrongQuestions,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  ExamPaperModel? paper,  List<ExamSectionModel> sections,  List<ExamQuestionModel> questions,  int currentIndex,  Map<String, String> selectedAnswers,  Set<String> flaggedQuestionIds,  int remainingSeconds,  int totalDurationSeconds,  bool isFinished,  bool isSubmitting,  ExamSubmissionModel? submission,  List<WrongQuestionModel> wrongQuestions,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ExamSessionState() when $default != null:
return $default(_that.isLoading,_that.paper,_that.sections,_that.questions,_that.currentIndex,_that.selectedAnswers,_that.flaggedQuestionIds,_that.remainingSeconds,_that.totalDurationSeconds,_that.isFinished,_that.isSubmitting,_that.submission,_that.wrongQuestions,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ExamSessionState extends ExamSessionState {
  const _ExamSessionState({this.isLoading = false, this.paper,  List<ExamSectionModel> sections = const [],  List<ExamQuestionModel> questions = const [], this.currentIndex = 0,  Map<String, String> selectedAnswers = const {},  Set<String> flaggedQuestionIds = const {}, this.remainingSeconds = 0, this.totalDurationSeconds = 0, this.isFinished = false, this.isSubmitting = false, this.submission,  List<WrongQuestionModel> wrongQuestions = const [], this.error}): _sections = sections,_questions = questions,_selectedAnswers = selectedAnswers,_flaggedQuestionIds = flaggedQuestionIds,_wrongQuestions = wrongQuestions,super._();
  

@override@JsonKey() final  bool isLoading;
@override final  ExamPaperModel? paper;
 final  List<ExamSectionModel> _sections;
@override@JsonKey() List<ExamSectionModel> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

 final  List<ExamQuestionModel> _questions;
@override@JsonKey() List<ExamQuestionModel> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

@override@JsonKey() final  int currentIndex;
 final  Map<String, String> _selectedAnswers;
@override@JsonKey() Map<String, String> get selectedAnswers {
  if (_selectedAnswers is EqualUnmodifiableMapView) return _selectedAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedAnswers);
}

 final  Set<String> _flaggedQuestionIds;
@override@JsonKey() Set<String> get flaggedQuestionIds {
  if (_flaggedQuestionIds is EqualUnmodifiableSetView) return _flaggedQuestionIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_flaggedQuestionIds);
}

@override@JsonKey() final  int remainingSeconds;
@override@JsonKey() final  int totalDurationSeconds;
@override@JsonKey() final  bool isFinished;
@override@JsonKey() final  bool isSubmitting;
@override final  ExamSubmissionModel? submission;
 final  List<WrongQuestionModel> _wrongQuestions;
@override@JsonKey() List<WrongQuestionModel> get wrongQuestions {
  if (_wrongQuestions is EqualUnmodifiableListView) return _wrongQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_wrongQuestions);
}

@override final  String? error;

/// Create a copy of ExamSessionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExamSessionStateCopyWith<_ExamSessionState> get copyWith => __$ExamSessionStateCopyWithImpl<_ExamSessionState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExamSessionState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.paper, paper) || other.paper == paper)&&const DeepCollectionEquality().equals(other.sections, _sections)&&const DeepCollectionEquality().equals(other.questions, _questions)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex)&&const DeepCollectionEquality().equals(other.selectedAnswers, _selectedAnswers)&&const DeepCollectionEquality().equals(other.flaggedQuestionIds, _flaggedQuestionIds)&&(identical(other.remainingSeconds, remainingSeconds) || other.remainingSeconds == remainingSeconds)&&(identical(other.totalDurationSeconds, totalDurationSeconds) || other.totalDurationSeconds == totalDurationSeconds)&&(identical(other.isFinished, isFinished) || other.isFinished == isFinished)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.submission, submission) || other.submission == submission)&&const DeepCollectionEquality().equals(other.wrongQuestions, _wrongQuestions)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode {
    return Object.hash(runtimeType,isLoading,paper,const DeepCollectionEquality().hash(_sections),const DeepCollectionEquality().hash(_questions),currentIndex,const DeepCollectionEquality().hash(_selectedAnswers),const DeepCollectionEquality().hash(_flaggedQuestionIds),remainingSeconds,totalDurationSeconds,isFinished,isSubmitting,submission,const DeepCollectionEquality().hash(_wrongQuestions),error);
}

@override
String toString() {
    return 'ExamSessionState(isLoading: $isLoading, paper: $paper, sections: $sections, questions: $questions, currentIndex: $currentIndex, selectedAnswers: $selectedAnswers, flaggedQuestionIds: $flaggedQuestionIds, remainingSeconds: $remainingSeconds, totalDurationSeconds: $totalDurationSeconds, isFinished: $isFinished, isSubmitting: $isSubmitting, submission: $submission, wrongQuestions: $wrongQuestions, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ExamSessionStateCopyWith<$Res> implements $ExamSessionStateCopyWith<$Res> {
  factory _$ExamSessionStateCopyWith(_ExamSessionState value, $Res Function(_ExamSessionState) _then) = __$ExamSessionStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, ExamPaperModel? paper, List<ExamSectionModel> sections, List<ExamQuestionModel> questions, int currentIndex, Map<String, String> selectedAnswers, Set<String> flaggedQuestionIds, int remainingSeconds, int totalDurationSeconds, bool isFinished, bool isSubmitting, ExamSubmissionModel? submission, List<WrongQuestionModel> wrongQuestions, String? error
});




}
/// @nodoc
class __$ExamSessionStateCopyWithImpl<$Res>
    implements _$ExamSessionStateCopyWith<$Res> {
  __$ExamSessionStateCopyWithImpl(this._self, this._then);

  final _ExamSessionState _self;
  final $Res Function(_ExamSessionState) _then;

/// Create a copy of ExamSessionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? paper = freezed,Object? sections = null,Object? questions = null,Object? currentIndex = null,Object? selectedAnswers = null,Object? flaggedQuestionIds = null,Object? remainingSeconds = null,Object? totalDurationSeconds = null,Object? isFinished = null,Object? isSubmitting = null,Object? submission = freezed,Object? wrongQuestions = null,Object? error = freezed,}) {
  return _then(_ExamSessionState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,paper: freezed == paper ? _self.paper : paper // ignore: cast_nullable_to_non_nullable
as ExamPaperModel?,sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<ExamSectionModel>,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<ExamQuestionModel>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,selectedAnswers: null == selectedAnswers ? _self._selectedAnswers : selectedAnswers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,flaggedQuestionIds: null == flaggedQuestionIds ? _self._flaggedQuestionIds : flaggedQuestionIds // ignore: cast_nullable_to_non_nullable
as Set<String>,remainingSeconds: null == remainingSeconds ? _self.remainingSeconds : remainingSeconds // ignore: cast_nullable_to_non_nullable
as int,totalDurationSeconds: null == totalDurationSeconds ? _self.totalDurationSeconds : totalDurationSeconds // ignore: cast_nullable_to_non_nullable
as int,isFinished: null == isFinished ? _self.isFinished : isFinished // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,submission: freezed == submission ? _self.submission : submission // ignore: cast_nullable_to_non_nullable
as ExamSubmissionModel?,wrongQuestions: null == wrongQuestions ? _self._wrongQuestions : wrongQuestions // ignore: cast_nullable_to_non_nullable
as List<WrongQuestionModel>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
