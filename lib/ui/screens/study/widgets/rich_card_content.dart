import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
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
    final audioPlayer = useMemoized(() => AudioPlayer(), []);

    useEffect(() {
      return () {
        audioPlayer.dispose();
      };
    }, [audioPlayer]);

    // Extract [sound:filename.ext] tags
    final soundRegex = RegExp(r'\[sound:([^\]]+)\]', caseSensitive: false);
    final soundMatches = soundRegex.allMatches(content).toList();
    final soundFiles = soundMatches.map((m) => m.group(1)!.trim()).toList();

    // Auto-play the first audio clip if configured
    useEffect(() {
      if (autoPlayAudio && soundFiles.isNotEmpty) {
        final firstAudio = soundFiles.first;
        final path = MediaStorageService.instance.getMediaFilePath(firstAudio);
        if (File(path).existsSync()) {
          audioPlayer.play(DeviceFileSource(path));
        }
      }
      return null;
    }, [content]);

    // HTML content without [sound:...] tags
    var cleanHtml = content.replaceAll(soundRegex, '').trim();

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

    final defaultStyle = textStyle ??
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
                return {
                  'margin': '8px auto',
                  'border-collapse': 'collapse',
                };
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
          if (hasHtml || hasTypeInput || hasTypeResult) const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: soundFiles.map((filename) {
              return _AudioPlayButton(
                filename: filename,
                player: audioPlayer,
              );
            }).toList(),
          ),
        ],
      ],
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
    final controller = useTextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(LucideIcons.keyboard, size: 18, color: theme.colorScheme.mutedForeground),
            const SizedBox(width: 8),
            Expanded(
              child: m.TextField(
                controller: controller,
                autofocus: false,
                style: theme.typography.normal.copyWith(
                  color: theme.colorScheme.foreground,
                  fontWeight: FontWeight.w600,
                ),
                decoration: m.InputDecoration(
                  hintText: 'Nhập câu trả lời...',
                  hintStyle: theme.typography.normal.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  border: m.InputBorder.none,
                  isDense: true,
                ),
                onChanged: onAnswerChanged,
                onSubmitted: (_) => onSubmitAnswer?.call(),
              ),
            ),
            if (onSubmitAnswer != null)
              IconButton.ghost(
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                onPressed: onSubmitAnswer,
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeAnswerResultBox extends StatelessWidget {
  final String? typedAnswer;
  final String expectedAnswer;

  const _TypeAnswerResultBox({
    this.typedAnswer,
    required this.expectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typed = typedAnswer?.trim() ?? '';
    final expected = expectedAnswer.trim();
    final isCorrect = typed.isNotEmpty && typed.toLowerCase() == expected.toLowerCase();
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
                  const Icon(LucideIcons.circleCheck, color: m.Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Chính xác!',
                    style: theme.typography.semiBold.copyWith(color: m.Colors.green),
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
                  const Icon(LucideIcons.circleAlert, color: m.Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Đã nhập: ',
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
                    'Đáp án đúng: ',
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
                  Icon(LucideIcons.circleHelp, color: theme.colorScheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Đáp án: ',
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
  final AudioPlayer player;

  const _AudioPlayButton({
    required this.filename,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = useState(false);

    useEffect(() {
      final sub = player.onPlayerStateChanged.listen((state) {
        isPlaying.value = state == PlayerState.playing;
      });
      return sub.cancel;
    }, [player]);

    Future<void> handlePlay() async {
      final path = MediaStorageService.instance.getMediaFilePath(filename);
      final file = File(path);
      if (file.existsSync()) {
        try {
          isPlaying.value = true;
          await player.stop();
          await player.play(DeviceFileSource(path));
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
