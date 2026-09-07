import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';

class PrivacyPolicyScreen extends HookWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft, size: 18),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/settings');
                }
              },
            ),
          ],
          title: Text(l10n.privacyPolicy),
        ),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Summary Header Card
              Card(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.shieldCheck,
                        size: 24,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.privacyPolicy,
                            style: theme.typography.semiBold.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Local-First • Zero Tracking • Open Source',
                            style: theme.typography.xSmall.copyWith(
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _PolicySectionCard(
                icon: LucideIcons.hardDrive,
                title: '1. Local-First Storage',
                content:
                    'All your decks, flashcards, study schedules, and review history are stored locally on your device via SQLite. Flanki does not transmit your personal flashcard content to any developer servers.',
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.ban,
                title: '2. Zero Tracking & No Ads',
                content:
                    'We do not integrate any third-party tracking frameworks, behavioral analytics SDKs (e.g., Google Analytics, Firebase, Sentry), or advertising networks. We do not sell or monetize your personal data.',
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.cloud,
                title: '3. Optional AnkiWeb Sync',
                content:
                    'If you choose to log in and synchronize with AnkiWeb, your credentials and collection data are transmitted directly between your device and official AnkiWeb servers over encrypted HTTPS. Authentication tokens are saved in platform-native secure vaults (Android Keystore, iOS Keychain, Windows DPAPI). We never store or access your password.',
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.refreshCw,
                title: '4. App Update Checks',
                content:
                    'Flanki periodically checks the public GitHub Releases API to notify you when a new version is available. No user-identifying information or device fingerprints are sent during update checks.',
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.bell,
                title: '5. Local Notifications',
                content:
                    'Daily study reminders and streak notifications are scheduled strictly on your local device. No remote push notification servers are used.',
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.trash2,
                title: '6. Data Control & Deletion',
                content:
                    'You retain 100% control of your data. You can delete decks, clear app data, or uninstall the app at any time to instantly remove all stored content.',
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.globe,
                title: '7. Full Policy & Source Code',
                content:
                    'Flanki is an open-source project. You can inspect our complete source code and read our full legal Privacy Policy at: https://github.com/zoroneo/flanki',
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _PolicySectionCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.typography.small.copyWith(
              color: theme.colorScheme.mutedForeground,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
