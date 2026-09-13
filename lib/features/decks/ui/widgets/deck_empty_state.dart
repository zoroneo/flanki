import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/theme/app_tokens.dart';

class DeckEmptyState extends StatelessWidget {
  final dynamic l10n;
  final VoidCallback onAddDeck;

  const DeckEmptyState({
    super.key,
    required this.l10n,
    required this.onAddDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.searchX,
              size: AppSpacing.xxxl,
              color: theme.colorScheme.mutedForeground,
            ),
            AppGaps.v12,
            Text(
              l10n.noDecksFound,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            AppGaps.v16,
            PrimaryButton(
              alignment: Alignment.center,
              onPressed: onAddDeck,
              leading: const Icon(LucideIcons.plus, size: AppIconSize.sm),
              child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
            ),
          ],
        ),
      ),
    );
  }
}
