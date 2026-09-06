class DeckModel {
  final String id;
  final String title;
  final String description;
  final int dueCount;
  final int newCount;
  final int totalCount;
  final DateTime? lastStudied;

  const DeckModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueCount,
    required this.newCount,
    required this.totalCount,
    this.lastStudied,
  });

  DeckModel copyWith({
    String? id,
    String? title,
    String? description,
    int? dueCount,
    int? newCount,
    int? totalCount,
    DateTime? lastStudied,
  }) {
    return DeckModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueCount: dueCount ?? this.dueCount,
      newCount: newCount ?? this.newCount,
      totalCount: totalCount ?? this.totalCount,
      lastStudied: lastStudied ?? this.lastStudied,
    );
  }
}
