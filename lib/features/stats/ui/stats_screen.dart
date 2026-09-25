import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../router/app_router.dart';
import '../../../core/config/settings_notifier.dart';
import '../providers/stats_notifier.dart';
import 'widgets/stats_heatmap_grid.dart';
import 'widgets/stats_metric_card.dart';
import 'widgets/stats_retention_card.dart';

class StatsScreen extends HookConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final stats = ref.watch(statsNotifierProvider);
    final desiredRetention = ref.watch(
      studySettingsProvider.select((s) => s.desiredRetention),
    );

    useEffect(() {
      Future.microtask(
        () => ref.read(statsNotifierProvider.notifier).refresh(),
      );
      return null;
    }, const []);

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final horizontalPadding = getValueForScreenType<double>(
          context: context,
          mobile: AppSpacing.md,
          tablet: AppSpacing.lg,
          desktop: AppSpacing.xl,
        );

        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

        return Scaffold(
          headers: [
            AppBar(
              leading: isMobile
                  ? [
                      IconButton.ghost(
                        icon: const Icon(
                          LucideIcons.arrowLeft,
                          size: AppIconSize.md,
                        ),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.decks);
                          }
                        },
                      ),
                    ]
                  : const [],
              title: Text(
                l10n.statsTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (isMobile ? theme.typography.large : theme.typography.h4)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.statsMaxWidth,
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                children: [
                  // Retention & FSRS Overview Card
                  StatsRetentionCard(
                    stats: stats,
                    desiredRetention: desiredRetention,
                    l10n: l10n,
                  ),
                  AppGaps.v16,

                  // 2 Metric Cards Grid
                  Row(
                    children: [
                      Expanded(
                        child: StatsMetricCard(
                          label: l10n.reviewedToday,
                          value: '${stats.reviewedToday}',
                          subtitle: l10n.reviewedDiff,
                          icon: LucideIcons.checkCheck,
                        ),
                      ),
                      AppGaps.h12,
                      Expanded(
                        child: StatsMetricCard(
                          label: l10n.studyTime,
                          value: l10n.studyMinutesUnit(stats.studyTimeMinutes),
                          subtitle: l10n.studyTimePerCard,
                          icon: LucideIcons.timer,
                        ),
                      ),
                    ],
                  ),
                  AppGaps.v20,

                  // Study Activity Heatmap (GitHub / Anki style)
                  StatsHeatmapGrid(
                    levels: stats.heatmapLevels,
                    streakDays: stats.streakDays,
                    l10n: l10n,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
