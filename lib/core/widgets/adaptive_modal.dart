import 'package:flutter/material.dart' as m;
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../extensions/responsive_extensions.dart';
import '../theme/app_tokens.dart';

/// Shows an adaptive modal:
/// - Bottom sheet on mobile (< 600dp)
/// - Centered dialog on desktop/tablet (>= 600dp)
Future<T?> showAdaptiveModal<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, bool isDesktop) builder,
  double desktopMaxWidth = AppDimensions.modalDesktopMaxWidth,
  double desktopMaxHeightFactor = AppDimensions.modalDesktopMaxHeightFactor,
  bool isDismissible = true,
  bool useRootNavigator = false,
}) {
  final isDesktop = !context.isMobile;

  if (!isDesktop) {
    return m.showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      backgroundColor: m.Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height *
            AppDimensions.modalMobileMaxHeightFactor,
      ),
      builder: (ctx) => m.Material(
        type: m.MaterialType.transparency,
        child: builder(ctx, false),
      ),
    );
  }

  return m.showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: isDismissible,
    builder: (ctx) => m.Dialog(
      backgroundColor: m.Colors.transparent,
      insetPadding: AppEdgeInsets.all24,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: desktopMaxWidth,
          maxHeight: MediaQuery.sizeOf(ctx).height * desktopMaxHeightFactor,
        ),
        child: m.Material(
          type: m.MaterialType.transparency,
          child: builder(ctx, true),
        ),
      ),
    ),
  );
}

/// Adaptive container styling for sheets (mobile) and dialogs (desktop).
class AdaptiveModalFrame extends StatelessWidget {
  final Widget child;
  final bool isDesktop;
  final EdgeInsetsGeometry? padding;
  final bool showGrabHandle;

  const AdaptiveModalFrame({
    super.key,
    required this.child,
    this.isDesktop = false,
    this.padding,
    this.showGrabHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      duration: AppDurations.short,
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: isDesktop
              ? AppRadius.borderXl
              : const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.lg),
                ),
          border: isDesktop
              ? Border.all(color: theme.colorScheme.border, width: 1)
              : Border(
                  top: BorderSide(color: theme.colorScheme.border, width: 1),
                  left: BorderSide(color: theme.colorScheme.border, width: 1),
                  right: BorderSide(color: theme.colorScheme.border, width: 1),
                ),
          boxShadow: [
            BoxShadow(
              color: m.Colors.black.withValues(alpha: isDesktop ? 0.2 : 0.15),
              blurRadius: isDesktop ? 24 : 16,
              offset: isDesktop ? const Offset(0, 8) : const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: isDesktop
              ? AppRadius.borderXl
              : const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.lg),
                ),
          child: SafeArea(
            top: false,
            bottom: !isDesktop,
            child: SingleChildScrollView(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isDesktop && showGrabHandle)
                    Center(
                      child: Container(
                        width: AppDimensions.modalGrabHandleWidth,
                        height: AppDimensions.modalGrabHandleHeight,
                        margin: const EdgeInsets.only(
                          top: AppSpacing.sm,
                          bottom: AppSpacing.smPlus,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.mutedForeground.withValues(
                            alpha: 0.25,
                          ),
                          borderRadius: AppRadius.borderXs,
                        ),
                      ),
                    ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
