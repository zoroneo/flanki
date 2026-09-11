// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrammarUnit _$GrammarUnitFromJson(Map<String, dynamic> json) => GrammarUnit(
  unitId: json['unitId'] as String? ?? '',
  title: json['title'] as String? ?? '',
  category: $enumDecode(
    _$GrammarCategoryEnumMap,
    json['category'],
    unknownValue: GrammarCategory.tenses,
  ),
  level: $enumDecode(
    _$GrammarLevelEnumMap,
    json['level'],
    unknownValue: GrammarLevel.foundation,
  ),
  coreConcept: json['coreConcept'] as String? ?? '',
  formulas:
      (json['formulas'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  commonTraps:
      (json['commonTraps'] as List<dynamic>?)
          ?.map((e) => GrammarTrap.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  exercises:
      (json['exercises'] as List<dynamic>?)
          ?.map((e) => GrammarExercise.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  extraGuides:
      (_readExtraGuides(json, 'extraGuides') as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$GrammarUnitToJson(GrammarUnit instance) =>
    <String, dynamic>{
      'unitId': instance.unitId,
      'title': instance.title,
      'category': _$GrammarCategoryEnumMap[instance.category]!,
      'level': _$GrammarLevelEnumMap[instance.level]!,
      'coreConcept': instance.coreConcept,
      'formulas': instance.formulas,
      'commonTraps': instance.commonTraps.map((e) => e.toJson()).toList(),
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
    };

const _$GrammarCategoryEnumMap = {
  GrammarCategory.tenses: 'tenses',
  GrammarCategory.voice: 'voice',
  GrammarCategory.modals: 'modals',
  GrammarCategory.conditionals: 'conditionals',
  GrammarCategory.subjunctive: 'subjunctive',
  GrammarCategory.clauses: 'clauses',
  GrammarCategory.inversion: 'inversion',
  GrammarCategory.verbForms: 'verb_forms',
  GrammarCategory.conjunctions: 'conjunctions',
  GrammarCategory.subjectVerbAgreement: 'subject_verb_agreement',
  GrammarCategory.comparisons: 'comparisons',
  GrammarCategory.articles: 'articles',
  GrammarCategory.determiners: 'determiners',
  GrammarCategory.pronouns: 'pronouns',
  GrammarCategory.prepositions: 'prepositions',
  GrammarCategory.adjectivesAdverbs: 'adjectives_adverbs',
  GrammarCategory.nounClauses: 'noun_clauses',
  GrammarCategory.sentenceStructure: 'sentence_structure',
  GrammarCategory.causativeVerbs: 'causative_verbs',
  GrammarCategory.phrasalVerbs: 'phrasal_verbs',
  GrammarCategory.questions: 'questions',
  GrammarCategory.emphasis: 'emphasis',
  GrammarCategory.parallelStructure: 'parallel_structure',
  GrammarCategory.participles: 'participles',
  GrammarCategory.wordFormation: 'word_formation',
  GrammarCategory.collocations: 'collocations',
  GrammarCategory.capstone: 'capstone',
};

const _$GrammarLevelEnumMap = {
  GrammarLevel.foundation: 1,
  GrammarLevel.intermediate: 2,
  GrammarLevel.advanced: 3,
};
