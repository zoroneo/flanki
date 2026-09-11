class GrammarTrap {
  final String trap;
  final String exampleWrong;
  final String exampleRight;
  final String note;

  const GrammarTrap({
    required this.trap,
    required this.exampleWrong,
    required this.exampleRight,
    required this.note,
  });

  factory GrammarTrap.fromJson(Map<String, dynamic> json) {
    return GrammarTrap(
      trap: json['trap'] as String? ?? '',
      exampleWrong: json['exampleWrong'] as String? ?? '',
      exampleRight: json['exampleRight'] as String? ?? '',
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'trap': trap,
    'exampleWrong': exampleWrong,
    'exampleRight': exampleRight,
    'note': note,
  };
}
