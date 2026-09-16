import 'dart:io';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../config/app_config.dart';
import '../database/media_storage_service.dart';
import '../services/card_audio_service.dart';
import '../theme/app_tokens.dart';
import 'audio_play_button.dart';
import 'card_content_parser.dart';
import 'type_answer_box.dart';

export 'card_content_parser.dart' show ParsedCardContent, CardContentParser;

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
  static bool hasTypeInput(String? content) =>
      CardContentParser.hasTypeInput(content);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final parsed = useMemoized(() => CardContentParser.parse(content), [
      content,
    ]);
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
    final processedHtml = isDark
        ? CardContentParser.adaptDarkModeHtml(cleanHtml)
        : cleanHtml;

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
              if (element.localName == AppConfig.customTagAnkiSound) {
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
              if (element.localName == AppConfig.customTagAnkiTypeResult) {
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
              if (element.children
                  .any((c) => c.localName == AppConfig.customTagAnkiSound)) {
                final isDarkTheme = theme.brightness == Brightness.dark;
                return {
                  'color': isDarkTheme ? '#e4e4e7' : '#3f3f46',
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
                final isDarkTheme = theme.brightness == Brightness.dark;
                return {
                  'background-color': isDarkTheme
                      ? 'rgba(245, 158, 11, 0.28)'
                      : 'rgba(245, 158, 11, 0.18)',
                  'color': isDarkTheme ? '#fbbf24' : '#b45309',
                  'padding': '1px 5px',
                  'border-radius': '4px',
                  'font-weight': '600',
                };
              }
              if (element.localName == 'code') {
                final isDarkTheme = theme.brightness == Brightness.dark;
                return {
                  'background-color': isDarkTheme
                      ? 'rgba(255, 255, 255, 0.09)'
                      : 'rgba(0, 0, 0, 0.06)',
                  'color': isDarkTheme ? '#e2e8f0' : '#334155',
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
}
