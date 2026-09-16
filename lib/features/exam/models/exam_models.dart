import 'dart:convert';

import '../../../l10n/generated/app_localizations.dart';
import 'exam_constants.dart';

export 'exam_constants.dart';

/// Categories of examinations supported by Flanki.
enum ExamCategory {
  jlpt('JLPT', 'Japanese Language Proficiency Test'),
  toeic('TOEIC', 'Test of English for International Communication'),
  thptqg('THPTQG', 'National High School Graduation Exam'),
  grammarTest('GRAMMAR', 'Comprehensive Grammar Test'),
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

/// Metadata describing an Exam Paper in the catalog.
class ExamPaperModel {
  final String id;
  final String title;
  final String description;
  final ExamCategory category;
  final String level; // e.g. "N3", "750+", "12"
  final int durationMinutes;
  final int totalQuestions;
  final int passingScore;
  final String iconName;
  final int version;
  final bool isPublished;
  final bool isDownloaded;
  final DateTime createdAt;
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

  factory ExamPaperModel.fromJson(Map<String, dynamic> json) {
    return ExamPaperModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Exam',
      description: json['description'] as String? ?? '',
      category: ExamCategory.fromString(json['category'] as String?),
      level: json['level'] as String? ?? ExamConstants.defaultExamLevel,
      durationMinutes:
          json['duration_minutes'] as int? ??
          ExamConstants.defaultDurationMinutes,
      totalQuestions:
          json['total_questions'] as int? ??
          ExamConstants.defaultTotalQuestions,
      passingScore:
          json['passing_score'] as int? ??
          ExamConstants.defaultPassingScorePercent,
      iconName: json['icon_name'] as String? ?? ExamConstants.defaultExamIcon,
      version: json['version'] as int? ?? ExamConstants.defaultExamVersion,
      isPublished: json['is_published'] as bool? ?? true,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category.code,
    'level': level,
    'duration_minutes': durationMinutes,
    'total_questions': totalQuestions,
    'passing_score': passingScore,
    'icon_name': iconName,
    'version': version,
    'is_published': isPublished,
    'is_downloaded': isDownloaded,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

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
class ExamSectionModel {
  final String id;
  final String examId;
  final String title;
  final String sectionType;
  final int orderIndex;
  final String instruction;

  const ExamSectionModel({
    required this.id,
    required this.examId,
    required this.title,
    this.sectionType = ExamConstants.defaultSectionType,
    this.orderIndex = ExamConstants.defaultSectionOrder,
    this.instruction = '',
  });

  factory ExamSectionModel.fromJson(Map<String, dynamic> json) {
    return ExamSectionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      title: json['title'] as String? ?? '',
      sectionType:
          json['section_type'] as String? ?? ExamConstants.defaultSectionType,
      orderIndex:
          json['order_index'] as int? ?? ExamConstants.defaultSectionOrder,
      instruction: json['instruction'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_id': examId,
    'title': title,
    'section_type': sectionType,
    'order_index': orderIndex,
    'instruction': instruction,
  };
}

/// Individual multiple choice option.
class ExamQuestionOption {
  final String id; // e.g. "A", "B", "C", "D"
  final String text;

  const ExamQuestionOption({required this.id, required this.text});

  factory ExamQuestionOption.fromJson(Map<String, dynamic> json) {
    return ExamQuestionOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

/// An individual question within an exam paper.
class ExamQuestionModel {
  final String id;
  final String examId;
  final String sectionId;
  final int questionNumber;
  final String questionText;
  final String? contextPassage;
  final String? audioUrl;
  final List<ExamQuestionOption> options;
  final String correctAnswer;
  final String explanation;
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

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options_json'];
    List<ExamQuestionOption> parsedOptions = [];
    if (rawOptions is List) {
      parsedOptions = rawOptions
          .map(
            (e) => ExamQuestionOption.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } else if (rawOptions is String && rawOptions.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawOptions);
        if (decoded is List) {
          parsedOptions = decoded
              .map(
                (e) => ExamQuestionOption.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList();
        }
      } catch (_) {}
    }

    return ExamQuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      sectionId: json['section_id'] as String,
      questionNumber:
          json['question_number'] as int? ??
          ExamConstants.defaultQuestionNumber,
      questionText: json['question_text'] as String? ?? '',
      contextPassage: json['context_passage'] as String?,
      audioUrl: json['audio_url'] as String?,
      options: parsedOptions,
      correctAnswer: json['correct_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      points: json['points'] as int? ?? ExamConstants.defaultQuestionPoints,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_id': examId,
    'section_id': sectionId,
    'question_number': questionNumber,
    'question_text': questionText,
    'context_passage': contextPassage,
    'audio_url': audioUrl,
    'options_json': options.map((o) => o.toJson()).toList(),
    'correct_answer': correctAnswer,
    'explanation': explanation,
    'points': points,
  };
}

/// A completed submission record of an exam attempt.
class ExamSubmissionModel {
  final String id;
  final String examId;
  final int score;
  final int totalCorrect;
  final int totalQuestions;
  final int durationSeconds;
  final Map<String, String> answers; // questionId -> selectedOptionId
  final DateTime submittedAt;
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

  factory ExamSubmissionModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> parsedAnswers = {};
    final rawAnswers = json['answers_json'];
    if (rawAnswers is Map) {
      parsedAnswers = rawAnswers.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    } else if (rawAnswers is String && rawAnswers.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawAnswers);
        if (decoded is Map) {
          parsedAnswers = decoded.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          );
        }
      } catch (_) {}
    }

    return ExamSubmissionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      score: json['score'] as int? ?? 0,
      totalCorrect: json['total_correct'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      answers: parsedAnswers,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      updatedAtHlc: json['updated_at_hlc'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_id': examId,
    'score': score,
    'total_correct': totalCorrect,
    'total_questions': totalQuestions,
    'duration_seconds': durationSeconds,
    'answers_json': answers,
    'submitted_at': submittedAt.toIso8601String(),
    'updated_at_hlc': updatedAtHlc,
  };
}

/// Status of a mistake entry in the Wrong Question Notebook.
enum WrongQuestionStatus {
  newQuestion('new', 'New'),
  reviewing('reviewing', 'Reviewing'),
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
class WrongQuestionModel {
  final String id;
  final String examId;
  final String questionId;
  final String userAnswer;
  final String explanation;
  final String notes;
  final WrongQuestionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
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

  factory WrongQuestionModel.fromJson(Map<String, dynamic> json) {
    return WrongQuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      questionId: json['question_id'] as String,
      userAnswer: json['user_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status: WrongQuestionStatus.fromString(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      updatedAtHlc: json['updated_at_hlc'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_id': examId,
    'question_id': questionId,
    'user_answer': userAnswer,
    'explanation': explanation,
    'notes': notes,
    'status': status.code,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'updated_at_hlc': updatedAtHlc,
  };

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
