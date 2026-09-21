import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/database/media_storage_service.dart';
import '../../../../core/services/card_audio_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../theme/app_tokens.dart';

class AudioPlayButton extends HookWidget {
  final String filename;
  final AudioPlayer? player;

  const AudioPlayButton({super.key, required this.filename, this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaying = useState(false);

    useEffect(() {
      if (player != null) {
        final sub = player!.onPlayerStateChanged.listen((state) {
          isPlaying.value = state == PlayerState.playing;
        });
        return sub.cancel;
      }

      void checkPlaying() {
        isPlaying.value =
            CardAudioService.instance.currentPlayingFilename == filename;
      }

      CardAudioService.instance.playingFilenameNotifier.addListener(
        checkPlaying,
      );
      checkPlaying();
      return () => CardAudioService.instance.playingFilenameNotifier
          .removeListener(checkPlaying);
    }, [player, filename]);

    Future<void> handlePlay() async {
      if (player != null) {
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
        return;
      }

      if (isPlaying.value) {
        await CardAudioService.instance.stop();
      } else {
        await CardAudioService.instance.playMedia(filename);
      }
    }

    final l10n = AppLocalizations.of(context)!;
    final tooltipText = isPlaying.value ? l10n.audioStop : l10n.audioPlay;

    return Tooltip(
      tooltip: (context) => TooltipContainer(child: Text(tooltipText)),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: handlePlay,
          child: AnimatedContainer(
            duration: AppDurations.short,
            width: AppDimensions.audioButtonSize,
            height: AppDimensions.audioButtonSize,
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
              size: AppIconSize.sm,
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
