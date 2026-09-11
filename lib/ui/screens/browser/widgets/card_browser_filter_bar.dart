import 'package:shadcn_flutter/shadcn_flutter.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? theme.colorScheme.primary : theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primaryForeground
                : theme.colorScheme.foreground,
          ),
        ),
      ),
    );
  }
}

class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final Widget titleRow;
  final Widget searchBox;
  final Widget filterRow;
  final ThemeData theme;

  static const double _titleHeight = 44.0;
  static const double _searchHeight = 46.0;
  static const double _filterHeight = 38.0;

  SearchHeaderDelegate({
    required this.topPadding,
    required this.titleRow,
    required this.searchBox,
    required this.filterRow,
    required this.theme,
  });

  @override
  double get minExtent => topPadding + _searchHeight + _filterHeight + 6.0;

  @override
  double get maxExtent =>
      topPadding + _titleHeight + _searchHeight + _filterHeight + 6.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / _titleHeight).clamp(0.0, 1.0);
    final borderAlpha = ((progress - 0.4) / 0.6).clamp(0.0, 1.0);
    final currentTop = (topPadding + _titleHeight - shrinkOffset).clamp(
      topPadding,
      topPadding + _titleHeight,
    );

    return Container(
      color: theme.colorScheme.background,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: topPadding - (shrinkOffset * 0.8),
            left: 0,
            right: 0,
            height: _titleHeight,
            child: Opacity(
              opacity: (1.0 - progress * 1.8).clamp(0.0, 1.0),
              child: titleRow,
            ),
          ),
          Positioned(
            top: currentTop,
            left: 0,
            right: 0,
            height: _searchHeight,
            child: searchBox,
          ),
          Positioned(
            top: currentTop + _searchHeight,
            left: 0,
            right: 0,
            height: _filterHeight,
            child: filterRow,
          ),
          if (borderAlpha > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 1,
                color: theme.colorScheme.border.withValues(alpha: borderAlpha),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SearchHeaderDelegate oldDelegate) {
    return oldDelegate.topPadding != topPadding ||
        oldDelegate.titleRow != titleRow ||
        oldDelegate.searchBox != searchBox ||
        oldDelegate.filterRow != filterRow ||
        oldDelegate.theme != theme;
  }
}
