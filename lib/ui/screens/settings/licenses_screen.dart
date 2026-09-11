import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/notifiers/locale_notifier.dart';

class PackageLicense {
  final String package;
  final String text;

  const PackageLicense({required this.package, required this.text});
}

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
              icon: const Icon(LucideIcons.arrowLeft, size: 18),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/settings');
                }
              },
            ),
          ],
          title: Text(
            l10n.openSourceLicenses,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.base.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Flanki Featured License Card
                      Card(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    LucideIcons.shieldCheck,
                                    size: 22,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Flanki',
                                            style: theme.typography.semiBold
                                                .copyWith(fontSize: 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.muted,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'v${AppConfig.version}',
                                              style: theme.typography.xSmall
                                                  .copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .mutedForeground,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Copyright © 2026 ZoroNeo. MIT License.',
                                        style: theme.typography.xSmall.copyWith(
                                          color:
                                              theme.colorScheme.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton.ghost(
                                  icon: Icon(
                                    expandedPackages.value.contains('flanki')
                                        ? LucideIcons.chevronDown
                                        : LucideIcons.chevronRight,
                                    size: 18,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  onPressed: () => toggleExpanded('flanki'),
                                ),
                              ],
                            ),
                            if (expandedPackages.value.contains('flanki')) ...[
                              const SizedBox(height: 14),
                              const Divider(),
                              const SizedBox(height: 12),
                              _LicenseCodeBlock(
                                licenseText: flankiLicenseText,
                                onCopy: () {
                                  Clipboard.setData(
                                    const ClipboardData(
                                      text: flankiLicenseText,
                                    ),
                                  );
                                  showToast(
                                    context: context,
                                    builder: (ctx, overlay) => SurfaceCard(
                                      child: Basic(
                                        title: Text(l10n.licenseCopied),
                                        trailing: IconButton.ghost(
                                          icon: const Icon(
                                            LucideIcons.x,
                                            size: 14,
                                          ),
                                          onPressed: () => overlay.close(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search & Filter
                      TextField(
                        controller: searchController,
                        placeholder: Text(l10n.searchLicensesPlaceholder),
                        features: [
                          InputFeature.leading(
                            Padding(
                              padding: const EdgeInsets.only(left: 4, right: 6),
                              child: Icon(
                                LucideIcons.search,
                                size: 16,
                                color: theme.colorScheme.mutedForeground,
                              ),
                            ),
                          ),
                          if (searchQuery.value.isNotEmpty)
                            InputFeature.trailing(
                              IconButton.ghost(
                                icon: const Icon(LucideIcons.x, size: 14),
                                onPressed: () => searchController.clear(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Third-party packages header
                      Text(
                        l10n.thirdPartyLicenses(filteredPackages.length),
                        style: theme.typography.xSmall.copyWith(
                          color: theme.colorScheme.mutedForeground,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ] else if (filteredPackages.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: filteredPackages.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredPackages[index];
                      final isExpanded = expandedPackages.value.contains(
                        item.package,
                      );

                      return Card(
                        key: ValueKey('pkg_${item.package}'),
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => toggleExpanded(item.package),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.package,
                                      size: 16,
                                      color: theme.colorScheme.mutedForeground,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.package,
                                        style: theme.typography.small.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? LucideIcons.chevronDown
                                          : LucideIcons.chevronRight,
                                      size: 16,
                                      color: theme.colorScheme.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  14,
                                ),
                                child: _LicenseCodeBlock(
                                  licenseText: item.text,
                                  onCopy: () {
                                    Clipboard.setData(
                                      ClipboardData(text: item.text),
                                    );
                                    showToast(
                                      context: context,
                                      builder: (ctx, overlay) => SurfaceCard(
                                        child: Basic(
                                          title: Text(l10n.licenseCopied),
                                          trailing: IconButton.ghost(
                                            icon: const Icon(
                                              LucideIcons.x,
                                              size: 14,
                                            ),
                                            onPressed: () => overlay.close(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LicenseCodeBlock extends StatelessWidget {
  final String licenseText;
  final VoidCallback onCopy;

  const _LicenseCodeBlock({required this.licenseText, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton.ghost(
                icon: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.copy, size: 13),
                    SizedBox(width: 4),
                  ],
                ),
                onPressed: onCopy,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SelectableText(
            licenseText,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              height: 1.45,
              color: theme.colorScheme.foreground.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}
