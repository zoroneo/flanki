import 'dart:convert';
import 'dart:math' as math;

import '../config/app_config.dart';

class ParsedCardContent {
  final String cleanHtml;
  final bool hasTypeInput;
  final List<String> soundFiles;

  const ParsedCardContent({
    required this.cleanHtml,
    required this.hasTypeInput,
    required this.soundFiles,
  });
}

class CardContentParser {
  const CardContentParser._();

  // ignore: deprecated_member_use
  static final soundRegex = RegExp(r'\[sound:([^\]]+)\]', caseSensitive: false);
  // ignore: deprecated_member_use
  static final legacyImgRegex = RegExp(
    r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''',
    caseSensitive: false,
  );
  // ignore: deprecated_member_use
  static final typeInputRegex = RegExp(r'\[\[TYPE_INPUT:(.*?)\]\]');
  // ignore: deprecated_member_use
  static final typeResultRegex = RegExp(r'\[\[TYPE_RESULT:(.*?)\]\]');
  // ignore: deprecated_member_use
  static final curlyTagsRegex = RegExp(r'\{\{[^}]+\}\}');

  static bool hasTypeInput(String? content) {
    if (content == null || content.isEmpty) return false;
    return typeInputRegex.hasMatch(content);
  }

  static ParsedCardContent parse(String content) {
    final soundMatches = soundRegex.allMatches(content).toList();
    final soundFiles = soundMatches.map((m) => m.group(1)!.trim()).toList();

    var cleanHtml = content.replaceAllMapped(soundRegex, (m) {
      final filename = m.group(1)!.trim();
      final escaped = htmlEscape.convert(filename);
      return '<${AppConfig.customTagAnkiSound} src="$escaped"></${AppConfig.customTagAnkiSound}>';
    });

    cleanHtml = cleanHtml.replaceAllMapped(
      legacyImgRegex,
      (m) => '${m.group(1)}${m.group(2)}${m.group(3)}',
    );

    final containsType = typeInputRegex.hasMatch(cleanHtml);
    cleanHtml = cleanHtml.replaceAll(typeInputRegex, '').trim();

    cleanHtml = cleanHtml.replaceAllMapped(typeResultRegex, (m) {
      final expected = m.group(1)!.trim();
      final escaped = htmlEscape.convert(expected);
      return '<${AppConfig.customTagAnkiTypeResult} expected="$escaped"></${AppConfig.customTagAnkiTypeResult}>';
    });

    cleanHtml = cleanHtml.replaceAll(curlyTagsRegex, '').trim();

    // Prevent orphan punctuation dropping to next line by anchoring it inside closing inline tags
    cleanHtml = cleanHtml.replaceAllMapped(
      RegExp(r'(</(?:mark|span|b|strong|i|em|u|code)>)\s*([:;,!?.])'),
      (m) => '${m.group(2)}${m.group(1)}',
    );

    // Eliminate abnormal whitespace before punctuation (e.g. "tag ," -> "tag,")
    cleanHtml = cleanHtml.replaceAllMapped(
      RegExp(r'\s+([,;:!?.])'),
      (m) => m.group(1)!,
    );

    // Convert markdown tables before linebreaks
    cleanHtml = convertMarkdownTables(cleanHtml);

    if (cleanHtml.contains('\n') &&
        !cleanHtml.contains('<br') &&
        !cleanHtml.contains('<p>') &&
        !cleanHtml.contains('<p ') &&
        !cleanHtml.contains('<div') &&
        !cleanHtml.contains('<table')) {
      cleanHtml = cleanHtml.replaceAll('\r\n', '\n').replaceAll('\n', '<br/>');
    }

    return ParsedCardContent(
      cleanHtml: cleanHtml,
      hasTypeInput: containsType,
      soundFiles: soundFiles,
    );
  }

  /// Converts Markdown tables into HTML tables supported by HtmlWidget.
  /// Handles both standard pipe-separated tables and <br/>-separated pseudo tables.
  static String convertMarkdownTables(String text) {
    if (!text.contains('|')) return text;

    final lines = text.split(RegExp(r'\r?\n'));
    final output = <String>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i].trim();
      if (line.startsWith('|') && line.endsWith('|') && i + 1 < lines.length) {
        final nextLine = lines[i + 1].trim();
        final isBrDelim = RegExp(r':?-{3,}:?(?:<br\s*/?>:?-{3,}:?)+')
            .hasMatch(nextLine);
        final isPipeDelim = RegExp(r'\|?\s*:?-{3,}:?\s*\|').hasMatch(nextLine);

        if (isBrDelim || isPipeDelim) {
          final tableLines = <String>[];
          while (i < lines.length &&
              lines[i].trim().startsWith('|') &&
              lines[i].trim().endsWith('|')) {
            tableLines.add(lines[i].trim());
            i++;
          }

          if (tableLines.length >= 2) {
            final delimRaw = tableLines[1]
                .substring(1, tableLines[1].length - 1)
                .trim();
            final useBr =
                isBrDelim ||
                (delimRaw.contains('<br') && !delimRaw.contains('|'));

            List<String> splitCells(String r) {
              final raw = r.substring(1, r.length - 1).trim();
              if (useBr) {
                return raw
                    .split(RegExp(r'<br\s*/?>'))
                    .map((c) => c.trim())
                    .toList();
              } else {
                return raw.split('|').map((c) => c.trim()).toList();
              }
            }

            final headers = splitCells(tableLines[0]);
            final buffer = StringBuffer();
            buffer.write(
              '<table class="grammar-table" style="width:100%; border-collapse:collapse; margin:8px 0;">',
            );
            buffer.write('<thead><tr>');
            for (final h in headers) {
              buffer.write(
                '<th style="border:1px solid rgba(128,128,128,0.3); padding:6px 8px; font-weight:bold; background:rgba(128,128,128,0.1);">$h</th>',
              );
            }
            buffer.write('</tr></thead><tbody>');

            for (var r = 2; r < tableLines.length; r++) {
              final cells = splitCells(tableLines[r]);
              buffer.write('<tr>');
              for (final c in cells) {
                buffer.write(
                  '<td style="border:1px solid rgba(128,128,128,0.25); padding:6px 8px;">$c</td>',
                );
              }
              buffer.write('</tr>');
            }
            buffer.write('</tbody></table>');
            output.add(buffer.toString());
            continue;
          }
        }
      }
      output.add(lines[i]);
      i++;
    }

    return output.join('\n');
  }

  static String adaptDarkModeHtml(String html) {
    // 1. Replace dark colors in inline style="..." attributes with color: inherit
    var result = html.replaceAllMapped(
      RegExp(r'''style\s*=\s*(["'])(.*?)\1''', caseSensitive: false),
      (match) {
        final quote = match.group(1)!;
        final styleContent = match.group(2)!;
        final updatedStyle = styleContent.replaceAllMapped(
          RegExp(r'color\s*:\s*([^;!]+)', caseSensitive: false),
          (colorMatch) {
            final rawColor = colorMatch.group(1)!.trim();
            if (isDarkColor(rawColor)) {
              return 'color: inherit';
            }
            return colorMatch.group(0)!;
          },
        );
        return 'style=$quote$updatedStyle$quote';
      },
    );

    // 2. Remove dark color in <font color="..."> attributes
    result = result.replaceAllMapped(
      RegExp(
        r'''<font\s+([^>]*?)color\s*=\s*(["'])(.*?)\2([^>]*)>''',
        caseSensitive: false,
      ),
      (match) {
        final before = match.group(1)!;
        final rawColor = match.group(3)!.trim();
        final after = match.group(4)!;
        if (isDarkColor(rawColor)) {
          return '<font $before$after>';
        }
        return match.group(0)!;
      },
    );

    return result;
  }

  static bool isDarkColor(String raw) {
    final val = raw.trim().toLowerCase();
    if (val == 'black' || val == 'darkgray' || val == 'darkgrey') {
      return true;
    }

    if (val.startsWith('#')) {
      try {
        final hex = val.substring(1);
        int r = 0, g = 0, b = 0;
        if (hex.length == 3) {
          r = int.parse(hex[0], radix: 16) * 17;
          g = int.parse(hex[1], radix: 16) * 17;
          b = int.parse(hex[2], radix: 16) * 17;
        } else if (hex.length >= 6) {
          r = int.parse(hex.substring(0, 2), radix: 16);
          g = int.parse(hex.substring(2, 4), radix: 16);
          b = int.parse(hex.substring(4, 6), radix: 16);
        } else {
          return false;
        }

        final isNearGrayscale =
            (r - g).abs() <= 25 && (g - b).abs() <= 25 && (r - b).abs() <= 25;
        final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        final maxChannel = math.max(r, math.max(g, b));

        return (isNearGrayscale && luminance < 130) || maxChannel < 60;
      } catch (_) {
        return false;
      }
    }

    if (val.startsWith('rgb')) {
      try {
        final match = RegExp(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)')
            .firstMatch(val);
        if (match != null) {
          final r = int.parse(match.group(1)!);
          final g = int.parse(match.group(2)!);
          final b = int.parse(match.group(3)!);
          final isNearGrayscale =
              (r - g).abs() <= 25 && (g - b).abs() <= 25 && (r - b).abs() <= 25;
          final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
          final maxChannel = math.max(r, math.max(g, b));
          return (isNearGrayscale && luminance < 130) || maxChannel < 60;
        }
      } catch (_) {
        return false;
      }
    }

    return false;
  }
}
