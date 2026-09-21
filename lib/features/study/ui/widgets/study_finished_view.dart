import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../providers/study_session_notifier.dart';

class StudyFinishedView extends StatelessWidget {
  final dynamic l10n;
  final StudySessionNotifier notifier;
  final int completedCount;

  const StudyFinishedView({
    super.key,
    required this.l10n,
    required this.notifier,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.x),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(
            l10n.studyCompleteTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Elastic bounce entrance for completion badge
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.2, end: 1.0),
                duration: AppDurations.celebrationBounce,
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  padding: AppEdgeInsets.all24,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.checkCheck,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
              ),
              AppGaps.v24,
              Text(
                l10n.studyCompleteTitle,
                style: theme.typography.h2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              AppGaps.v8,
              // Animated count-up for completed cards
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: completedCount),
                duration: AppDurations.celebration,
                curve: Curves.easeOutCubic,
                builder: (context, count, _) {
                  return Text(
                    l10n.studyCompleteDesc(count),
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              AppGaps.v32,
              PrimaryButton(
                alignment: Alignment.center,
                onPressed: () => context.pop(),
                child: Text(l10n.backToDecks),
              ),
              AppGaps.v12,
              GhostButton(
                onPressed: () => notifier.restart(),
                child: Text(l10n.studyAgain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
