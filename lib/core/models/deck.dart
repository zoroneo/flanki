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
    this.description = '',
    this.dueCount = 0,
    this.newCount = 0,
    this.totalCount = 0,
    this.lastStudied,
  });

  bool get isCram =>
      id.startsWith('cram') ||
      title.startsWith('⚡') ||
      title.toLowerCase().contains('cram');

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
