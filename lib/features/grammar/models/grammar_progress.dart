import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/models/card.dart';

part 'grammar_progress.freezed.dart';
part 'grammar_progress.g.dart';

@freezed
abstract class GrammarProgressModel with _$GrammarProgressModel {
  const GrammarProgressModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GrammarProgressModel({
    required String unitId,
    required String exerciseId,
    @Default(0.0) double stability,
    @Default(0.0) double difficulty,
    DateTime? due,
    DateTime? lastStudied,
    @Default(0) int reps,
    @Default(0) int lapses,
    @Default(CardState.newCard) CardState state,
    @Default(false) bool isGhost,
    @Default(false) bool isCompleted,
    String? lastUserAnswer,
    required DateTime updatedAt,
  }) = _GrammarProgressModel;

  factory GrammarProgressModel.fromJson(Map<String, dynamic> json) =>
      _$GrammarProgressModelFromJson(json);

  bool get isDue {
    if (due == null) return false;
    return due!.isBefore(DateTime.now().toUtc());
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
