import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';

class NoteTagEditor extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;

  const NoteTagEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          placeholder: Text(l10n.addTagPlaceholder),
          features: [
            InputFeature.trailing(
              IconButton.ghost(
                icon: const Icon(LucideIcons.plus, size: 16),
                onPressed: onAddTag,
              ),
            ),
          ],
          onSubmitted: (_) => onAddTag(),
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((t) {
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
                      onTap: () => onRemoveTag(t),
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
}
