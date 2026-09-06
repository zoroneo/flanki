import 'package:flutter/material.dart' as m;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FlankiApp(),
    ),
  );
}

class FlankiApp extends StatelessWidget {
  const FlankiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Flanki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc,
        radius: 0.5,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorSchemes.darkZinc,
        radius: 0.5,
      ),
      home: const FlankiHomeScreen(),
    );
  }
}

class FlankiHomeScreen extends StatefulWidget {
  const FlankiHomeScreen({super.key});

  @override
  State<FlankiHomeScreen> createState() => _FlankiHomeScreenState();
}

class _FlankiHomeScreenState extends State<FlankiHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      headers: [
        AppBar(
          title: Row(
            children: [
              const Icon(m.Icons.bolt_rounded, size: 24),
              const SizedBox(width: 8),
              Text(
                'Flanki',
                style: theme.typography.h3.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              const PrimaryBadge(
                child: Text('Alpha 0.1.0 • FSRS Core'),
              ),
            ],
          ),
          trailing: [
            OutlineButton(
              onPressed: () {},
              leading: const Icon(m.Icons.cloud_sync_outlined),
              child: const Text('AnkiWeb Sync'),
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              onPressed: () {},
              leading: const Icon(m.Icons.add),
              child: const Text('Import .apkg'),
            ),
          ],
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar: Decks & navigation
            SizedBox(
              width: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NAVIGATION',
                    style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                  ),
                  const SizedBox(height: 12),
                  _NavButton(
                    icon: m.Icons.space_dashboard_outlined,
                    label: 'Decks Overview',
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _NavButton(
                    icon: m.Icons.auto_stories_outlined,
                    label: 'Study Session',
                    selected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _NavButton(
                    icon: m.Icons.query_stats_outlined,
                    label: 'Retention & Stats',
                    selected: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _NavButton(
                    icon: m.Icons.settings_outlined,
                    label: 'Settings',
                    selected: _selectedIndex == 3,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  const Spacer(),
                  Card(
                    filled: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Anki Engine', style: theme.typography.semiBold),
                        const SizedBox(height: 4),
                        Text(
                          'rslib: FSRS v5 Active\nStatus: Synced',
                          style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Practice', style: theme.typography.h2),
                    const SizedBox(height: 8),
                    Text(
                      'Targeting 85% retention rate with active recall and context spacing.',
                      style: theme.typography.lead,
                    ),
                    const SizedBox(height: 24),
                    // Quick Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Cards Due',
                            value: '42',
                            subtitle: '12 new • 30 learning',
                            icon: m.Icons.alarm,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Current Streak',
                            value: '14 Days',
                            subtitle: 'Top 5% consistency',
                            icon: m.Icons.local_fire_department_rounded,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            title: 'Engine Status',
                            value: 'Rust 24.11',
                            subtitle: 'C ABI Protobuf Bridge',
                            icon: m.Icons.terminal_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('Your Decks', style: theme.typography.h4),
                    const SizedBox(height: 16),
                    _DeckItemCard(
                      title: 'TOEIC 600 Essential Vocabulary',
                      dueCount: 24,
                      newCount: 10,
                      totalCount: 600,
                      onStudy: () {},
                    ),
                    const SizedBox(height: 12),
                    _DeckItemCard(
                      title: '4000 Essential English Words 2 (Vietnamese)',
                      dueCount: 18,
                      newCount: 5,
                      totalCount: 600,
                      onStudy: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final m.IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: SizedBox(
        width: double.infinity,
        child: selected
            ? PrimaryButton(
                onPressed: onTap,
                leading: Icon(icon, size: 18),
                alignment: Alignment.centerLeft,
                child: Text(label),
              )
            : GhostButton(
                onPressed: onTap,
                leading: Icon(icon, size: 18, color: theme.colorScheme.mutedForeground),
                alignment: Alignment.centerLeft,
                child: Text(label, style: TextStyle(color: theme.colorScheme.foreground)),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final m.IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      filled: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground),
              ),
              Icon(icon, size: 20, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.typography.h2.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.typography.xSmall.copyWith(color: theme.colorScheme.mutedForeground)),
        ],
      ),
    );
  }
}

class _DeckItemCard extends StatelessWidget {
  final String title;
  final int dueCount;
  final int newCount;
  final int totalCount;
  final VoidCallback onStudy;

  const _DeckItemCard({
    required this.title,
    required this.dueCount,
    required this.newCount,
    required this.totalCount,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(m.Icons.folder_outlined, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.typography.h4),
                const SizedBox(height: 4),
                Text(
                  'Total $totalCount cards in collection',
                  style: theme.typography.small.copyWith(color: theme.colorScheme.mutedForeground),
                ),
              ],
            ),
          ),
          Row(
            children: [
              SecondaryBadge(
                child: Text('$newCount New'),
              ),
              const SizedBox(width: 8),
              DestructiveBadge(
                child: Text('$dueCount Due'),
              ),
              const SizedBox(width: 16),
              PrimaryButton(
                onPressed: onStudy,
                leading: const Icon(m.Icons.play_arrow_rounded),
                child: const Text('Study Now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
