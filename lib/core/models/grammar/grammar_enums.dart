import 'package:flutter/material.dart' as m;
import 'package:json_annotation/json_annotation.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Exercise question formats
@JsonEnum(valueField: 'value')
enum GrammarExerciseType {
  @JsonValue('choice')
  choice('choice', 'TRẮC NGHIỆM'),
  @JsonValue('error_id')
  errorId('error_id', 'TÌM LỖI SAI'),
  @JsonValue('cloze')
  cloze('cloze', 'ĐIỀN TỪ');

  final String value;
  final String label;

  const GrammarExerciseType(this.value, this.label);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case GrammarExerciseType.choice:
        return l10n.grammarTypeChoice;
      case GrammarExerciseType.errorId:
        return l10n.grammarTypeErrorId;
      case GrammarExerciseType.cloze:
        return l10n.grammarTypeCloze;
    }
  }

  static GrammarExerciseType fromString(String? val) {
    return GrammarExerciseType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => GrammarExerciseType.choice,
    );
  }
}

/// Academic proficiency levels
@JsonEnum(valueField: 'value')
enum GrammarLevel {
  @JsonValue(1)
  foundation(1, 'Foundation', 'Level 1: Foundation (8)', m.Colors.blue),
  @JsonValue(2)
  intermediate(
    2,
    'Intermediate',
    'Level 2: Intermediate (17)',
    m.Colors.purple,
  ),
  @JsonValue(3)
  advanced(
    3,
    'Advanced C1/C2',
    'Level 3: Advanced C1/C2 (11)',
    m.Colors.orange,
  );

  final int value;
  final String label;
  final String displayName;
  final m.Color color;

  const GrammarLevel(this.value, this.label, this.displayName, this.color);

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case GrammarLevel.foundation:
        return l10n.grammarLevelFoundation;
      case GrammarLevel.intermediate:
        return l10n.grammarLevelIntermediate;
      case GrammarLevel.advanced:
        return l10n.grammarLevelAdvanced;
    }
  }

  static GrammarLevel fromValue(dynamic val) {
    if (val is GrammarLevel) return val;
    final intVal = (val is num)
        ? val.toInt()
        : int.tryParse(val?.toString() ?? '') ?? 1;
    switch (intVal) {
      case 2:
        return GrammarLevel.intermediate;
      case 3:
        return GrammarLevel.advanced;
      case 1:
      default:
        return GrammarLevel.foundation;
    }
  }
}

/// Cognitive difficulty grading
@JsonEnum(valueField: 'value')
enum GrammarDifficulty {
  @JsonValue(1)
  recognition(1, 'Nhận Biết (Recognition)'),
  @JsonValue(2)
  analysis(2, 'Phân Tích & Bẫy (Analysis)'),
  @JsonValue(3)
  production(3, 'Sản Sinh Thực Hành (Production)');

  final int value;
  final String label;

  const GrammarDifficulty(this.value, this.label);

  static GrammarDifficulty fromValue(dynamic val) {
    if (val is GrammarDifficulty) return val;
    final intVal = (val is num)
        ? val.toInt()
        : int.tryParse(val?.toString() ?? '') ?? 1;
    switch (intVal) {
      case 2:
        return GrammarDifficulty.analysis;
      case 3:
        return GrammarDifficulty.production;
      case 1:
      default:
        return GrammarDifficulty.recognition;
    }
  }
}

/// 27 Academic Grammar Domains
@JsonEnum(valueField: 'code')
enum GrammarCategory {
  tenses('tenses', 'Thì & Khía Cạnh (Tenses & Aspects)'),
  voice('voice', 'Câu Bị Động (Passive Voice)'),
  modals('modals', 'Động Từ Khuyết Thiếu (Modal Verbs)'),
  conditionals('conditionals', 'Câu Điều Kiện (Conditionals)'),
  subjunctive('subjunctive', 'Thể Giả Định (Subjunctive Mood)'),
  clauses('clauses', 'Mệnh Đề Quan Hệ (Relative Clauses)'),
  inversion('inversion', 'Đảo Ngữ (Inversion)'),
  verbForms('verb_forms', 'Dạng Động Từ (Gerund & Infinitive)'),
  conjunctions('conjunctions', 'Liên Từ (Conjunctions)'),
  subjectVerbAgreement(
    'subject_verb_agreement',
    'Hòa Hợp Chủ Vị (Subject-Verb Agreement)',
  ),
  comparisons('comparisons', 'Cấu Trúc So Sánh (Comparisons)'),
  articles('articles', 'Mạo Từ (Articles)'),
  determiners('determiners', 'Từ Hạn Định (Determiners)'),
  pronouns('pronouns', 'Đại Từ (Pronouns)'),
  prepositions('prepositions', 'Giới Từ (Prepositions)'),
  adjectivesAdverbs(
    'adjectives_adverbs',
    'Tính Từ & Trạng Từ (Adjectives & Adverbs)',
  ),
  nounClauses('noun_clauses', 'Mệnh Đề Danh Từ (Noun Clauses)'),
  sentenceStructure('sentence_structure', 'Cấu Trúc Câu (Sentence Structure)'),
  causativeVerbs('causative_verbs', 'Thể Sai Khiến (Causative Verbs)'),
  phrasalVerbs('phrasal_verbs', 'Cụm Động Từ (Phrasal Verbs)'),
  questions('questions', 'Câu Hỏi & Đuôi (Questions & Tag Questions)'),
  emphasis('emphasis', 'Cấu Trúc Nhấn Mạnh (Emphasis & Cleft Sentences)'),
  parallelStructure('parallel_structure', 'Cấu Trúc Song Song (Parallelism)'),
  participles('participles', 'Phân Từ & Mệnh Đề Rút Gọn (Participles)'),
  wordFormation('word_formation', 'Cấu Tạo Từ (Word Formation)'),
  collocations('collocations', 'Kết Hợp Từ (Collocations)'),
  capstone('capstone', 'Tổng Ôn Toàn Diện (Capstone Exam Mastery)');

  final String code;
  final String displayName;

  const GrammarCategory(this.code, this.displayName);

  static GrammarCategory fromCode(dynamic code) {
    if (code is GrammarCategory) return code;
    if (code == null) return GrammarCategory.tenses;
    final normalized = code.toString().trim().toLowerCase();
    return GrammarCategory.values.firstWhere(
      (c) => c.code == normalized || c.name.toLowerCase() == normalized,
      orElse: () => GrammarCategory.tenses,
    );
  }
}

/// Study & Review modes
@JsonEnum(valueField: 'value')
enum GrammarPracticeMode {
  unit('unit'),
  ghost('ghost'),
  due('due');

  final String value;
  const GrammarPracticeMode(this.value);

  static GrammarPracticeMode fromString(String? val) {
    return GrammarPracticeMode.values.firstWhere(
      (m) => m.value == val || m.name == val,
      orElse: () => GrammarPracticeMode.unit,
    );
  }
}
