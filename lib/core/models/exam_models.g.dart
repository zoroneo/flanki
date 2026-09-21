// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamPaperModel _$ExamPaperModelFromJson(Map<String, dynamic> json) =>
    ExamPaperModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Exam',
      description: json['description'] as String? ?? '',
      category:
          $enumDecodeNullable(
            _$ExamCategoryEnumMap,
            json['category'],
            unknownValue: ExamCategory.jlpt,
          ) ??
          ExamCategory.jlpt,
      level: json['level'] as String? ?? 'N3',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 40,
      passingScore: (json['passing_score'] as num?)?.toInt() ?? 60,
      iconName: json['icon_name'] as String? ?? 'file-text',
      version: (json['version'] as num?)?.toInt() ?? 1,
      isPublished: json['is_published'] as bool? ?? true,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
    );

Map<String, dynamic> _$ExamPaperModelToJson(ExamPaperModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': _$ExamCategoryEnumMap[instance.category]!,
      'level': instance.level,
      'duration_minutes': instance.durationMinutes,
      'total_questions': instance.totalQuestions,
      'passing_score': instance.passingScore,
      'icon_name': instance.iconName,
      'version': instance.version,
      'is_published': instance.isPublished,
      'is_downloaded': instance.isDownloaded,
      'created_at': _dateTimeToJson(instance.createdAt),
      'updated_at': _dateTimeToJson(instance.updatedAt),
    };

const _$ExamCategoryEnumMap = {
  ExamCategory.jlpt: 'JLPT',
  ExamCategory.toeic: 'TOEIC',
  ExamCategory.thptqg: 'THPTQG',
  ExamCategory.grammarTest: 'GRAMMAR',
  ExamCategory.custom: 'CUSTOM',
};

ExamSectionModel _$ExamSectionModelFromJson(Map<String, dynamic> json) =>
    ExamSectionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      title: json['title'] as String? ?? '',
      sectionType: json['section_type'] as String? ?? 'general',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      instruction: json['instruction'] as String? ?? '',
    );

Map<String, dynamic> _$ExamSectionModelToJson(ExamSectionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exam_id': instance.examId,
      'title': instance.title,
      'section_type': instance.sectionType,
      'order_index': instance.orderIndex,
      'instruction': instance.instruction,
    };

ExamQuestionOption _$ExamQuestionOptionFromJson(Map<String, dynamic> json) =>
    ExamQuestionOption(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );

Map<String, dynamic> _$ExamQuestionOptionToJson(ExamQuestionOption instance) =>
    <String, dynamic>{'id': instance.id, 'text': instance.text};

ExamQuestionModel _$ExamQuestionModelFromJson(Map<String, dynamic> json) =>
    ExamQuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      sectionId: json['section_id'] as String,
      questionNumber: (json['question_number'] as num?)?.toInt() ?? 1,
      questionText: json['question_text'] as String? ?? '',
      contextPassage: json['context_passage'] as String?,
      audioUrl: json['audio_url'] as String?,
      options: const ExamOptionsConverter().fromJson(
        _readOptions(json, 'options_json'),
      ),
      correctAnswer: json['correct_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$ExamQuestionModelToJson(ExamQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exam_id': instance.examId,
      'section_id': instance.sectionId,
      'question_number': instance.questionNumber,
      'question_text': instance.questionText,
      'context_passage': instance.contextPassage,
      'audio_url': instance.audioUrl,
      'options_json': const ExamOptionsConverter().toJson(instance.options),
      'correct_answer': instance.correctAnswer,
      'explanation': instance.explanation,
      'points': instance.points,
    };

ExamSubmissionModel _$ExamSubmissionModelFromJson(Map<String, dynamic> json) =>
    ExamSubmissionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['total_correct'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
      answers: const ExamAnswersConverter().fromJson(
        _readAnswers(json, 'answers_json'),
      ),
      submittedAt: _dateTimeFromJson(json['submitted_at']),
      updatedAtHlc: json['updated_at_hlc'] as String? ?? '',
    );

Map<String, dynamic> _$ExamSubmissionModelToJson(
  ExamSubmissionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'exam_id': instance.examId,
  'score': instance.score,
  'total_correct': instance.totalCorrect,
  'total_questions': instance.totalQuestions,
  'duration_seconds': instance.durationSeconds,
  'answers_json': const ExamAnswersConverter().toJson(instance.answers),
  'submitted_at': _dateTimeToJson(instance.submittedAt),
  'updated_at_hlc': instance.updatedAtHlc,
};

WrongQuestionModel _$WrongQuestionModelFromJson(Map<String, dynamic> json) =>
    WrongQuestionModel(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      questionId: json['question_id'] as String,
      userAnswer: json['user_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      status:
          $enumDecodeNullable(
            _$WrongQuestionStatusEnumMap,
            json['status'],
            unknownValue: WrongQuestionStatus.newQuestion,
          ) ??
          WrongQuestionStatus.newQuestion,
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
      updatedAtHlc: json['updated_at_hlc'] as String? ?? '',
    );

Map<String, dynamic> _$WrongQuestionModelToJson(WrongQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exam_id': instance.examId,
      'question_id': instance.questionId,
      'user_answer': instance.userAnswer,
      'explanation': instance.explanation,
      'notes': instance.notes,
      'status': _$WrongQuestionStatusEnumMap[instance.status]!,
      'created_at': _dateTimeToJson(instance.createdAt),
      'updated_at': _dateTimeToJson(instance.updatedAt),
      'updated_at_hlc': instance.updatedAtHlc,
    };

const _$WrongQuestionStatusEnumMap = {
  WrongQuestionStatus.newQuestion: 'new',
  WrongQuestionStatus.reviewing: 'reviewing',
  WrongQuestionStatus.mastered: 'mastered',
};

ExamPaperDetailsDto _$ExamPaperDetailsDtoFromJson(Map<String, dynamic> json) =>
    ExamPaperDetailsDto(
      paper: ExamPaperModel.fromJson(json['paper'] as Map<String, dynamic>),
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((e) => ExamSectionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (e) => ExamQuestionModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

Map<String, dynamic> _$ExamPaperDetailsDtoToJson(
  ExamPaperDetailsDto instance,
) => <String, dynamic>{
  'paper': instance.paper.toJson(),
  'sections': instance.sections.map((e) => e.toJson()).toList(),
  'questions': instance.questions.map((e) => e.toJson()).toList(),
};
