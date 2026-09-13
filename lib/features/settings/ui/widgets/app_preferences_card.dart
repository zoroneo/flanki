import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/theme_notifier.dart';
import 'settings_info_rows.dart';

class AppPreferencesCard extends ConsumerWidget {
  const AppPreferencesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeNotifierProvider);
    final localeNotifier = ref.read(localeNotifierProvider.notifier);
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    final isVi = currentLocale?.languageCode == 'vi';
    final isEn = currentLocale?.languageCode == 'en';
    final isSystem = currentLocale == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appPreferences,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        AppGaps.v8,
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLanguageHeader(theme, l10n),
              AppGaps.v12,
              _buildLanguageOptions(l10n, localeNotifier, isVi, isEn, isSystem),
              AppGaps.v16,
              const Divider(),
              AppGaps.v16,
              _buildAppearanceHeader(theme, l10n),
              AppGaps.v12,
              _buildThemeOptions(l10n, themeMode, themeNotifier),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageHeader(ThemeData theme, dynamic l10n) {
    return Row(
      children: [
        const Icon(LucideIcons.languages, size: AppIconSize.md),
        AppGaps.h12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.language, style: theme.typography.semiBold),
              Text(
                l10n.languageSubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOptions(
    dynamic l10n,
    LocaleNotifier localeNotifier,
    bool isVi,
    bool isEn,
    bool isSystem,
  ) {
    return Row(
      children: [
        Expanded(
          child: LanguageOptionButton(
            label: l10n.languageVietnamese,
            isSelected: isVi,
            onTap: () => localeNotifier.setLocale(const Locale('vi')),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: LanguageOptionButton(
            label: l10n.languageEnglish,
            isSelected: isEn,
            onTap: () => localeNotifier.setLocale(const Locale('en')),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: LanguageOptionButton(
            label: l10n.languageSystem,
            isSelected: isSystem,
            onTap: () => localeNotifier.setLocale(null),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceHeader(ThemeData theme, dynamic l10n) {
    return Row(
      children: [
        const Icon(LucideIcons.sunMoon, size: AppIconSize.md),
        AppGaps.h12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.appearance, style: theme.typography.semiBold),
              Text(
                l10n.appearanceSubtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOptions(
    dynamic l10n,
    ThemeMode themeMode,
    ThemeNotifier themeNotifier,
  ) {
    return Row(
      children: [
        Expanded(
          child: LanguageOptionButton(
            label: l10n.themeLight,
            isSelected: themeMode == ThemeMode.light,
            onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: LanguageOptionButton(
            label: l10n.themeDark,
            isSelected: themeMode == ThemeMode.dark,
            onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
          ),
        ),
        AppGaps.h8,
        Expanded(
          child: LanguageOptionButton(
            label: l10n.themeSystem,
            isSelected: themeMode == ThemeMode.system,
            onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}
