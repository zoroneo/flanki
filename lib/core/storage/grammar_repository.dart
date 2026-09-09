import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/grammar/grammar_models.dart';
import 'app_database.dart';
import 'database_service.dart';

final grammarRepositoryProvider = Provider<GrammarRepository>((ref) {
  final db = DatabaseService.instance.db;
  final repo = GrammarRepository(db);
  return repo;
});

class GrammarRepository {
  final AppDatabase _db;

  // In-memory cache keyed by "unitId:exerciseId" for zero-latency synchronous reads
  final Map<String, GrammarProgressModel> _cache = {};
  bool _isInitialized = false;

  GrammarRepository(this._db);

  String _cacheKey(String unitId, String exerciseId) => '$unitId:$exerciseId';

  /// Preload all progress entries into memory cache
  Future<void> init() async {
    if (_isInitialized) return;
    final entries = await _db.select(_db.grammarProgressEntries).get();
    _cache.clear();
    for (final entry in entries) {
      final model = _toModel(entry);
      _cache[_cacheKey(model.unitId, model.exerciseId)] = model;
    }
    _isInitialized = true;
  }

  /// Synchronous retrieval of a single exercise's progress
  GrammarProgressModel? getProgress(String unitId, String exerciseId) {
    return _cache[_cacheKey(unitId, exerciseId)];
  }

  /// Get all progress entries for a specific unit
  List<GrammarProgressModel> getUnitProgressList(String unitId) {
    return _cache.values.where((p) => p.unitId == unitId).toList();
  }

  /// Calculate unit mastery and review summary
  UnitProgressSummary getUnitSummary(
    String unitId, {
    int totalExercises = GrammarConstants.exercisesPerUnit,
  }) {
    final list = getUnitProgressList(unitId);
    int completed = 0;
    int ghosts = 0;
    int dues = 0;
    double totalStabilityRatio = 0.0;

    for (final p in list) {
      if (p.isCompleted) completed++;
      if (p.isGhost) ghosts++;
      if (p.isDue) dues++;

      // Mastery: capped at masteryStabilityCapDays = 100%
      final itemMastery =
          (p.stability / GrammarConstants.masteryStabilityCapDays).clamp(0.0, 1.0) *
              100.0;
      totalStabilityRatio += itemMastery;
    }

    final mastery = totalExercises > 0
        ? (totalStabilityRatio / totalExercises).clamp(0.0, 100.0)
        : 0.0;

    return UnitProgressSummary(
      unitId: unitId,
      totalExercises: totalExercises,
      completedCount: completed,
      ghostCount: ghosts,
      dueCount: dues,
      masteryPercentage: mastery,
    );
  }

  /// Save or update an exercise progress entry (in-memory + SQLite)
  Future<void> saveProgress(GrammarProgressModel model) async {
    // 1. Update in-memory cache immediately
    _cache[_cacheKey(model.unitId, model.exerciseId)] = model;

    // 2. Persist to SQLite
    final companion = GrammarProgressEntriesCompanion(
      unitId: Value(model.unitId),
      exerciseId: Value(model.exerciseId),
      stability: Value(model.stability),
      difficulty: Value(model.difficulty),
      due: Value(model.due),
      lastStudied: Value(model.lastStudied),
      reps: Value(model.reps),
      lapses: Value(model.lapses),
      state: Value(model.state),
      isGhost: Value(model.isGhost),
      isCompleted: Value(model.isCompleted),
      lastUserAnswer: Value(model.lastUserAnswer),
      updatedAt: Value(DateTime.now().toUtc()),
    );

    await _db
        .into(_db.grammarProgressEntries)
        .insertOnConflictUpdate(companion);
  }

  /// Get all active Ghost reviews across all units
  List<GrammarProgressModel> getAllGhosts() {
    return _cache.values.where((p) => p.isGhost).toList();
  }

  /// Get all Due reviews across all units
  List<GrammarProgressModel> getAllDue() {
    return _cache.values.where((p) => p.isDue).toList();
  }

  /// Total count of completed exercises across all units
  int get totalCompletedCount =>
      _cache.values.where((p) => p.isCompleted).length;

  /// Total count of active ghosts across all units
  int get totalGhostCount => _cache.values.where((p) => p.isGhost).length;

  /// Total count of due items across all units
  int get totalDueCount => _cache.values.where((p) => p.isDue).length;

  /// Clear all progress for a unit (e.g. user chooses to reset unit)
  Future<void> resetUnit(String unitId) async {
    _cache.removeWhere((k, v) => v.unitId == unitId);
    await (_db.delete(_db.grammarProgressEntries)
          ..where((tbl) => tbl.unitId.equals(unitId)))
        .go();
  }

  GrammarProgressModel _toModel(GrammarProgressEntry entry) {
    return GrammarProgressModel(
      unitId: entry.unitId,
      exerciseId: entry.exerciseId,
      stability: entry.stability,
      difficulty: entry.difficulty,
      due: entry.due,
      lastStudied: entry.lastStudied,
      reps: entry.reps,
      lapses: entry.lapses,
      state: entry.state,
      isGhost: entry.isGhost,
      isCompleted: entry.isCompleted,
      lastUserAnswer: entry.lastUserAnswer,
      updatedAt: entry.updatedAt,
    );
  }
}
