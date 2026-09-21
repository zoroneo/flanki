import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/anki_web_auth_service.dart';
import '../../providers/auth_notifier.dart';

class AnkiWebAuthHeader extends StatelessWidget {
  final bool isDesktopMode;
  final VoidCallback? onClose;

  const AnkiWebAuthHeader({
    super.key,
    required this.isDesktopMode,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
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
                  l10n.authHeaderTitle,
                  style: theme.typography.h4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppGaps.v2,
                Text(
                  l10n.authHeaderDesc,
                  style: theme.typography.xSmall.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isDesktopMode && onClose != null)
            IconButton.ghost(
              icon: const Icon(LucideIcons.x, size: AppIconSize.md),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }
}

class AnkiWebAuthErrorBanner extends StatelessWidget {
  final AuthState authState;

  const AnkiWebAuthErrorBanner({super.key, required this.authState});

  static String getErrorMessage(AppLocalizations l10n, AuthState state) {
    switch (state.errorCode) {
      case AuthErrorCode.emptyCredentials:
        return l10n.authEmailPasswordEmpty;
      case AuthErrorCode.invalidCredentials:
        return l10n.authInvalidCredentials;
      case AuthErrorCode.rateLimited:
        return l10n.authTooManyAttempts;
      case AuthErrorCode.invalidResponse:
        return l10n.authServerResponseInvalid;
      case AuthErrorCode.networkError:
        return l10n.authNetworkError(state.errorMessage ?? '');
      case AuthErrorCode.serverError:
      case AuthErrorCode.unknown:
      case null:
        return state.errorMessage ?? l10n.authUnknownError(l10n.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (authState.status != AuthStatus.error ||
        authState.errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: AppEdgeInsets.all12,
      decoration: BoxDecoration(
        color: theme.colorScheme.destructive.withValues(alpha: 0.1),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: theme.colorScheme.destructive.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            LucideIcons.circleAlert,
            size: AppIconSize.sm,
            color: theme.colorScheme.destructive,
          ),
          AppGaps.h8,
          Expanded(
            child: Text(
              getErrorMessage(l10n, authState),
              style: context.textStyles.xSmall.copyWith(
                color: theme.colorScheme.destructive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnkiWebSubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onSubmit;

  const AnkiWebSubmitButton({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: AppSpacing.xxxl,
      child: PrimaryButton(
        onPressed: isLoading ? null : onSubmit,
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: AppIconSize.sm,
                    height: AppIconSize.sm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  AppGaps.h8,
                  Text(l10n.authSubmitting),
                ],
              )
            : m.Center(
                child: Text(
                  l10n.authLoginButton,
                  style: context.textStyles.smallSemiBold,
                ),
              ),
      ),
    );
  }
}

class AnkiWebSecurityNote extends StatelessWidget {
  const AnkiWebSecurityNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.shieldCheck,
          size: AppIconSize.xs,
          color: theme.colorScheme.mutedForeground,
        ),
        AppGaps.h8,
        Flexible(
          child: Text(
            l10n.authSecurityNote,
            style: context.textStyles.subMuted,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
