import 'package:json_annotation/json_annotation.dart';

part 'grammar_trap.g.dart';

@JsonSerializable()
class GrammarTrap {
  @JsonKey(defaultValue: '')
  final String trap;
  @JsonKey(defaultValue: '')
  final String exampleWrong;
  @JsonKey(defaultValue: '')
  final String exampleRight;
  @JsonKey(defaultValue: '')
  final String note;

  const GrammarTrap({
    required this.trap,
    required this.exampleWrong,
    required this.exampleRight,
    required this.note,
  });

  factory GrammarTrap.fromJson(Map<String, dynamic> json) =>
      _$GrammarTrapFromJson(json);

  Map<String, dynamic> toJson() => _$GrammarTrapToJson(this);
}
