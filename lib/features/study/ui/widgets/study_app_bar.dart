import 'package:flutter/material.dart' as m;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
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
          icon: const Icon(LucideIcons.chevronLeft, size: 18),
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
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color:
                    CardActionSheet.ankiFlagColors[currentCard!.flag] ??
                    m.Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
      trailing: [
        if (canUndo)
          IconButton.ghost(
            icon: const Icon(LucideIcons.undo2, size: 20),
            onPressed: onUndo,
          ),
        IconButton.ghost(
          icon: Icon(
            LucideIcons.pencil,
            size: 20,
            color: isWhiteboardOpen ? theme.colorScheme.primary : null,
          ),
          onPressed: onToggleWhiteboard,
        ),
        IconButton.ghost(
          icon: const Icon(LucideIcons.ellipsisVertical, size: 20),
          onPressed: onOpenActions,
        ),
      ],
    );
  }
}
