import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/config/settings_notifier.dart';
import '../../../sync/providers/auth_notifier.dart';
import '../../../sync/providers/supabase_auth_notifier.dart';
import '../../../sync/providers/sync_state_notifier.dart';
import '../../../sync/ui/supabase_auth_sheet.dart';

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
            AppConfig.appName,
            style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          AppGaps.h8,
          Consumer(
            builder: (context, ref, _) {
              final fsrsEnabled = ref.watch(
                studySettingsProvider.select((s) => s.fsrsEnabled),
              );
              return Container(
                padding: AppEdgeInsets.h8v2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  fsrsEnabled ? 'FSRS v5' : 'SM-2',
                  style: context.textStyles.captionBold.copyWith(
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
            final cloudAuth = ref.watch(supabaseAuthNotifierProvider);
            final syncState = ref.watch(syncStateNotifierProvider);
            final ankiAuth = ref.watch(authNotifierProvider);

            final isCloudAuthed = cloudAuth.isAuthenticated;
            final isAnkiAuthed = ankiAuth.isAuthenticated;
            final isAnySyncing = isSyncing.value || syncState.isSyncing;

            final VoidCallback? onTap;
            final Widget leadingIcon;
            final String badgeText;

            if (isCloudAuthed) {
              if (isAnySyncing) {
                onTap = null;
                leadingIcon = const SizedBox(
                  width: AppIconSize.sm,
                  height: AppIconSize.sm,
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.spinnerStrokeWidth,
                  ),
                );
                badgeText = l10n.syncing;
              } else if (syncState.isOffline) {
                onTap = () =>
                    ref.read(syncStateNotifierProvider.notifier).syncNow();
                leadingIcon = Icon(
                  LucideIcons.cloudOff,
                  size: AppIconSize.sm,
                  color: theme.colorScheme.mutedForeground,
                );
                badgeText = l10n.syncNoInternet;
              } else if (syncState.pendingCount > 0) {
                onTap = () =>
                    ref.read(syncStateNotifierProvider.notifier).syncNow();
                leadingIcon = Icon(
                  LucideIcons.cloudUpload,
                  size: AppIconSize.sm,
                  color: context.colors.success,
                );
                badgeText = '${l10n.sync} (${syncState.pendingCount})';
              } else {
                onTap = () =>
                    ref.read(syncStateNotifierProvider.notifier).syncNow();
                leadingIcon = Icon(
                  LucideIcons.cloud,
                  size: AppIconSize.sm,
                  color: context.colors.success,
                );
                badgeText = l10n.linkedBadge;
              }
            } else if (isAnkiAuthed) {
              if (isAnySyncing) {
                onTap = null;
                leadingIcon = const SizedBox(
                  width: AppIconSize.sm,
                  height: AppIconSize.sm,
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimensions.spinnerStrokeWidth,
                  ),
                );
                badgeText = l10n.linkedBadge;
              } else {
                onTap = onSync;
                leadingIcon = Icon(
                  LucideIcons.cloud,
                  size: AppIconSize.sm,
                  color: context.colors.success,
                );
                badgeText = l10n.linkedBadge;
              }
            } else {
              onTap = () => SupabaseAuthSheet.show(context);
              leadingIcon = const Icon(LucideIcons.cloud, size: AppIconSize.sm);
              badgeText = l10n.syncBadge;
            }

            return GhostButton(
              alignment: Alignment.center,
              size: ButtonSize.small,
              onPressed: onTap,
              leading: leadingIcon,
              child: Text(badgeText, maxLines: 1, softWrap: false),
            );
          },
        ),
      ],
    );
  }
}
