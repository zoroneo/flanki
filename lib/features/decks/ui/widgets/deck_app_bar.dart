import 'package:flutter/material.dart' as m;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/auth_notifier.dart';
import '../../../../core/notifiers/settings_notifier.dart';

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
          const Icon(LucideIcons.zap, size: 20),
          const SizedBox(width: 8),
          Text(
            'Flanki',
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Consumer(
            builder: (context, ref, _) {
              final fsrsEnabled = ref.watch(
                studySettingsProvider.select((s) => s.fsrsEnabled),
              );
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
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
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      LucideIcons.cloud,
                      size: 16,
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
