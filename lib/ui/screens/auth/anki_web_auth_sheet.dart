import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/auth/anki_web_auth_service.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Ultra-streamlined minimalist AnkiWeb authentication modal bottom sheet.
class AnkiWebAuthSheet extends HookConsumerWidget {
  const AnkiWebAuthSheet({super.key});

  /// Displays the AnkiWeb authentication bottom sheet.
  /// Returns `true` if login was successful.
  static Future<bool?> show(BuildContext context) {
    return m.showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      backgroundColor: m.Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const m.Material(
        type: m.MaterialType.transparency,
        child: AnkiWebAuthSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);

    // Clear stale auth error on modal open and close
    useEffect(() {
      Future.microtask(() {
        authNotifier.clearError();
      });
      return () {
        authNotifier.clearError();
      };
    }, const []);

    // Clear error dynamically as soon as user types
    useEffect(() {
      void clearOnType() {
        authNotifier.clearError();
      }

      emailController.addListener(clearOnType);
      passwordController.addListener(clearOnType);
      return () {
        emailController.removeListener(clearOnType);
        passwordController.removeListener(clearOnType);
      };
    }, [emailController, passwordController]);

    Future<void> handleLogin() async {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.authMissingInfoTitle),
                subtitle: Text(l10n.authMissingInfoDesc),
                leading: const Icon(
                  LucideIcons.triangleAlert,
                  color: m.Colors.orange,
                ),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
        return;
      }

      final success = await authNotifier.login(email, password);
      if (context.mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          showToast(
            context: context,
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  title: Text(l10n.authSuccessToastTitle),
                  subtitle: Text(l10n.authSuccessToastDesc(email)),
                  leading: const Icon(
                    LucideIcons.circleCheck,
                    color: m.Colors.green,
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
    }

    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(
            top: BorderSide(color: theme.colorScheme.border, width: 1),
            left: BorderSide(color: theme.colorScheme.border, width: 1),
            right: BorderSide(color: theme.colorScheme.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: m.Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top drag grab handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.mutedForeground.withValues(
                        alpha: 0.25,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header with icon badge, title, subtitle (no close button)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          LucideIcons.cloud,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            const SizedBox(height: 2),
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
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                ),

                // Form fields & actions
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email input
                      TextField(
                        controller: emailController,
                        placeholder: Text(l10n.authEmail),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        features: [
                          InputFeature.leading(
                            Icon(
                              LucideIcons.mail,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Password input
                      TextField(
                        controller: passwordController,
                        placeholder: Text(l10n.authPassword),
                        obscureText: obscurePassword.value,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => handleLogin(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        features: [
                          InputFeature.leading(
                            Icon(
                              LucideIcons.lock,
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                          InputFeature.trailing(
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                obscurePassword.value = !obscurePassword.value;
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Icon(
                                    obscurePassword.value
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    size: 16,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Auth error message banner
                      if (authState.status == AuthStatus.error &&
                          authState.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.destructive.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.destructive.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.circleAlert,
                                size: 16,
                                color: theme.colorScheme.destructive,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getAuthErrorMessage(l10n, authState),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.destructive,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Primary submit button (height matching input ~48px)
                      SizedBox(
                        height: 48,
                        child: PrimaryButton(
                          onPressed: authState.isLoading ? null : handleLogin,
                          child: authState.isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(l10n.authSubmitting),
                                  ],
                                )
                              : m.Center(
                                  child: Text(
                                    l10n.authLoginButton,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Security footnote
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.shieldCheck,
                            size: 13,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.authSecurityNote,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getAuthErrorMessage(AppLocalizations l10n, AuthState state) {
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
        return state.errorMessage ?? l10n.authUnknownError('Unknown');
    }
  }
}
