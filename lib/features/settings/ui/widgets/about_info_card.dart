import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/anki_bridge.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/notifiers/locale_notifier.dart';
import '../../providers/settings_notifier.dart';
import '../../providers/update_notifier.dart';
import '../../../../core/notifiers/theme_notifier.dart';
import 'update_dialog.dart';
import 'settings_info_rows.dart';

class AboutInfoCard extends ConsumerWidget {
  const AboutInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final themeMode = ref.watch(themeNotifierProvider);
    final isFsrsEnabled = ref.watch(
      studySettingsProvider.select((s) => s.fsrsEnabled),
    );
    final updateState = ref.watch(updateProvider);
    final updateNotifier = ref.read(updateProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aboutSection,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InfoRow(
                label: l10n.ankiRustCore,
                value: AnkiBridge.isAvailable
                    ? l10n.rslibLinked
                    : l10n.dartCoreEngine,
              ),
              const Divider(),
              InfoRow(
                label: l10n.appearance,
                value: switch (themeMode) {
                  ThemeMode.light => l10n.themeLight,
                  ThemeMode.dark => l10n.themeDark,
                  ThemeMode.system => l10n.themeSystem,
                },
              ),
              const Divider(),
              InfoRow(
                label: l10n.algorithmLabel,
                value: isFsrsEnabled ? 'FSRS v5' : 'SM-2',
              ),
              const Divider(),
              VersionInfoRow(
                label: l10n.appVersion,
                version: AppConfig.version,
                updateState: updateState,
                onCheckUpdate: () async {
                  final info = await updateNotifier.checkForUpdates();
                  if (info != null && info.hasUpdate && context.mounted) {
                    UpdateDialog.show(context, info);
                  }
                },
                onShowDialog: () {
                  if (updateState.updateInfo != null && context.mounted) {
                    UpdateDialog.show(context, updateState.updateInfo!);
                  }
                },
              ),
              const Divider(),
              ClickableInfoRow(
                label: l10n.openSourceLicenses,
                onTap: () => context.push('/licenses'),
              ),
              const Divider(),
              ClickableInfoRow(
                label: l10n.privacyPolicy,
                onTap: () => context.push('/privacy-policy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
