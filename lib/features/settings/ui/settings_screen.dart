import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import 'widgets/about_info_card.dart';
import 'widgets/account_sync_card.dart';
import 'widgets/cloud_backup_card.dart';
import 'widgets/app_preferences_card.dart';
import 'widgets/settings_section.dart';
import 'widgets/spaced_repetition_card.dart';
import 'widgets/study_reminders_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;
        final theme = Theme.of(context);
        final horizontalPadding = isMobile
            ? AppSpacing.pageMobile
            : AppSpacing.pageDesktop;

        // Semantic Group 1: Đồng bộ & Dữ liệu
        final syncAndDataSection = SettingsSection(
          icon: LucideIcons.cloud,
          title: l10n.accountAndSync,
          children: const [AccountSyncCard(), AppGaps.v16, CloudBackupCard()],
        );

        // Semantic Group 2: Thuật toán & Nhắc nhở
        final learningSection = SettingsSection(
          icon: LucideIcons.brain,
          title: l10n.spacedRepetitionAlgorithm,
          children: const [
            SpacedRepetitionCard(),
            AppGaps.v16,
            StudyRemindersCard(),
          ],
        );

        // Semantic Group 3: Giao diện & Hệ thống
        final preferencesSection = SettingsSection(
          icon: LucideIcons.slidersHorizontal,
          title: l10n.appPreferences,
          children: const [AppPreferencesCard()],
        );

        // Semantic Group 4: Thông tin ứng dụng & Bản quyền
        final aboutSection = SettingsSection(
          icon: LucideIcons.info,
          title: l10n.aboutSection,
          children: const [AboutInfoCard()],
        );

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
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                children: [
                  if (isMobile) ...[
                    syncAndDataSection,
                    AppGaps.v24,
                    learningSection,
                    AppGaps.v24,
                    preferencesSection,
                    AppGaps.v24,
                    aboutSection,
                  ] else ...[
                    // Responsive Desktop / Tablet: 2-Column Balanced Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              syncAndDataSection,
                              AppGaps.v24,
                              preferencesSection,
                            ],
                          ),
                        ),
                        AppGaps.h24,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              learningSection,
                              AppGaps.v24,
                              aboutSection,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
