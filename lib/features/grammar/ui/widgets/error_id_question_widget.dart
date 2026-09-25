import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';

class ErrorIdQuestionWidget extends StatelessWidget {
  final GrammarExercise exercise;
  final String? selectedAnswer;
  final bool isSubmitted;
  final ValueChanged<String> onSelectAnswer;

  const ErrorIdQuestionWidget({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.isSubmitted,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = context.colors;
    final prompt = exercise.prompt;
    final options = exercise.options.isNotEmpty
        ? exercise.options
        : GrammarConstants.errorIdOptionLabels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instructions badge
        Row(
          children: [
            Container(
              padding: AppEdgeInsets.h8v4,
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: AppRadius.borderSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.scanSearch, size: AppIconSize.xs),
                  AppGaps.h8,
                  Text(
                    l10n.grammarErrorIdInstruction,
                    style: theme.typography.xSmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppGaps.v8,

        // Prompt Card with parsed tags
        Card(
          child: Padding(
            padding: AppEdgeInsets.h16v12,
            child: _buildRichPrompt(context, prompt, theme),
          ),
        ),
        AppGaps.v12,

        // 4 Option Buttons (A, B, C, D)
        Row(
          children: options.map((opt) {
            final isSelected = selectedAnswer?.toUpperCase() == opt;
            final isCorrectError = opt == exercise.correctAnswer.toUpperCase();

            m.Color? backgroundColor;
            m.Color? borderColor;
            m.Color? textColor;

            if (isSubmitted) {
              if (isCorrectError) {
                backgroundColor = colors.success.withValues(alpha: 0.15);
                borderColor = colors.success;
                textColor = colors.success;
              } else if (isSelected && !isCorrectError) {
                backgroundColor = colors.error.withValues(alpha: 0.15);
                borderColor = colors.error;
                textColor = colors.error;
              } else {
                backgroundColor = theme.colorScheme.muted.withValues(
                  alpha: 0.3,
                );
              }
            } else if (isSelected) {
              backgroundColor = theme.colorScheme.primary.withValues(
                alpha: 0.1,
              );
              borderColor = theme.colorScheme.primary;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: GestureDetector(
                  onTap: isSubmitted ? null : () => onSelectAnswer(opt),
                  child: AnimatedContainer(
                    duration: AppDurations.short,
                    height: AppDimensions.buttonHeightStandard,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? theme.colorScheme.card,
                      borderRadius: AppRadius.borderMd,
                      border: Border.all(
                        color: borderColor ?? theme.colorScheme.border,
                        width: (isSelected || (isSubmitted && isCorrectError))
                            ? 1.8
                            : AppDimensions.hairline,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '[$opt]',
                          style: TextStyle(
                            fontSize: AppTypography.navPlus,
                            fontWeight: FontWeight.bold,
                            color:
                                textColor ??
                                (isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.foreground),
                          ),
                        ),
                        if (isSubmitted && isCorrectError) ...[
                          AppGaps.h4,
                          Icon(
                            LucideIcons.check,
                            size: AppIconSize.xs,
                            color: colors.success,
                          ),
                        ],
                        if (isSubmitted && isSelected && !isCorrectError) ...[
                          AppGaps.h4,
                          Icon(
                            LucideIcons.x,
                            size: AppIconSize.xs,
                            color: colors.error,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRichPrompt(
    BuildContext context,
    String prompt,
    ThemeData theme,
  ) {
    // Regex splits on [A], [B], [C], [D]
    final regex = RegExp(r'(\[(?:A|B|C|D)\])');
    final parts = prompt.split(regex);
    final matches = regex.allMatches(prompt).map((m) => m.group(0)!).toList();

    final textSpans = <InlineSpan>[];
    int matchIdx = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        textSpans.add(
          TextSpan(
            text: parts[i],
            style: TextStyle(
              fontSize: AppTypography.medium,
              fontWeight: FontWeight.normal,
              height: 1.45,
              color: theme.colorScheme.foreground,
            ),
          ),
        );
      }
      if (matchIdx < matches.length) {
        final tag = matches[matchIdx];
        final letter = tag.replaceAll(RegExp(r'[\[\]]'), '');
        final isSelected = selectedAnswer?.toUpperCase() == letter;
        final isCorrectError = letter == exercise.correctAnswer.toUpperCase();

        final colors = context.colors;
        m.Color badgeColor = theme.colorScheme.primary;
        if (isSubmitted) {
          if (isCorrectError) {
            badgeColor = colors.success;
          } else if (isSelected) {
            badgeColor = colors.error;
          }
        }

        textSpans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: isSubmitted ? null : () => onSelectAnswer(letter),
              child: Container(
                margin: AppEdgeInsets.h4v2,
                padding: AppEdgeInsets.h8v4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? badgeColor.withValues(alpha: 0.15)
                      : theme.colorScheme.muted,
                  border: Border.all(
                    color: isSelected ? badgeColor : theme.colorScheme.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: AppTypography.nav,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? badgeColor
                        : theme.colorScheme.foreground,
                  ),
                ),
              ),
            ),
          ),
        );
        matchIdx++;
      }
    }

    return Text.rich(TextSpan(children: textSpans));
  }
}
