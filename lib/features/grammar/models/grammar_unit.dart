import 'package:json_annotation/json_annotation.dart';

import 'grammar_enums.dart';
import 'grammar_exercise.dart';
import 'grammar_trap.dart';

part 'grammar_unit.g.dart';

Object? _readExtraGuides(Map json, String key) {
  const baseKeys = {
    'unitId',
    'title',
    'category',
    'level',
    'coreConcept',
    'formulas',
    'commonTraps',
    'exercises',
  };
  final extraGuides = <String, String>{};
  json.forEach((k, v) {
    if (!baseKeys.contains(k) && v is String) {
      extraGuides[k.toString()] = v;
    }
  });
  return extraGuides;
}

@JsonSerializable(explicitToJson: true)
class GrammarUnit {
  @JsonKey(defaultValue: '')
  final String unitId;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(unknownEnumValue: GrammarCategory.tenses)
  final GrammarCategory category;
  @JsonKey(unknownEnumValue: GrammarLevel.foundation)
  final GrammarLevel level;
  @JsonKey(defaultValue: '')
  final String coreConcept;
  @JsonKey(defaultValue: {})
  final Map<String, String> formulas;
  @JsonKey(defaultValue: [])
  final List<GrammarTrap> commonTraps;
  @JsonKey(defaultValue: [])
  final List<GrammarExercise> exercises;

  @JsonKey(readValue: _readExtraGuides, includeToJson: false)
  final Map<String, String> extraGuides;

  const GrammarUnit({
    required this.unitId,
    required this.title,
    required this.category,
    required this.level,
    required this.coreConcept,
    required this.formulas,
    required this.commonTraps,
    required this.exercises,
    this.extraGuides = const {},
  });

  List<GrammarExercise> get choiceExercises =>
      exercises.where((e) => e.type == GrammarExerciseType.choice).toList();

  List<GrammarExercise> get errorIdExercises =>
      exercises.where((e) => e.type == GrammarExerciseType.errorId).toList();

  List<GrammarExercise> get clozeExercises =>
      exercises.where((e) => e.type == GrammarExerciseType.cloze).toList();

  int get totalExercises => exercises.length;

  factory GrammarUnit.fromJson(Map<String, dynamic> json) =>
      _$GrammarUnitFromJson(json);

  Map<String, dynamic> toJson() =>
      _$GrammarUnitToJson(this)..addAll(extraGuides);
}
