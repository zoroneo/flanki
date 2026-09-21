import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/card.dart';
import '../../../../core/models/deck.dart';
import '../../../../core/theme/app_tokens.dart';
import 'deck_picker_dropdown.dart';
import 'note_editor_fields.dart';
import 'note_tag_editor.dart';
import 'note_type_selectors.dart';

class NoteEditorDesktopLayout extends StatelessWidget {
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

  const NoteEditorDesktopLayout({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: NoteEditorFields(
            noteType: noteType.value,
            frontController: frontController,
            backController: backController,
            frontFocusNode: frontFocusNode,
            backFocusNode: backFocusNode,
            isDesktop: true,
            onInsertCloze: onInsertCloze,
          ),
        ),
        AppGaps.h20,
        SizedBox(
          width: AppDimensions.noteEditorSidebarWidth,
          child: _buildDesktopSidebar(context),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, LucideIcons.layers, l10n.deckLabel),
              AppGaps.v8,
              DeckPickerDropdown(
                l10n: l10n,
                decks: decks,
                selectedDeckId: selectedDeckId,
              ),
            ],
          ),
        ),
        AppGaps.v16,
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, LucideIcons.sparkles, l10n.noteType),
              AppGaps.v12,
              DesktopTypeOption(
                title: l10n.basicNoteType,
                subtitle: l10n.basicNoteSubtitle,
                icon: LucideIcons.fileText,
                isSelected: noteType.value == NoteType.basic,
                onTap: () => noteType.value = NoteType.basic,
              ),
              AppGaps.v8,
              DesktopTypeOption(
                title: l10n.clozeNoteType,
                subtitle: l10n.clozeNoteSubtitle,
                icon: LucideIcons.brackets,
                isSelected: noteType.value == NoteType.cloze,
                onTap: () => noteType.value = NoteType.cloze,
              ),
              AppGaps.v8,
              DesktopTypeOption(
                title: l10n.reversedNoteType,
                subtitle: l10n.reversedNoteSubtitle,
                icon: LucideIcons.arrowLeftRight,
                isSelected: noteType.value == NoteType.reversed,
                onTap: () => noteType.value = NoteType.reversed,
              ),
            ],
          ),
        ),
        AppGaps.v16,
        Card(
          padding: AppEdgeInsets.all16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, LucideIcons.tags, l10n.tagsLabel),
              AppGaps.v8,
              NoteTagEditor(
                controller: tagController,
                focusNode: tagFocusNode,
                tags: tags.value,
                onAddTag: onAddTag,
                onRemoveTag: (t) =>
                    tags.value = tags.value.where((x) => x != t).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: AppIconSize.sm,
          color: theme.colorScheme.mutedForeground,
        ),
        AppGaps.h8,
        Text(
          title.toUpperCase(),
          style: theme.typography.xSmall.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }
}
