import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import '../../sync/ui/sync_flow_coordinator.dart';
import 'widgets/about_info_card.dart';
import 'widgets/account_sync_card.dart';
import 'widgets/app_preferences_card.dart';
import 'widgets/spaced_repetition_card.dart';
import 'widgets/study_reminders_card.dart';
import 'widgets/tools_navigation_card.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isSyncing = useState(false);

    Future<void> handleSync() async {
      await SyncFlowCoordinator.runSyncFlow(
        context: context,
        ref: ref,
        l10n: l10n,
        isSyncing: isSyncing,
      );
    }

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
        final theme = Theme.of(context);
        final horizontalPadding = isMobile
            ? AppSpacing.pageMobile
            : AppSpacing.pageDesktop;

        return Scaffold(
          headers: [
            AppBar(
              title: Text(
                l10n.settingsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (isMobile ? theme.typography.large : theme.typography.h4)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                children: [
                  AccountSyncCard(isSyncing: isSyncing, onSync: handleSync),
                  AppGaps.v24,
                  const ToolsNavigationCard(),
                  AppGaps.v24,
                  const AppPreferencesCard(),
                  AppGaps.v24,
                  const SpacedRepetitionCard(),
                  AppGaps.v24,
                  const StudyRemindersCard(),
                  AppGaps.v24,
                  const AboutInfoCard(),
                  SizedBox(height: isMobile ? 110 : 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
