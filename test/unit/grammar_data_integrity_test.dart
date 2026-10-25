import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flanki/features/grammar/models/grammar_models.dart';

void main() {
  group('Grammar Units Data Integrity & Formatting Tests', () {
    final grammarDir = Directory('assets/data/grammar');
    final files =
        grammarDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    test('All 36 grammar units exist', () {
      expect(files.length, 36);
    });

    for (final file in files) {
      final filename = file.uri.pathSegments.last;

      test(
        '$filename deserializes cleanly into GrammarUnit and meets formatting standards',
        () {
          final content = file.readAsStringSync();
          final json = jsonDecode(content) as Map<String, dynamic>;

          // 1. Deserialization verification
          final unit = GrammarUnit.fromJson(json);
          expect(
            unit.unitId.isNotEmpty,
            isTrue,
            reason: '$filename: unitId missing',
          );
          expect(
            unit.title.isNotEmpty,
            isTrue,
            reason: '$filename: title missing',
          );
          expect(
            unit.coreConcept.isNotEmpty,
            isTrue,
            reason: '$filename: coreConcept missing',
          );
          expect(
            unit.exercises.length,
            15,
            reason: '$filename: must have exactly 15 exercises',
          );

          // 2. Formatting verification
          // coreConcept must have HTML tags for visual hierarchy
          expect(
            unit.coreConcept.contains('<br') ||
                unit.coreConcept.contains('<b>'),
            isTrue,
            reason:
                '$filename: coreConcept must contain HTML tags (<br/>, <b>)',
          );

          // commonTraps must contain <u> in examples
          for (final trap in unit.commonTraps) {
            expect(
              trap.exampleWrong.contains('<u>'),
              isTrue,
              reason:
                  '$filename Trap "${trap.trap}": exampleWrong must contain <u>',
            );
            expect(
              trap.exampleRight.contains('<u>'),
              isTrue,
              reason:
                  '$filename Trap "${trap.trap}": exampleRight must contain <u>',
            );
          }
        },
      );
    }

    test('Total exercise count across all units remains exactly 540', () {
      var totalExercises = 0;
      for (final file in files) {
        final content = file.readAsStringSync();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final unit = GrammarUnit.fromJson(json);
        totalExercises += unit.exercises.length;
      }
      expect(totalExercises, 540);
    });
  });
}
