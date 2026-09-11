import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/anki_bridge.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/notifiers/update_notifier.dart';
import '../../../widgets/update_dialog.dart';
import 'settings_info_rows.dart';

class AboutInfoCard extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isFsrsEnabled;
  final UpdateState updateState;
  final UpdateNotifier updateNotifier;

  const AboutInfoCard({
    super.key,
    required this.themeMode,
    required this.isFsrsEnabled,
    required this.updateState,
    required this.updateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

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
