import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/storage/media_storage_service.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AudioPlayButton extends HookWidget {
  final String filename;
  final AudioPlayer? player;

  const AudioPlayButton({
    super.key,
    required this.filename,
    required this.player,
  });

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

    final l10n = AppLocalizations.of(context);
    final tooltipText = l10n?.audioPlay ?? 'Play audio';

    return Tooltip(
      tooltip: (context) => TooltipContainer(child: Text(tooltipText)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: handlePlay,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isPlaying.value
                  ? theme.colorScheme.primary.withValues(alpha: 0.18)
                  : theme.colorScheme.muted.withValues(alpha: 0.75),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPlaying.value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            child: Icon(
              isPlaying.value ? LucideIcons.volumeX : LucideIcons.volume2,
              size: 14,
              color: isPlaying.value
                  ? theme.colorScheme.primary
                  : theme.colorScheme.foreground.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}
