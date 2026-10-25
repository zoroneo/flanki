import 'package:animated_emoji/animated_emoji.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/flanki_animated_emoji.dart';

class DeckEmptyState extends StatelessWidget {
  final dynamic l10n;
  final VoidCallback onAddDeck;
  final bool showAddButton;

  const DeckEmptyState({
    super.key,
    required this.l10n,
    required this.onAddDeck,
    this.showAddButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            FlankiAnimatedEmoji(
              emoji: showAddButton ? AnimatedEmojis.books : AnimatedEmojis.eyes,
              size: 48.0,
              repeat: true,
            ),
            AppGaps.v12,
            Text(
              l10n.noDecksFound,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            if (showAddButton) ...[
              AppGaps.v16,
              PrimaryButton(
                alignment: Alignment.center,
                onPressed: onAddDeck,
                leading: const Icon(LucideIcons.plus, size: AppIconSize.sm),
                child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
