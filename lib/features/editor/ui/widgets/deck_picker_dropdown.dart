import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/deck.dart';

class DeckPickerDropdown extends StatelessWidget {
  final dynamic l10n;
  final List<DeckModel> decks;
  final ValueNotifier<String> selectedDeckId;

  const DeckPickerDropdown({
    super.key,
    required this.l10n,
    required this.decks,
    required this.selectedDeckId,
  });

  @override
  Widget build(BuildContext context) {
    return Select<String>(
      value: selectedDeckId.value.isNotEmpty
          ? selectedDeckId.value
          : (decks.isNotEmpty ? decks.first.id : null),
      placeholder: Text(l10n.deckLabel),
      onChanged: (val) {
        if (val != null) selectedDeckId.value = val;
      },
      itemBuilder: (context, item) {
        final match = decks.where((d) => d.id == item);
        return Text(match.isNotEmpty ? match.first.title : item);
      },
      popup: (context) => SelectPopup(
        items: SelectItemList(
          children: [
            for (final deck in decks)
              SelectItemButton(value: deck.id, child: Text(deck.title)),
          ],
        ),
      ),
    );
  }
}
