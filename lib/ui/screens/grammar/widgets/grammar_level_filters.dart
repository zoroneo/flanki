import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/models/grammar/grammar_models.dart';
import '../../../../l10n/generated/app_localizations.dart';

class GrammarLevelFilters extends StatelessWidget {
  final ValueNotifier<GrammarLevel?> selectedLevel;
  final bool isMobile;
  final double horizontalPadding;

  const GrammarLevelFilters({
    super.key,
    required this.selectedLevel,
    required this.isMobile,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final chips = [
      GrammarFilterChip(
        label: l10n.grammarFilterAll(GrammarConstants.totalUnits),
        isSelected: selectedLevel.value == null,
        onTap: () => selectedLevel.value = null,
      ),
      ...GrammarLevel.values.map((lvl) {
        return GrammarFilterChip(
          label: lvl.getLocalizedName(l10n),
          isSelected: selectedLevel.value == lvl,
          onTap: () => selectedLevel.value = lvl,
        );
      }),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            for (int i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              chips[i],
            ],
          ],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}

class GrammarFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GrammarFilterChip({
    super.key,
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.muted.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}
