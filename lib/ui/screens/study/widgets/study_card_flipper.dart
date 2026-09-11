import 'dart:math' as math;

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import 'study_card_views.dart';

class StudyCardFlipper extends StatelessWidget {
  final AnimationController flipController;
  final CardModel? currentCard;
  final String typedAnswer;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onSubmitAnswer;
  final double cardHorizontalPadding;

  const StudyCardFlipper({
    super.key,
    required this.flipController,
    required this.currentCard,
    required this.typedAnswer,
    required this.onAnswerChanged,
    required this.onSubmitAnswer,
    required this.cardHorizontalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: flipController,
      builder: (context, child) {
        final angle = flipController.value * math.pi;
        final isUnder = angle > (math.pi / 2);
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: cardHorizontalPadding,
                vertical: 12,
              ),
              child: SizedBox.expand(
                child: Transform(
                  alignment: Alignment.center,
                  transform: matrix,
                  child: isUnder
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: CardBackView(
                            card: currentCard,
                            theme: theme,
                            typedAnswer: typedAnswer,
                          ),
                        )
                      : CardFrontView(
                          card: currentCard,
                          theme: theme,
                          typedAnswer: typedAnswer,
                          onAnswerChanged: onAnswerChanged,
                          onSubmitAnswer: onSubmitAnswer,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
