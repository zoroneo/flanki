import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';
import '../../../../core/models/card.dart';
import 'card_action_sheet.dart';
import 'package:flanki/core/widgets/rich_card_content.dart';

class CardFrontView extends StatelessWidget {
  final CardModel? card;
  final ThemeData theme;
  final String? typedAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;

  const CardFrontView({
    super.key,
    required this.card,
    required this.theme,
    this.typedAnswer,
    this.onAnswerChanged,
    this.onSubmitAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: theme.borderRadiusLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0.0, constraints.maxHeight - 40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBadgeRow(theme, l10n),
                      const SizedBox(height: 18),
                      RichCardContent(
                        content: card?.front ?? '',
                        autoPlayAudio: true,
                        typedAnswer: typedAnswer,
                        onAnswerChanged: onAnswerChanged,
                        onSubmitAnswer: onSubmitAnswer,
                        textStyle: theme.typography.h2.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeRow(ThemeData theme, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.studyQuestion,
            style: theme.typography.xSmall.copyWith(
              color: theme.colorScheme.mutedForeground,
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (card != null && card!.hasFlag) ...[
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  CardActionSheet.ankiFlagColors[card!.flag] ?? m.Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}

class CardBackView extends StatelessWidget {
  final CardModel? card;
  final ThemeData theme;
  final String? typedAnswer;

  const CardBackView({
    super.key,
    required this.card,
    required this.theme,
    this.typedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: theme.borderRadiusLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(0.0, constraints.maxHeight - 40),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.studyAnswer,
                          style: theme.typography.xSmall.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      RichCardContent(
                        content: card?.back ?? '',
                        autoPlayAudio: true,
                        typedAnswer: typedAnswer,
                        textStyle: theme.typography.h3.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
