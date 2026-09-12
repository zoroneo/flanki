import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import 'study_rating_bar.dart';

class StudyBottomActionArea extends StatelessWidget {
  final bool isFlipped;
  final bool isMobile;
  final Map<ReviewRating, String> intervals;
  final ValueChanged<ReviewRating> onRate;
  final VoidCallback onFlip;
  final double bottomHorizontalPadding;
  final dynamic l10n;

  const StudyBottomActionArea({
    super.key,
    required this.isFlipped,
    required this.isMobile,
    required this.intervals,
    required this.onRate,
    required this.onFlip,
    required this.bottomHorizontalPadding,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: bottomHorizontalPadding,
              vertical: 12,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.15),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isFlipped
                  ? KeyedSubtree(
                      key: const ValueKey('rating_bar'),
                      child: StudyRatingBar(
                        intervals: intervals,
                        isMobile: isMobile,
                        onRate: onRate,
                      ),
                    )
                  : KeyedSubtree(
                      key: const ValueKey('flip_button'),
                      child: SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          alignment: Alignment.center,
                          onPressed: onFlip,
                          child: Text(
                            !isMobile
                                ? '${l10n.tapToFlip}  [Space]'
                                : l10n.tapToFlip,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
