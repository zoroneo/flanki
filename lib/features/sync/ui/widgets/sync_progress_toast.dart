import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class SyncProgressStatus {
  final String title;
  final String message;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final bool isError;

  const SyncProgressStatus({
    required this.title,
    required this.message,
    this.progress = 0.0,
    this.isCompleted = false,
    this.isError = false,
  });
}

class SyncProgressToast extends StatelessWidget {
  final ValueNotifier<SyncProgressStatus> statusNotifier;
  final VoidCallback onClose;

  const SyncProgressToast({
    super.key,
    required this.statusNotifier,
    required this.onClose,
  });

  static ToastOverlay show({
    required BuildContext context,
    required ValueNotifier<SyncProgressStatus> statusNotifier,
  }) {
    late ToastOverlay overlay;
    overlay = showToast(
      context: context,
      showDuration: const Duration(minutes: 5),
      builder: (context, currentOverlay) {
        return SyncProgressToast(
          statusNotifier: statusNotifier,
          onClose: () => currentOverlay.close(),
        );
      },
    );
    return overlay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<SyncProgressStatus>(
      valueListenable: statusNotifier,
      builder: (context, status, _) {
        final pct = (status.progress * 100).toInt().clamp(0, 100);

        return SurfaceCard(
          padding: AppEdgeInsets.h16v12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (status.isError)
                    const Icon(
                      LucideIcons.cloudOff,
                      color: m.Colors.red,
                      size: AppIconSize.md,
                    )
                  else if (status.isCompleted)
                    const Icon(
                      LucideIcons.cloud,
                      color: m.Colors.green,
                      size: AppIconSize.md,
                    )
                  else
                    const SizedBox(
                      width: AppIconSize.sm,
                      height: AppIconSize.sm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  AppGaps.h8,
                  Expanded(
                    child: Text(
                      status.title,
                      style: theme.typography.semiBold.copyWith(fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton.ghost(
                    icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
                    onPressed: onClose,
                  ),
                ],
              ),
              AppGaps.v6,
              Text(
                status.message,
                style: theme.typography.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              AppGaps.v8,
              Row(
                children: [
                  Expanded(
                    child: Progress(progress: status.progress.clamp(0.0, 1.0)),
                  ),
                  AppGaps.h8,
                  Text(
                    '$pct%',
                    style: theme.typography.xSmall.copyWith(
                      color: theme.colorScheme.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
