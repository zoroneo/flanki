import 'package:freezed_annotation/freezed_annotation.dart';

part 'card.freezed.dart';
part 'card.g.dart';

enum NoteType {
  @JsonValue('basic')
  basic('basic'),
  @JsonValue('cloze')
  cloze('cloze'),
  @JsonValue('reversed')
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
  @JsonValue(0)
  none(0),
  @JsonValue(1)
  red(1),
  @JsonValue(2)
  orange(2),
  @JsonValue(3)
  green(3),
  @JsonValue(4)
  blue(4),
  @JsonValue(5)
  pink(5),
  @JsonValue(6)
  turquoise(6),
  @JsonValue(7)
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
  @JsonValue(1)
  again(1),
  @JsonValue(2)
  hard(2),
  @JsonValue(3)
  good(3),
  @JsonValue(4)
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
  @JsonValue(0)
  newCard(0),
  @JsonValue(1)
  learning(1),
  @JsonValue(2)
  review(2),
  @JsonValue(3)
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

class CardTagsConverter implements JsonConverter<List<String>, dynamic> {
  const CardTagsConverter();

  @override
  List<String> fromJson(dynamic json) {
    if (json == null) return const [];
    if (json is List) return json.map((e) => e.toString()).toList();
    if (json is String) {
      if (json.trim().isEmpty) return const [];
      return json
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
    }
    return const [];
  }

  @override
  dynamic toJson(List<String> object) => object.join(',');
}

@freezed
abstract class CardModel with _$CardModel {
  const CardModel._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CardModel({
    required String id,
    @Default('') String deckId,
    @Default('') String front,
    @Default('') String back,
    String? hint,
    @Default(NoteType.basic) NoteType noteType,
    @Default(CardFlag.none) CardFlag flag,
    @Default(false) bool isSuspended,
    @Default(false) bool isBuried,
    @CardTagsConverter() @Default([]) List<String> tags,
    @Default(0) int intervalDays,
    @Default(0.0) double stability,
    @Default(0.0) double difficulty,
    @Default(0) int reps,
    @Default(0) int lapses,
    DateTime? due,
    DateTime? lastStudied,
    DateTime? createdAt,
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);

  bool get hasFlag => flag != CardFlag.none;
}
