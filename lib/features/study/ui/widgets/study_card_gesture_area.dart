import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import 'study_card_flipper.dart';

class StudyCardGestureArea extends StatefulWidget {
  final CardModel? currentCard;
  final bool isFlipped;
  final bool isWhiteboardOpen;
  final AnimationController flipController;
  final String typedAnswer;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onSubmitAnswer;
  final double cardHorizontalPadding;
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
    required this.onSwipeRate,
    required this.quickFocusTagOffset,
    required this.onQuickFocusTagOffsetChanged,
  });

  @override
  State<StudyCardGestureArea> createState() => _StudyCardGestureAreaState();
}

class _StudyCardGestureAreaState extends State<StudyCardGestureArea> {
  double _dragOffset = 0.0;

  @override
  void didUpdateWidget(covariant StudyCardGestureArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCard?.id != widget.currentCard?.id) {
      _dragOffset = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (widget.isFlipped && !widget.isWhiteboardOpen) {
          setState(() {
            _dragOffset += details.primaryDelta ?? 0;
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (widget.isFlipped && !widget.isWhiteboardOpen) {
          if (_dragOffset < -80) {
            setState(() => _dragOffset = 0.0);
            widget.onSwipeRate(ReviewRating.again);
          } else if (_dragOffset > 80) {
            setState(() => _dragOffset = 0.0);
            widget.onSwipeRate(ReviewRating.good);
          } else {
            setState(() => _dragOffset = 0.0);
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
          key: AppWidgetKeys.card(widget.currentCard?.id),
          child: StudyCardFlipper(
            flipController: widget.flipController,
            currentCard: widget.currentCard,
            isFlipped: widget.isFlipped,
            typedAnswer: widget.typedAnswer,
            onAnswerChanged: widget.onAnswerChanged,
            onSubmitAnswer: widget.onSubmitAnswer,
            cardHorizontalPadding: widget.cardHorizontalPadding,
            dragOffset: _dragOffset,
            quickFocusTagOffset: widget.quickFocusTagOffset,
            onQuickFocusTagOffsetChanged: widget.onQuickFocusTagOffsetChanged,
          ),
        ),
      ),
    );
  }
}
