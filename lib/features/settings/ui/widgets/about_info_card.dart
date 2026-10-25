import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/anki/anki_bridge.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../router/app_router.dart';
import '../../providers/update_notifier.dart';
import 'update_dialog.dart';
import 'settings_info_rows.dart';

class AboutInfoCard extends ConsumerWidget {
  const AboutInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final updateState = ref.watch(updateProvider);
    final updateNotifier = ref.read(updateProvider.notifier);

    return Card(
      padding: AppEdgeInsets.all16,
      child: Column(
        children: [
          InfoRow(
            label: l10n.ankiRustCore,
            value: AnkiBridge.isAvailable
                ? l10n.rslibLinked
                : l10n.dartCoreEngine,
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
            onTap: () => context.push(AppRoutes.licenses),
          ),
          const Divider(),
          ClickableInfoRow(
            label: l10n.privacyPolicy,
            onTap: () => context.push(AppRoutes.privacyPolicy),
          ),
        ],
      ),
    );
  }
}
