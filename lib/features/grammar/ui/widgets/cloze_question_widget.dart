import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';

import 'package:flanki/core/widgets/rich_card_content.dart';

class ClozeQuestionWidget extends HookWidget {
  final GrammarExercise exercise;
  final String? selectedAnswer;
  final bool isSubmitted;
  final bool? isCorrect;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onSubmit;

  const ClozeQuestionWidget({
    super.key,
    required this.exercise,
    required this.selectedAnswer,
    required this.isSubmitted,
    required this.isCorrect,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final colors = context.colors;
    final textController = useTextEditingController(text: selectedAnswer ?? '');

    useEffect(() {
      textController.text = selectedAnswer ?? '';
      return null;
    }, [exercise.id]);

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
                  const Icon(LucideIcons.penLine, size: AppIconSize.xs),
                  AppGaps.h8,
                  Text(
                    l10n.grammarClozeInstruction,
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

        // Prompt Card
        Card(
          child: Padding(
            padding: AppEdgeInsets.h16v12,
            child: RichCardContent(
              content: exercise.prompt,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: AppTypography.medium,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ),
        AppGaps.v12,

        // Text input field
        if (!isSubmitted) ...[
          TextField(
            controller: textController,
            autofocus: true,
            placeholder: Text(l10n.grammarClozePlaceholder),
            features: [
              InputFeature.trailing(
                IconButton.primary(
                  density: ButtonDensity.compact,
                  icon: const Icon(
                    LucideIcons.arrowRight,
                    size: AppIconSize.sm,
                  ),
                  onPressed: (selectedAnswer?.trim().isNotEmpty ?? false)
                      ? onSubmit
                      : null,
                ),
              ),
            ],
            onChanged: (val) => onAnswerChanged(val),
            onSubmitted: (val) {
              onAnswerChanged(val);
              if (val.trim().isNotEmpty) {
                onSubmit();
              }
            },
          ),
        ] else ...[
          // Submitted View
          Container(
            padding: AppEdgeInsets.all16,
            decoration: BoxDecoration(
              color: (isCorrect == true)
                  ? colors.success.withValues(alpha: 0.1)
                  : colors.error.withValues(alpha: 0.1),
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: (isCorrect == true) ? colors.success : colors.error,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      (isCorrect == true)
                          ? LucideIcons.circleCheck
                          : LucideIcons.circleX,
                      color: (isCorrect == true) ? colors.success : colors.error,
                      size: AppIconSize.md,
                    ),
                    AppGaps.h8,
                    Text(
                      (isCorrect == true)
                          ? l10n.grammarClozeSubmittedCorrect
                          : l10n.grammarClozeSubmittedIncorrect,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (isCorrect == true) ? colors.success : colors.error,
                      ),
                    ),
                  ],
                ),
                AppGaps.v8,
                Text(
                  l10n.grammarClozeYourAnswer(
                    selectedAnswer?.trim().isEmpty ?? true
                        ? l10n.grammarClozeBlank
                        : selectedAnswer!,
                  ),
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                if (isCorrect != true) ...[
                  AppGaps.v6,
                  Row(
                    children: [
                      Text(
                        l10n.grammarClozeStandardAnswer,
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: AppEdgeInsets.h8v4,
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(
                            color: colors.success.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          exercise.correctAnswer,
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
