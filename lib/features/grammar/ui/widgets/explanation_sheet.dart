import 'dart:math' as math;

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/grammar_models.dart';
import 'explanation_content_cards.dart';

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
          if (explanation.translation.isNotEmpty)
            ExplanationSection(
              icon: LucideIcons.languages,
              title: l10n.grammarSectionTranslation,
              content: explanation.translation,
              color: theme.colorScheme.primary,
            ),
          if (explanation.keySignal.isNotEmpty)
            ExplanationSection(
              icon: LucideIcons.sparkles,
              title: l10n.grammarSectionKeySignal,
              content: explanation.keySignal,
              color: Colors.amber,
            ),
          if (explanation.rule.isNotEmpty)
            ExplanationSection(
              icon: LucideIcons.bookOpenCheck,
              title: l10n.grammarSectionRule,
              content: explanation.rule,
              color: Colors.blue,
            ),
          if (explanation.whyCorrect.isNotEmpty)
            ExplanationSection(
              icon: LucideIcons.checkCheck,
              title: l10n.grammarSectionWhyCorrect,
              content: explanation.whyCorrect,
              color: Colors.green,
            ),
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
              return DistractorItemCard(
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
}
