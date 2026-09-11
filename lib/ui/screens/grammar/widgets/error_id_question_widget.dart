import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.scanSearch, size: 14),
                  const SizedBox(width: 6),
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
        const SizedBox(height: 8),

        // Prompt Card with parsed tags
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: _buildRichPrompt(context, prompt, theme),
          ),
        ),
        const SizedBox(height: 10),

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
                backgroundColor = Colors.green.withValues(alpha: 0.15);
                borderColor = Colors.green;
                textColor = Colors.green;
              } else if (isSelected && !isCorrectError) {
                backgroundColor = Colors.red.withValues(alpha: 0.15);
                borderColor = Colors.red;
                textColor = Colors.red;
              } else {
                backgroundColor = theme.colorScheme.muted.withValues(alpha: 0.3);
              }
            } else if (isSelected) {
              backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
              borderColor = theme.colorScheme.primary;
            }

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: isSubmitted ? null : () => onSelectAnswer(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? theme.colorScheme.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor ?? theme.colorScheme.border,
                        width: (isSelected || (isSubmitted && isCorrectError)) ? 1.8 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '[$opt]',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: textColor ?? (isSelected ? theme.colorScheme.primary : theme.colorScheme.foreground),
                          ),
                        ),
                        if (isSubmitted && isCorrectError) ...[
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.check, size: 15, color: Colors.green),
                        ],
                        if (isSubmitted && isSelected && !isCorrectError) ...[
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.x, size: 15, color: Colors.red),
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

  Widget _buildRichPrompt(BuildContext context, String prompt, ThemeData theme) {
    // Regex splits on [A], [B], [C], [D]
    final regex = RegExp(r'(\[(?:A|B|C|D)\])');
    final parts = prompt.split(regex);
    final matches = regex.allMatches(prompt).map((m) => m.group(0)!).toList();

    final textSpans = <InlineSpan>[];
    int matchIdx = 0;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        textSpans.add(TextSpan(
          text: parts[i],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
            height: 1.45,
            color: theme.colorScheme.foreground,
          ),
        ));
      }
      if (matchIdx < matches.length) {
        final tag = matches[matchIdx];
        final letter = tag.replaceAll(RegExp(r'[\[\]]'), '');
        final isSelected = selectedAnswer?.toUpperCase() == letter;
        final isCorrectError = letter == exercise.correctAnswer.toUpperCase();

        m.Color badgeColor = theme.colorScheme.primary;
        if (isSubmitted) {
          if (isCorrectError) {
            badgeColor = Colors.green;
          } else if (isSelected) {
            badgeColor = Colors.red;
          }
        }

        textSpans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: isSubmitted ? null : () => onSelectAnswer(letter),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? badgeColor.withValues(alpha: 0.15)
                      : theme.colorScheme.muted,
                  border: Border.all(
                    color: isSelected ? badgeColor : theme.colorScheme.border,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? badgeColor : theme.colorScheme.foreground,
                  ),
                ),
              ),
            ),
          ),
        );
        matchIdx++;
      }
    }

    return Text.rich(
      TextSpan(children: textSpans),
    );
  }
}
