import 'package:flutter/material.dart' as m;
import 'package:json_annotation/json_annotation.dart';

import '../../../core/theme/app_tokens.dart';

/// Exercise question formats
@JsonEnum(valueField: 'value')
enum GrammarExerciseType {
  @JsonValue('choice')
  choice('choice', 'Multiple Choice'),
  @JsonValue('error_id')
  errorId('error_id', 'Error Identification'),
  @JsonValue('cloze')
  cloze('cloze', 'Fill in the Blank');

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
  foundation(1, 'Foundation', 'Level 1: Foundation (8)', AppColors.accentBlue),
  @JsonValue(2)
  intermediate(
    2,
    'Intermediate',
    'Level 2: Intermediate (17)',
    AppColors.accentPurple,
  ),
  @JsonValue(3)
  advanced(
    3,
    'Advanced C1/C2',
    'Level 3: Advanced C1/C2 (11)',
    AppColors.accentOrange,
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
  recognition(1, 'Recognition'),
  @JsonValue(2)
  analysis(2, 'Analysis & Traps'),
  @JsonValue(3)
  production(3, 'Production');

  final int value;
  final String label;

  const GrammarDifficulty(this.value, this.label);

  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case GrammarDifficulty.recognition:
        return l10n.grammarDifficultyRecognition;
      case GrammarDifficulty.analysis:
        return l10n.grammarDifficultyAnalysis;
      case GrammarDifficulty.production:
        return l10n.grammarDifficultyProduction;
    }
  }

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
  tenses('tenses', 'Tenses & Aspects'),
  voice('voice', 'Passive Voice'),
  modals('modals', 'Modal Verbs'),
  conditionals('conditionals', 'Conditionals'),
  subjunctive('subjunctive', 'Subjunctive Mood'),
  clauses('clauses', 'Relative Clauses'),
  inversion('inversion', 'Inversion'),
  verbForms('verb_forms', 'Gerund & Infinitive'),
  conjunctions('conjunctions', 'Conjunctions'),
  subjectVerbAgreement('subject_verb_agreement', 'Subject-Verb Agreement'),
  comparisons('comparisons', 'Comparisons'),
  articles('articles', 'Articles'),
  determiners('determiners', 'Determiners'),
  pronouns('pronouns', 'Pronouns'),
  prepositions('prepositions', 'Prepositions'),
  adjectivesAdverbs('adjectives_adverbs', 'Adjectives & Adverbs'),
  nounClauses('noun_clauses', 'Noun Clauses'),
  sentenceStructure('sentence_structure', 'Sentence Structure'),
  causativeVerbs('causative_verbs', 'Causative Verbs'),
  phrasalVerbs('phrasal_verbs', 'Phrasal Verbs'),
  questions('questions', 'Questions & Tag Questions'),
  emphasis('emphasis', 'Emphasis & Cleft Sentences'),
  parallelStructure('parallel_structure', 'Parallelism'),
  participles('participles', 'Participles'),
  wordFormation('word_formation', 'Word Formation'),
  collocations('collocations', 'Collocations'),
  capstone('capstone', 'Capstone Exam Mastery');

  final String code;
  final String displayName;

  const GrammarCategory(this.code, this.displayName);

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case GrammarCategory.tenses:
        return l10n.grammarCatTenses;
      case GrammarCategory.voice:
        return l10n.grammarCatVoice;
      case GrammarCategory.modals:
        return l10n.grammarCatModals;
      case GrammarCategory.conditionals:
        return l10n.grammarCatConditionals;
      case GrammarCategory.subjunctive:
        return l10n.grammarCatSubjunctive;
      case GrammarCategory.clauses:
        return l10n.grammarCatClauses;
      case GrammarCategory.inversion:
        return l10n.grammarCatInversion;
      case GrammarCategory.verbForms:
        return l10n.grammarCatVerbForms;
      case GrammarCategory.conjunctions:
        return l10n.grammarCatConjunctions;
      case GrammarCategory.subjectVerbAgreement:
        return l10n.grammarCatSubjectVerbAgreement;
      case GrammarCategory.comparisons:
        return l10n.grammarCatComparisons;
      case GrammarCategory.articles:
        return l10n.grammarCatArticles;
      case GrammarCategory.determiners:
        return l10n.grammarCatDeterminers;
      case GrammarCategory.pronouns:
        return l10n.grammarCatPronouns;
      case GrammarCategory.prepositions:
        return l10n.grammarCatPrepositions;
      case GrammarCategory.adjectivesAdverbs:
        return l10n.grammarCatAdjectivesAdverbs;
      case GrammarCategory.nounClauses:
        return l10n.grammarCatNounClauses;
      case GrammarCategory.sentenceStructure:
        return l10n.grammarCatSentenceStructure;
      case GrammarCategory.causativeVerbs:
        return l10n.grammarCatCausativeVerbs;
      case GrammarCategory.phrasalVerbs:
        return l10n.grammarCatPhrasalVerbs;
      case GrammarCategory.questions:
        return l10n.grammarCatQuestions;
      case GrammarCategory.emphasis:
        return l10n.grammarCatEmphasis;
      case GrammarCategory.parallelStructure:
        return l10n.grammarCatParallelStructure;
      case GrammarCategory.participles:
        return l10n.grammarCatParticiples;
      case GrammarCategory.wordFormation:
        return l10n.grammarCatWordFormation;
      case GrammarCategory.collocations:
        return l10n.grammarCatCollocations;
      case GrammarCategory.capstone:
        return l10n.grammarCatCapstone;
    }
  }

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
