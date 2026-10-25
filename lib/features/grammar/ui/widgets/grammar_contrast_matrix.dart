import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class ContrastAspect {
  final String title;
  final String subtitle;
  final String nature;
  final String example;
  final String meaning;
  final Color color;
  final IconData icon;

  const ContrastAspect({
    required this.title,
    required this.subtitle,
    required this.nature,
    required this.example,
    required this.meaning,
    required this.color,
    required this.icon,
  });
}

/// Adaptive side-by-side comparison matrix contrasting two grammatical concepts.
class GrammarContrastMatrix extends StatelessWidget {
  final String unitId;
  final bool isMobile;

  const GrammarContrastMatrix({
    super.key,
    this.unitId = 'unit-01-present-simple-vs-continuous',
    this.isMobile = true,
  });

  static bool hasContrastData(String unitId) {
    return _contrastRegistry.containsKey(unitId);
  }

  static const _contrastRegistry = {
    'unit-01-present-simple-vs-continuous': true,
    'unit-02-past-simple-vs-continuous': true,
    'unit-03-present-perfect-vs-past-simple': true,
    'unit-04-present-perfect-vs-continuous': true,
    'unit-06-past-perfect-vs-past-simple': true,
    'test_structured_concept': true,
  };

  (ContrastAspect, ContrastAspect)? _resolveAspects(
    AppColorsExtension colors,
    AppLocalizations l10n,
  ) {
    switch (unitId) {
      case 'unit-01-present-simple-vs-continuous':
      case 'test_structured_concept':
        return (
          ContrastAspect(
            title: l10n.grammarPresentSimple,
            subtitle: 'Fact / Permanent',
            nature: l10n.grammarPresentSimpleNature,
            example: "'I live in Hanoi'",
            meaning: l10n.grammarPresentSimpleMeaning,
            color: colors.success,
            icon: LucideIcons.shieldCheck,
          ),
          ContrastAspect(
            title: l10n.grammarPresentContinuous,
            subtitle: 'Temporary / Trend',
            nature: l10n.grammarPresentContinuousNature,
            example: "'I am living in Hanoi'",
            meaning: l10n.grammarPresentContinuousMeaning,
            color: colors.info,
            icon: LucideIcons.activity,
          ),
        );

      case 'unit-02-past-simple-vs-continuous':
        return (
          ContrastAspect(
            title: 'Quá khứ đơn (Past Simple)',
            subtitle: 'Completed & Terminated',
            nature: 'Gói sự kiện hoàn tất 100%, mốc thời gian đã đóng',
            example: "'We finalized the contract yesterday.'",
            meaning: 'Đóng khung hành động như một bức ảnh (Snapshot)',
            color: colors.success,
            icon: LucideIcons.circleCheck,
          ),
          ContrastAspect(
            title: 'Quá khứ tiếp diễn (Past Continuous)',
            subtitle: 'In-progress Background',
            nature: 'Đoạn phim đang diễn ra lưng chừng tại thời điểm xét',
            example: "'The auditor was reviewing invoices.'",
            meaning: 'Bức tranh phông nền cho hành động khác (Video Clip)',
            color: colors.info,
            icon: LucideIcons.timer,
          ),
        );

      case 'unit-03-present-perfect-vs-past-simple':
        return (
          ContrastAspect(
            title: 'Quá khứ đơn (Past Simple)',
            subtitle: 'Finished Time / Severed',
            nature: 'Thời gian đã khép lại (yesterday, in 2019, 5 years ago)',
            example: "'I lost my keys yesterday.'",
            meaning: 'Đứt đoạn hoàn toàn với hiện tại, không dính líu',
            color: colors.success,
            icon: LucideIcons.history,
          ),
          ContrastAspect(
            title: 'Hiện tại hoàn thành (Present Perfect)',
            subtitle: 'Unfinished Time / Bridge',
            nature: 'Cầu nối quá khứ và hiện tại, thời gian còn mở',
            example: "'I have lost my keys.'",
            meaning: 'Hệ quả sờ sờ ở hiện tại (bây giờ chưa có chìa khóa)',
            color: colors.info,
            icon: LucideIcons.link,
          ),
        );

      case 'unit-04-present-perfect-vs-continuous':
        return (
          ContrastAspect(
            title: 'Hiện tại hoàn thành (Present Perfect)',
            subtitle: 'Result & Quantity',
            nature: 'Tập trung vào sản phẩm hoàn tất & số lượng đạt được',
            example: "'I have painted the living room.'",
            meaning: 'Phòng đã sơn xong, tường đã khô ráo',
            color: colors.success,
            icon: LucideIcons.checkCheck,
          ),
          ContrastAspect(
            title: 'HTHT Tiếp diễn (Continuous)',
            subtitle: 'Process & Tangible Evidence',
            nature: 'Tập trung vào tiến trình & dấu vết thực tế lưu lại',
            example: "'I have been painting the living room.'",
            meaning: 'Vừa làm xong hoặc đang dang dở, người dính sơn',
            color: colors.info,
            icon: LucideIcons.flame,
          ),
        );

      case 'unit-06-past-perfect-vs-past-simple':
        return (
          ContrastAspect(
            title: 'Quá khứ hoàn thành (Past Perfect)',
            subtitle: 'The Past before the Past',
            nature: 'Xảy ra và kết thúc TRƯỚC một mốc quá khứ khác',
            example: "'The train had left when I arrived.'",
            meaning: 'Tàu đã đi mất trước khi tôi kịp đến ga',
            color: colors.cramAmber,
            icon: LucideIcons.stepBack,
          ),
          ContrastAspect(
            title: 'Quá khứ đơn (Past Simple)',
            subtitle: 'The Primary Anchor Past',
            nature: 'Điểm tựa mốc thời gian quy chiếu hoặc chuỗi tự sự',
            example: "'When I arrived at the station...'",
            meaning: 'Mốc thời gian neo đậu trong quá khứ',
            color: colors.info,
            icon: LucideIcons.milestone,
          ),
        );

      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final aspects = _resolveAspects(colors, l10n);
    if (aspects == null) {
      return const SizedBox.shrink();
    }

    final (aspect1, aspect2) = aspects;

    return Container(
      padding: isMobile ? AppEdgeInsets.all12 : AppEdgeInsets.all16,
      decoration: BoxDecoration(
        color: theme.colorScheme.card,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: isDark
              ? theme.colorScheme.border
              : theme.colorScheme.border.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.arrowLeftRight,
                size: isMobile ? AppIconSize.xsPlus : AppIconSize.sm,
                color: colors.cramAmber,
              ),
              AppGaps.h8,
              Expanded(
                child: Text(
                  l10n.grammarQuickContrastTitle,
                  style: TextStyle(
                    fontSize: isMobile
                        ? AppTypography.xSmallPlus
                        : AppTypography.nav,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.foreground,
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v12,
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildAspectCard(
                    aspect: aspect1,
                    theme: theme,
                    l10n: l10n,
                    isDark: isDark,
                  ),
                ),
                AppGaps.h8,
                Expanded(
                  child: _buildAspectCard(
                    aspect: aspect2,
                    theme: theme,
                    l10n: l10n,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectCard({
    required ContrastAspect aspect,
    required ThemeData theme,
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    final color = aspect.color;
    return Container(
      padding: AppEdgeInsets.all8,
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(aspect.icon, size: AppIconSize.xs, color: color),
              AppGaps.h4,
              Expanded(
                child: Text(
                  aspect.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppTypography.xSmall,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          AppGaps.v4,
          Text(
            aspect.subtitle,
            style: TextStyle(
              fontSize: AppTypography.caption,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
          AppGaps.v8,
          Container(height: 1, color: color.withValues(alpha: 0.18)),
          AppGaps.v8,
          Text(
            l10n.grammarNatureLabel,
            style: TextStyle(
              fontSize: AppTypography.caption,
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            aspect.nature,
            style: TextStyle(
              fontSize: AppTypography.captionPlus,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          AppGaps.v8,
          Text(
            l10n.grammarContrastExampleLabel,
            style: TextStyle(
              fontSize: AppTypography.caption,
              color: theme.colorScheme.mutedForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            aspect.example,
            style: TextStyle(
              fontSize: AppTypography.captionPlus,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          AppGaps.v2,
          Text(
            '(${aspect.meaning})',
            style: TextStyle(
              fontSize: AppTypography.caption,
              color: theme.colorScheme.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
