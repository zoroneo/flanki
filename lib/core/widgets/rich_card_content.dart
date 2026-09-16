import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import '../services/card_audio_service.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../database/media_storage_service.dart';
import '../theme/app_tokens.dart';
import 'audio_play_button.dart';
import 'type_answer_box.dart';

class _ParsedCardContent {
  final String cleanHtml;
  final bool hasTypeInput;
  final List<String> soundFiles;

  const _ParsedCardContent({
    required this.cleanHtml,
    required this.hasTypeInput,
    required this.soundFiles,
  });
}

/// Renders rich HTML flashcard content with local images, audio buttons,
/// and interactive type-in answer fields.
class RichCardContent extends HookWidget {
  final String content;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final bool autoPlayAudio;
  final String? typedAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;
  final FocusNode? typeAnswerFocusNode;

  const RichCardContent({
    super.key,
    required this.content,
    this.textStyle,
    this.textAlign = TextAlign.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.autoPlayAudio = false,
    this.typedAnswer,
    this.onAnswerChanged,
    this.onSubmitAnswer,
    this.typeAnswerFocusNode,
  });

  /// Check whether the raw content contains a type-in answer placeholder.
  static bool hasTypeInput(String? content) {
    if (content == null || content.isEmpty) return false;
    return _typeInputRegex.hasMatch(content);
  }

  // ignore: deprecated_member_use
  static final _soundRegex = RegExp(
    r'\[sound:([^\]]+)\]',
    caseSensitive: false,
  );
  // ignore: deprecated_member_use
  static final _legacyImgRegex = RegExp(
    r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''',
    caseSensitive: false,
  );
  // ignore: deprecated_member_use
  static final _typeInputRegex = RegExp(r'\[\[TYPE_INPUT:(.*?)\]\]');
  // ignore: deprecated_member_use
  static final _typeResultRegex = RegExp(r'\[\[TYPE_RESULT:(.*?)\]\]');
  // ignore: deprecated_member_use
  static final _curlyTagsRegex = RegExp(r'\{\{[^}]+\}\}');

  static _ParsedCardContent _parseContent(String content) {
    final soundMatches = _soundRegex.allMatches(content).toList();
    final soundFiles = soundMatches.map((m) => m.group(1)!.trim()).toList();

    var cleanHtml = content.replaceAllMapped(_soundRegex, (m) {
      final filename = m.group(1)!.trim();
      final escaped = htmlEscape.convert(filename);
      return '<anki-sound src="$escaped"></anki-sound>';
    });

    cleanHtml = cleanHtml.replaceAllMapped(
      _legacyImgRegex,
      (m) => '${m.group(1)}${m.group(2)}${m.group(3)}',
    );

    final hasTypeInput = _typeInputRegex.hasMatch(cleanHtml);
    cleanHtml = cleanHtml.replaceAll(_typeInputRegex, '').trim();

    cleanHtml = cleanHtml.replaceAllMapped(_typeResultRegex, (m) {
      final expected = m.group(1)!.trim();
      final escaped = htmlEscape.convert(expected);
      return '<anki-type-result expected="$escaped"></anki-type-result>';
    });

    cleanHtml = cleanHtml.replaceAll(_curlyTagsRegex, '').trim();

    if (cleanHtml.contains('\n') &&
        !cleanHtml.contains('<br') &&
        !cleanHtml.contains('<p>') &&
        !cleanHtml.contains('<p ') &&
        !cleanHtml.contains('<div')) {
      cleanHtml = cleanHtml.replaceAll('\r\n', '\n').replaceAll('\n', '<br/>');
    }

    return _ParsedCardContent(
      cleanHtml: cleanHtml,
      hasTypeInput: hasTypeInput,
      soundFiles: soundFiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final parsed = useMemoized(() => _parseContent(content), [content]);
    final soundFiles = parsed.soundFiles;
    final cleanHtml = parsed.cleanHtml;
    final hasTypeInput = parsed.hasTypeInput;

    // Auto-play the first audio clip if configured
    useEffect(() {
      if (autoPlayAudio && soundFiles.isNotEmpty) {
        final firstAudio = soundFiles.first;
        CardAudioService.instance.playMedia(firstAudio);
      }
      return null;
    }, [content, autoPlayAudio]);

    final hasHtml = cleanHtml.isNotEmpty;

    final isDark = theme.brightness == Brightness.dark;
    final processedHtml = isDark ? _adaptDarkModeHtml(cleanHtml) : cleanHtml;

    final alignCss = switch (textAlign) {
      TextAlign.center => 'center',
      TextAlign.right || TextAlign.end => 'right',
      TextAlign.justify => 'justify',
      _ => 'left',
    };
    final formattedHtml =
        '<div class="card-root" style="text-align: $alignCss">$processedHtml</div>';

    final baseStyle = textStyle ?? theme.typography.h3;
    final defaultStyle = baseStyle.copyWith(
      color: baseStyle.color ?? theme.colorScheme.foreground,
      fontWeight: baseStyle.fontWeight ?? FontWeight.w500,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (hasHtml)
          HtmlWidget(
            formattedHtml,
            textStyle: defaultStyle,
            customWidgetBuilder: (element) {
              if (element.localName == 'anki-sound') {
                final filename = element.attributes['src'] ?? '';
                if (filename.isEmpty) return const SizedBox.shrink();
                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: AudioPlayButton(filename: filename),
                  ),
                );
              }
              if (element.localName == 'anki-type-result') {
                final expected = element.attributes['expected'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Center(
                    child: TypeAnswerResultBox(
                      typedAnswer: typedAnswer,
                      expectedAnswer: expected,
                    ),
                  ),
                );
              }
              if (element.localName == 'img') {
                final rawSrc = element.attributes['src'] ?? '';
                if (rawSrc.isNotEmpty) {
                  if (rawSrc.startsWith('http://') ||
                      rawSrc.startsWith('https://')) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: AppRadius.borderMd,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Image.network(rawSrc, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  }

                  final filename = p.basename(rawSrc.replaceAll('file://', ''));
                  final localPath = MediaStorageService.instance
                      .getMediaFilePath(filename);
                  final file = File(localPath);

                  if (file.existsSync()) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: AppRadius.borderMd,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Image.file(
                              file,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildMissingMediaBadge(theme, filename),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return _buildMissingMediaBadge(theme, filename);
                  }
                }
              }
              return null;
            },
            customStylesBuilder: (element) {
              if (element.children.any((c) => c.localName == 'anki-sound')) {
                final isDark = theme.brightness == Brightness.dark;
                return {
                  'color': isDark ? '#e4e4e7' : '#3f3f46',
                  'font-weight': '600',
                  'margin-top': '4px',
                  'margin-bottom': '4px',
                };
              }
              if (element.localName == 'img') {
                return {
                  'max-width': '100%',
                  'height': 'auto',
                  'margin': '12px auto',
                  'border-radius': '10px',
                  'display': 'block',
                };
              }
              if (element.localName == 'table') {
                return {'margin': '8px auto', 'border-collapse': 'collapse'};
              }
              if (element.localName == 'mark') {
                final isDark = theme.brightness == Brightness.dark;
                return {
                  'background-color': isDark
                      ? 'rgba(245, 158, 11, 0.28)'
                      : 'rgba(245, 158, 11, 0.18)',
                  'color': isDark ? '#fbbf24' : '#b45309',
                  'padding': '1px 5px',
                  'border-radius': '4px',
                  'font-weight': '600',
                };
              }
              if (element.localName == 'code') {
                final isDark = theme.brightness == Brightness.dark;
                return {
                  'background-color': isDark
                      ? 'rgba(255, 255, 255, 0.09)'
                      : 'rgba(0, 0, 0, 0.06)',
                  'color': isDark ? '#e2e8f0' : '#334155',
                  'padding': '2px 6px',
                  'border-radius': '4px',
                  'font-family': 'monospace',
                  'font-size': '0.9em',
                };
              }
              if (element.localName == 'u') {
                return {
                  'text-decoration': 'underline',
                  'text-underline-offset': '3px',
                };
              }
              return null;
            },
          ),
        if (hasTypeInput) ...[
          AppGaps.v12,
          TypeAnswerInputBox(
            key: ValueKey(content),
            initialValue: typedAnswer ?? '',
            focusNode: typeAnswerFocusNode,
            onAnswerChanged: onAnswerChanged,
            onSubmitAnswer: onSubmitAnswer,
          ),
        ],
      ],
    );
  }

  static Widget _buildMissingMediaBadge(ThemeData theme, String filename) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: AppRadius.borderMd,
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.image,
            size: AppIconSize.sm,
            color: theme.colorScheme.mutedForeground,
          ),
          AppGaps.h8,
          Flexible(
            child: Text(
              filename,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.mutedForeground,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  static String _adaptDarkModeHtml(String html) {
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
            if (_isDarkColor(rawColor)) {
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
        if (_isDarkColor(rawColor)) {
          return '<font $before$after>';
        }
        return match.group(0)!;
      },
    );

    return result;
  }

  static bool _isDarkColor(String raw) {
    final val = raw.trim().toLowerCase();
    if (val == 'black' || val == 'darkgray' || val == 'darkgrey') {
      return true;
    }

    // Hex #rgb, #rrggbb, #rrggbbaa
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

    // rgb(...) or rgba(...)
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
