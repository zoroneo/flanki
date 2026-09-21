import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import 'study_card_flipper.dart';

class StudyCardGestureArea extends StatelessWidget {
  final CardModel? currentCard;
  final bool isFlipped;
  final bool isWhiteboardOpen;
  final AnimationController flipController;
  final String typedAnswer;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onSubmitAnswer;
  final double cardHorizontalPadding;
  final double dragOffset;
  final ValueChanged<double> onDragOffsetDelta;
  final ValueChanged<double> onDragOffsetReset;
  final ValueChanged<ReviewRating> onSwipeRate;
  final Offset? quickFocusTagOffset;
  final ValueChanged<Offset> onQuickFocusTagOffsetChanged;

  const StudyCardGestureArea({
    super.key,
    required this.currentCard,
    required this.isFlipped,
    required this.isWhiteboardOpen,
    required this.flipController,
    required this.typedAnswer,
    required this.onAnswerChanged,
    required this.onSubmitAnswer,
    required this.cardHorizontalPadding,
    required this.dragOffset,
    required this.onDragOffsetDelta,
    required this.onDragOffsetReset,
    required this.onSwipeRate,
    required this.quickFocusTagOffset,
    required this.onQuickFocusTagOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (isFlipped && !isWhiteboardOpen) {
          onDragOffsetDelta(details.primaryDelta ?? 0);
        }
      },
      onHorizontalDragEnd: (details) {
        if (isFlipped && !isWhiteboardOpen) {
          if (dragOffset < -80) {
            onSwipeRate(ReviewRating.again);
          } else if (dragOffset > 80) {
            onSwipeRate(ReviewRating.good);
          } else {
            onDragOffsetReset(0.0);
          }
        }
      },
      child: AnimatedSwitcher(
        duration: AppDurations.modal,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: AppWidgetKeys.card(currentCard?.id),
          child: StudyCardFlipper(
            flipController: flipController,
            currentCard: currentCard,
            isFlipped: isFlipped,
            typedAnswer: typedAnswer,
            onAnswerChanged: onAnswerChanged,
            onSubmitAnswer: onSubmitAnswer,
            cardHorizontalPadding: cardHorizontalPadding,
            dragOffset: dragOffset,
            quickFocusTagOffset: quickFocusTagOffset,
            onQuickFocusTagOffsetChanged: onQuickFocusTagOffsetChanged,
          ),
        ),
      ),
    );
  }
}
