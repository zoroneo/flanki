import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/models/card.dart';

class NoteEditorScreen extends HookConsumerWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final decks = ref.watch(deckListProvider);
    final browserNotifier = ref.read(cardBrowserProvider.notifier);

    // Hooks for note input
    final noteType = useState<NoteType>(NoteType.basic);
    final selectedDeckId = useState<String>(
      decks.isNotEmpty ? decks.first.id : '',
    );
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
        // Insert empty cloze at cursor
        final offset = selection.isValid ? selection.start : text.length;
        final insertion = '{{$clozeTag::...}}';
        final newText = text.replaceRange(offset, offset, insertion);
        frontController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: offset + 7,
            extentOffset: offset + 10,
          ),
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

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.x),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(l10n.addCardTitle),
          trailing: [
            PrimaryButton(
              onPressed: handleSave,
              size: ButtonSize.small,
              leading: const Icon(LucideIcons.check, size: 15),
              child: Text(l10n.saveCard),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Note Type Selector
            Text(l10n.noteType, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeSelectButton(
                    label: l10n.basicNoteType,
                    subtitle: l10n.basicNoteSubtitle,
                    isSelected: noteType.value == NoteType.basic,
                    onTap: () => noteType.value = NoteType.basic,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeSelectButton(
                    label: l10n.clozeNoteType,
                    subtitle: l10n.clozeNoteSubtitle,
                    isSelected: noteType.value == NoteType.cloze,
                    onTap: () => noteType.value = NoteType.cloze,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeSelectButton(
                    label: l10n.reversedNoteType,
                    subtitle: l10n.reversedNoteSubtitle,
                    isSelected: noteType.value == NoteType.reversed,
                    onTap: () => noteType.value = NoteType.reversed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Deck Selection
            Text(l10n.deckLabel, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 8),
            Select<String>(
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
                      SelectItemButton(
                        value: deck.id,
                        child: Text(deck.title),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Front Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  noteType.value == NoteType.cloze ? l10n.clozeTextLabel : l10n.frontSide,
                  style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                ),
                if (noteType.value == NoteType.cloze)
                  Row(
                    children: [
                      GhostButton(
                        onPressed: () => insertCloze(1),
                        child: const Text('{{c1::}}', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      GhostButton(
                        onPressed: () => insertCloze(2),
                        child: const Text('{{c2::}}', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: frontController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              placeholder: Text(
                noteType.value == NoteType.cloze
                    ? l10n.clozePlaceholder
                    : l10n.frontPlaceholder,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            // Back Field / Extra Notes
            Text(
              noteType.value == NoteType.cloze ? l10n.extraNotes : l10n.backSide,
              style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: backController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              placeholder: Text(l10n.backPlaceholder),
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // Tags section
            Text(l10n.tagsLabel, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 8),
            Card(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: tagInputController,
                    placeholder: Text(l10n.addTagPlaceholder),
                    features: [
                      InputFeature.trailing(
                        IconButton.ghost(
                          icon: const Icon(LucideIcons.plus, size: 16),
                          onPressed: handleAddTag,
                        ),
                      ),
                    ],
                    onSubmitted: (_) => handleAddTag(),
                  ),
                  if (tags.value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.value.map((t) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.muted,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('#$t', style: const TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  tags.value = tags.value.where((x) => x != t).toList();
                                },
                                child: const Icon(LucideIcons.x, size: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelectButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeSelectButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? theme.colorScheme.primaryForeground : theme.colorScheme.foreground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: isSelected
                    ? theme.colorScheme.primaryForeground.withValues(alpha: 0.8)
                    : theme.colorScheme.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
