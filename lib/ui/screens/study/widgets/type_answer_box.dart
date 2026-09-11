import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';

class TypeAnswerInputBox extends HookWidget {
  final String initialValue;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;

  const TypeAnswerInputBox({
    super.key,
    this.initialValue = '',
    this.onAnswerChanged,
    this.onSubmitAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = useTextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: TextField(
          controller: controller,
          autofocus: false,
          placeholder: Text(l10n.typeAnswerPlaceholder),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
          features: [
            InputFeature.leading(
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 6),
                child: Icon(
                  LucideIcons.keyboard,
                  size: 18,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            if (onSubmitAnswer != null)
              InputFeature.trailing(
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: onSubmitAnswer,
                    leading: const Icon(LucideIcons.send, size: 14),
                    child: Text(l10n.submitAnswer),
                  ),
                ),
              ),
          ],
          onChanged: onAnswerChanged,
          onSubmitted: (_) => onSubmitAnswer?.call(),
        ),
      ),
    );
  }
}

class TypeAnswerResultBox extends StatelessWidget {
  final String? typedAnswer;
  final String expectedAnswer;

  const TypeAnswerResultBox({
    super.key,
    this.typedAnswer,
    required this.expectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final typed = typedAnswer?.trim() ?? '';
    final expected = expectedAnswer.trim();
    final isCorrect =
        typed.isNotEmpty && typed.toLowerCase() == expected.toLowerCase();
    final isEmpty = typed.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEmpty
              ? theme.colorScheme.muted
              : (isCorrect
                    ? m.Colors.green.withValues(alpha: 0.12)
                    : m.Colors.red.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? theme.colorScheme.border
                : (isCorrect ? m.Colors.green : m.Colors.red),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isCorrect) ...[
              _buildCorrectContent(theme, l10n, expected),
            ] else if (!isEmpty) ...[
              _buildIncorrectContent(theme, l10n, typed, expected),
            ] else ...[
              _buildEmptyContent(theme, l10n, expected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectContent(ThemeData theme, dynamic l10n, String expected) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.circleCheck,
              color: m.Colors.green,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.correctAnswerLabel,
              style: theme.typography.semiBold.copyWith(color: m.Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          expected,
          style: theme.typography.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: m.Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildIncorrectContent(
    ThemeData theme,
    dynamic l10n,
    String typed,
    String expected,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert, color: m.Colors.red, size: 18),
            const SizedBox(width: 6),
            Text(
              l10n.yourAnswerLabel,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            Text(
              typed,
              style: theme.typography.semiBold.copyWith(
                color: m.Colors.red,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.expectedAnswerLabel,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            Text(
              expected,
              style: theme.typography.h4.copyWith(
                fontWeight: FontWeight.w700,
                color: m.Colors.green.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyContent(ThemeData theme, dynamic l10n, String expected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          LucideIcons.circleHelp,
          color: theme.colorScheme.primary,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          l10n.answerLabel,
          style: theme.typography.small.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        Text(
          expected,
          style: theme.typography.h4.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
