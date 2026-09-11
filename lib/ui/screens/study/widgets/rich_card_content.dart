import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/storage/media_storage_service.dart';
import 'audio_play_button.dart';
import 'type_answer_box.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Extract [sound:filename.ext] tags
    final soundRegex = useMemoized(
      () => RegExp(r'\[sound:([^\]]+)\]', caseSensitive: false),
      [],
    );
    final soundMatches = soundRegex.allMatches(content).toList();
    final soundFiles = soundMatches.map((m) => m.group(1)!.trim()).toList();

    // Only instantiate an AudioPlayer if there are sound files present
    final audioPlayer = useMemoized(
      () => soundFiles.isNotEmpty ? AudioPlayer() : null,
      [soundFiles.isNotEmpty],
    );

    useEffect(() {
      return () {
        if (audioPlayer != null) {
          audioPlayer
              .stop()
              .then((_) => audioPlayer.dispose())
              .catchError((_) {});
        }
      };
    }, [audioPlayer]);

    // Auto-play the first audio clip if configured
    useEffect(() {
      if (autoPlayAudio && soundFiles.isNotEmpty && audioPlayer != null) {
        final firstAudio = soundFiles.first;
        final path = MediaStorageService.instance.getMediaFilePath(firstAudio);
        if (File(path).existsSync()) {
          audioPlayer.play(DeviceFileSource(path)).catchError((_) {});
        }
      }
      return null;
    }, [content, audioPlayer]);

    // Convert [sound:filename] tags to inline <anki-sound> elements to preserve exact position
    var cleanHtml = content.replaceAllMapped(soundRegex, (m) {
      final filename = m.group(1)!.trim();
      final escaped = htmlEscape.convert(filename);
      return '<anki-sound src="$escaped"></anki-sound>';
    });

    // Clean legacy file:// absolute paths to standard relative filenames
    cleanHtml = cleanHtml.replaceAllMapped(
      RegExp(
        r'''(<img\s+[^>]*src\s*=\s*["'])file:\/\/[^"'>]*[\\\/]([^"'>]+)(["'][^>]*>)''',
        caseSensitive: false,
      ),
      (m) => '${m.group(1)}${m.group(2)}${m.group(3)}',
    );

    // Extract [[TYPE_INPUT:expected]] marker
    final typeInputRegex = RegExp(r'\[\[TYPE_INPUT:(.*?)\]\]');
    final hasTypeInput = typeInputRegex.hasMatch(cleanHtml);
    cleanHtml = cleanHtml.replaceAll(typeInputRegex, '').trim();

    // Convert [[TYPE_RESULT:expected]] marker to inline <anki-type-result> element
    final typeResultRegex = RegExp(r'\[\[TYPE_RESULT:(.*?)\]\]');
    cleanHtml = cleanHtml.replaceAllMapped(typeResultRegex, (m) {
      final expected = m.group(1)!.trim();
      final escaped = htmlEscape.convert(expected);
      return '<anki-type-result expected="$escaped"></anki-type-result>';
    });

    // Clean up any stray curly tags
    cleanHtml = cleanHtml.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '').trim();

    // If text contains newlines but no html break/paragraph tags, convert \n to <br/>
    if (cleanHtml.contains('\n') &&
        !cleanHtml.contains('<br') &&
        !cleanHtml.contains('<p>') &&
        !cleanHtml.contains('<p ') &&
        !cleanHtml.contains('<div')) {
      cleanHtml = cleanHtml.replaceAll('\r\n', '\n').replaceAll('\n', '<br/>');
    }

    final hasHtml = cleanHtml.isNotEmpty;

    final alignCss = switch (textAlign) {
      TextAlign.center => 'center',
      TextAlign.right || TextAlign.end => 'right',
      TextAlign.justify => 'justify',
      _ => 'left',
    };
    final formattedHtml = '<div style="text-align: $alignCss">$cleanHtml</div>';

    final defaultStyle =
        textStyle ??
        theme.typography.h3.copyWith(
          color: theme.colorScheme.foreground,
          fontWeight: FontWeight.w500,
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
                    child: AudioPlayButton(
                      filename: filename,
                      player: audioPlayer,
                    ),
                  ),
                );
              }
              if (element.localName == 'anki-type-result') {
                final expected = element.attributes['expected'] ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: Image.file(
                              file,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) =>
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
          const SizedBox(height: 12),
          TypeAnswerInputBox(
            initialValue: typedAnswer ?? '',
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.image,
            size: 14,
            color: theme.colorScheme.mutedForeground,
          ),
          const SizedBox(width: 6),
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
