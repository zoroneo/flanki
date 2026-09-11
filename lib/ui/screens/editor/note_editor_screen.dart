import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/extensions/responsive_extensions.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/card.dart';
import '../../../core/models/deck.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../widgets/form_focus_helper.dart';
import 'widgets/note_editor_fields.dart';
import 'widgets/note_tag_editor.dart';
import 'widgets/note_type_selectors.dart';

class NoteEditorScreen extends HookConsumerWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final decks = ref.watch(deckListProvider);
    final browserNotifier = ref.read(cardBrowserProvider.notifier);
    final isDesktop = !context.isMobile;

    final noteType = useState<NoteType>(NoteType.basic);
    final selectedDeckId = useState<String>(decks.isNotEmpty ? decks.first.id : '');
    final frontController = useTextEditingController();
    final backController = useTextEditingController();
    final tagInputController = useTextEditingController();
    final tags = useState<List<String>>([]);

    void insertCloze(int index) {
      final text = frontController.text;
      final selection = frontController.selection;
      final clozeTag = 'c$index';

      if (selection.isValid && selection.start != selection.end) {
        final selectedText = text.substring(selection.start, selection.end);
        final replacement = '{{$clozeTag::$selectedText}}';
        final newText = text.replaceRange(selection.start, selection.end, replacement);
        frontController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: selection.start + replacement.length),
        );
      } else {
        final offset = selection.isValid ? selection.start : text.length;
        final insertion = '{{$clozeTag::...}}';
        final newText = text.replaceRange(offset, offset, insertion);
        frontController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(baseOffset: offset + 7, extentOffset: offset + 10),
        );
      }
    }

    void handleAddTag() {
      final val = tagInputController.text.trim().toLowerCase();
      if (val.isNotEmpty && !tags.value.contains(val)) {
        tags.value = [...tags.value, val];
        tagInputController.clear();
      }
    }

    void handleSave() {
      final front = frontController.text.trim();
      final back = backController.text.trim();

      if (front.isEmpty) {
        showToast(
          context: context,
          builder: (context, overlay) {
            return SurfaceCard(
              child: Basic(
                title: Text(l10n.missingContent),
                subtitle: Text(l10n.missingContentDesc),
                leading: const Icon(LucideIcons.triangleAlert, color: m.Colors.orange),
                trailing: IconButton.ghost(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
        return;
      }

      final deckId = selectedDeckId.value.isNotEmpty
          ? selectedDeckId.value
          : (decks.isNotEmpty ? decks.first.id : 'default');

      final newCard = CardModel(
        id: 'card-${DateTime.now().millisecondsSinceEpoch}',
        deckId: deckId,
        front: front,
        back: back,
        noteType: noteType.value,
        tags: tags.value,
        createdAt: DateTime.now(),
      );

      browserNotifier.addCard(newCard);

      showToast(
        context: context,
        builder: (context, overlay) {
          return SurfaceCard(
            child: Basic(
              title: Text(l10n.cardCreatedSuccess),
              subtitle: Text(l10n.cardCreatedSuccessDesc),
              leading: const Icon(LucideIcons.check, color: m.Colors.green),
              trailing: IconButton.ghost(
                icon: const Icon(LucideIcons.x),
                onPressed: () => overlay.close(),
              ),
            ),
          );
        },
      );

      context.pop();
    }

    final editorFocusNodes = useTabFocusChain(3, onSubmit: handleSave);
    final frontFocusNode = editorFocusNodes[0];
    final backFocusNode = editorFocusNodes[1];
    final tagFocusNode = editorFocusNodes[2];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): handleSave,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): handleSave,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          headers: [
            _buildAppBar(context, l10n, theme, isDesktop, handleSave),
          ],
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsive(mobile: 640.0, tablet: 760.0, desktop: 1120.0),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(
                  context.responsive(mobile: 16.0, tablet: 20.0, desktop: 24.0),
                ),
                child: isDesktop
                    ? _buildDesktopLayout(
                        theme: theme,
                        l10n: l10n,
                        decks: decks,
                        noteType: noteType,
                        selectedDeckId: selectedDeckId,
                        frontController: frontController,
                        backController: backController,
                        frontFocusNode: frontFocusNode,
                        backFocusNode: backFocusNode,
                        tagController: tagInputController,
                        tagFocusNode: tagFocusNode,
                        tags: tags,
                        onInsertCloze: insertCloze,
                        onAddTag: handleAddTag,
                      )
                    : _buildMobileLayout(
                        theme: theme,
                        l10n: l10n,
                        decks: decks,
                        noteType: noteType,
                        selectedDeckId: selectedDeckId,
                        frontController: frontController,
                        backController: backController,
                        frontFocusNode: frontFocusNode,
                        backFocusNode: backFocusNode,
                        tagController: tagInputController,
                        tagFocusNode: tagFocusNode,
                        tags: tags,
                        onInsertCloze: insertCloze,
                        onAddTag: handleAddTag,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    dynamic l10n,
    ThemeData theme,
    bool isDesktop,
    VoidCallback onSave,
  ) {
    return AppBar(
      leading: [
        IconButton.ghost(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
      ],
      title: Text(l10n.addCardTitle),
      trailing: [
        if (isDesktop)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              'Ctrl/⌘ + ↵',
              style: theme.typography.xSmall.copyWith(
                color: theme.colorScheme.mutedForeground,
              ),
            ),
          ),
        PrimaryButton(
          alignment: Alignment.center,
          onPressed: onSave,
          leading: const Icon(LucideIcons.check, size: 16),
          child: Text(l10n.saveCard, maxLines: 1, softWrap: false),
        ),
      ],
    );
  }

  Widget _buildDeckSelector(
    dynamic l10n,
    List<DeckModel> decks,
    ValueNotifier<String> selectedDeckId,
  ) {
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

  Widget _buildDesktopLayout({
    required ThemeData theme,
    required dynamic l10n,
    required List<DeckModel> decks,
    required ValueNotifier<NoteType> noteType,
    required ValueNotifier<String> selectedDeckId,
    required TextEditingController frontController,
    required TextEditingController backController,
    required FocusNode frontFocusNode,
    required FocusNode backFocusNode,
    required TextEditingController tagController,
    required FocusNode tagFocusNode,
    required ValueNotifier<List<String>> tags,
    required ValueChanged<int> onInsertCloze,
    required VoidCallback onAddTag,
  }) {
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
        const SizedBox(width: 20),
        SizedBox(
          width: 340,
          child: _buildDesktopSidebar(
            theme: theme,
            l10n: l10n,
            decks: decks,
            noteType: noteType,
            selectedDeckId: selectedDeckId,
            tagController: tagController,
            tagFocusNode: tagFocusNode,
            tags: tags,
            onAddTag: onAddTag,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar({
    required ThemeData theme,
    required dynamic l10n,
    required List<DeckModel> decks,
    required ValueNotifier<NoteType> noteType,
    required ValueNotifier<String> selectedDeckId,
    required TextEditingController tagController,
    required FocusNode tagFocusNode,
    required ValueNotifier<List<String>> tags,
    required VoidCallback onAddTag,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, LucideIcons.layers, l10n.deckLabel),
              const SizedBox(height: 10),
              _buildDeckSelector(l10n, decks, selectedDeckId),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, LucideIcons.sparkles, l10n.noteType),
              const SizedBox(height: 12),
              DesktopTypeOption(
                title: l10n.basicNoteType,
                subtitle: l10n.basicNoteSubtitle,
                icon: LucideIcons.fileText,
                isSelected: noteType.value == NoteType.basic,
                onTap: () => noteType.value = NoteType.basic,
              ),
              const SizedBox(height: 8),
              DesktopTypeOption(
                title: l10n.clozeNoteType,
                subtitle: l10n.clozeNoteSubtitle,
                icon: LucideIcons.brackets,
                isSelected: noteType.value == NoteType.cloze,
                onTap: () => noteType.value = NoteType.cloze,
              ),
              const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        Card(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, LucideIcons.tags, l10n.tagsLabel),
              const SizedBox(height: 10),
              NoteTagEditor(
                controller: tagController,
                focusNode: tagFocusNode,
                tags: tags.value,
                onAddTag: onAddTag,
                onRemoveTag: (t) => tags.value = tags.value.where((x) => x != t).toList(),
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
        Icon(icon, size: 14, color: theme.colorScheme.mutedForeground),
        const SizedBox(width: 6),
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

  Widget _buildMobileLayout({
    required ThemeData theme,
    required dynamic l10n,
    required List<DeckModel> decks,
    required ValueNotifier<NoteType> noteType,
    required ValueNotifier<String> selectedDeckId,
    required TextEditingController frontController,
    required TextEditingController backController,
    required FocusNode frontFocusNode,
    required FocusNode backFocusNode,
    required TextEditingController tagController,
    required FocusNode tagFocusNode,
    required ValueNotifier<List<String>> tags,
    required ValueChanged<int> onInsertCloze,
    required VoidCallback onAddTag,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.noteType,
          style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
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
          style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
        ),
        const SizedBox(height: 8),
        _buildDeckSelector(l10n, decks, selectedDeckId),
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
          style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
        ),
        const SizedBox(height: 8),
        Card(
          padding: const EdgeInsets.all(12),
          child: NoteTagEditor(
            controller: tagController,
            focusNode: tagFocusNode,
            tags: tags.value,
            onAddTag: onAddTag,
            onRemoveTag: (t) => tags.value = tags.value.where((x) => x != t).toList(),
          ),
        ),
      ],
    );
  }
}
