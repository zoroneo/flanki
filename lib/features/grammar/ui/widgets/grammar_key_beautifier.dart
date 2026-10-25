import '../../data/grammar_topic_catalog.dart';

/// Utility to format raw camelCase keys from formulas and extraGuides
/// into elegant, human-readable section titles.
class GrammarKeyBeautifier {
  const GrammarKeyBeautifier._();

  static const Map<String, String> _customTitles = GrammarTopicCatalog.titles;

  /// Converts a raw key into a formatted, human-readable title.
  static String format(String rawKey) {
    if (rawKey.isEmpty) return '';

    final mapped = _customTitles[rawKey];
    if (mapped != null) return mapped;

    // Fallback: Split camelCase into Title Case
    final buffer = StringBuffer();
    for (var i = 0; i < rawKey.length; i++) {
      final char = rawKey[i];
      if (i > 0 &&
          char.toUpperCase() == char &&
          rawKey[i - 1].toLowerCase() == rawKey[i - 1]) {
        buffer.write(' ');
      }
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
