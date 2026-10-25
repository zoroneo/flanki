import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/services/desktop_window_service.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../providers/settings_notifier.dart';
import 'settings_info_rows.dart';

class StudyRemindersCard extends ConsumerWidget {
  const StudyRemindersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final reminderEnabled = ref.watch(
      studySettingsProvider.select((s) => s.reminderEnabled),
    );
    final studySettingsNotifier = ref.read(studySettingsProvider.notifier);

    return Card(
      padding: AppEdgeInsets.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDailyReminderToggle(
            theme,
            l10n,
            reminderEnabled,
            studySettingsNotifier,
          ),
          if (reminderEnabled) ...[
            AppGaps.v16,
            Consumer(
              builder: (context, ref, _) {
                final (hour, min) = ref.watch(
                  studySettingsProvider.select(
                    (s) => (s.reminderHour, s.reminderMinute),
                  ),
                );
                return _buildReminderTimes(
                  theme,
                  l10n,
                  hour,
                  min,
                  studySettingsNotifier,
                );
              },
            ),
            AppGaps.v16,
            const Divider(),
            AppGaps.v12,
            Consumer(
              builder: (context, ref, _) {
                final streakSaverEnabled = ref.watch(
                  studySettingsProvider.select((s) => s.streakSaverEnabled),
                );
                return _buildStreakSaverToggle(
                  context,
                  theme,
                  l10n,
                  streakSaverEnabled,
                  studySettingsNotifier,
                );
              },
            ),
            if (DesktopWindowService.isDesktop) ...[
              AppGaps.v16,
              const Divider(),
              AppGaps.v12,
              Consumer(
                builder: (context, ref, _) {
                  final minimizeToTray = ref.watch(
                    studySettingsProvider.select(
                      (s) => s.minimizeToTrayOnClose,
                    ),
                  );
                  return _buildMinimizeToTrayToggle(
                    theme,
                    l10n,
                    minimizeToTray,
                    studySettingsNotifier,
                  );
                },
              ),
              AppGaps.v16,
              const Divider(),
              AppGaps.v12,
              Consumer(
                builder: (context, ref, _) {
                  final launchAtStartup = ref.watch(
                    studySettingsProvider.select((s) => s.launchAtStartup),
                  );
                  return _buildLaunchAtStartupToggle(
                    theme,
                    l10n,
                    launchAtStartup,
                    studySettingsNotifier,
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDailyReminderToggle(
    ThemeData theme,
    dynamic l10n,
    bool reminderEnabled,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDailyReminder,
                style: theme.typography.semiBold,
              ),
              AppGaps.v2,
              Text(
                l10n.settingsDailyReminderSubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        AppGaps.h12,
        Switch(
          value: reminderEnabled,
          onChanged: studySettingsNotifier.toggleReminder,
        ),
      ],
    );
  }

  Widget _buildReminderTimes(
    ThemeData theme,
    dynamic l10n,
    int selectedHour,
    int selectedMin,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsReminderTime,
          style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
        ),
        AppGaps.v8,
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:
                [
                  [19, 0],
                  [20, 0],
                  [21, 0],
                  [22, 0],
                ].map((time) {
                  final hour = time[0];
                  final min = time[1];
                  final label =
                      '${hour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
                  final isSelected = selectedHour == hour && selectedMin == min;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxs,
                      ),
                      child: LanguageOptionButton(
                        label: label,
                        isSelected: isSelected,
                        onTap: () =>
                            studySettingsNotifier.setReminderTime(hour, min),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakSaverToggle(
    BuildContext context,
    ThemeData theme,
    dynamic l10n,
    bool streakSaverEnabled,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(l10n.settingsStreakSaver),
                  AppGaps.h8,
                  Text('(22:30)', style: context.textStyles.xSmallMedium),
                ],
              ),
              AppGaps.v2,
              Text(
                l10n.settingsStreakSaverSubtitle,
                style: context.textStyles.subMuted,
              ),
            ],
          ),
        ),
        AppGaps.h12,
        Switch(
          value: streakSaverEnabled,
          onChanged: studySettingsNotifier.toggleStreakSaver,
        ),
      ],
    );
  }

  Widget _buildMinimizeToTrayToggle(
    ThemeData theme,
    dynamic l10n,
    bool minimizeToTray,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsMinimizeToTray,
                style: theme.typography.semiBold,
              ),
              AppGaps.v2,
              Text(
                l10n.settingsMinimizeToTraySubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        AppGaps.h12,
        Switch(
          value: minimizeToTray,
          onChanged: studySettingsNotifier.toggleMinimizeToTray,
        ),
      ],
    );
  }

  Widget _buildLaunchAtStartupToggle(
    ThemeData theme,
    dynamic l10n,
    bool launchAtStartup,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsLaunchAtStartup,
                style: theme.typography.semiBold,
              ),
              AppGaps.v2,
              Text(
                l10n.settingsLaunchAtStartupSubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        AppGaps.h12,
        Switch(
          value: launchAtStartup,
          onChanged: (val) {
            studySettingsNotifier.toggleLaunchAtStartup(val);
          },
        ),
      ],
    );
  }
}
