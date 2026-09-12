import 'package:flutter/material.dart' as m;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/extensions/responsive_extensions.dart';
import '../../../core/localization/locale_notifier.dart';
import '../../../core/models/card.dart';
import 'package:flanki/features/browser/providers/card_browser_notifier.dart';
import 'package:flanki/features/decks/providers/deck_notifier.dart';
import 'package:flanki/core/widgets/form_focus_helper.dart';
import 'widgets/note_editor_desktop_layout.dart';
import 'widgets/note_editor_mobile_layout.dart';

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

    final editorFocusNodes = useTabFocusChain(3, onSubmit: handleSave);
    final frontFocusNode = editorFocusNodes[0];
    final backFocusNode = editorFocusNodes[1];
    final tagFocusNode = editorFocusNodes[2];

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
          headers: [_buildAppBar(context, l10n, theme, isDesktop, handleSave)],
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: context.responsive(
                  mobile: 640.0,
                  tablet: 760.0,
                  desktop: 1120.0,
                ),
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.all(
                  context.responsive(mobile: 16.0, tablet: 20.0, desktop: 24.0),
                ),
                child: isDesktop
                    ? NoteEditorDesktopLayout(
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
                    : NoteEditorMobileLayout(
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
      title: Text(
        l10n.addCardTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (isDesktop ? theme.typography.large : theme.typography.base)
            .copyWith(fontWeight: FontWeight.w600),
      ),
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
          size: ButtonSize.small,
          alignment: Alignment.center,
          onPressed: onSave,
          leading: const Icon(LucideIcons.check, size: 14),
          child: Text(l10n.saveCard, maxLines: 1, softWrap: false),
        ),
      ],
    );
  }
}
