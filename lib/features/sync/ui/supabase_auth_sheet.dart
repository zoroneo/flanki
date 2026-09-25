import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/adaptive_modal.dart';
import '../providers/supabase_auth_notifier.dart';
import '../providers/sync_state_notifier.dart';
import 'widgets/social_auth_buttons.dart';
import 'widgets/supabase_auth_header.dart';

/// Modal sheet for Flanki Cloud authentication (Sign in & Sign up via Supabase).
class SupabaseAuthSheet extends HookConsumerWidget {
  final bool isDesktop;

  const SupabaseAuthSheet({super.key, this.isDesktop = false});

  /// Displays the Flanki Cloud authentication sheet/dialog adaptively.
  /// Returns `true` if login or signup was successful.
  static Future<bool?> show(BuildContext context) {
    return showAdaptiveModal<bool>(
      context: context,
      useRootNavigator: true,
      desktopMaxWidth: 440,
      builder: (ctx, isDesktop) => SupabaseAuthSheet(isDesktop: isDesktop),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final authState = ref.watch(supabaseAuthNotifierProvider);
    final authNotifier = ref.read(supabaseAuthNotifierProvider.notifier);

    final isSignUp = useState(false);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);
    final localError = useState<String?>(null);

    // Clear local error when switching tabs
    useEffect(() {
      localError.value = null;
      return null;
    }, [isSignUp.value]);

    Future<void> handleSubmit() async {
      final email = emailController.text.trim();
      final password = passwordController.text;

      localError.value = null;

      if (email.isEmpty || !email.contains('@')) {
        localError.value = l10n.authInvalidEmail;
        return;
      }

      if (password.length < 6) {
        localError.value = l10n.authPasswordTooShort;
        return;
      }

      final success = isSignUp.value
          ? await authNotifier.signUp(email, password)
          : await authNotifier.signIn(email, password);

      if (!context.mounted) return;

      if (success) {
        // Trigger initial sync cycle
        ref.read(syncStateNotifierProvider.notifier).syncNow();

        Navigator.of(context).pop(true);

        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.authSuccess),
                subtitle: Text(
                  isSignUp.value
                      ? l10n.authSuccessSubtitle
                      : l10n.syncConnecting,
                ),
                leading: Icon(
                  LucideIcons.circleCheck,
                  color: context.colors.success,
                ),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
      }
    }

    final displayedError =
        localError.value ?? authState.getLocalizedError(l10n);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: isDesktop
            ? AppRadius.borderLg
            : const BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
        border: isDesktop ? Border.all(color: theme.colorScheme.border) : null,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: isDesktop ? AppSpacing.lg : AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isDesktop) ...[
              Center(
                child: Container(
                  width: AppDimensions.modalGrabHandleWidth,
                  height: AppDimensions.modalGrabHandleHeight,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.mutedForeground.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: AppRadius.borderSm,
                  ),
                ),
              ),
            ],
            SupabaseAuthHeader(
              isSignUp: isSignUp.value,
              onTabChanged: (val) => isSignUp.value = val,
              onClose: () => Navigator.of(context).pop(false),
            ),
            AppGaps.v16,

            // Social Authentication Buttons (Google & Apple OAuth)
            SocialAuthButtons(
              isLoading: authState.isLoading,
              onGooglePressed: () async {
                localError.value = null;
                await authNotifier.signInWithGoogle();
              },
              onApplePressed: () async {
                localError.value = null;
                await authNotifier.signInWithApple();
              },
            ),

            // Error Message Banner
            if (displayedError != null) ...[
              Container(
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
                        displayedError,
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppGaps.v12,
            ],

            // Email Input
            Text(
              l10n.authEmail,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppGaps.v6,
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              placeholder: Text(l10n.authEmailPlaceholder),
            ),
            AppGaps.v12,

            // Password Input
            Text(
              l10n.authPassword,
              style: theme.typography.xSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppGaps.v6,
            TextField(
              controller: passwordController,
              obscureText: obscurePassword.value,
              placeholder: Text(l10n.authPasswordDots),
              features: [
                InputFeature.trailing(
                  IconButton.ghost(
                    icon: Icon(
                      obscurePassword.value
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
                      size: AppIconSize.sm,
                    ),
                    onPressed: () {
                      obscurePassword.value = !obscurePassword.value;
                    },
                  ),
                ),
              ],
            ),
            AppGaps.v20,

            // Submit Button
            PrimaryButton(
              onPressed: authState.isLoading ? null : handleSubmit,
              child: authState.isLoading
                  ? const SizedBox(
                      width: AppSpacing.md,
                      height: AppSpacing.md,
                      child: CircularProgressIndicator(
                        strokeWidth: AppDimensions.spinnerStrokeWidth,
                      ),
                    )
                  : Text(
                      isSignUp.value ? l10n.signUpCloud : l10n.authLoginButton,
                      style: context.textStyles.bodySemiBold,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
