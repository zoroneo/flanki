import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../../../core/models/card.dart';

class CardActionSheet extends HookWidget {
  final CardModel card;
  final ValueChanged<int> onSetFlag;
  final VoidCallback onBury;
  final VoidCallback onSuspend;
  final void Function(String front, String back) onEdit;

  const CardActionSheet({
    super.key,
    required this.card,
    required this.onSetFlag,
    required this.onBury,
    required this.onSuspend,
    required this.onEdit,
  });

  static const ankiFlagColors = [
    m.Colors.red, // 1
    m.Colors.orange, // 2
    m.Colors.green, // 3
    m.Colors.blue, // 4
    m.Colors.pink, // 5
    m.Colors.cyan, // 6
    m.Colors.purple, // 7
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = useState(false);
    final frontController = useTextEditingController(text: card.front);
    final backController = useTextEditingController(text: card.back);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grab handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.mutedForeground.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (isEditing.value) ...[
                Text('Sửa nội dung thẻ', style: theme.typography.h4),
                const SizedBox(height: 16),
                Text('MẶT TRƯỚC', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 6),
                TextField(
                  controller: frontController,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                Text('MẶT SAU', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 6),
                TextField(
                  controller: backController,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GhostButton(
                      onPressed: () => isEditing.value = false,
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    PrimaryButton(
                      onPressed: () {
                        onEdit(frontController.text, backController.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Lưu thay đổi'),
                    ),
                  ],
                ),
              ] else ...[
                // Card Actions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tùy Chọn Thẻ Học', style: theme.typography.h4),
                    if (card.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: card.tags.take(2).map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text('#$t', style: const TextStyle(fontSize: 10)),
                          );
                        }).toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // 7 Anki Flag Selectors
                Text('CẮM CỜ ĐÁNH DẤU (7 MÀU ANKI)', style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Clear flag option
                    GestureDetector(
                      onTap: () {
                        onSetFlag(0);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m.Icons.flag_outlined, size: 18, color: theme.colorScheme.mutedForeground),
                      ),
                    ),
                    ...List.generate(7, (i) {
                      final flagNum = i + 1;
                      final isSelected = card.flag == flagNum;
                      final c = ankiFlagColors[i];

                      return GestureDetector(
                        onTap: () {
                          onSetFlag(flagNum);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: isSelected ? 1.0 : 0.25),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: theme.colorScheme.foreground, width: 2)
                                : Border.all(color: c, width: 1),
                          ),
                          child: isSelected
                              ? const Icon(m.Icons.check, size: 16, color: m.Colors.white)
                              : null,
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          onBury();
                          Navigator.of(context).pop();
                        },
                        leading: const Icon(m.Icons.schedule_rounded, size: 16),
                        child: const Text('Hoãn thẻ (Bury)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlineButton(
                        onPressed: () {
                          onSuspend();
                          Navigator.of(context).pop();
                        },
                        leading: const Icon(m.Icons.pause_circle_outline_rounded, size: 16),
                        child: const Text('Tạm dừng (Suspend)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                OutlineButton(
                  onPressed: () => isEditing.value = true,
                  leading: const Icon(m.Icons.edit_note_rounded, size: 18),
                  child: const Text('Chỉnh sửa nội dung thẻ on-the-fly'),
                ),
                const SizedBox(height: 20),

                // FSRS Technical Card Stats
                Card(
                  padding: const EdgeInsets.all(12),
                  filled: true,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatMini(label: 'FSRS Stability', value: '${card.stability.toStringAsFixed(1)}d'),
                      _StatMini(label: 'Difficulty', value: card.difficulty.toStringAsFixed(1)),
                      _StatMini(label: 'Reps', value: '${card.reps}'),
                      _StatMini(label: 'Lapses', value: '${card.lapses}'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;

  const _StatMini({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.typography.semiBold),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.mutedForeground)),
      ],
    );
  }
}
