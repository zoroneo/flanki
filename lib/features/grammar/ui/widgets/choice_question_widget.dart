import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';

import 'package:flanki/core/widgets/animations/shake_animation.dart';
import 'package:flanki/core/widgets/rich_card_content.dart';

class ChoiceQuestionWidget extends StatelessWidget {
  final GrammarExercise exercise;
  final String? selectedAnswer;
  final bool isSubmitted;
  final ValueChanged<String> onSelectAnswer;

  const ChoiceQuestionWidget({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.isSubmitted,
    required this.onSelectAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = exercise.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Prompt container
        Card(
          child: Padding(
            padding: AppEdgeInsets.h16v12,
            child: RichCardContent(
              content: exercise.prompt,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ),
        AppGaps.v12,

        // 4 Options
        ...List.generate(options.length, (index) {
          final option = options[index];
          final optionLetter =
              index < GrammarConstants.errorIdOptionLabels.length
              ? GrammarConstants.errorIdOptionLabels[index]
              : String.fromCharCode(65 + index);
          final isSelected = selectedAnswer == option;
          final isCorrectOption = option == exercise.correctAnswer;

          m.Color? backgroundColor;
          m.Color? borderColor;
          m.Color? textColor;

          if (isSubmitted) {
            if (isCorrectOption) {
              backgroundColor = Colors.green.withValues(alpha: 0.12);
              borderColor = Colors.green;
              textColor = Colors.green;
            } else if (isSelected && !isCorrectOption) {
              backgroundColor = Colors.red.withValues(alpha: 0.12);
              borderColor = Colors.red;
              textColor = Colors.red;
            } else {
              backgroundColor = theme.colorScheme.muted.withValues(alpha: 0.3);
            }
          } else if (isSelected) {
            backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.08);
            borderColor = theme.colorScheme.primary;
          }

          final isWrongSelected = isSubmitted && isSelected && !isCorrectOption;

          Widget optionWidget = GestureDetector(
            onTap: isSubmitted ? null : () => onSelectAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: AppEdgeInsets.h12v8,
              decoration: BoxDecoration(
                color: backgroundColor ?? theme.colorScheme.card,
                borderRadius: AppRadius.borderMd,
                border: Border.all(
                  color: borderColor ?? theme.colorScheme.border,
                  width: (isSelected || (isSubmitted && isCorrectOption))
                      ? 1.8
                      : 1.0,
                ),
              ),
              child: Row(
                children: [
                  // Badge A, B, C, D
                  Container(
                    width: AppSpacing.xxl,
                    height: AppSpacing.xxl,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: (isSelected || (isSubmitted && isCorrectOption))
                          ? (borderColor ?? theme.colorScheme.primary)
                          : theme.colorScheme.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      optionLetter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (isSelected || (isSubmitted && isCorrectOption))
                            ? theme.colorScheme.primaryForeground
                            : theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  AppGaps.h12,
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: textColor ?? theme.colorScheme.foreground,
                      ),
                    ),
                  ),
                  if (isSubmitted && isCorrectOption)
                    const Icon(
                      LucideIcons.check,
                      size: AppIconSize.sm,
                      color: Colors.green,
                    ),
                  if (isSubmitted && isSelected && !isCorrectOption)
                    const Icon(
                      LucideIcons.x,
                      size: AppIconSize.sm,
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          );

          if (isWrongSelected) {
            optionWidget = ShakeAnimation(trigger: true, child: optionWidget);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: optionWidget,
          );
        }),
      ],
    );
  }
}
