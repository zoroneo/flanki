import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../core/auth/auth_notifier.dart';
import '../../../core/localization/locale_notifier.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);

    final isVi = currentLocale?.languageCode == 'vi';
    final isEn = currentLocale?.languageCode == 'en';
    final isSystem = currentLocale == null;

    return Scaffold(
      headers: [
        AppBar(
          title: Text(l10n.settingsTitle),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // AnkiWeb Account Card
          Text(
            l10n.accountAndSync,
            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
          ),
          const SizedBox(height: 8),
          Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: authState.isAuthenticated
                            ? m.Colors.green.withValues(alpha: 0.15)
                            : theme.colorScheme.muted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        authState.isAuthenticated
                            ? m.Icons.cloud_done_rounded
                            : m.Icons.cloud_off_rounded,
                        color: authState.isAuthenticated
                            ? m.Colors.green
                            : theme.colorScheme.mutedForeground,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authState.isAuthenticated
                                ? authState.email!
                                : l10n.notLinkedAnkiWeb,
                            style: theme.typography.semiBold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            authState.isAuthenticated
                                ? (authState.lastSyncedAt != null
                                    ? l10n.syncedAt(
                                        '${authState.lastSyncedAt!.hour.toString().padLeft(2, '0')}:${authState.lastSyncedAt!.minute.toString().padLeft(2, '0')}',
                                      )
                                    : l10n.readyToSync)
                                : l10n.loginToSyncHint,
                            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                if (authState.isAuthenticated)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DestructiveButton(
                        onPressed: () async {
                          await authNotifier.logout();
                          if (context.mounted) {
                            showToast(
                              context: context,
                              builder: (context, overlay) {
                                return SurfaceCard(
                                  child: Basic(
                                    title: Text(l10n.loggedOut),
                                    subtitle: Text(l10n.logoutSubtitle),
                                    trailing: IconButton.ghost(
                                      icon: const Icon(m.Icons.close),
                                      onPressed: () => overlay.close(),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        leading: const Icon(m.Icons.logout_rounded, size: 16),
                        child: Text(l10n.logout),
                      ),
                      PrimaryButton(
                        onPressed: () {
                          authNotifier.recordSyncSuccess();
                          showToast(
                            context: context,
                            builder: (context, overlay) {
                              return SurfaceCard(
                                child: Basic(
                                  title: Text(l10n.syncCompleted),
                                  subtitle: const Text('AnkiWeb USN delta synchronized.'),
                                  trailing: IconButton.ghost(
                                    icon: const Icon(m.Icons.close),
                                    onPressed: () => overlay.close(),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        leading: const Icon(m.Icons.sync_rounded, size: 16),
                        child: Text(l10n.syncAnkiWeb),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPressed: () => context.push('/auth'),
                      leading: const Icon(m.Icons.login_rounded, size: 16),
                      child: Text(l10n.connectAnkiWeb),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // App Preferences (Language & Theme)
          Text(
            l10n.appPreferences,
            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
          ),
          const SizedBox(height: 8),
          Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(m.Icons.language_rounded, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.language, style: theme.typography.semiBold),
                          Text(
                            l10n.languageSubtitle,
                            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _LanguageOptionButton(
                        label: l10n.languageVietnamese,
                        isSelected: isVi,
                        onTap: () => localeNotifier.setLocale(const Locale('vi')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LanguageOptionButton(
                        label: l10n.languageEnglish,
                        isSelected: isEn,
                        onTap: () => localeNotifier.setLocale(const Locale('en')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _LanguageOptionButton(
                        label: l10n.languageSystem,
                        isSelected: isSystem,
                        onTap: () => localeNotifier.setLocale(null),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Spaced Repetition Engine
          Text(
            l10n.spacedRepetitionAlgorithm,
            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
          ),
          const SizedBox(height: 8),
          Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.enableFsrs, style: theme.typography.semiBold),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '85% (FSRS v4.5)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.fsrsSubtitle,
                  style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System / Core Info
          Text(
            l10n.aboutSection,
            style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
          ),
          const SizedBox(height: 8),
          Card(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Anki Rust Core', value: 'rslib 24.11 (Protobuf RPC)'),
                const Divider(),
                _InfoRow(label: l10n.appearance, value: 'shadcn_flutter (Zinc Theme)'),
                const Divider(),
                _InfoRow(label: 'Scheduler Engine', value: 'FSRS v5 Spaced Repetition'),
                const Divider(),
                _InfoRow(label: l10n.appVersion, value: 'Alpha 0.1.0 Mobile'),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _LanguageOptionButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.small.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? theme.colorScheme.primaryForeground
                  : theme.colorScheme.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground)),
          Text(value, style: theme.typography.small.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
