enum NoteType {
  basic('basic'),
  cloze('cloze'),
  reversed('reversed');

  final String value;
  const NoteType(this.value);

  static NoteType fromString(String? val) {
    return NoteType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => NoteType.basic,
    );
  }
}

enum CardFlag {
  none(0),
  red(1),
  orange(2),
  green(3),
  blue(4),
  pink(5),
  turquoise(6),
  purple(7);

  final int value;
  const CardFlag(this.value);

  static CardFlag fromValue(int? val) {
    return CardFlag.values.firstWhere(
      (e) => e.value == val,
      orElse: () => CardFlag.none,
    );
  }
}

enum ReviewRating {
  again(1),
  hard(2),
  good(3),
  easy(4);

  final int value;
  const ReviewRating(this.value);

  static ReviewRating fromValue(int val) {
    return ReviewRating.values.firstWhere(
      (e) => e.value == val,
      orElse: () => ReviewRating.again,
    );
  }
}

enum CardState {
  newCard(0),
  learning(1),
  review(2),
  relearning(3);

  final int value;
  const CardState(this.value);

  static CardState fromValue(int? val) {
    return CardState.values.firstWhere(
      (e) => e.value == val,
      orElse: () => CardState.newCard,
    );
  }
}

class CardModel {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String? hint;
  final NoteType noteType;
  final CardFlag flag;
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
    this.noteType = NoteType.basic,
    this.flag = CardFlag.none,
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

  bool get hasFlag => flag != CardFlag.none;

  CardModel copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? hint,
    NoteType? noteType,
    CardFlag? flag,
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
