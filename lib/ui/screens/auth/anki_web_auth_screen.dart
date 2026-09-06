import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';

class AnkiWebAuthScreen extends HookConsumerWidget {
  const AnkiWebAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Hooks replacing StatefulWidget state & controllers
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final obscurePassword = useState(true);

    Future<void> handleLogin() async {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: const Text('Thiếu thông tin'),
                subtitle: const Text('Vui lòng nhập đầy đủ Email và Mật khẩu AnkiWeb.'),
                leading: const Icon(m.Icons.warning_amber_rounded, color: m.Colors.orange),
                trailing: IconButton.ghost(
                  icon: const Icon(m.Icons.close),
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
          showToast(
            context: context,
            builder: (context, overlay) {
              return SurfaceCard(
                child: Basic(
                  title: const Text('Đăng nhập thành công'),
                  subtitle: Text('Đã liên kết tài khoản $email với Flanki.'),
                  leading: const Icon(m.Icons.check_circle, color: m.Colors.green),
                  trailing: IconButton.ghost(
                    icon: const Icon(m.Icons.close),
                    onPressed: () => overlay.close(),
                  ),
                ),
              );
            },
          );
          context.pop();
        }
      }
    }

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(m.Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/decks');
                }
              },
            ),
          ],
          title: const Text('AnkiWeb Account'),
        ),
      ],
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header badge & title
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      m.Icons.cloud_sync_rounded,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Đồng bộ AnkiWeb',
                  textAlign: TextAlign.center,
                  style: theme.typography.h2.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập tài khoản AnkiWeb để đồng bộ hai chiều toàn bộ bộ thẻ, lịch ôn FSRS và tiến độ học tập.',
                  textAlign: TextAlign.center,
                  style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground),
                ),
                const SizedBox(height: 32),

                // Form card
                Card(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('EMAIL ANKIWEB', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(m.Icons.email_outlined, size: 18, color: theme.colorScheme.mutedForeground),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              placeholder: const Text('user@example.com'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('MẬT KHẨU', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(m.Icons.lock_outline_rounded, size: 18, color: theme.colorScheme.mutedForeground),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: passwordController,
                              placeholder: const Text('Nhập mật khẩu...'),
                              obscureText: obscurePassword.value,
                            ),
                          ),
                          IconButton.ghost(
                            icon: Icon(
                              obscurePassword.value
                                  ? m.Icons.visibility_off_outlined
                                  : m.Icons.visibility_outlined,
                              size: 18,
                            ),
                            onPressed: () {
                              obscurePassword.value = !obscurePassword.value;
                            },
                          ),
                        ],
                      ),
                      if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.destructive.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.destructive.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                m.Icons.error_outline_rounded,
                                size: 18,
                                color: theme.colorScheme.destructive,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
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
                      const SizedBox(height: 28),
                      PrimaryButton(
                        onPressed: authState.isLoading ? null : handleLogin,
                        child: authState.isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Đang xác thực...'),
                                ],
                              )
                            : const Text('Đăng nhập & Bắt đầu Sync'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Guest / Skip action
                GhostButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/decks');
                    }
                  },
                  child: const Text('Dùng thử Ngoại tuyến (Guest Mode)'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bảo mật: Flanki chỉ lưu trữ mã phiên HostKey trong Secure Storage của thiết bị, không lưu lại mật khẩu thô của bạn.',
                  textAlign: TextAlign.center,
                  style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
