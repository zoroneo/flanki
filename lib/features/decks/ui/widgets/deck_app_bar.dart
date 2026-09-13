import 'package:flutter/material.dart' as m;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/auth_notifier.dart';
import '../../../settings/providers/settings_notifier.dart';

class DeckAppBar extends StatelessWidget {
  final ValueNotifier<bool> isSyncing;
  final Future<void> Function() onSync;
  final dynamic l10n;

  const DeckAppBar({
    super.key,
    required this.isSyncing,
    required this.onSync,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Row(
        children: [
          const Icon(LucideIcons.zap, size: AppIconSize.md),
          AppGaps.h8,
          Text(
            'Flanki',
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGaps.h8,
          Consumer(
            builder: (context, ref, _) {
              final fsrsEnabled = ref.watch(
                studySettingsProvider.select((s) => s.fsrsEnabled),
              );
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  fsrsEnabled ? 'FSRS v5' : 'SM-2',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      trailing: [
        Consumer(
          builder: (context, ref, _) {
            final isAuthenticated = ref.watch(
              authNotifierProvider.select((s) => s.isAuthenticated),
            );
            return GhostButton(
              onPressed: isSyncing.value ? null : onSync,
              leading: isSyncing.value
                  ? const SizedBox(
                      width: AppIconSize.sm,
                      height: AppIconSize.sm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      LucideIcons.cloud,
                      size: AppIconSize.sm,
                      color: isAuthenticated ? m.Colors.green : null,
                    ),
              child: Text(
                isAuthenticated ? l10n.linkedBadge : l10n.syncBadge,
                maxLines: 1,
                softWrap: false,
              ),
            );
          },
        ),
      ],
    );
  }
}
