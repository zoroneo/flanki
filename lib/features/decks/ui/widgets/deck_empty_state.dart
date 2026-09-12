import 'package:shadcn_flutter/shadcn_flutter.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              LucideIcons.searchX,
              size: 48,
              color: theme.colorScheme.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDecksFound,
              style: theme.typography.small.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              alignment: Alignment.center,
              onPressed: onAddDeck,
              leading: const Icon(LucideIcons.plus, size: 16),
              child: Text(l10n.addNewDeck, maxLines: 1, softWrap: false),
            ),
          ],
        ),
      ),
    );
  }
}
