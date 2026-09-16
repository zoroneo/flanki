import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/adaptive_modal.dart';
import '../../../core/widgets/form_focus_helper.dart';
import '../providers/auth_notifier.dart';
import 'widgets/anki_web_auth_form.dart';

class AnkiWebAuthSheet extends HookConsumerWidget {
  final bool isDesktop;

  const AnkiWebAuthSheet({super.key, this.isDesktop = false});

  /// Displays the AnkiWeb authentication sheet/dialog adaptively.
  /// Returns `true` if login was successful.
  static Future<bool?> show(BuildContext context) {
    return showAdaptiveModal<bool>(
      context: context,
      useRootNavigator: true,
      desktopMaxWidth: 440,
      builder: (ctx, isDesktop) => AnkiWebAuthSheet(isDesktop: isDesktop),
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

    // Clear stale auth error on modal open
    useEffect(() {
      Future.microtask(() {
        authNotifier.clearError();
      });
      return null;
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
      if (context.mounted && success) {
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

    final focusNodes = useTabFocusChain(2, onSubmit: handleLogin);
    final emailFocusNode = focusNodes[0];
    final passwordFocusNode = focusNodes[1];

    final viewInsets = MediaQuery.of(context).viewInsets;
    final isDesktopMode = isDesktop;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: isDesktopMode
              ? AppRadius.borderXl
              : const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.lg),
                ),
          border: isDesktopMode
              ? Border.all(color: theme.colorScheme.border, width: 1)
              : Border(
                  top: BorderSide(color: theme.colorScheme.border, width: 1),
                  left: BorderSide(color: theme.colorScheme.border, width: 1),
                  right: BorderSide(color: theme.colorScheme.border, width: 1),
                ),
          boxShadow: [
            BoxShadow(
              color: m.Colors.black.withValues(
                alpha: isDesktopMode ? 0.2 : 0.15,
              ),
              blurRadius: isDesktopMode ? 24 : 16,
              offset: isDesktopMode ? const Offset(0, 8) : const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          bottom: !isDesktopMode,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isDesktopMode)
                  Center(
                    child: Container(
                      width: 36,
                      height: AppSpacing.xs,
                      margin: const EdgeInsets.only(
                        top: AppSpacing.smPlus,
                        bottom: AppSpacing.smPlus,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.mutedForeground.withValues(
                          alpha: 0.25,
                        ),
                        borderRadius: AppRadius.borderXs,
                      ),
                    ),
                  ),

                if (isDesktopMode) AppGaps.v16,

                AnkiWebAuthHeader(
                  isDesktopMode: isDesktopMode,
                  onClose: () => Navigator.of(context).pop(),
                ),
                AppGaps.v12,
                Divider(
                  height: 1,
                  color: theme.colorScheme.border.withValues(alpha: 0.6),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Shortcuts(
                    shortcuts: const <ShortcutActivator, Intent>{
                      SingleActivator(LogicalKeyboardKey.tab):
                          NextFocusIntent(),
                      SingleActivator(LogicalKeyboardKey.tab, shift: true):
                          PreviousFocusIntent(),
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: emailController,
                          focusNode: emailFocusNode,
                          placeholder: Text(l10n.authEmail),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () =>
                              passwordFocusNode.requestFocus(),
                          onSubmitted: (_) => passwordFocusNode.requestFocus(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: AppSpacing.smPlus,
                          ),
                          features: [
                            InputFeature.leading(
                              Icon(
                                LucideIcons.mail,
                                size: AppIconSize.sm,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                        AppGaps.v12,

                        TextField(
                          controller: passwordController,
                          focusNode: passwordFocusNode,
                          placeholder: Text(l10n.authPassword),
                          obscureText: obscurePassword.value,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => handleLogin(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: AppSpacing.smPlus,
                          ),
                          features: [
                            InputFeature.leading(
                              Icon(
                                LucideIcons.lock,
                                size: AppIconSize.sm,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                            InputFeature.trailing(
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  obscurePassword.value =
                                      !obscurePassword.value;
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xs,
                                    ),
                                    child: Icon(
                                      obscurePassword.value
                                          ? LucideIcons.eyeOff
                                          : LucideIcons.eye,
                                      size: AppIconSize.sm,
                                      color: theme.colorScheme.mutedForeground,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (authState.status == AuthStatus.error &&
                            authState.errorMessage != null) ...[
                          AppGaps.v12,
                          AnkiWebAuthErrorBanner(authState: authState),
                        ],

                        AppGaps.v16,

                        AnkiWebSubmitButton(
                          isLoading: authState.isLoading,
                          onSubmit: handleLogin,
                        ),
                        AppGaps.v12,
                        const AnkiWebSecurityNote(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
