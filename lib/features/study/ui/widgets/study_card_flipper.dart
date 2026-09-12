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
  final double dragOffset;

  const StudyCardFlipper({
    super.key,
    required this.flipController,
    required this.currentCard,
    required this.typedAnswer,
    required this.onAnswerChanged,
    required this.onSubmitAnswer,
    required this.cardHorizontalPadding,
    this.dragOffset = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Natural cubic easing curve for organic 3D flip sensation
    final flipAnimation = CurvedAnimation(
      parent: flipController,
      curve: Curves.easeInOutCubic,
    );

    return AnimatedBuilder(
      animation: flipAnimation,
      builder: (context, child) {
        final flipProgress = flipAnimation.value;
        final angle = flipProgress * math.pi;
        final isUnder = angle > (math.pi / 2);

        // Perspective flip matrix with 0.001 depth entry
        final flipMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(angle);

        // Scale dip during mid-turn (simulating slight depth recoil in 3D space)
        final depthScale = 1.0 - (math.sin(flipProgress * math.pi) * 0.035);

        // Drag & tilt physics: horizontal displacement and slight Z-axis rotation
        final tiltAngle = (dragOffset * 0.0006).clamp(-0.12, 0.12);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: cardHorizontalPadding,
                vertical: 12,
              ),
              child: SizedBox.expand(
                child: Transform.translate(
                  offset: Offset(dragOffset, 0.0),
                  child: Transform.rotate(
                    angle: tiltAngle,
                    child: Transform.scale(
                      scale: depthScale,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: flipMatrix,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
