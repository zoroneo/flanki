import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';

class SupabaseAuthHeader extends StatelessWidget {
  final bool isSignUp;
  final ValueChanged<bool> onTabChanged;
  final VoidCallback onClose;

  const SupabaseAuthHeader({
    super.key,
    required this.isSignUp,
    required this.onTabChanged,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              padding: AppEdgeInsets.all8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.borderMd,
              ),
              child: Icon(
                LucideIcons.cloud,
                color: theme.colorScheme.primary,
                size: AppIconSize.md,
              ),
            ),
            AppGaps.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.flankiCloud,
                    style: theme.typography.h4.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppGaps.v2,
                  Text(
                    l10n.cloudSyncSubtitle,
                    style: theme.typography.xSmall.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.ghost(
              icon: const Icon(LucideIcons.x, size: AppIconSize.sm),
              onPressed: onClose,
            ),
          ],
        ),
        AppGaps.v16,
        Container(
          padding: AppEdgeInsets.all4,
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: AppRadius.borderMd,
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !isSignUp
                          ? theme.colorScheme.background
                          : Colors.transparent,
                      borderRadius: AppRadius.borderSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.authLoginButton,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: !isSignUp
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: !isSignUp
                            ? theme.colorScheme.foreground
                            : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTabChanged(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSignUp
                          ? theme.colorScheme.background
                          : Colors.transparent,
                      borderRadius: AppRadius.borderSm,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.signUpCloud,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSignUp
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSignUp
                            ? theme.colorScheme.foreground
                            : theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
