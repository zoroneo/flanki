import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/notifiers/settings_notifier.dart';
import '../../../core/notifiers/update_notifier.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../widgets/sync_flow_coordinator.dart';
import 'widgets/about_info_card.dart';
import 'widgets/account_sync_card.dart';
import 'widgets/app_preferences_card.dart';
import 'widgets/spaced_repetition_card.dart';
import 'widgets/study_reminders_card.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final studySettings = ref.watch(studySettingsProvider);
    final studySettingsNotifier = ref.read(studySettingsProvider.notifier);
    final updateState = ref.watch(updateProvider);
    final updateNotifier = ref.read(updateProvider.notifier);

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
        final horizontalPadding = isMobile ? 16.0 : 24.0;

        return Scaffold(
          headers: [AppBar(title: Text(l10n.settingsTitle))],
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16.0,
                ),
                children: [
                  AccountSyncCard(
                    authState: authState,
                    authNotifier: authNotifier,
                    isSyncing: isSyncing,
                    onSync: handleSync,
                  ),
                  const SizedBox(height: 24),
                  AppPreferencesCard(
                    currentLocale: currentLocale,
                    localeNotifier: localeNotifier,
                    themeMode: themeMode,
                    themeNotifier: themeNotifier,
                  ),
                  const SizedBox(height: 24),
                  SpacedRepetitionCard(
                    studySettings: studySettings,
                    studySettingsNotifier: studySettingsNotifier,
                  ),
                  const SizedBox(height: 24),
                  StudyRemindersCard(
                    studySettings: studySettings,
                    studySettingsNotifier: studySettingsNotifier,
                  ),
                  const SizedBox(height: 24),
                  AboutInfoCard(
                    themeMode: themeMode,
                    isFsrsEnabled: studySettings.fsrsEnabled,
                    updateState: updateState,
                    updateNotifier: updateNotifier,
                  ),
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
