import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';
import 'card_action_sheet.dart';

class StudyAppBar extends StatelessWidget {
  final dynamic l10n;
  final CardModel? currentCard;
  final int remainingCount;
  final bool canUndo;
  final bool isWhiteboardOpen;
  final VoidCallback onUndo;
  final VoidCallback onToggleWhiteboard;
  final VoidCallback onOpenActions;

  const StudyAppBar({
    super.key,
    required this.l10n,
    required this.currentCard,
    required this.remainingCount,
    required this.canUndo,
    required this.isWhiteboardOpen,
    required this.onUndo,
    required this.onToggleWhiteboard,
    required this.onOpenActions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      leading: [
        IconButton.ghost(
          icon: const Icon(LucideIcons.chevronLeft, size: AppIconSize.md),
          onPressed: () => context.pop(),
        ),
      ],
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.cardsRemaining(remainingCount),
            style: theme.typography.small.copyWith(fontWeight: FontWeight.w600),
          ),
          if (currentCard != null && currentCard!.hasFlag) ...[
            AppGaps.h8,
            Container(
              width: AppSpacing.sm,
              height: AppSpacing.sm,
              decoration: BoxDecoration(
                color: CardActionSheet.getFlagColor(
                  context,
                  currentCard!.flag,
                ),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      trailing: [
        if (canUndo)
          IconButton.ghost(
            icon: const Icon(LucideIcons.undo2, size: AppIconSize.md),
            onPressed: onUndo,
          ),
        IconButton.ghost(
          icon: Icon(
            LucideIcons.pencil,
            size: AppIconSize.md,
            color: isWhiteboardOpen ? theme.colorScheme.primary : null,
          ),
          onPressed: onToggleWhiteboard,
        ),
        IconButton.ghost(
          icon: const Icon(LucideIcons.ellipsisVertical, size: AppIconSize.md),
          onPressed: onOpenActions,
        ),
      ],
    );
  }
}
