import 'grammar_enums.dart';
import 'grammar_exercise.dart';
import 'grammar_trap.dart';

class GrammarUnit {
  final String unitId;
  final String title;
  final GrammarCategory category;
  final GrammarLevel level;
  final String coreConcept;
  final Map<String, String> formulas;
  final List<GrammarTrap> commonTraps;
  final List<GrammarExercise> exercises;
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

  factory GrammarUnit.fromJson(Map<String, dynamic> json) {
    // 1. Formulas
    final rawFormulas = json['formulas'];
    final formulasMap = <String, String>{};
    if (rawFormulas is Map) {
      rawFormulas.forEach((key, value) {
        formulasMap[key.toString()] = value?.toString() ?? '';
      });
    }

    // 2. Common Traps
    final rawTraps = json['commonTraps'];
    final trapsList = <GrammarTrap>[];
    if (rawTraps is List) {
      for (final item in rawTraps) {
        if (item is Map<String, dynamic>) {
          trapsList.add(GrammarTrap.fromJson(item));
        } else if (item is Map) {
          trapsList.add(GrammarTrap.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // 3. Exercises
    final rawExercises = json['exercises'];
    final exercisesList = <GrammarExercise>[];
    if (rawExercises is List) {
      for (final item in rawExercises) {
        if (item is Map<String, dynamic>) {
          exercisesList.add(GrammarExercise.fromJson(item));
        } else if (item is Map) {
          exercisesList.add(GrammarExercise.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // 4. Extra Guides (e.g. stativeVerbsGuide, modalPerfectGuide, etc.)
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
    final extraGuidesMap = <String, String>{};
    json.forEach((key, value) {
      if (!baseKeys.contains(key) && value is String) {
        extraGuidesMap[key] = value;
      }
    });

    return GrammarUnit(
      unitId: json['unitId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: GrammarCategory.fromCode(json['category']),
      level: GrammarLevel.fromValue(json['level']),
      coreConcept: json['coreConcept'] as String? ?? '',
      formulas: formulasMap,
      commonTraps: trapsList,
      exercises: exercisesList,
      extraGuides: extraGuidesMap,
    );
  }

  Map<String, dynamic> toJson() => {
        'unitId': unitId,
        'title': title,
        'category': category.code,
        'level': level.value,
        'coreConcept': coreConcept,
        'formulas': formulas,
        'commonTraps': commonTraps.map((e) => e.toJson()).toList(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        ...extraGuides,
      };
}
