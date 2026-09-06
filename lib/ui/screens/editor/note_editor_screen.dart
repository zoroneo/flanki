import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../core/notifiers/card_browser_notifier.dart';
import '../../../core/notifiers/deck_notifier.dart';
import '../../../core/models/card.dart';

class NoteEditorScreen extends HookConsumerWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final decks = ref.watch(deckListProvider);
    final browserNotifier = ref.read(cardBrowserProvider.notifier);

    // Hooks for note input
    final noteType = useState<String>('basic'); // 'basic', 'cloze', 'reversed'
    final selectedDeckId = useState<String>(
      decks.isNotEmpty ? decks.first.id : 'deck-toeic-600',
    );
    final frontController = useTextEditingController();
    final backController = useTextEditingController();
    final tagInputController = useTextEditingController();
    final tags = useState<List<String>>(['vocabulary']);

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
                title: const Text('Thiếu nội dung'),
                subtitle: const Text('Vui lòng nhập nội dung câu hỏi/mặt trước.'),
                leading: const Icon(m.Icons.warning_amber_rounded, color: m.Colors.orange),
                trailing: IconButton.ghost(
                  icon: const Icon(m.Icons.close),
                  onPressed: () => overlay.close(),
                ),
              ),
            );
          },
        );
        return;
      }

      final newCard = CardModel(
        id: 'card-${DateTime.now().millisecondsSinceEpoch}',
        deckId: selectedDeckId.value,
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
              title: const Text('Đã tạo thẻ mới'),
              subtitle: Text('Đã thêm thẻ vào bộ "${selectedDeckId.value}".'),
              leading: const Icon(m.Icons.check_circle, color: m.Colors.green),
              trailing: IconButton.ghost(
                icon: const Icon(m.Icons.close),
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
              icon: const Icon(m.Icons.close_rounded),
              onPressed: () => context.pop(),
            ),
          ],
          title: const Text('Thêm Thẻ Mới'),
          trailing: [
            PrimaryButton(
              onPressed: handleSave,
              leading: const Icon(m.Icons.check_rounded, size: 16),
              child: const Text('Lưu thẻ'),
            ),
          ],
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Note Type Selector
            Text('LOẠI THẺ (NOTE TYPE)', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeSelectButton(
                    label: 'Basic',
                    subtitle: 'Câu hỏi / Đáp án',
                    isSelected: noteType.value == 'basic',
                    onTap: () => noteType.value = 'basic',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeSelectButton(
                    label: 'Cloze',
                    subtitle: 'Điền vào chỗ trống',
                    isSelected: noteType.value == 'cloze',
                    onTap: () => noteType.value = 'cloze',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeSelectButton(
                    label: 'Reversed',
                    subtitle: 'Đảo 2 chiều',
                    isSelected: noteType.value == 'reversed',
                    onTap: () => noteType.value = 'reversed',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Deck Selection
            Text('BỘ THẺ (DECK)', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 8),
            Card(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: m.DropdownButtonHideUnderline(
                child: m.DropdownButton<String>(
                  value: selectedDeckId.value,
                  isExpanded: true,
                  dropdownColor: theme.colorScheme.background,
                  items: decks.map((deck) {
                    return m.DropdownMenuItem<String>(
                      value: deck.id,
                      child: Text(
                        deck.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.foreground,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedDeckId.value = val;
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Front Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  noteType.value == 'cloze' ? 'VĂN BẢN (TEXT WITH CLOZE)' : 'MẶT TRƯỚC (CÂU HỎI)',
                  style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                ),
                if (noteType.value == 'cloze')
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
            Card(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: frontController,
                placeholder: Text(
                  noteType.value == 'cloze'
                      ? 'The capital of France is {{c1::Paris}}.'
                      : 'Nhập câu hỏi, từ vựng hoặc khái niệm...',
                ),
                maxLines: 4,
              ),
            ),
            const SizedBox(height: 20),

            // Back Field / Extra Notes
            Text(
              noteType.value == 'cloze' ? 'CHÚ THÍCH THÊM (EXTRA)' : 'MẶT SAU (ĐÁP ÁN & GIẢI THÍCH)',
              style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
            ),
            const SizedBox(height: 8),
            Card(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: backController,
                placeholder: const Text('Nhập giải nghĩa chi tiết, ví dụ minh họa...'),
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 24),

            // Tags section
            Text('THẺ PHÂN LOẠI (TAGS)', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
            const SizedBox(height: 8),
            Card(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagInputController,
                          placeholder: const Text('Thêm tag (ví dụ: toeic, grammar)...'),
                          onSubmitted: (_) => handleAddTag(),
                        ),
                      ),
                      IconButton.ghost(
                        icon: const Icon(m.Icons.add, size: 18),
                        onPressed: handleAddTag,
                      ),
                    ],
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
                                child: const Icon(m.Icons.close, size: 12),
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
