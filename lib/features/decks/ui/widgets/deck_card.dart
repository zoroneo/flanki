import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';

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
    final parts = title.split('::');
    final hasHierarchy = parts.length > 1;
    final parentPath = hasHierarchy
        ? parts.sublist(0, parts.length - 1).join(' › ')
        : null;
    final leafName = parts.last;
    final isCram =
        deckId.startsWith('cram') ||
        title.startsWith('⚡') ||
        title.toLowerCase().contains('cram');

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onStudy,
      child: Card(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, isCram, parentPath, leafName),
            const SizedBox(height: 16),
            _buildFooter(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    bool isCram,
    String? parentPath,
    String leafName,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isCram
                ? m.Colors.amber.withValues(alpha: 0.15)
                : theme.colorScheme.muted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCram ? LucideIcons.zap : LucideIcons.folder,
            size: 20,
            color: isCram ? m.Colors.amber : theme.colorScheme.foreground,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (parentPath != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: Text(
                    parentPath,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ),
              Text(
                leafName,
                style: theme.typography.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
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
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (dueCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.destructive.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$dueCount ${l10n.dueCards}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.destructive,
                    ),
                  ),
                ),
              if (newCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$newCount ${l10n.newCards}',
                    style: TextStyle(
                      fontSize: 11,
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
        const SizedBox(width: 8),
        PrimaryButton(
          alignment: Alignment.center,
          onPressed: onStudy,
          size: ButtonSize.small,
          leading: const Center(child: Icon(LucideIcons.play, size: 14)),
          child: Center(child: Text(l10n.studyNow)),
        ),
      ],
    );
  }
}
