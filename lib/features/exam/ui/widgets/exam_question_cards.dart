import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../models/exam_models.dart';

class ExamPassageCard extends StatelessWidget {
  final String passage;

  const ExamPassageCard({super.key, required this.passage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      padding: const EdgeInsets.all(AppSpacing.smPlus),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.readingPassage,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppGaps.v6,
          Text(passage, style: theme.typography.small),
        ],
      ),
    );
  }
}

class ExamOptionCard extends StatelessWidget {
  final ExamQuestionOption opt;
  final bool isSelected;
  final VoidCallback onTap;

  const ExamOptionCard({
    super.key,
    required this.opt,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return m.InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderMd,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.card,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.muted,
              ),
              child: Text(
                opt.id,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.primaryForeground
                      : theme.colorScheme.foreground,
                ),
              ),
            ),
            AppGaps.h12,
            Expanded(child: Text(opt.text, style: theme.typography.base)),
          ],
        ),
      ),
    );
  }
}
