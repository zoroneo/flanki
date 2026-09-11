import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/storage/media_storage_service.dart';

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

    final displayName =
        filename.length > 25 ? '${filename.substring(0, 22)}...' : filename;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: handlePlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPlaying.value
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(16),
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
                size: 14,
                color: isPlaying.value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.foreground,
              ),
              const SizedBox(width: 5),
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
