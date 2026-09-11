import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/models/grammar/grammar_models.dart';
import '../../../core/services/grammar_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../study/widgets/rich_card_content.dart';

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
            AppBar(
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
            ),
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
                mobile: (context) => SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Unit Header Banner
                        _buildHeaderBanner(context, unit, isMobile: true),
                        const SizedBox(height: 10),

                        // 1. Core Concept Section
                        _buildSectionCard(
                          context,
                          icon: LucideIcons.lightbulb,
                          iconColor: Colors.amber,
                          title: l10n.grammarCoreConceptTitle,
                          content: unit.coreConcept,
                          isMobile: true,
                        ),
                        const SizedBox(height: 10),

                        // 2. Formulas Section
                        if (unit.formulas.isNotEmpty) ...[
                          _buildFormulasSection(context, unit.formulas, isMobile: true),
                          const SizedBox(height: 10),
                        ],

                        // 3. Common Traps Section
                        if (unit.commonTraps.isNotEmpty) ...[
                          _buildCommonTrapsSection(context, unit.commonTraps, isMobile: true),
                          const SizedBox(height: 10),
                        ],

                        // 4. Extra Guides Section (if any)
                        if (unit.extraGuides.isNotEmpty) ...[
                          _buildExtraGuidesSection(context, unit.extraGuides, isMobile: true),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
                desktop: (context) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Pane: Sticky TOC & Unit Info Sidebar (320px)
                          SizedBox(
                            width: 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeaderBanner(context, unit),
                                const SizedBox(height: 16),
                                _buildTocCard(
                                  context,
                                  unit,
                                  onScrollToConcept: () => scrollTo(conceptKey),
                                  onScrollToFormulas: () => scrollTo(formulasKey),
                                  onScrollToTraps: () => scrollTo(trapsKey),
                                  onScrollToGuides: () => scrollTo(guidesKey),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),

                          // Right Pane: Scrollable Theory Reading Area
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // 1. Core Concept Section
                                  KeyedSubtree(
                                    key: conceptKey,
                                    child: _buildSectionCard(
                                      context,
                                      icon: LucideIcons.lightbulb,
                                      iconColor: Colors.amber,
                                      title: l10n.grammarCoreConceptTitle,
                                      content: unit.coreConcept,
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // 2. Formulas Section
                                  if (unit.formulas.isNotEmpty) ...[
                                    KeyedSubtree(
                                      key: formulasKey,
                                      child: _buildFormulasSection(context, unit.formulas),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // 3. Common Traps Section
                                  if (unit.commonTraps.isNotEmpty) ...[
                                    KeyedSubtree(
                                      key: trapsKey,
                                      child: _buildCommonTrapsSection(context, unit.commonTraps),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // 4. Extra Guides Section (if any)
                                  if (unit.extraGuides.isNotEmpty) ...[
                                    KeyedSubtree(
                                      key: guidesKey,
                                      child: _buildExtraGuidesSection(context, unit.extraGuides),
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
                ),
              );
            },
          ),
        );
      },
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
          top: BorderSide(
            color: theme.colorScheme.border,
            width: 1,
          ),
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

  Widget _buildTocCard(
    BuildContext context,
    GrammarUnit unit, {
    required VoidCallback onScrollToConcept,
    VoidCallback? onScrollToFormulas,
    VoidCallback? onScrollToTraps,
    VoidCallback? onScrollToGuides,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.listTree, size: 15, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Mục Lục Chuyên Đề',
                  style: theme.typography.small.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _TocItem(
              icon: LucideIcons.lightbulb,
              iconColor: Colors.amber,
              title: l10n.grammarCoreConceptTitle,
              onTap: onScrollToConcept,
            ),
            if (unit.formulas.isNotEmpty && onScrollToFormulas != null) ...[
              const SizedBox(height: 2),
              _TocItem(
                icon: LucideIcons.sigma,
                iconColor: Colors.blue,
                title: l10n.grammarFormulasTitle,
                onTap: onScrollToFormulas,
              ),
            ],
            if (unit.commonTraps.isNotEmpty && onScrollToTraps != null) ...[
              const SizedBox(height: 2),
              _TocItem(
                icon: LucideIcons.triangleAlert,
                iconColor: Colors.orange,
                title: l10n.grammarCommonTrapsTitle,
                onTap: onScrollToTraps,
              ),
            ],
            if (unit.extraGuides.isNotEmpty && onScrollToGuides != null) ...[
              const SizedBox(height: 2),
              _TocItem(
                icon: LucideIcons.bookOpen,
                iconColor: Colors.purple,
                title: l10n.grammarExtraGuidesTitle,
                onTap: onScrollToGuides,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(
    BuildContext context,
    GrammarUnit unit, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    final levelLabel = unit.level.displayName;
    final levelColor = unit.level.color;

    return Card(
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    levelLabel,
                    style: TextStyle(
                      fontSize: isMobile ? 10.5 : 11,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.muted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    unit.category.code.toUpperCase(),
                    style: TextStyle(
                      fontSize: isMobile ? 10.5 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Text(
              unit.title,
              style: isMobile
                  ? TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: theme.colorScheme.foreground,
                    )
                  : theme.typography.h4.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required m.Color iconColor,
    required String title,
    required String content,
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: isMobile ? 18 : 20, color: iconColor),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    title,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 14),
            RichCardContent(
              content: content,
              crossAxisAlignment: CrossAxisAlignment.start,
              textAlign: TextAlign.start,
              textStyle: isMobile
                  ? TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: theme.colorScheme.foreground,
                    )
                  : theme.typography.base.copyWith(
                      height: 1.6,
                      color: theme.colorScheme.foreground,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulasSection(
    BuildContext context,
    Map<String, String> formulas, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.sigma, size: isMobile ? 18 : 20, color: Colors.blue),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    l10n.grammarFormulasTitle,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            ...formulas.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
                padding: isMobile
                    ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    : const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: isMobile ? 12.5 : 13.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichCardContent(
                      content: entry.value,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textAlign: TextAlign.start,
                      textStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: isMobile ? 12.5 : 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonTrapsSection(
    BuildContext context,
    List<GrammarTrap> traps, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.triangleAlert, size: isMobile ? 18 : 20, color: Colors.orange),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    l10n.grammarCommonTrapsTitle,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            ...traps.map((trap) {
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 10 : 16),
                padding: isMobile
                    ? const EdgeInsets.all(12)
                    : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.colorScheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichCardContent(
                      content: trap.trap,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textAlign: TextAlign.start,
                      textStyle: TextStyle(
                        fontSize: isMobile ? 13.5 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 10),

                    // Wrong
                    Container(
                      padding: isMobile
                          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('❌ ', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: RichCardContent(
                              content: trap.exampleWrong,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textAlign: TextAlign.start,
                              textStyle: TextStyle(
                                fontSize: isMobile ? 12.5 : 13.5,
                                color: Colors.red,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Right
                    Container(
                      padding: isMobile
                          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
                          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✅ ', style: TextStyle(fontSize: 13)),
                          Expanded(
                            child: RichCardContent(
                              content: trap.exampleRight,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textAlign: TextAlign.start,
                              textStyle: TextStyle(
                                fontSize: isMobile ? 12.5 : 13.5,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 10),

                    // Note
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.info, size: isMobile ? 13 : 15, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: RichCardContent(
                            content: trap.note,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textAlign: TextAlign.start,
                            textStyle: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: theme.colorScheme.mutedForeground,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExtraGuidesSection(
    BuildContext context,
    Map<String, String> extraGuides, {
    bool isMobile = false,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: isMobile
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.bookOpen, size: isMobile ? 18 : 20, color: Colors.purple),
                SizedBox(width: isMobile ? 8 : 10),
                Expanded(
                  child: Text(
                    l10n.grammarExtraGuidesTitle,
                    style: isMobile
                        ? TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.foreground,
                          )
                        : theme.typography.h4.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 10 : 16),
            ...extraGuides.entries.map((entry) {
              return Container(
                margin: EdgeInsets.only(bottom: isMobile ? 10 : 14),
                padding: isMobile
                    ? const EdgeInsets.all(12)
                    : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: isMobile ? 13.5 : 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    RichCardContent(
                      content: entry.value,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textAlign: TextAlign.start,
                      textStyle: TextStyle(
                        fontSize: isMobile ? 13 : 14.5,
                        height: isMobile ? 1.45 : 1.55,
                        color: theme.colorScheme.foreground,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TocItem extends StatelessWidget {
  final IconData icon;
  final m.Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _TocItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.xSmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 14,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
