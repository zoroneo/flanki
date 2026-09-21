import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/localization/locale_notifier.dart';
import '../../../core/theme/app_tokens.dart';
import 'widgets/license_cards.dart';

export 'widgets/license_cards.dart' show PackageLicense;

class LicensesScreen extends HookWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text.trim().toLowerCase();
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final licensesFuture = useMemoized(() async {
      final Map<String, List<String>> packageMap = {};

      await for (final entry in LicenseRegistry.licenses) {
        final text = entry.paragraphs
            .map((p) {
              if (p.indent == LicenseParagraph.centeredIndent) {
                return p.text;
              }
              final indent = '  ' * (p.indent > 0 ? p.indent : 0);
              return '$indent${p.text}';
            })
            .join('\n\n');

        for (final pkg in entry.packages) {
          packageMap.putIfAbsent(pkg, () => []).add(text);
        }
      }

      final List<PackageLicense> packages = [];
      packageMap.forEach((pkg, texts) {
        if (pkg.toLowerCase() != 'flanki') {
          packages.add(
            PackageLicense(package: pkg, text: texts.join('\n\n---\n\n')),
          );
        }
      });

      packages.sort(
        (a, b) => a.package.toLowerCase().compareTo(b.package.toLowerCase()),
      );
      return packages;
    });

    final snapshot = useFuture(licensesFuture);
    final expandedPackages = useState<Set<String>>({'flanki'});

    void toggleExpanded(String pkg) {
      final current = Set<String>.from(expandedPackages.value);
      if (current.contains(pkg)) {
        current.remove(pkg);
      } else {
        current.add(pkg);
      }
      expandedPackages.value = current;
    }

    final allPackages = snapshot.data ?? [];
    final filteredPackages = allPackages.where((p) {
      if (searchQuery.value.isEmpty) return true;
      return p.package.toLowerCase().contains(searchQuery.value);
    }).toList();

    const flankiLicenseText = '''MIT License

Copyright (c) 2026 ZoroNeo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''';

    return Scaffold(
      headers: [
        AppBar(
          leading: [
            IconButton.ghost(
              icon: const Icon(LucideIcons.arrowLeft, size: AppIconSize.md),
              onPressed: () => context.pop(),
            ),
          ],
          title: Text(
            l10n.openSourceLicenses,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FlankiLicenseCard(
                        isExpanded: expandedPackages.value.contains('flanki'),
                        onToggle: () => toggleExpanded('flanki'),
                        licenseText: flankiLicenseText,
                      ),
                      AppGaps.v20,

                      // Search & Filter
                      TextField(
                        controller: searchController,
                        placeholder: Text(l10n.searchLicensesPlaceholder),
                        features: [
                          InputFeature.leading(
                            Padding(
                              padding: const EdgeInsets.only(
                                left: AppSpacing.xs,
                                right: AppSpacing.sm,
                              ),
                              child: Icon(
                                LucideIcons.search,
                                size: AppIconSize.sm,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                          if (searchQuery.value.isNotEmpty)
                            InputFeature.trailing(
                              IconButton.ghost(
                                icon: const Icon(
                                  LucideIcons.x,
                                  size: AppIconSize.xs,
                                ),
                                onPressed: () => searchController.clear(),
                              ),
                            ),
                        ],
                      ),
                      AppGaps.v16,

                      // Third-party packages header
                      Text(
                        l10n.thirdPartyLicenses(filteredPackages.length),
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      AppGaps.v8,

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) ...[
                        const Padding(
                          padding: AppEdgeInsets.v48,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ] else if (filteredPackages.isEmpty) ...[
                        Padding(
                          padding: AppEdgeInsets.v48,
                          child: Center(
                            child: Text(
                              l10n.noLicensesFound,
                              style: theme.typography.small.copyWith(
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (snapshot.connectionState != ConnectionState.waiting &&
                  filteredPackages.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverList.separated(
                    itemCount: filteredPackages.length,
                    separatorBuilder: (context, index) => AppGaps.v8,
                    itemBuilder: (context, index) {
                      final item = filteredPackages[index];
                      return PackageLicenseCard(
                        item: item,
                        isExpanded: expandedPackages.value.contains(
                          item.package,
                        ),
                        onToggle: () => toggleExpanded(item.package),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
