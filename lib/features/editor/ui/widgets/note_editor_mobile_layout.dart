import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/models/deck.dart';
import 'deck_picker_dropdown.dart';
import 'note_editor_fields.dart';
import 'note_tag_editor.dart';
import 'note_type_selectors.dart';

class NoteEditorMobileLayout extends StatelessWidget {
  final ThemeData theme;
  final dynamic l10n;
  final List<DeckModel> decks;
  final ValueNotifier<NoteType> noteType;
  final ValueNotifier<String> selectedDeckId;
  final TextEditingController frontController;
  final TextEditingController backController;
  final FocusNode frontFocusNode;
  final FocusNode backFocusNode;
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final ValueNotifier<List<String>> tags;
  final ValueChanged<int> onInsertCloze;
  final VoidCallback onAddTag;

  const NoteEditorMobileLayout({
    super.key,
    required this.theme,
    required this.l10n,
    required this.decks,
    required this.noteType,
    required this.selectedDeckId,
    required this.frontController,
    required this.backController,
    required this.frontFocusNode,
    required this.backFocusNode,
    required this.tagController,
    required this.tagFocusNode,
    required this.tags,
    required this.onInsertCloze,
    required this.onAddTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.noteType,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TypeSelectButton(
                label: l10n.basicNoteType,
                subtitle: l10n.basicNoteSubtitle,
                isSelected: noteType.value == NoteType.basic,
                onTap: () => noteType.value = NoteType.basic,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TypeSelectButton(
                label: l10n.clozeNoteType,
                subtitle: l10n.clozeNoteSubtitle,
                isSelected: noteType.value == NoteType.cloze,
                onTap: () => noteType.value = NoteType.cloze,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TypeSelectButton(
                label: l10n.reversedNoteType,
                subtitle: l10n.reversedNoteSubtitle,
                isSelected: noteType.value == NoteType.reversed,
                onTap: () => noteType.value = NoteType.reversed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.deckLabel,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        DeckPickerDropdown(
          l10n: l10n,
          decks: decks,
          selectedDeckId: selectedDeckId,
        ),
        const SizedBox(height: 16),
        NoteEditorFields(
          noteType: noteType.value,
          frontController: frontController,
          backController: backController,
          frontFocusNode: frontFocusNode,
          backFocusNode: backFocusNode,
          isDesktop: false,
          onInsertCloze: onInsertCloze,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.tagsLabel,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          padding: const EdgeInsets.all(12),
          child: NoteTagEditor(
            controller: tagController,
            focusNode: tagFocusNode,
            tags: tags.value,
            onAddTag: onAddTag,
            onRemoveTag: (t) =>
                tags.value = tags.value.where((x) => x != t).toList(),
          ),
        ),
      ],
    );
  }
}
