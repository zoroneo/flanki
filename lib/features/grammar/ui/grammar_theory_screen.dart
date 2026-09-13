import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/grammar_service.dart';
import '../models/grammar_models.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'widgets/grammar_theory_mobile_tabs.dart';
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
          headers: [_buildAppBar(context, l10n, isMobile)],
          child: grammarAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text(l10n.grammarErrorLoadUnit(err.toString()))),
            data: (units) {
              final unit = units.cast<GrammarUnit?>().firstWhere(
                (u) => u?.unitId == unitId,
                orElse: () => null,
              );

              if (unit == null) {
                return Center(child: Text(l10n.grammarUnitNotFound));
              }

              return isMobile
                  ? GrammarTheoryMobileTabs(unit: unit)
                  : _buildDesktopTheoryLayout(
                      context,
                      l10n,
                      unit,
                      conceptKey: conceptKey,
                      formulasKey: formulasKey,
                      trapsKey: trapsKey,
                      guidesKey: guidesKey,
                      onScrollTo: scrollTo,
                    );
            },
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    final theme = Theme.of(context);
    return AppBar(
      leading: [
        IconButton.ghost(
          icon: const Icon(LucideIcons.arrowLeft, size: AppIconSize.md),
          onPressed: () => context.pop(),
        ),
      ],
      title: Text(
        l10n.grammarTheoryScreenTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isMobile ? 15 : 17,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.foreground,
        ),
      ),
      trailing: [
        Padding(
          padding: EdgeInsets.only(right: isMobile ? AppSpacing.xs : 0),
          child: PrimaryButton(
            size: ButtonSize.small,
            onPressed: () => context.push('/grammar/$unitId/practice'),
            leading: Icon(
              LucideIcons.play,
              size: AppIconSize.xs,
              color: theme.colorScheme.primaryForeground,
            ),
            child: Text(
              isMobile
                  ? l10n.grammarPracticeButton
                  : l10n.grammarPracticeCountButton(
                      GrammarConstants.exercisesPerUnit,
                    ),
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primaryForeground,
              ),
            ),
          ),
        ),
      ],
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageDesktop,
            AppSpacing.pageDesktop,
            AppSpacing.pageDesktop,
            AppSpacing.xxl,
          ),
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
                    AppGaps.v16,
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
              AppGaps.h24,
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
                      AppGaps.v20,
                      if (unit.formulas.isNotEmpty) ...[
                        KeyedSubtree(
                          key: formulasKey,
                          child: GrammarTheoryFormulasCard(
                            formulas: unit.formulas,
                          ),
                        ),
                        AppGaps.v20,
                      ],
                      if (unit.commonTraps.isNotEmpty) ...[
                        KeyedSubtree(
                          key: trapsKey,
                          child: GrammarTheoryTrapsCard(
                            commonTraps: unit.commonTraps,
                          ),
                        ),
                        AppGaps.v20,
                      ],
                      if (unit.extraGuides.isNotEmpty) ...[
                        KeyedSubtree(
                          key: guidesKey,
                          child: GrammarTheoryGuidesCard(
                            extraGuides: unit.extraGuides,
                          ),
                        ),
                        AppGaps.v20,
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
