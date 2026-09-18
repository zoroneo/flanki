import 'dart:math' as math;

import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import 'study_card_views.dart';

class StudyCardFlipper extends StatelessWidget {
  final AnimationController flipController;
  final CardModel? currentCard;
  final bool isFlipped;
  final String typedAnswer;
  final ValueChanged<String> onAnswerChanged;
  final VoidCallback onSubmitAnswer;
  final double cardHorizontalPadding;
  final double dragOffset;
  final Offset? quickFocusTagOffset;
  final ValueChanged<Offset>? onQuickFocusTagOffsetChanged;

  const StudyCardFlipper({
    super.key,
    required this.flipController,
    required this.currentCard,
    this.isFlipped = false,
    required this.typedAnswer,
    required this.onAnswerChanged,
    required this.onSubmitAnswer,
    required this.cardHorizontalPadding,
    this.dragOffset = 0.0,
    this.quickFocusTagOffset,
    this.onQuickFocusTagOffsetChanged,
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
        final isUnder = isFlipped && angle > (math.pi / 2);

        // Perspective flip matrix with 0.001 depth entry
        final flipMatrix = Matrix4.identity()
          ..setEntry(3, 2, AppThemeValues.cardFlipPerspective)
          ..rotateY(angle);

        // Scale dip during mid-turn (simulating slight depth recoil in 3D space)
        final depthScale =
            1.0 - (math.sin(flipProgress * math.pi) *
                AppThemeValues.cardFlipDepthScaleDip);

        // Drag & tilt physics: horizontal displacement and slight Z-axis rotation
        final tiltAngle = (dragOffset * AppThemeValues.cardFlipTiltFactor).clamp(
          -AppThemeValues.cardFlipMaxTilt,
          AppThemeValues.cardFlipMaxTilt,
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.cardMaxWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: cardHorizontalPadding,
                vertical: AppSpacing.smPlus,
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
                                quickFocusTagOffset: quickFocusTagOffset,
                                onQuickFocusTagOffsetChanged:
                                    onQuickFocusTagOffsetChanged,
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
