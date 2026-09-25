import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../theme/app_tokens.dart';

class TypeAnswerInputBox extends HookWidget {
  final String initialValue;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;
  final FocusNode? focusNode;

  const TypeAnswerInputBox({
    super.key,
    this.initialValue = '',
    this.onAnswerChanged,
    this.onSubmitAnswer,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = useTextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.smPlus,
        horizontal: AppSpacing.xs,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.typeInputMaxWidth,
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.text,
          placeholder: Text(l10n.typeAnswerPlaceholder),
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.smPlus,
            AppSpacing.s6,
            AppSpacing.s6,
            AppSpacing.s6,
          ),
          features: [
            InputFeature.leading(
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xs,
                  right: AppSpacing.s6,
                ),
                child: Icon(
                  LucideIcons.keyboard,
                  size: AppIconSize.md,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
            if (onSubmitAnswer != null)
              InputFeature.trailing(
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xxs),
                  child: PrimaryButton(
                    alignment: Alignment.center,
                    size: ButtonSize.small,
                    onPressed: onSubmitAnswer,
                    leading: const Icon(LucideIcons.send, size: AppIconSize.sm),
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
    final colors = context.colors;
    final typed = typedAnswer?.trim() ?? '';
    final expected = expectedAnswer.trim();
    final isCorrect =
        typed.isNotEmpty && typed.toLowerCase() == expected.toLowerCase();
    final isEmpty = typed.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.typeResultMaxWidth,
        ),
        padding: AppEdgeInsets.h16v12,
        decoration: BoxDecoration(
          color: isEmpty
              ? theme.colorScheme.muted
              : (isCorrect
                    ? colors.success.withValues(alpha: 0.12)
                    : colors.error.withValues(alpha: 0.12)),
          borderRadius: AppRadius.borderLg,
          border: Border.all(
            color: isEmpty
                ? theme.colorScheme.border
                : (isCorrect ? colors.success : colors.error),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isCorrect) ...[
              _buildCorrectContent(theme, colors, l10n, expected),
            ] else if (!isEmpty) ...[
              _buildIncorrectContent(theme, colors, l10n, typed, expected),
            ] else ...[
              _buildEmptyContent(theme, l10n, expected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectContent(
    ThemeData theme,
    AppColorsExtension colors,
    dynamic l10n,
    String expected,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.circleCheck,
              color: colors.success,
              size: AppIconSize.md,
            ),
            AppGaps.h8,
            Text(
              l10n.correctAnswerLabel,
              style: theme.typography.semiBold.copyWith(color: colors.success),
            ),
          ],
        ),
        AppGaps.v4,
        Text(
          expected,
          style: theme.typography.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.successDark,
          ),
        ),
      ],
    );
  }

  Widget _buildIncorrectContent(
    ThemeData theme,
    AppColorsExtension colors,
    dynamic l10n,
    String typed,
    String expected,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.circleAlert,
              color: colors.error,
              size: AppIconSize.md,
            ),
            AppGaps.h8,
            Text(
              l10n.yourAnswerLabel,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            Text(
              typed,
              style: theme.typography.semiBold.copyWith(
                color: colors.error,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
        AppGaps.v6,
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
                color: colors.successDark,
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
          size: AppIconSize.md,
        ),
        AppGaps.h8,
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
