import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/models/card.dart';
import '../../../../core/services/desktop_window_service.dart';
import '../../../../core/theme/app_tokens.dart';
import 'card_action_sheet.dart';
import 'draggable_quick_focus_tag.dart';

import 'package:flanki/core/widgets/rich_card_content.dart';

class CardFrontView extends HookWidget {
  final CardModel? card;
  final ThemeData theme;
  final String? typedAnswer;
  final ValueChanged<String>? onAnswerChanged;
  final VoidCallback? onSubmitAnswer;
  final Offset? quickFocusTagOffset;
  final ValueChanged<Offset>? onQuickFocusTagOffsetChanged;

  const CardFrontView({
    super.key,
    required this.card,
    required this.theme,
    this.typedAnswer,
    this.onAnswerChanged,
    this.onSubmitAnswer,
    this.quickFocusTagOffset,
    this.onQuickFocusTagOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDesktop = DesktopWindowService.isDesktop || context.isDesktop;
    final focusNode = useFocusNode();
    final scrollController = useScrollController();
    useListenable(focusNode);
    final isFocused = focusNode.hasFocus;

    final hasTypeInput = useMemoized(
      () => RichCardContent.hasTypeInput(card?.front),
      [card?.front],
    );

    // Auto-focus the input box on desktop once card data finishes loading
    useEffect(() {
      if (isDesktop && hasTypeInput) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });
      }
      return null;
    }, [card?.id, isDesktop, hasTypeInput]);

    void handleQuickFocus() {
      HapticFeedback.lightImpact();
      focusNode.requestFocus();
      if (scrollController.hasClients &&
          scrollController.position.maxScrollExtent > 0) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
        );
      }
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: theme.borderRadiusLg,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              final cardHeight = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  CustomScrollView(
                    controller: scrollController,
                    clipBehavior: Clip.antiAlias,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBadgeRow(context, theme, l10n),
                              AppGaps.v16,
                              RichCardContent(
                                content: card?.front ?? '',
                                autoPlayAudio: true,
                                typedAnswer: typedAnswer,
                                typeAnswerFocusNode: focusNode,
                                onAnswerChanged: onAnswerChanged,
                                onSubmitAnswer: onSubmitAnswer,
                                textStyle: theme.typography.h2.copyWith(
                                  color: theme.colorScheme.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hasTypeInput &&
                      !isDesktop &&
                      cardWidth > 0 &&
                      cardHeight > 0)
                    DraggableQuickFocusTag(
                      theme: theme,
                      isFocused: isFocused,
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      initialOffset: quickFocusTagOffset,
                      onPositionChanged: onQuickFocusTagOffsetChanged,
                      onTap: handleQuickFocus,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeRow(BuildContext context, ThemeData theme, dynamic l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smPlus,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.muted,
            borderRadius: AppRadius.borderFull,
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
          AppGaps.h8,
          Container(
            width: AppSpacing.sm,
            height: AppSpacing.sm,
            decoration: BoxDecoration(
              color: CardActionSheet.getFlagColor(context, card!.flag),
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
          child: CustomScrollView(
            clipBehavior: Clip.antiAlias,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.smPlus,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: AppRadius.borderFull,
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
                      AppGaps.v16,
                      RichCardContent(
                        content: card?.back ?? '',
                        autoPlayAudio: true,
                        typedAnswer: typedAnswer,
                        textStyle: theme.typography.h3.copyWith(
                          color: theme.colorScheme.foreground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
