import '../card.dart';

class GrammarProgressModel {
  final String unitId;
  final String exerciseId;
  final double stability;
  final double difficulty;
  final DateTime? due;
  final DateTime? lastStudied;
  final int reps;
  final int lapses;
  final CardState state;
  final bool isGhost;
  final bool isCompleted;
  final String? lastUserAnswer;
  final DateTime updatedAt;

  const GrammarProgressModel({
    required this.unitId,
    required this.exerciseId,
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.due,
    this.lastStudied,
    this.reps = 0,
    this.lapses = 0,
    this.state = CardState.newCard,
    this.isGhost = false,
    this.isCompleted = false,
    this.lastUserAnswer,
    required this.updatedAt,
  });

  bool get isDue {
    if (due == null) return false;
    return due!.isBefore(DateTime.now().toUtc());
  }

  GrammarProgressModel copyWith({
    String? unitId,
    String? exerciseId,
    double? stability,
    double? difficulty,
    DateTime? due,
    DateTime? lastStudied,
    int? reps,
    int? lapses,
    CardState? state,
    bool? isGhost,
    bool? isCompleted,
    String? lastUserAnswer,
    DateTime? updatedAt,
  }) {
    return GrammarProgressModel(
      unitId: unitId ?? this.unitId,
      exerciseId: exerciseId ?? this.exerciseId,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      due: due ?? this.due,
      lastStudied: lastStudied ?? this.lastStudied,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      isGhost: isGhost ?? this.isGhost,
      isCompleted: isCompleted ?? this.isCompleted,
      lastUserAnswer: lastUserAnswer ?? this.lastUserAnswer,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UnitProgressSummary {
  final String unitId;
  final int totalExercises;
  final int completedCount;
  final int ghostCount;
  final int dueCount;
  final double masteryPercentage; // 0.0 to 100.0%

  const UnitProgressSummary({
    required this.unitId,
    this.totalExercises = 15,
    this.completedCount = 0,
    this.ghostCount = 0,
    this.dueCount = 0,
    this.masteryPercentage = 0.0,
  });

  bool get isMastered => masteryPercentage >= 90.0;
}
