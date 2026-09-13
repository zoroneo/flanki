import 'dart:math' as math;

import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../models/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

import 'package:flanki/core/widgets/rich_card_content.dart';

class ExplanationSheet extends StatelessWidget {
  final GrammarExercise exercise;
  final bool isCorrect;
  final bool isLastQuestion;
  final VoidCallback onNext;
  final bool isSidePanel;
  final ScrollController? scrollController;
  final DraggableScrollableController? sheetController;

  const ExplanationSheet({
    super.key,
    required this.exercise,
    required this.isCorrect,
    required this.isLastQuestion,
    required this.onNext,
    this.isSidePanel = false,
    this.scrollController,
    this.sheetController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final explanation = exercise.explanation;

    final containerDecoration = isSidePanel
        ? BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: AppRadius.borderLg,
            border: Border.all(
              color: theme.colorScheme.border.withValues(alpha: 0.6),
              width: 1,
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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.xl),
            ),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.border.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          );

    final scrollableWidget = SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                bottom: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.shieldAlert,
                    size: AppIconSize.xs,
                    color: Colors.orange,
                  ),
                  AppGaps.h8,
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

    final detailsContent = (sheetController != null)
        ? NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              if (notification.scrollDelta != null &&
                  notification.scrollDelta! > 1.0 &&
                  sheetController!.isAttached &&
                  sheetController!.size < 0.95) {
                sheetController!.animateTo(
                  1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                );
              }
              return false;
            },
            child: scrollableWidget,
          )
        : scrollableWidget;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final isExpandedLayout = isSidePanel || scrollController != null;
    final scrollableDetails = isExpandedLayout
        ? Expanded(child: detailsContent)
        : ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.min(380.0, screenHeight * 0.45),
            ),
            child: detailsContent,
          );

    return Container(
      decoration: containerDecoration,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        isSidePanel ? AppSpacing.md : 0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: SafeArea(
        top: scrollController != null,
        bottom: !isSidePanel,
        child: Column(
          mainAxisSize: isExpandedLayout ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isSidePanel)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (sheetController != null && sheetController!.isAttached) {
                    final target = sheetController!.size < 0.75 ? 1.0 : 0.50;
                    sheetController!.animateTo(
                      target,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: AppSpacing.xs,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.mutedForeground.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: AppRadius.borderXs,
                      ),
                    ),
                  ),
                ),
              ),

            // Banner Status
            Padding(
              padding: EdgeInsets.only(
                top: isSidePanel ? 0 : 2,
                bottom: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? LucideIcons.circleCheck
                        : LucideIcons.circleAlert,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: AppIconSize.md,
                  ),
                  AppGaps.h8,
                  Expanded(
                    child: Text(
                      isCorrect
                          ? l10n.grammarAnswerCorrect
                          : l10n.grammarAnswerIncorrect,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            scrollableDetails,
            const Divider(height: AppSpacing.lg, thickness: 0.8),

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
                    AppGaps.h8,
                    Icon(
                      isLastQuestion
                          ? LucideIcons.flag
                          : LucideIcons.arrowRight,
                      size: AppIconSize.xs,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppIconSize.xs, color: color),
              AppGaps.h8,
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
          AppGaps.v4,
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.xl),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppEdgeInsets.h12v8,
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: AppRadius.borderMd,
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
                padding: AppEdgeInsets.h8v4,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.x,
                      size: AppIconSize.xs,
                      color: Colors.red,
                    ),
                    AppGaps.h4,
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
                AppGaps.h8,
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
          AppGaps.v4,
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
