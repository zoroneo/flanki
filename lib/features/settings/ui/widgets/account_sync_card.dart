import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/supabase_auth_notifier.dart';
import '../../../sync/providers/sync_state_notifier.dart';
import '../../../sync/ui/supabase_auth_sheet.dart';
import '../../../sync/ui/widgets/sync_diagnostics_sheet.dart';
import 'anki_web_card.dart';

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
              _buildCloudHeader(context, theme, l10n, cloudAuth, syncState),
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
        const AnkiWebCard(),
      ],
    );
  }

  Widget _buildCloudHeader(
    BuildContext context,
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
                ? AppColors.success.withValues(alpha: 0.15)
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
                ? AppColors.success
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
        IconButton.ghost(
          icon: const Icon(LucideIcons.activity, size: AppIconSize.sm),
          onPressed: () => SyncDiagnosticsSheet.show(context),
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
        height: AppDimensions.buttonHeightStandard,
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
                        child: CircularProgressIndicator(
                          strokeWidth: AppDimensions.spinnerStrokeWidth,
                        ),
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
      height: AppDimensions.buttonHeightStandard,
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
