class CardModel {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? hint;
  final String noteType; // 'basic', 'cloze', 'reversed'
  final int flag; // 0: None, 1: Red, 2: Orange, 3: Green, 4: Blue, 5: Pink, 6: Turquoise, 7: Purple
  final bool isSuspended;
  final bool isBuried;
  final List<String> tags;
  final int intervalDays;
  final double stability;
  final double difficulty;
  final int reps;
  final int lapses;
  final DateTime? due;
  final DateTime? lastStudied;
  final DateTime? createdAt;

  const CardModel({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.hint,
    this.noteType = 'basic',
    this.flag = 0,
    this.isSuspended = false,
    this.isBuried = false,
    this.tags = const [],
    this.intervalDays = 0,
    this.stability = 0.0,
    this.difficulty = 0.0,
    this.reps = 0,
    this.lapses = 0,
    this.due,
    this.lastStudied,
    this.createdAt,
  });

  bool get hasFlag => flag > 0 && flag <= 7;

  CardModel copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? hint,
    String? noteType,
    int? flag,
    bool? isSuspended,
    bool? isBuried,
    List<String>? tags,
    int? intervalDays,
    double? stability,
    double? difficulty,
    int? reps,
    int? lapses,
    DateTime? due,
    DateTime? lastStudied,
    DateTime? createdAt,
  }) {
    return CardModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      noteType: noteType ?? this.noteType,
      flag: flag ?? this.flag,
      isSuspended: isSuspended ?? this.isSuspended,
      isBuried: isBuried ?? this.isBuried,
      tags: tags ?? this.tags,
      intervalDays: intervalDays ?? this.intervalDays,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      due: due ?? this.due,
      lastStudied: lastStudied ?? this.lastStudied,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
