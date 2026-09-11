import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';
import '../../../../core/models/card.dart';

class NoteEditorFields extends StatelessWidget {
  final NoteType noteType;
  final TextEditingController frontController;
  final TextEditingController backController;
  final FocusNode frontFocusNode;
  final FocusNode backFocusNode;
  final bool isDesktop;
  final ValueChanged<int> onInsertCloze;

  const NoteEditorFields({
    super.key,
    required this.noteType,
    required this.frontController,
    required this.backController,
    required this.frontFocusNode,
    required this.backFocusNode,
    required this.isDesktop,
    required this.onInsertCloze,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

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
                    noteType == NoteType.cloze
                        ? LucideIcons.brackets
                        : LucideIcons.circleHelp,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    noteType == NoteType.cloze
                        ? l10n.clozeTextLabel
                        : l10n.frontSide,
                    style: theme.typography.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (noteType == NoteType.cloze)
                Row(
                  children: [
                    OutlineButton(
                      size: ButtonSize.small,
                      onPressed: () => onInsertCloze(1),
                      child: const Text(
                        '{{c1}}',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    OutlineButton(
                      size: ButtonSize.small,
                      onPressed: () => onInsertCloze(2),
                      child: const Text(
                        '{{c2}}',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    OutlineButton(
                      size: ButtonSize.small,
                      onPressed: () => onInsertCloze(3),
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
            focusNode: frontFocusNode,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            placeholder: Text(
              noteType == NoteType.cloze
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
                noteType == NoteType.cloze ? l10n.extraNotes : l10n.backSide,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: backController,
            focusNode: backFocusNode,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            placeholder: Text(l10n.backPlaceholder),
            minLines: isDesktop ? 7 : 5,
            maxLines: isDesktop ? 12 : 8,
          ),
        ],
      ),
    );
  }
}
