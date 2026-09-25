import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Standard Social Authentication buttons (Google & Apple OAuth)
/// conforming to design guidelines and height limits.
class SocialAuthButtons extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const SocialAuthButtons({
    super.key,
    required this.isLoading,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Google Sign-In Button
        SizedBox(
          height: AppDimensions.buttonHeightStandard,
          child: OutlineButton(
            alignment: Alignment.center,
            onPressed: isLoading ? null : onGooglePressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.chrome,
                  size: AppIconSize.sm,
                  color: theme.colorScheme.primary,
                ),
                AppGaps.h10,
                Text(
                  l10n.continueWithGoogle,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppGaps.v8,

        // Apple Sign-In Button
        SizedBox(
          height: AppDimensions.buttonHeightStandard,
          child: OutlineButton(
            alignment: Alignment.center,
            onPressed: isLoading ? null : onApplePressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.apple,
                  size: AppIconSize.sm,
                  color: theme.colorScheme.foreground,
                ),
                AppGaps.h10,
                Text(
                  l10n.continueWithApple,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppGaps.v16,

        // Divider: Or continue with email
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                l10n.orContinueWithEmail,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        AppGaps.v16,
      ],
    );
  }
}
