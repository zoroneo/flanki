import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/notifiers/locale_notifier.dart';

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
          title: Text(
            l10n.privacyPolicy,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
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
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
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
                            style: theme.typography.semiBold.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.privacyPolicyTagline,
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
                title: l10n.privacySection1Title,
                content: l10n.privacySection1Content,
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.ban,
                title: l10n.privacySection2Title,
                content: l10n.privacySection2Content,
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.cloud,
                title: l10n.privacySection3Title,
                content: l10n.privacySection3Content,
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.refreshCw,
                title: l10n.privacySection4Title,
                content: l10n.privacySection4Content,
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.bell,
                title: l10n.privacySection5Title,
                content: l10n.privacySection5Content,
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.trash2,
                title: l10n.privacySection6Title,
                content: l10n.privacySection6Content,
              ),
              const SizedBox(height: 12),

              _PolicySectionCard(
                icon: LucideIcons.globe,
                title: l10n.privacySection7Title,
                content: l10n.privacySection7Content,
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
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
