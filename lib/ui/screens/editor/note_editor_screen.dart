import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
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
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

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
        final newText = text.replaceRange(
          selection.start,
          selection.end,
          replacement,
        );
        frontController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(
            offset: selection.start + replacement.length,
          ),
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
                leading: const Icon(
                  LucideIcons.triangleAlert,
                  color: m.Colors.orange,
                ),
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

    // Deck Selector Dropdown Widget
    Widget buildDeckSelector() {
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

    // Tags Section Widget
    Widget buildTagsSection() {
      return Column(
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
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.value.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.border),
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
      );
    }

    // Editor Input Fields (Front & Back)
    Widget buildEditorFields() {
      return Card(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Front Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      noteType.value == NoteType.cloze
                          ? LucideIcons.brackets
                          : LucideIcons.circleHelp,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      noteType.value == NoteType.cloze
                          ? l10n.clozeTextLabel
                          : l10n.frontSide,
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (noteType.value == NoteType.cloze)
                  Row(
                    children: [
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => insertCloze(1),
                        child: const Text(
                          '{{c1}}',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => insertCloze(2),
                        child: const Text(
                          '{{c2}}',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      OutlineButton(
                        size: ButtonSize.small,
                        onPressed: () => insertCloze(3),
                        child: const Text(
                          '{{c3}}',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
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
              minLines: isDesktop ? 6 : 4,
              maxLines: isDesktop ? 10 : 6,
            ),
            const SizedBox(height: 20),

            // Back Header
            Row(
              children: [
                Icon(
                  LucideIcons.fileCheck,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  noteType.value == NoteType.cloze
                      ? l10n.extraNotes
                      : l10n.backSide,
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: backController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              placeholder: Text(l10n.backPlaceholder),
              minLines: isDesktop ? 7 : 5,
              maxLines: isDesktop ? 12 : 8,
            ),
          ],
        ),
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true):
            handleSave,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): handleSave,
        const SingleActivator(LogicalKeyboardKey.escape): () => context.pop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
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
                  onPressed: handleSave,
                  leading: const Icon(LucideIcons.check, size: 16),
                  child: Text(l10n.saveCard, maxLines: 1, softWrap: false),
                ),
              ],
            ),
          ],
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1120 : 640),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: Editor fields
                          Expanded(flex: 5, child: buildEditorFields()),
                          const SizedBox(width: 20),

                          // Right column: Metadata & Options
                          SizedBox(
                            width: 340,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Deck card
                                Card(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.layers,
                                            size: 14,
                                            color: theme
                                                .colorScheme
                                                .mutedForeground,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.deckLabel.toUpperCase(),
                                            style: theme.typography.xSmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: theme
                                                      .colorScheme
                                                      .mutedForeground,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      buildDeckSelector(),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Note Type Card
                                Card(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.sparkles,
                                            size: 14,
                                            color: theme
                                                .colorScheme
                                                .mutedForeground,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.noteType.toUpperCase(),
                                            style: theme.typography.xSmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: theme
                                                      .colorScheme
                                                      .mutedForeground,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _DesktopTypeOption(
                                        title: l10n.basicNoteType,
                                        subtitle: l10n.basicNoteSubtitle,
                                        icon: LucideIcons.fileText,
                                        isSelected:
                                            noteType.value == NoteType.basic,
                                        onTap: () =>
                                            noteType.value = NoteType.basic,
                                      ),
                                      const SizedBox(height: 8),
                                      _DesktopTypeOption(
                                        title: l10n.clozeNoteType,
                                        subtitle: l10n.clozeNoteSubtitle,
                                        icon: LucideIcons.brackets,
                                        isSelected:
                                            noteType.value == NoteType.cloze,
                                        onTap: () =>
                                            noteType.value = NoteType.cloze,
                                      ),
                                      const SizedBox(height: 8),
                                      _DesktopTypeOption(
                                        title: l10n.reversedNoteType,
                                        subtitle: l10n.reversedNoteSubtitle,
                                        icon: LucideIcons.arrowLeftRight,
                                        isSelected:
                                            noteType.value == NoteType.reversed,
                                        onTap: () =>
                                            noteType.value = NoteType.reversed,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Tags Card
                                Card(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.tags,
                                            size: 14,
                                            color: theme
                                                .colorScheme
                                                .mutedForeground,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            l10n.tagsLabel.toUpperCase(),
                                            style: theme.typography.xSmall
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                  color: theme
                                                      .colorScheme
                                                      .mutedForeground,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      buildTagsSection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mobile Layout
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
                                  isSelected:
                                      noteType.value == NoteType.reversed,
                                  onTap: () =>
                                      noteType.value = NoteType.reversed,
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
                          buildDeckSelector(),
                          const SizedBox(height: 16),
                          buildEditorFields(),
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
                            child: buildTagsSection(),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopTypeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.08)
              : theme.colorScheme.muted.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                LucideIcons.check,
                size: 16,
                color: theme.colorScheme.primary,
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
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? theme.colorScheme.primaryForeground
                    : theme.colorScheme.foreground,
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
