import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../study/widgets/rich_card_content.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.muted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.penLine, size: 14),
                  const SizedBox(width: 6),
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
        const SizedBox(height: 8),

        // Prompt Card
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        const SizedBox(height: 10),

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
                  icon: const Icon(LucideIcons.arrowRight, size: 16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isCorrect == true)
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (isCorrect == true) ? Colors.green : Colors.red,
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
                      color: (isCorrect == true) ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (isCorrect == true)
                          ? l10n.grammarClozeSubmittedCorrect
                          : l10n.grammarClozeSubmittedIncorrect,
                      style: theme.typography.base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: (isCorrect == true) ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.grammarClozeYourAnswer(
                      selectedAnswer?.trim().isEmpty ?? true
                          ? l10n.grammarClozeBlank
                          : selectedAnswer!),
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
                if (isCorrect != true) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        l10n.grammarClozeStandardAnswer,
                        style: theme.typography.small.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.green.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          exercise.correctAnswer,
                          style: theme.typography.small.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
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
