import 'package:flutter/material.dart' as m;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/notifiers/locale_notifier.dart';

class DeckSpeedDial extends HookWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onCreateDeck;
  final VoidCallback onImportApkg;
  final VoidCallback onCram;

  const DeckSpeedDial({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.onCreateDeck,
    required this.onImportApkg,
    required this.onCram,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );

    useEffect(() {
      if (isOpen) {
        controller.forward();
      } else {
        controller.reverse();
      }
      return null;
    }, [isOpen]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen || controller.value > 0)
          _buildAnimatedOptions(context, controller, l10n),
        _buildFabButton(theme),
      ],
    );
  }

  Widget _buildAnimatedOptions(
    BuildContext context,
    AnimationController controller,
    dynamic l10n,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final p = controller.value;
        return Opacity(
          opacity: p.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - p)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SpeedDialOption(
                  icon: LucideIcons.folderPlus,
                  iconColor: m.Colors.green,
                  label: l10n.createDeckAction,
                  onTap: onCreateDeck,
                ),
                const SizedBox(height: 12),
                SpeedDialOption(
                  icon: LucideIcons.upload,
                  iconColor: m.Colors.blue,
                  label: l10n.importApkgAction,
                  onTap: onImportApkg,
                ),
                const SizedBox(height: 12),
                SpeedDialOption(
                  icon: LucideIcons.zap,
                  iconColor: m.Colors.amber,
                  label: l10n.cramAction,
                  onTap: onCram,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFabButton(ThemeData theme) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              LucideIcons.plus,
              color: theme.colorScheme.primaryForeground,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class SpeedDialOption extends StatelessWidget {
  final IconData icon;
  final m.Color iconColor;
  final String label;
  final VoidCallback onTap;

  const SpeedDialOption({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: m.Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.cardForeground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: m.Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
        ],
      ),
    );
  }
}
