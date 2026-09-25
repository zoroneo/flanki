import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../sync/providers/auth_notifier.dart';
import '../../../sync/ui/anki_web_auth_sheet.dart';

/// Settings card for connecting or disconnecting legacy AnkiWeb synchronization.
class AnkiWebCard extends ConsumerWidget {
  const AnkiWebCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ankiAuthState = ref.watch(authNotifierProvider);
    final ankiAuthNotifier = ref.read(authNotifierProvider.notifier);

    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
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
                  padding: AppEdgeInsets.h8v2,
                  decoration: BoxDecoration(
                    color: context.colors.success.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    l10n.linkedBadge,
                    style: context.textStyles.subSemiBold.copyWith(
                      color: context.colors.success,
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
    );
  }
}
