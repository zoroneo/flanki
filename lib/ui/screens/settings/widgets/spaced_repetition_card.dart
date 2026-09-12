import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';
import '../../../../core/notifiers/settings_notifier.dart';
import 'settings_info_rows.dart';

class SpacedRepetitionCard extends ConsumerWidget {
  const SpacedRepetitionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final studySettings = ref.watch(studySettingsProvider);
    final studySettingsNotifier = ref.read(studySettingsProvider.notifier);
    final isFsrsEnabled = studySettings.fsrsEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.spacedRepetitionAlgorithm,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlgorithmSwitch(
                theme,
                l10n,
                isFsrsEnabled,
                studySettings,
                studySettingsNotifier,
              ),
              if (isFsrsEnabled) ...[
                const SizedBox(height: 16),
                _buildRetentionRates(
                  theme,
                  l10n,
                  studySettings,
                  studySettingsNotifier,
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              _buildNewCardsPerDay(
                theme,
                l10n,
                studySettings,
                studySettingsNotifier,
              ),
              const SizedBox(height: 16),
              _buildMaxReviewsPerDay(
                theme,
                l10n,
                studySettings,
                studySettingsNotifier,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlgorithmSwitch(
    ThemeData theme,
    dynamic l10n,
    bool isFsrsEnabled,
    StudySettings studySettings,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.enableFsrs, style: theme.typography.semiBold),
              const SizedBox(height: 2),
              Text(
                isFsrsEnabled ? l10n.fsrsSubtitle : l10n.sm2Subtitle,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: isFsrsEnabled,
          onChanged: (val) {
            studySettingsNotifier.updateSettings(
              studySettings.copyWith(fsrsEnabled: val),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRetentionRates(
    ThemeData theme,
    dynamic l10n,
    StudySettings studySettings,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.targetRetentionRate('${(studySettings.desiredRetention * 100).toInt()}%')} (FSRS)',
          style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [0.80, 0.85, 0.90, 0.95].map((rate) {
            final isSelected =
                (studySettings.desiredRetention - rate).abs() < 0.001;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: LanguageOptionButton(
                  label: '${(rate * 100).toInt()}%',
                  isSelected: isSelected,
                  onTap: () {
                    studySettingsNotifier.updateSettings(
                      studySettings.copyWith(desiredRetention: rate),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNewCardsPerDay(
    ThemeData theme,
    dynamic l10n,
    StudySettings studySettings,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.newCardsPerDay,
          style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [10, 20, 30, 50].map((count) {
            final isSelected = studySettings.newCardsPerDay == count;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: LanguageOptionButton(
                  label: '$count',
                  isSelected: isSelected,
                  onTap: () {
                    studySettingsNotifier.updateSettings(
                      studySettings.copyWith(newCardsPerDay: count),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMaxReviewsPerDay(
    ThemeData theme,
    dynamic l10n,
    StudySettings studySettings,
    StudySettingsNotifier studySettingsNotifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.maxReviewsPerDay,
          style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [50, 100, 200, 500].map((count) {
            final isSelected = studySettings.maxReviewsPerDay == count;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: LanguageOptionButton(
                  label: '$count',
                  isSelected: isSelected,
                  onTap: () {
                    studySettingsNotifier.updateSettings(
                      studySettings.copyWith(maxReviewsPerDay: count),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
