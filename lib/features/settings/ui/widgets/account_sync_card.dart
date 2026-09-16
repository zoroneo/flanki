import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/auth_notifier.dart';
import '../../../sync/providers/supabase_auth_notifier.dart';
import '../../../sync/providers/sync_state_notifier.dart';
import '../../../sync/ui/anki_web_auth_sheet.dart';
import '../../../sync/ui/supabase_auth_sheet.dart';

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
    final cloudAuth = ref.watch(supabaseAuthNotifierProvider);
    final cloudAuthNotifier = ref.read(supabaseAuthNotifierProvider.notifier);
    final syncState = ref.watch(syncStateNotifierProvider);
    final syncNotifier = ref.read(syncStateNotifierProvider.notifier);

    final ankiAuthState = ref.watch(authNotifierProvider);
    final ankiAuthNotifier = ref.read(authNotifierProvider.notifier);

    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          l10n.accountAndSync,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        AppGaps.v8,

        // --- 1. Primary Card: Flanki Cloud Sync ---
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCloudHeader(theme, l10n, cloudAuth, syncState),
              AppGaps.v16,
              const Divider(),
              AppGaps.v12,
              _buildCloudActions(
                context,
                theme,
                l10n,
                cloudAuth,
                cloudAuthNotifier,
                syncState,
                syncNotifier,
              ),
            ],
          ),
        ),

        AppGaps.v16,

        // --- 2. Secondary Card: Legacy AnkiWeb Sync ---
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.repeat,
                    size: AppIconSize.sm,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  AppGaps.h8,
                  Text(
                    l10n.ankiWebLegacy,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (ankiAuthState.isAuthenticated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: m.Colors.green.withValues(alpha: 0.15),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Text(
                        l10n.linkedBadge,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: m.Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              AppGaps.v8,
              Text(
                l10n.connectAnkiWebSubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
              AppGaps.v12,
              if (ankiAuthState.isAuthenticated)
                OutlineButton(
                  onPressed: () => ankiAuthNotifier.logout(),
                  child: Text(l10n.logout),
                )
              else
                OutlineButton(
                  onPressed: () => AnkiWebAuthSheet.show(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.logIn, size: AppIconSize.sm),
                      AppGaps.h8,
                      Text(l10n.connectAnkiWeb),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCloudHeader(
    ThemeData theme,
    dynamic l10n,
    SupabaseAuthState cloudAuth,
    SyncUiState syncState,
  ) {
    final isOnlineAndAuthed = cloudAuth.isAuthenticated && !syncState.isOffline;

    return Row(
      children: [
        Container(
          padding: AppEdgeInsets.all8,
          decoration: BoxDecoration(
            color: isOnlineAndAuthed
                ? m.Colors.green.withValues(alpha: 0.15)
                : theme.colorScheme.muted,
            shape: BoxShape.circle,
          ),
          child: Icon(
            cloudAuth.isAuthenticated
                ? (syncState.isOffline
                      ? LucideIcons.cloudOff
                      : LucideIcons.cloud)
                : LucideIcons.cloudOff,
            color: isOnlineAndAuthed
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
                cloudAuth.isAuthenticated
                    ? cloudAuth.email!
                    : l10n.cloudNotConnected,
                style: theme.typography.semiBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppGaps.v2,
              Text(
                _getCloudSubtitle(l10n, cloudAuth, syncState),
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

  String _getCloudSubtitle(
    dynamic l10n,
    SupabaseAuthState cloudAuth,
    SyncUiState syncState,
  ) {
    if (!cloudAuth.isAuthenticated) {
      return l10n.loginToSyncHint as String;
    }
    if (syncState.isSyncing) {
      return l10n.syncing as String;
    }
    if (syncState.isOffline) {
      return l10n.syncNoInternet as String;
    }
    final lastSyncedAt = syncState.lastSyncedAt;
    if (lastSyncedAt != null) {
      final timeStr =
          '${lastSyncedAt.hour.toString().padLeft(2, '0')}:${lastSyncedAt.minute.toString().padLeft(2, '0')}';
      return syncState.pendingCount > 0
          ? '${l10n.syncedAt(timeStr)} • ${l10n.pendingChanges(syncState.pendingCount)}'
          : l10n.syncedAt(timeStr) as String;
    }
    return l10n.readyToSync as String;
  }

  Widget _buildCloudActions(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    SupabaseAuthState cloudAuth,
    SupabaseAuthNotifier cloudAuthNotifier,
    SyncUiState syncState,
    SyncStateNotifier syncNotifier,
  ) {
    if (cloudAuth.isAuthenticated) {
      return SizedBox(
        height: 42,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: OutlineButton(
                alignment: Alignment.center,
                onPressed: () async {
                  await cloudAuthNotifier.signOut();
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
                    ),
                  ],
                ),
              ),
            ),
            AppGaps.h12,
            Expanded(
              child: PrimaryButton(
                alignment: Alignment.center,
                onPressed: syncState.isSyncing
                    ? null
                    : () async {
                        await syncNotifier.syncNow();
                      },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (syncState.isSyncing)
                      const SizedBox(
                        width: AppSpacing.md,
                        height: AppSpacing.md,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(LucideIcons.refreshCw, size: AppIconSize.sm),
                    AppGaps.h8,
                    Text(syncState.isSyncing ? l10n.syncing : l10n.sync),
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
        onPressed: () => SupabaseAuthSheet.show(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.cloud, size: AppIconSize.sm),
            AppGaps.h8,
            Text(l10n.signInCloud),
          ],
        ),
      ),
    );
  }
}
