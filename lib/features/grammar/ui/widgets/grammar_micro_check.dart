import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

/// Micro Concept Check (CCQ) widget placed at the end of the Concept theory
/// to activate immediate active recall with instant feedback.
class GrammarMicroCheck extends HookWidget {
  final bool isMobile;

  const GrammarMicroCheck({super.key, this.isMobile = true});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final selectedOption = useState<int?>(null);

    return Container(
      padding: isMobile ? AppEdgeInsets.all12 : AppEdgeInsets.all16,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.border
              : theme.colorScheme.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: isMobile ? AppIconSize.xsPlus : AppIconSize.sm,
                color: colors.warning,
              ),
              AppGaps.h8,
              Expanded(
                child: Text(
                  l10n.grammarQuickCheckTitle,
                  style: TextStyle(
                    fontSize: isMobile
                        ? AppTypography.xSmallPlus
                        : AppTypography.nav,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v10,

          // Prompt
          Container(
            padding: AppEdgeInsets.all8,
            decoration: BoxDecoration(
              color: theme.colorScheme.muted.withValues(alpha: 0.35),
              borderRadius: AppRadius.borderSm,
            ),
            child: Text(
              l10n.grammarQuickCheckPrompt,
              style: TextStyle(
                fontSize: AppTypography.xSmallPlus,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
                height: 1.4,
              ),
            ),
          ),
          AppGaps.v10,

          // Option A
          _buildOptionTile(
            index: 0,
            letter: 'A',
            text: 'I live in Da Nang.',
            isSelected: selectedOption.value == 0,
            isCorrect: false,
            colors: colors,
            theme: theme,
            onTap: () => selectedOption.value = 0,
          ),
          AppGaps.v6,

          // Option B
          _buildOptionTile(
            index: 1,
            letter: 'B',
            text: 'I am living in Da Nang.',
            isSelected: selectedOption.value == 1,
            isCorrect: true,
            colors: colors,
            theme: theme,
            onTap: () => selectedOption.value = 1,
          ),

          // Feedback message
          AnimatedSize(
            duration: AppDurations.short,
            curve: Curves.easeInOut,
            child: selectedOption.value == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Container(
                      padding: AppEdgeInsets.all8,
                      decoration: BoxDecoration(
                        color: selectedOption.value == 1
                            ? colors.success.withValues(
                                alpha: isDark ? 0.12 : 0.08,
                              )
                            : colors.error.withValues(
                                alpha: isDark ? 0.12 : 0.08,
                              ),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(
                          color: selectedOption.value == 1
                              ? colors.success.withValues(alpha: 0.4)
                              : colors.error.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            selectedOption.value == 1
                                ? LucideIcons.circleCheck
                                : LucideIcons.circleAlert,
                            size: AppIconSize.sm,
                            color: selectedOption.value == 1
                                ? colors.success
                                : colors.error,
                          ),
                          AppGaps.h8,
                          Expanded(
                            child: Text(
                              selectedOption.value == 1
                                  ? l10n.grammarQuickCheckCorrectFeedback
                                  : l10n.grammarQuickCheckIncorrectFeedback,
                              style: TextStyle(
                                fontSize: AppTypography.xSmall,
                                height: 1.45,
                                color: selectedOption.value == 1
                                    ? colors.success
                                    : colors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String letter,
    required String text,
    required bool isSelected,
    required bool isCorrect,
    required AppColorsExtension colors,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final borderColor = isSelected
        ? (isCorrect ? colors.success : colors.error)
        : theme.colorScheme.border;

    final bgColor = isSelected
        ? (isCorrect
              ? colors.success.withValues(alpha: 0.08)
              : colors.error.withValues(alpha: 0.08))
        : theme.colorScheme.muted.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.short,
        padding: AppEdgeInsets.all8,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderSm,
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isCorrect ? colors.success : colors.error)
                    : theme.colorScheme.muted.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: AppTypography.caption,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.primaryForeground
                        : theme.colorScheme.foreground,
                  ),
                ),
              ),
            ),
            AppGaps.h10,
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: AppTypography.xSmallPlus,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isCorrect ? colors.success : colors.error)
                      : theme.colorScheme.foreground,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                isCorrect ? LucideIcons.check : LucideIcons.x,
                size: AppIconSize.xsPlus,
                color: isCorrect ? colors.success : colors.error,
              ),
          ],
        ),
      ),
    );
  }
}
