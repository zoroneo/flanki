import 'package:flutter/widgets.dart';

import '../gen/fonts.gen.dart';

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

/// Flanki Typography Tokens.
abstract final class AppTypography {
  // Font families
  static const String fontFamilySans = FontFamily.beVietnamPro;
  static const String fontFamilyMono = FontFamily.jetBrainsMono;

  // Font sizes
  static const double badge = 9.0;
  static const double caption = 10.0;
  static const double sub = 11.0;
  static const double xSmall = 12.0;
  static const double nav = 13.0;
  static const double small = 14.0;
  static const double base = 16.0;
  static const double large = 18.0;
  static const double xLarge = 20.0;
  static const double h4 = 24.0;

  // Line heights
  static const double lineHeightNormal = 1.35;
  static const double lineHeightTight = 1.2;
  static const double lineHeightBadge = 1.1;
}

/// Flanki Semantic Colors & Rating Palette Tokens.
abstract final class AppColors {
  // FSRS & SM-2 Review Rating Colors
  static const Color ratingAgain = Color(0xFFE53935);
  static const Color ratingHard = Color(0xFFF57C00);
  static const Color ratingGood = Color(0xFF1E88E5);
  static const Color ratingEasy = Color(0xFF43A047);

  // Status & Highlights
  static const Color streakFlame = Color(0xFFFF5722);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

/// Flanki Tab Navigation Indices.
abstract final class AppNavIndex {
  static const int decks = 0;
  static const int browser = 1;
  static const int grammar = 2;
  static const int exams = 3;
  static const int stats = 4;
  static const int settings = 5;
}

/// Flanki Standard Dimensions & Layout Metrics.
abstract final class AppDimensions {
  // Navigation
  static const double sidebarWidth = 240.0;
  static const double navRailWidth = 72.0;
  static const double brandIconDesktop = 36.0;
  static const double brandIconTablet = 38.0;
  static const double navRailItemSize = 48.0;
  static const double mobileNavItemMinWidth = 40.0;
  static const double mobileNavItemMinHeight = 48.0;
  static const double statusDotSize = 8.0;
  static const double indicatorDotSize = 6.0;

  // Modals & Sheets
  static const double modalDesktopMaxWidth = 480.0;
  static const double modalDesktopMaxHeightFactor = 0.85;
  static const double modalMobileMaxHeightFactor = 0.9;
  static const double modalGrabHandleWidth = 36.0;
  static const double modalGrabHandleHeight = 4.0;

  // Max Widths & Heights
  static const double cardMaxWidth = 760.0;
  static const double statsMaxWidth = 880.0;
  static const double typeInputMaxWidth = 400.0;
  static const double typeResultMaxWidth = 380.0;
  static const double toastWidth = 380.0;
  static const double bottomNavClearance = 110.0;

  // Interactive buttons
  static const double ratingButtonMinHeight = 48.0;
  static const double audioButtonSize = 28.0;
  static const double speedDialFabSize = 56.0;
  static const double speedDialOptionSize = 44.0;
}

/// Flanki Standard Animation Durations.
abstract final class AppDurations {
  static const Duration quick = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration shake = Duration(milliseconds: 360);
  static const Duration long = Duration(milliseconds: 500);
}

/// Flanki Display Limits & Overflows.
abstract final class AppLimits {
  static const int badgeMaxCount = 99;
  static const String badgeOverflowText = '99+';
}

/// Flanki Theme Values, Scales & Physics Factors.
abstract final class AppThemeValues {
  static const double shadcnRadiusFactor = 0.5;
  static const EdgeInsets textFieldPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const double ratingButtonPressedScale = 0.94;
  static const double speedDialRotationTurns = 0.125;
  static const double cardFlipPerspective = 0.001;
  static const double cardFlipDepthScaleDip = 0.035;
  static const double cardFlipTiltFactor = 0.0006;
  static const double cardFlipMaxTilt = 0.12;
}

