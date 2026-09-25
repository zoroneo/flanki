import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_tokens.dart';

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
                icon: const Icon(LucideIcons.plus, size: AppIconSize.sm),
                onPressed: onAddTag,
              ),
            ),
          ],
          onSubmitted: (_) => onAddTag(),
        ),
        if (tags.isNotEmpty) ...[
          AppGaps.v8,
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.smPlus,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: AppRadius.borderFull,
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${AppConfig.tagPrefix}$t',
                      style: context.textStyles.sub,
                    ),
                    AppGaps.h4,
                    GestureDetector(
                      onTap: () => onRemoveTag(t),
                      child: const Icon(LucideIcons.x, size: AppIconSize.xs),
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
