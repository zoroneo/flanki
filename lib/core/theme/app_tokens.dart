import 'package:flutter/widgets.dart';

/// Flanki Spacing Tokens (Dựa trên 8-pt grid với 4-pt half-steps).
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smPlus = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Responsive page padding defaults
  static const double pageMobile = 16;
  static const double pageTablet = 20;
  static const double pageDesktop = 24;
}

/// Ready-made [SizedBox] instances để tái sử dụng với zero runtime overhead.
abstract final class AppGaps {
  static const SizedBox empty = SizedBox.shrink();

  // Horizontal gaps
  static const SizedBox h2 = SizedBox(width: AppSpacing.xxs);
  static const SizedBox h4 = SizedBox(width: AppSpacing.xs);
  static const SizedBox h8 = SizedBox(width: AppSpacing.sm);
  static const SizedBox h12 = SizedBox(width: AppSpacing.smPlus);
  static const SizedBox h16 = SizedBox(width: AppSpacing.md);
  static const SizedBox h20 = SizedBox(width: AppSpacing.lg);
  static const SizedBox h24 = SizedBox(width: AppSpacing.xl);
  static const SizedBox h32 = SizedBox(width: AppSpacing.xxl);

  // Vertical gaps
  static const SizedBox v2 = SizedBox(height: AppSpacing.xxs);
  static const SizedBox v4 = SizedBox(height: AppSpacing.xs);
  static const SizedBox v6 = SizedBox(height: 6);
  static const SizedBox v8 = SizedBox(height: AppSpacing.sm);
  static const SizedBox v12 = SizedBox(height: AppSpacing.smPlus);
  static const SizedBox v16 = SizedBox(height: AppSpacing.md);
  static const SizedBox v20 = SizedBox(height: AppSpacing.lg);
  static const SizedBox v24 = SizedBox(height: AppSpacing.xl);
  static const SizedBox v32 = SizedBox(height: AppSpacing.xxl);
}

/// Flanki Border Radius Tokens.
abstract final class AppRadius {
  static const double none = 0;
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double full = 999;

  // BorderRadius objects
  static const BorderRadius borderZero = BorderRadius.zero;
  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );
}

/// Flanki Icon Size Tokens.
abstract final class AppIconSize {
  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
}

/// Pre-allocated [EdgeInsets] thường dùng.
abstract final class AppEdgeInsets {
  static const EdgeInsets zero = EdgeInsets.zero;
  static const EdgeInsets all4 = EdgeInsets.all(AppSpacing.xs);
  static const EdgeInsets all8 = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets all12 = EdgeInsets.all(AppSpacing.smPlus);
  static const EdgeInsets all16 = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets all20 = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets all24 = EdgeInsets.all(AppSpacing.xl);

  // Symmetric
  static const EdgeInsets h8v4 = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );
  static const EdgeInsets h12v8 = EdgeInsets.symmetric(
    horizontal: AppSpacing.smPlus,
    vertical: AppSpacing.sm,
  );
  static const EdgeInsets h16v8 = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );
  static const EdgeInsets h16v12 = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.smPlus,
  );
}
