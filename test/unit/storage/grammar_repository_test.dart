import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flanki/core/models/card.dart';
import 'package:flanki/features/grammar/models/grammar_models.dart';
import 'package:flanki/core/database/app_database.dart';
import 'package:flanki/features/grammar/data/grammar_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late GrammarRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = GrammarRepository(db);
    await repo.init();
  });

  tearDown(() async {
    await db.close();
  });

  group('GrammarRepository & SQLite Storage Tests', () {
    test('Starts empty', () {
      expect(repo.totalCompletedCount, equals(0));
      expect(repo.totalGhostCount, equals(0));
      expect(repo.totalDueCount, equals(0));

      final summary = repo.getUnitSummary('unit-01');
      expect(summary.completedCount, equals(0));
      expect(summary.masteryPercentage, equals(0.0));
    });

    test('Saves, caches and persists exercise progress', () async {
      final now = DateTime.now().toUtc();
      final progress = GrammarProgressModel(
        unitId: 'unit-01',
        exerciseId: 'ex_01',
        stability: 15.0,
        difficulty: 4.2,
        due: now.add(const Duration(days: 15)),
        lastStudied: now,
        reps: 2,
        lapses: 0,
        state: CardState.review,
        isGhost: false,
        isCompleted: true,
        lastUserAnswer: 'works',
        updatedAt: now,
      );

      await repo.saveProgress(progress);

      // 1. In-memory sync read
      final cached = repo.getProgress('unit-01', 'ex_01');
      expect(cached, isNotNull);
      expect(cached!.unitId, equals('unit-01'));
      expect(cached.exerciseId, equals('ex_01'));
      expect(cached.stability, equals(15.0));
      expect(cached.isCompleted, isTrue);

      // 2. Fresh repository reads from SQLite
      final freshRepo = GrammarRepository(db);
      await freshRepo.init();
      final persisted = freshRepo.getProgress('unit-01', 'ex_01');
      expect(persisted, isNotNull);
      expect(persisted!.stability, equals(15.0));
      expect(persisted.isCompleted, isTrue);
    });

    test('Calculates unit mastery and summary accurately', () async {
      final now = DateTime.now().toUtc();

      // Add 3 exercises to unit-01
      // Ex 1: Stability masteryStabilityCapDays (100% item mastery)
      await repo.saveProgress(
        GrammarProgressModel(
          unitId: 'unit-01',
          exerciseId: 'ex_01',
          stability: GrammarConstants.masteryStabilityCapDays,
          isCompleted: true,
          updatedAt: now,
        ),
      );

      // Ex 2: Stability 15 (50% item mastery), isGhost = true
      await repo.saveProgress(
        GrammarProgressModel(
          unitId: 'unit-01',
          exerciseId: 'ex_02',
          stability: 15.0,
          isGhost: true,
          isCompleted: true,
          updatedAt: now,
        ),
      );

      // Ex 3: Due in the past
      await repo.saveProgress(
        GrammarProgressModel(
          unitId: 'unit-01',
          exerciseId: 'ex_03',
          stability: 3.0,
          due: now.subtract(const Duration(hours: 1)),
          isCompleted: true,
          updatedAt: now,
        ),
      );

      final summary = repo.getUnitSummary(
        'unit-01',
        totalExercises: GrammarConstants.exercisesPerUnit,
      );

      expect(summary.completedCount, equals(3));
      expect(summary.ghostCount, equals(1));
      expect(summary.dueCount, equals(1));

      // Item 1: 100%, Item 2: 50%, Item 3: (3/30)*100 = 10%. Total = 160% / 15 items = 10.67%
      expect(summary.masteryPercentage, closeTo(10.67, 0.05));
      expect(summary.isMastered, isFalse);

      expect(repo.getAllGhosts().length, equals(1));
      expect(repo.getAllDue().length, equals(1));
    });

    test('Resets unit progress cleanly', () async {
      final now = DateTime.now().toUtc();
      await repo.saveProgress(
        GrammarProgressModel(
          unitId: 'unit-01',
          exerciseId: 'ex_01',
          isCompleted: true,
          updatedAt: now,
        ),
      );

      expect(repo.getProgress('unit-01', 'ex_01'), isNotNull);

      await repo.resetUnit('unit-01');

      expect(repo.getProgress('unit-01', 'ex_01'), isNull);
      final summary = repo.getUnitSummary('unit-01');
      expect(summary.completedCount, equals(0));
    });
  });
}
