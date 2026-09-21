import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'exam_constants.dart';

export 'exam_constants.dart';

part 'exam_models.g.dart';

/// Categories of examinations supported by Flanki.
@JsonEnum()
enum ExamCategory {
  @JsonValue('JLPT')
  jlpt('JLPT', 'Japanese Language Proficiency Test'),
  @JsonValue('TOEIC')
  toeic('TOEIC', 'Test of English for International Communication'),
  @JsonValue('THPTQG')
  thptqg('THPTQG', 'National High School Graduation Exam'),
  @JsonValue('GRAMMAR')
  grammarTest('GRAMMAR', 'Comprehensive Grammar Test'),
  @JsonValue('CUSTOM')
  custom('CUSTOM', 'Custom Exam');

  final String code;
  final String label;

  const ExamCategory(this.code, this.label);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExamCategory.jlpt:
        return l10n.examCategoryJlpt;
      case ExamCategory.toeic:
        return l10n.examCategoryToeic;
      case ExamCategory.thptqg:
        return l10n.examCategoryThptqg;
      case ExamCategory.grammarTest:
        return l10n.examCategoryGrammarTest;
      case ExamCategory.custom:
        return l10n.examCategoryCustom;
    }
  }

  static ExamCategory fromString(String? val) {
    if (val == null) return ExamCategory.jlpt;
    final upper = val.toUpperCase();
    for (final cat in ExamCategory.values) {
      if (cat.name.toUpperCase() == upper || cat.code == upper) {
        return cat;
      }
    }
    return ExamCategory.jlpt;
  }
}

/// Fallback helper for createdAt / updatedAt parsing in JSON models
DateTime _dateTimeFromJson(Object? val) {
  if (val is String && val.isNotEmpty) {
    return DateTime.tryParse(val) ?? DateTime.now();
  }
  return DateTime.now();
}

String _dateTimeToJson(DateTime dt) => dt.toIso8601String();

Object? _readOptions(Map json, String key) =>
    json['options_json'] ?? json['options'];

Object? _readAnswers(Map json, String key) =>
    json['answers_json'] ?? json['answers'];

/// Converts list of ExamQuestionOptions from List or raw JSON String
class ExamOptionsConverter
    implements JsonConverter<List<ExamQuestionOption>, Object?> {
  const ExamOptionsConverter();

  @override
  List<ExamQuestionOption> fromJson(Object? json) {
    if (json is List) {
      return json
          .map(
            (e) => ExamQuestionOption.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } else if (json is String && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is List) {
          return decoded
              .map(
                (e) => ExamQuestionOption.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
      } catch (_) {}
    }
    return const [];
  }

  @override
  Object? toJson(List<ExamQuestionOption> object) =>
      object.map((o) => o.toJson()).toList();
}

/// Converts answers map from Map or raw JSON String
class ExamAnswersConverter
    implements JsonConverter<Map<String, String>, Object?> {
  const ExamAnswersConverter();

  @override
  Map<String, String> fromJson(Object? json) {
    if (json is Map) {
      return json.map((k, v) => MapEntry(k.toString(), v.toString()));
    } else if (json is String && json.isNotEmpty) {
      try {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {}
    }
    return const {};
  }

  @override
  Object? toJson(Map<String, String> object) => object;
}

/// Metadata describing an Exam Paper in the catalog.
@JsonSerializable(fieldRename: FieldRename.snake)
class ExamPaperModel {
  final String id;
  @JsonKey(defaultValue: ExamConstants.defaultExamTitle)
  final String title;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(unknownEnumValue: ExamCategory.jlpt)
  final ExamCategory category;
  @JsonKey(defaultValue: ExamConstants.defaultExamLevel)
  final String level; // e.g. "N3", "750+", "12"
  @JsonKey(defaultValue: ExamConstants.defaultDurationMinutes)
  final int durationMinutes;
  @JsonKey(defaultValue: ExamConstants.defaultTotalQuestions)
  final int totalQuestions;
  @JsonKey(defaultValue: ExamConstants.defaultPassingScorePercent)
  final int passingScore;
  @JsonKey(defaultValue: ExamConstants.defaultExamIcon)
  final String iconName;
  @JsonKey(defaultValue: ExamConstants.defaultExamVersion)
  final int version;
  @JsonKey(defaultValue: true)
  final bool isPublished;
  @JsonKey(defaultValue: false)
  final bool isDownloaded;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  const ExamPaperModel({
    required this.id,
    required this.title,
    this.description = '',
    this.category = ExamCategory.jlpt,
    this.level = ExamConstants.defaultExamLevel,
    this.durationMinutes = ExamConstants.defaultDurationMinutes,
    this.totalQuestions = ExamConstants.defaultTotalQuestions,
    this.passingScore = ExamConstants.defaultPassingScorePercent,
    this.iconName = ExamConstants.defaultExamIcon,
    this.version = ExamConstants.defaultExamVersion,
    this.isPublished = true,
    this.isDownloaded = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamPaperModel.fromJson(Map<String, dynamic> json) =>
      _$ExamPaperModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamPaperModelToJson(this);

  ExamPaperModel copyWith({
    String? id,
    String? title,
    String? description,
    ExamCategory? category,
    String? level,
    int? durationMinutes,
    int? totalQuestions,
    int? passingScore,
    String? iconName,
    int? version,
    bool? isPublished,
    bool? isDownloaded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamPaperModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      passingScore: passingScore ?? this.passingScore,
      iconName: iconName ?? this.iconName,
      version: version ?? this.version,
      isPublished: isPublished ?? this.isPublished,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// A distinct Section within an Exam Paper.
@JsonSerializable(fieldRename: FieldRename.snake)
class ExamSectionModel {
  final String id;
  final String examId;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: ExamConstants.defaultSectionType)
  final String sectionType;
  @JsonKey(defaultValue: ExamConstants.defaultSectionOrder)
  final int orderIndex;
  @JsonKey(defaultValue: '')
  final String instruction;

  const ExamSectionModel({
    required this.id,
    required this.examId,
    required this.title,
    this.sectionType = ExamConstants.defaultSectionType,
    this.orderIndex = ExamConstants.defaultSectionOrder,
    this.instruction = '',
  });

  factory ExamSectionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamSectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSectionModelToJson(this);
}

/// Individual multiple choice option.
@JsonSerializable()
class ExamQuestionOption {
  @JsonKey(defaultValue: '')
  final String id; // e.g. "A", "B", "C", "D"
  @JsonKey(defaultValue: '')
  final String text;

  const ExamQuestionOption({required this.id, required this.text});

  factory ExamQuestionOption.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionOptionFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionOptionToJson(this);
}

/// An individual question within an exam paper.
@JsonSerializable(fieldRename: FieldRename.snake)
class ExamQuestionModel {
  final String id;
  final String examId;
  final String sectionId;
  @JsonKey(defaultValue: ExamConstants.defaultQuestionNumber)
  final int questionNumber;
  @JsonKey(defaultValue: '')
  final String questionText;
  final String? contextPassage;
  final String? audioUrl;
  @JsonKey(name: 'options_json', readValue: _readOptions)
  @ExamOptionsConverter()
  final List<ExamQuestionOption> options;
  @JsonKey(defaultValue: '')
  final String correctAnswer;
  @JsonKey(defaultValue: '')
  final String explanation;
  @JsonKey(defaultValue: ExamConstants.defaultQuestionPoints)
  final int points;

  const ExamQuestionModel({
    required this.id,
    required this.examId,
    required this.sectionId,
    required this.questionNumber,
    required this.questionText,
    this.contextPassage,
    this.audioUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation = '',
    this.points = ExamConstants.defaultQuestionPoints,
  });

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamQuestionModelToJson(this);
}

/// A completed submission record of an exam attempt.
@JsonSerializable(fieldRename: FieldRename.snake)
class ExamSubmissionModel {
  final String id;
  final String examId;
  @JsonKey(defaultValue: 0)
  final int score;
  @JsonKey(defaultValue: 0)
  final int totalCorrect;
  @JsonKey(defaultValue: 0)
  final int totalQuestions;
  @JsonKey(defaultValue: 0)
  final int durationSeconds;
  @JsonKey(name: 'answers_json', readValue: _readAnswers)
  @ExamAnswersConverter()
  final Map<String, String> answers; // questionId -> selectedOptionId
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime submittedAt;
  @JsonKey(defaultValue: '')
  final String updatedAtHlc;

  const ExamSubmissionModel({
    required this.id,
    required this.examId,
    required this.score,
    required this.totalCorrect,
    required this.totalQuestions,
    required this.durationSeconds,
    required this.answers,
    required this.submittedAt,
    this.updatedAtHlc = '',
  });

  bool get isPassed =>
      totalQuestions > 0 &&
      ((totalCorrect / totalQuestions) * 100) >=
          ExamConstants.defaultPassingScorePercent;

  factory ExamSubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamSubmissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExamSubmissionModelToJson(this);
}

/// Status of a mistake entry in the Wrong Question Notebook.
@JsonEnum()
enum WrongQuestionStatus {
  @JsonValue('new')
  newQuestion('new', 'New'),
  @JsonValue('reviewing')
  reviewing('reviewing', 'Reviewing'),
  @JsonValue('mastered')
  mastered('mastered', 'Mastered');

  final String code;
  final String label;

  const WrongQuestionStatus(this.code, this.label);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case WrongQuestionStatus.newQuestion:
        return l10n.wrongStatusNew;
      case WrongQuestionStatus.reviewing:
        return l10n.wrongStatusReviewing;
      case WrongQuestionStatus.mastered:
        return l10n.wrongStatusMastered;
    }
  }

  static WrongQuestionStatus fromString(String? val) {
    if (val == null) return WrongQuestionStatus.newQuestion;
    for (final s in WrongQuestionStatus.values) {
      if (s.name == val || s.code == val) return s;
    }
    return WrongQuestionStatus.newQuestion;
  }
}

/// An entry in the user's personal Wrong Question Notebook.
@JsonSerializable(fieldRename: FieldRename.snake)
class WrongQuestionModel {
  final String id;
  final String examId;
  final String questionId;
  @JsonKey(defaultValue: '')
  final String userAnswer;
  @JsonKey(defaultValue: '')
  final String explanation;
  @JsonKey(defaultValue: '')
  final String notes;
  @JsonKey(unknownEnumValue: WrongQuestionStatus.newQuestion)
  final WrongQuestionStatus status;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;
  @JsonKey(defaultValue: '')
  final String updatedAtHlc;

  const WrongQuestionModel({
    required this.id,
    required this.examId,
    required this.questionId,
    required this.userAnswer,
    this.explanation = '',
    this.notes = '',
    this.status = WrongQuestionStatus.newQuestion,
    required this.createdAt,
    required this.updatedAt,
    this.updatedAtHlc = '',
  });

  factory WrongQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$WrongQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$WrongQuestionModelToJson(this);

  WrongQuestionModel copyWith({
    String? id,
    String? examId,
    String? questionId,
    String? userAnswer,
    String? explanation,
    String? notes,
    WrongQuestionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedAtHlc,
  }) {
    return WrongQuestionModel(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      questionId: questionId ?? this.questionId,
      userAnswer: userAnswer ?? this.userAnswer,
      explanation: explanation ?? this.explanation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedAtHlc: updatedAtHlc ?? this.updatedAtHlc,
    );
  }
}

/// Composite payload representing a complete downloaded exam bundle (paper, sections, questions)
@JsonSerializable(explicitToJson: true)
class ExamPaperDetailsDto {
  final ExamPaperModel paper;
  @JsonKey(defaultValue: [])
  final List<ExamSectionModel> sections;
  @JsonKey(defaultValue: [])
  final List<ExamQuestionModel> questions;

  const ExamPaperDetailsDto({
    required this.paper,
    this.sections = const [],
    this.questions = const [],
  });

  factory ExamPaperDetailsDto.fromJson(Map<String, dynamic> json) =>
      _$ExamPaperDetailsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ExamPaperDetailsDtoToJson(this);
}
