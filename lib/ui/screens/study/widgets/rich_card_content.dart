import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:path/path.dart' as p;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/storage/media_storage_service.dart';

/// Renders rich HTML flashcard content with local images, audio buttons,
/// and interactive type-in answer fields.
class RichCardContent extends HookWidget {
  final String content;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final bool autoPlayAudio;
  final String? typedAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;

  const RichCardContent({
    super.key,
    required this.content,
    this.textStyle,
    this.textAlign = TextAlign.center,
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

    // HTML content without [sound:...] tags
    var cleanHtml = content.replaceAll(soundRegex, '').trim();

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

    // Extract [[TYPE_RESULT:expected]] marker
    final typeResultRegex = RegExp(r'\[\[TYPE_RESULT:(.*?)\]\]');
    final typeResultMatch = typeResultRegex.firstMatch(cleanHtml);
    final hasTypeResult = typeResultMatch != null;
    final expectedResult = typeResultMatch?.group(1) ?? '';
    cleanHtml = cleanHtml.replaceAll(typeResultRegex, '').trim();

    // Clean up any stray curly tags
    cleanHtml = cleanHtml.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '').trim();

    final hasHtml = cleanHtml.isNotEmpty;

    final defaultStyle =
        textStyle ??
        theme.typography.h3.copyWith(
          color: theme.colorScheme.foreground,
          fontWeight: FontWeight.w500,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasHtml)
          HtmlWidget(
            cleanHtml,
            textStyle: defaultStyle,
            customWidgetBuilder: (element) {
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
              return null;
            },
          ),
        if (hasTypeInput) ...[
          const SizedBox(height: 12),
          _TypeAnswerInputBox(
            initialValue: typedAnswer ?? '',
            onAnswerChanged: onAnswerChanged,
            onSubmitAnswer: onSubmitAnswer,
          ),
        ],
        if (hasTypeResult) ...[
          const SizedBox(height: 12),
          _TypeAnswerResultBox(
            typedAnswer: typedAnswer,
            expectedAnswer: expectedResult,
          ),
        ],
        if (soundFiles.isNotEmpty) ...[
          if (hasHtml || hasTypeInput || hasTypeResult)
            const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: soundFiles.map((filename) {
              return _AudioPlayButton(filename: filename, player: audioPlayer);
            }).toList(),
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

class _TypeAnswerInputBox extends HookWidget {
  final String initialValue;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;

  const _TypeAnswerInputBox({
    this.initialValue = '',
    this.onAnswerChanged,
    this.onSubmitAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = useTextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: controller,
          autofocus: false,
          placeholder: Text(l10n.typeAnswerPlaceholder),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
          features: [
            InputFeature.leading(
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 6),
                child: Icon(
                  LucideIcons.keyboard,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            if (onSubmitAnswer != null)
              InputFeature.trailing(
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: onSubmitAnswer,
                    leading: const Icon(LucideIcons.send, size: 14),
                    child: Text(l10n.submitAnswer),
                  ),
                ),
              ),
          ],
          onChanged: onAnswerChanged,
          onSubmitted: (_) => onSubmitAnswer?.call(),
        ),
      ),
    );
  }
}

class _TypeAnswerResultBox extends StatelessWidget {
  final String? typedAnswer;
  final String expectedAnswer;

  const _TypeAnswerResultBox({this.typedAnswer, required this.expectedAnswer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final typed = typedAnswer?.trim() ?? '';
    final expected = expectedAnswer.trim();
    final isCorrect =
        typed.isNotEmpty && typed.toLowerCase() == expected.toLowerCase();
    final isEmpty = typed.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEmpty
              ? theme.colorScheme.muted
              : (isCorrect
                    ? m.Colors.green.withValues(alpha: 0.12)
                    : m.Colors.red.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? theme.colorScheme.border
                : (isCorrect ? m.Colors.green : m.Colors.red),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isCorrect) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.circleCheck,
                    color: m.Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.correctAnswerLabel,
                    style: theme.typography.semiBold.copyWith(
                      color: m.Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                expected,
                style: theme.typography.h3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: m.Colors.green.shade700,
                ),
              ),
            ] else if (!isEmpty) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.circleAlert,
                    color: m.Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.yourAnswerLabel,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  Text(
                    typed,
                    style: theme.typography.semiBold.copyWith(
                      color: m.Colors.red,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.expectedAnswerLabel,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  Text(
                    expected,
                    style: theme.typography.h4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: m.Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.circleHelp,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.answerLabel,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  Text(
                    expected,
                    style: theme.typography.h4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AudioPlayButton extends HookWidget {
  final String filename;
  final AudioPlayer? player;

  const _AudioPlayButton({required this.filename, required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = useState(false);

    useEffect(() {
      if (player == null) return null;
      final sub = player!.onPlayerStateChanged.listen((state) {
        isPlaying.value = state == PlayerState.playing;
      });
      return sub.cancel;
    }, [player]);

    Future<void> handlePlay() async {
      if (player == null) return;
      final path = MediaStorageService.instance.getMediaFilePath(filename);
      final file = File(path);
      if (file.existsSync()) {
        try {
          isPlaying.value = true;
          await player!.stop();
          await player!.play(DeviceFileSource(path));
        } catch (_) {
          isPlaying.value = false;
        }
      }
    }

    final displayName = filename.length > 25
        ? '${filename.substring(0, 22)}...'
        : filename;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: handlePlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isPlaying.value
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPlaying.value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying.value ? LucideIcons.volumeX : LucideIcons.volume2,
                size: 16,
                color: isPlaying.value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.foreground,
              ),
              const SizedBox(width: 6),
              Text(
                displayName,
                style: theme.typography.xSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPlaying.value
                      ? theme.colorScheme.primary
                      : theme.colorScheme.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
