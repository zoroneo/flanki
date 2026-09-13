import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/localization/locale_notifier.dart';
import '../../../../core/models/card.dart';
import '../../../../core/theme/app_tokens.dart';

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
      padding: AppEdgeInsets.all20,
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
                    size: AppIconSize.sm,
                    color: theme.colorScheme.primary,
                  ),
                  AppGaps.h8,
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
                    AppGaps.h4,
                    OutlineButton(
                      size: ButtonSize.small,
                      onPressed: () => onInsertCloze(2),
                      child: const Text(
                        '{{c2}}',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    AppGaps.h4,
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
          AppGaps.v8,
          TextField(
            controller: frontController,
            focusNode: frontFocusNode,
            padding: AppEdgeInsets.h16v12,
            placeholder: Text(
              noteType == NoteType.cloze
                  ? l10n.clozePlaceholder
                  : l10n.frontPlaceholder,
            ),
            minLines: isDesktop ? 6 : 4,
            maxLines: isDesktop ? 10 : 6,
          ),
          AppGaps.v20,

          // Back Header
          Row(
            children: [
              Icon(
                LucideIcons.fileCheck,
                size: AppIconSize.sm,
                color: theme.colorScheme.primary,
              ),
              AppGaps.h8,
              Text(
                noteType == NoteType.cloze ? l10n.extraNotes : l10n.backSide,
                style: theme.typography.small.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          AppGaps.v8,
          TextField(
            controller: backController,
            focusNode: backFocusNode,
            padding: AppEdgeInsets.h16v12,
            placeholder: Text(l10n.backPlaceholder),
            minLines: isDesktop ? 7 : 5,
            maxLines: isDesktop ? 12 : 8,
          ),
        ],
      ),
    );
  }
}
