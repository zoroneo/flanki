import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/auth_notifier.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../sync/ui/anki_web_auth_sheet.dart';

class AccountSyncCard extends ConsumerWidget {
  final ValueNotifier<bool> isSyncing;
  final Future<void> Function() onSync;

  const AccountSyncCard({
    super.key,
    required this.isSyncing,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.accountAndSync,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        AppGaps.v8,
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAccountStatusHeader(theme, l10n, authState),
              AppGaps.v16,
              const Divider(),
              AppGaps.v12,
              _buildActionsRow(context, theme, l10n, authState, authNotifier),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountStatusHeader(
    ThemeData theme,
    dynamic l10n,
    AuthState authState,
  ) {
    return Row(
      children: [
        Container(
          padding: AppEdgeInsets.all8,
          decoration: BoxDecoration(
            color: authState.isAuthenticated
                ? m.Colors.green.withValues(alpha: 0.15)
                : theme.colorScheme.muted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            authState.isAuthenticated
                ? LucideIcons.cloud
                : LucideIcons.cloudOff,
            color: authState.isAuthenticated
                ? m.Colors.green
                : theme.colorScheme.mutedForeground,
            size: AppIconSize.md,
          ),
        ),
        AppGaps.h12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authState.isAuthenticated
                    ? authState.email!
                    : l10n.notLinkedAnkiWeb,
                style: theme.typography.semiBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppGaps.v2,
              Text(
                authState.isAuthenticated
                    ? (authState.lastSyncedAt != null
                          ? l10n.syncedAt(
                              '${authState.lastSyncedAt!.hour.toString().padLeft(2, '0')}:${authState.lastSyncedAt!.minute.toString().padLeft(2, '0')}',
                            )
                          : l10n.readyToSync)
                    : l10n.loginToSyncHint,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsRow(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    AuthState authState,
    AuthNotifier authNotifier,
  ) {
    if (authState.isAuthenticated) {
      return SizedBox(
        height: 42,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OutlineButton(
                alignment: Alignment.center,
                onPressed: () async {
                  await authNotifier.logout();
                  if (context.mounted) {
                    showToast(
                      context: context,
                      builder: (context, overlay) {
                        return SurfaceCard(
                          child: Basic(
                            title: Text(l10n.loggedOut),
                            subtitle: Text(l10n.logoutSubtitle),
                            trailing: IconButton.ghost(
                              icon: const Icon(LucideIcons.x),
                              onPressed: () => overlay.close(),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.logOut,
                      size: AppIconSize.sm,
                      color: theme.colorScheme.destructive,
                    ),
                    AppGaps.h8,
                    Text(
                      l10n.logout,
                      style: TextStyle(color: theme.colorScheme.destructive),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
            AppGaps.h8,
            Expanded(
              child: PrimaryButton(
                alignment: Alignment.center,
                onPressed: isSyncing.value ? null : onSync,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSyncing.value)
                      const SizedBox(
                        width: AppSpacing.md,
                        height: AppSpacing.md,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(LucideIcons.refreshCw, size: AppIconSize.sm),
                    AppGaps.h8,
                    Text(
                      isSyncing.value ? l10n.syncing : l10n.sync,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: PrimaryButton(
        alignment: Alignment.center,
        onPressed: () => AnkiWebAuthSheet.show(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logIn, size: AppIconSize.sm),
            AppGaps.h8,
            Text(l10n.connectAnkiWeb, overflow: TextOverflow.visible),
          ],
        ),
      ),
    );
  }
}
