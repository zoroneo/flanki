import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../models/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:flanki/core/widgets/rich_card_content.dart';

class ExplanationSheet extends StatelessWidget {
  final GrammarExercise exercise;
  final bool isCorrect;
  final bool isLastQuestion;
  final VoidCallback onNext;
  final bool isSidePanel;

  const ExplanationSheet({
    super.key,
    required this.exercise,
    required this.isCorrect,
    required this.isLastQuestion,
    required this.onNext,
    this.isSidePanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final explanation = exercise.explanation;

    final containerDecoration = isSidePanel
        ? BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCorrect
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.red.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          )
        : BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(
              top: BorderSide(
                color: isCorrect ? Colors.green : Colors.red,
                width: 2.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          );

    final detailsContent = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Translation
          if (explanation.translation.isNotEmpty)
            _buildSection(
              context,
              icon: LucideIcons.languages,
              title: l10n.grammarSectionTranslation,
              content: explanation.translation,
              color: theme.colorScheme.primary,
            ),

          // 2. Key Signal
          if (explanation.keySignal.isNotEmpty)
            _buildSection(
              context,
              icon: LucideIcons.sparkles,
              title: l10n.grammarSectionKeySignal,
              content: explanation.keySignal,
              color: Colors.amber,
            ),

          // 3. Rule
          if (explanation.rule.isNotEmpty)
            _buildSection(
              context,
              icon: LucideIcons.bookOpenCheck,
              title: l10n.grammarSectionRule,
              content: explanation.rule,
              color: Colors.blue,
            ),

          // 4. Why Correct
          if (explanation.whyCorrect.isNotEmpty)
            _buildSection(
              context,
              icon: LucideIcons.checkCheck,
              title: l10n.grammarSectionWhyCorrect,
              content: explanation.whyCorrect,
              color: Colors.green,
            ),

          // 5. Distractor Breakdown
          if (explanation.distractorBreakdown.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.shieldAlert,
                    size: 15,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.grammarSectionDistractors,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            ...explanation.distractorBreakdown.entries.map((entry) {
              return _buildDistractorItem(
                context,
                theme: theme,
                rawKey: entry.key,
                explanation: entry.value,
              );
            }),
          ],
        ],
      ),
    );

    final screenHeight = MediaQuery.sizeOf(context).height;
    final scrollableDetails = isSidePanel
        ? Expanded(child: detailsContent)
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.min(380.0, screenHeight * 0.45),
            ),
            child: detailsContent,
          );

    return Container(
      decoration: containerDecoration,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: SafeArea(
        top: false,
        bottom: !isSidePanel,
        child: Column(
          mainAxisSize: isSidePanel ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner Status
            Row(
              children: [
                Icon(
                  isCorrect ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? l10n.grammarAnswerCorrect
                        : l10n.grammarAnswerIncorrect,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ).copyWith(color: isCorrect ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            scrollableDetails,
            const Divider(height: 16, thickness: 0.8),

            // Next Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                size: ButtonSize.normal,
                onPressed: onNext,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastQuestion
                          ? l10n.grammarViewResults
                          : l10n.grammarNextQuestion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLastQuestion
                          ? LucideIcons.flag
                          : LucideIcons.arrowRight,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required m.Color color,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: RichCardContent(
              content: content,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: theme.colorScheme.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String badgeText, String? detailText) _parseDistractorKey(
    String rawKey,
    AppLocalizations l10n,
  ) {
    final match = RegExp(
      r'^(?:option\s*)?([A-D])(?:\s*[:(]\s*(.*?)[)]?)?$',
      caseSensitive: false,
    ).firstMatch(rawKey.trim());
    if (match != null) {
      final letter = match.group(1)!.toUpperCase();
      final detail = match.group(2)?.trim();
      return (
        l10n.grammarOptionBadge(letter),
        detail != null && detail.isNotEmpty ? detail : null,
      );
    }
    return (rawKey, null);
  }

  Widget _buildDistractorItem(
    BuildContext context, {
    required ThemeData theme,
    required String rawKey,
    required String explanation,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final (badgeText, detailText) = _parseDistractorKey(rawKey, l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.x, size: 11, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              if (detailText != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    detailText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.foreground.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          RichCardContent(
            content: explanation,
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
            textStyle: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: theme.colorScheme.foreground.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
