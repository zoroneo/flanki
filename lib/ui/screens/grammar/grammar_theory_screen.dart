import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/models/grammar/grammar_models.dart';
import '../../../core/services/grammar_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/grammar_theory_sections.dart';
import 'widgets/grammar_theory_toc.dart';

class GrammarTheoryScreen extends HookConsumerWidget {
  final String unitId;

  const GrammarTheoryScreen({super.key, required this.unitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final grammarAsync = ref.watch(grammarUnitsProvider);

    final conceptKey = useMemoized(() => GlobalKey());
    final formulasKey = useMemoized(() => GlobalKey());
    final trapsKey = useMemoized(() => GlobalKey());
    final guidesKey = useMemoized(() => GlobalKey());

    void scrollTo(GlobalKey key) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    return ResponsiveBuilder(
      builder: (context, sizingInfo) {
        final isMobile = sizingInfo.deviceScreenType == DeviceScreenType.mobile;

        return Scaffold(
          headers: [
            _buildAppBar(context, l10n, isMobile),
          ],
          footers: [
            if (isMobile)
              _buildStickyBottomCta(
                context,
                unitId: unitId,
                exercisesCount: GrammarConstants.exercisesPerUnit,
              ),
          ],
          child: grammarAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text(l10n.grammarErrorLoadUnit(err.toString()))),
            data: (units) {
              final unit = units.cast<GrammarUnit?>().firstWhere(
                    (u) => u?.unitId == unitId,
                    orElse: () => null,
                  );

              if (unit == null) {
                return Center(child: Text(l10n.grammarUnitNotFound));
              }

              return ScreenTypeLayout.builder(
                mobile: (context) => _buildMobileTheoryList(context, l10n, unit),
                desktop: (context) => _buildDesktopTheoryLayout(
                  context,
                  l10n,
                  unit,
                  conceptKey: conceptKey,
                  formulasKey: formulasKey,
                  trapsKey: trapsKey,
                  guidesKey: guidesKey,
                  onScrollTo: scrollTo,
                ),
              );
            },
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n, bool isMobile) {
    return AppBar(
      leading: [
        IconButton.ghost(
          icon: const Icon(LucideIcons.arrowLeft, size: 20),
          onPressed: () => context.pop(),
        ),
      ],
      title: Text(
        l10n.grammarTheoryScreenTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: [
        if (!isMobile)
          PrimaryButton(
            onPressed: () => context.push('/grammar/$unitId/practice'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.grammarPracticeCountButton(GrammarConstants.exercisesPerUnit)),
                const SizedBox(width: 6),
                const Icon(LucideIcons.play, size: 14),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStickyBottomCta(
    BuildContext context, {
    required String unitId,
    required int exercisesCount,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          top: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: PrimaryButton(
        size: ButtonSize.normal,
        onPressed: () => context.push('/grammar/$unitId/practice'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.play, size: 15),
            const SizedBox(width: 8),
            Text(
              l10n.grammarStartPracticeNowButton(exercisesCount),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTheoryList(
    BuildContext context,
    AppLocalizations l10n,
    GrammarUnit unit,
  ) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GrammarTheoryHeaderBanner(unit: unit, isMobile: true),
            const SizedBox(height: 10),
            GrammarTheorySectionCard(
              icon: LucideIcons.lightbulb,
              iconColor: m.Colors.amber,
              title: l10n.grammarCoreConceptTitle,
              content: unit.coreConcept,
              isMobile: true,
            ),
            const SizedBox(height: 10),
            if (unit.formulas.isNotEmpty) ...[
              GrammarTheoryFormulasCard(formulas: unit.formulas, isMobile: true),
              const SizedBox(height: 10),
            ],
            if (unit.commonTraps.isNotEmpty) ...[
              GrammarTheoryTrapsCard(commonTraps: unit.commonTraps, isMobile: true),
              const SizedBox(height: 10),
            ],
            if (unit.extraGuides.isNotEmpty) ...[
              GrammarTheoryGuidesCard(extraGuides: unit.extraGuides, isMobile: true),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTheoryLayout(
    BuildContext context,
    AppLocalizations l10n,
    GrammarUnit unit, {
    required GlobalKey conceptKey,
    required GlobalKey formulasKey,
    required GlobalKey trapsKey,
    required GlobalKey guidesKey,
    required ValueChanged<GlobalKey> onScrollTo,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GrammarTheoryHeaderBanner(unit: unit),
                    const SizedBox(height: 16),
                    GrammarTheoryTocCard(
                      unit: unit,
                      onScrollToConcept: () => onScrollTo(conceptKey),
                      onScrollToFormulas: () => onScrollTo(formulasKey),
                      onScrollToTraps: () => onScrollTo(trapsKey),
                      onScrollToGuides: () => onScrollTo(guidesKey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KeyedSubtree(
                        key: conceptKey,
                        child: GrammarTheorySectionCard(
                          icon: LucideIcons.lightbulb,
                          iconColor: m.Colors.amber,
                          title: l10n.grammarCoreConceptTitle,
                          content: unit.coreConcept,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (unit.formulas.isNotEmpty) ...[
                        KeyedSubtree(
                          key: formulasKey,
                          child: GrammarTheoryFormulasCard(formulas: unit.formulas),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (unit.commonTraps.isNotEmpty) ...[
                        KeyedSubtree(
                          key: trapsKey,
                          child: GrammarTheoryTrapsCard(commonTraps: unit.commonTraps),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (unit.extraGuides.isNotEmpty) ...[
                        KeyedSubtree(
                          key: guidesKey,
                          child: GrammarTheoryGuidesCard(extraGuides: unit.extraGuides),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
