import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/core/models/grammar/grammar_models.dart';
import 'package:flanki/core/services/grammar_service.dart';

class LocalFileAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (!file.existsSync()) {
      throw FileSystemException('File not found: $key');
    }
    final bytes = await file.readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final file = File(key);
    if (!file.existsSync()) {
      throw FileSystemException('File not found: $key');
    }
    return file.readAsString();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GrammarService service;
  late LocalFileAssetBundle testBundle;

  setUp(() {
    service = GrammarService();
    testBundle = LocalFileAssetBundle();
  });

  group('Grammar Models & GrammarService Tests', () {
    test('Load all 36 units successfully with exact counts', () async {
      final units = await service.loadAllUnits(bundle: testBundle);

      // Verify unit count
      expect(units.length, equals(36));

      // Verify total exercises count
      expect(service.totalExercises, equals(540));

      // Verify each unit structure
      for (final unit in units) {
        expect(unit.unitId, isNotEmpty);
        expect(unit.title, isNotEmpty);
        expect(unit.category, isA<GrammarCategory>());
        expect(unit.level, isA<GrammarLevel>());
        expect(unit.coreConcept, isNotEmpty);
        expect(unit.formulas, isNotEmpty);
        expect(unit.commonTraps.length, inInclusiveRange(1, 10));

        // 15 exercises per unit
        expect(
            unit.exercises.length, equals(GrammarConstants.exercisesPerUnit));
        expect(unit.choiceExercises.length,
            equals(GrammarConstants.choiceExercisesPerUnit));
        expect(unit.errorIdExercises.length,
            equals(GrammarConstants.errorIdExercisesPerUnit));
        expect(unit.clozeExercises.length,
            equals(GrammarConstants.clozeExercisesPerUnit));

        // Test individual exercises
        for (final ex in unit.exercises) {
          expect(ex.id, isNotEmpty);
          expect(ex.prompt, isNotEmpty);
          expect(ex.correctAnswer, isNotEmpty);
          expect(ex.difficulty, isA<GrammarDifficulty>());

          // Explanations
          expect(ex.explanation.translation, isNotEmpty);
          expect(ex.explanation.keySignal, isNotEmpty);
          expect(ex.explanation.rule, isNotEmpty);
          expect(ex.explanation.whyCorrect, isNotEmpty);

          if (ex.type == GrammarExerciseType.choice) {
            expect(ex.options.length, equals(4));
            expect(ex.options.contains(ex.correctAnswer), isTrue);
            expect(ex.explanation.distractorBreakdown, isNotEmpty);
          } else if (ex.type == GrammarExerciseType.errorId) {
            expect(ex.options, equals(GrammarConstants.errorIdOptionLabels));
            expect(
                GrammarConstants.errorIdOptionLabels.contains(ex.correctAnswer),
                isTrue);
          } else if (ex.type == GrammarExerciseType.cloze) {
            expect(ex.options, isEmpty);
          }
        }
      }
    });

    test('Filter by level and category', () async {
      await service.loadAllUnits(bundle: testBundle);

      final level1 = service.filterByLevel(GrammarLevel.foundation);
      final level2 = service.filterByLevel(GrammarLevel.intermediate);
      final level3 = service.filterByLevel(GrammarLevel.advanced);

      expect(level1.length, equals(GrammarConstants.level1UnitCount));
      expect(level2.length, equals(GrammarConstants.level2UnitCount));
      expect(level3.length, equals(GrammarConstants.level3UnitCount));
      expect(level1.length + level2.length + level3.length,
          equals(GrammarConstants.totalUnits));

      final categories = service.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.contains(GrammarCategory.tenses), isTrue);

      final tensesUnits = service.filterByCategory(GrammarCategory.tenses);
      expect(tensesUnits.length, equals(6));
    });

    test('Get single unit by unitId', () async {
      final unit01 = await service
          .getUnit('unit-01-present-simple-vs-continuous', bundle: testBundle);
      expect(unit01, isNotNull);
      expect(unit01!.category, equals(GrammarCategory.tenses));
      expect(unit01.level, equals(GrammarLevel.foundation));
      expect(unit01.extraGuides.containsKey('stativeVerbsGuide'), isTrue);

      final nonExistent =
          await service.getUnit('non-existent-unit', bundle: testBundle);
      expect(nonExistent, isNull);
    });

    test('Json roundtrip serialization for GrammarUnit', () async {
      final unit = await service.getUnit('unit-01-present-simple-vs-continuous',
          bundle: testBundle);
      expect(unit, isNotNull);

      final json = unit!.toJson();
      final restored = GrammarUnit.fromJson(json);

      expect(restored.unitId, equals(unit.unitId));
      expect(restored.title, equals(unit.title));
      expect(restored.category, equals(unit.category));
      expect(restored.level, equals(unit.level));
      expect(restored.exercises.length, equals(unit.exercises.length));
      expect(restored.commonTraps.length, equals(unit.commonTraps.length));
      expect(restored.extraGuides.length, equals(unit.extraGuides.length));
    });
  });
}
