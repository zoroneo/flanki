import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/theme/app_tokens.dart';

class DeckCard extends StatelessWidget {
  final String deckId;
  final String title;
  final String description;
  final int dueCount;
  final int newCount;
  final int totalCount;
  final VoidCallback onStudy;

  const DeckCard({
    super.key,
    required this.deckId,
    required this.title,
    required this.description,
    required this.dueCount,
    required this.newCount,
    required this.totalCount,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Parse Hierarchical deck title (Parent::Child)
    final parts = title.split(AppConfig.deckHierarchyDelimiter);
    final hasHierarchy = parts.length > 1;
    final parentPath = hasHierarchy
        ? parts
              .sublist(0, parts.length - 1)
              .join(AppConfig.deckHierarchyBreadcrumbSeparator)
        : null;
    final leafName = parts.last;
    final isCram =
        deckId.startsWith(IdHelper.prefixCram) ||
        title.startsWith('⚡') ||
        title.toLowerCase().contains(IdHelper.prefixCram);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStudy,
      child: Card(
        padding: AppEdgeInsets.all16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme, isCram, parentPath, leafName),
            AppGaps.v16,
            _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    bool isCram,
    String? parentPath,
    String leafName,
  ) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppEdgeInsets.all8,
          decoration: BoxDecoration(
            color: isCram
                ? colors.cramAmber.withValues(alpha: 0.15)
                : theme.colorScheme.muted,
            borderRadius: AppRadius.borderMd,
          ),
          child: Icon(
            isCram ? LucideIcons.zap : LucideIcons.folder,
            size: AppIconSize.md,
            color: isCram ? colors.cramAmber : theme.colorScheme.foreground,
          ),
        ),
        AppGaps.h12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (parentPath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
                  child: Text(parentPath, style: context.textStyles.caption),
                ),
              Text(
                leafName,
                style: theme.typography.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppGaps.v4,
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.s6,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (dueCount > 0)
                Container(
                  padding: AppEdgeInsets.countBadge,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.destructive.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    '$dueCount ${l10n.dueCards}',
                    style: context.textStyles.sub.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.destructive,
                    ),
                  ),
                ),
              if (newCount > 0)
                Container(
                  padding: AppEdgeInsets.countBadge,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Text(
                    '$newCount ${l10n.newCards}',
                    style: context.textStyles.sub.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              Text(
                l10n.cardsCount(totalCount),
                style: theme.typography.xSmall.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        AppGaps.h8,
        PrimaryButton(
          alignment: Alignment.center,
          onPressed: onStudy,
          size: ButtonSize.small,
          leading: const Center(
            child: Icon(LucideIcons.play, size: AppIconSize.sm),
          ),
          child: Center(child: Text(l10n.studyNow)),
        ),
      ],
    );
  }
}
