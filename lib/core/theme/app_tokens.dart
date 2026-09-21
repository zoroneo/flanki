import 'package:flutter/widgets.dart';

import '../gen/fonts.gen.dart';
import 'app_colors_extension.dart';

export 'app_colors_extension.dart';
export 'app_text_theme.dart';

/// Flanki Spacing Tokens (Dựa trên 8-pt grid với 4-pt half-steps).
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double s3 = 3;
  static const double xs = 4;
  static const double s6 = 6;
  static const double sm = 8;
  static const double s10 = 10;
  static const double smPlus = 12;
  static const double s14 = 14;
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
  static const SizedBox h6 = SizedBox(width: AppSpacing.s6);
  static const SizedBox h8 = SizedBox(width: AppSpacing.sm);
  static const SizedBox h10 = SizedBox(width: AppSpacing.s10);
  static const SizedBox h12 = SizedBox(width: AppSpacing.smPlus);
  static const SizedBox h16 = SizedBox(width: AppSpacing.md);
  static const SizedBox h20 = SizedBox(width: AppSpacing.lg);
  static const SizedBox h24 = SizedBox(width: AppSpacing.xl);
  static const SizedBox h32 = SizedBox(width: AppSpacing.xxl);
  static const SizedBox h48 = SizedBox(width: AppSpacing.xxxl);

  // Vertical gaps
  static const SizedBox v2 = SizedBox(height: AppSpacing.xxs);
  static const SizedBox v4 = SizedBox(height: AppSpacing.xs);
  static const SizedBox v6 = SizedBox(height: AppSpacing.s6);
  static const SizedBox v8 = SizedBox(height: AppSpacing.sm);
  static const SizedBox v10 = SizedBox(height: AppSpacing.s10);
  static const SizedBox v12 = SizedBox(height: AppSpacing.smPlus);
  static const SizedBox v16 = SizedBox(height: AppSpacing.md);
  static const SizedBox v20 = SizedBox(height: AppSpacing.lg);
  static const SizedBox v24 = SizedBox(height: AppSpacing.xl);
  static const SizedBox v32 = SizedBox(height: AppSpacing.xxl);
  static const SizedBox v48 = SizedBox(height: AppSpacing.xxxl);
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
  static const EdgeInsets all32 = EdgeInsets.all(AppSpacing.xxl);
  static const EdgeInsets all48 = EdgeInsets.all(AppSpacing.xxxl);

  // Vertical only
  static const EdgeInsets v2 = EdgeInsets.symmetric(vertical: AppSpacing.xxs);
  static const EdgeInsets v4 = EdgeInsets.symmetric(vertical: AppSpacing.xs);
  static const EdgeInsets v6 = EdgeInsets.symmetric(vertical: AppSpacing.s6);
  static const EdgeInsets v8 = EdgeInsets.symmetric(vertical: AppSpacing.sm);
  static const EdgeInsets v10 = EdgeInsets.symmetric(vertical: AppSpacing.s10);
  static const EdgeInsets v12 = EdgeInsets.symmetric(
    vertical: AppSpacing.smPlus,
  );
  static const EdgeInsets v16 = EdgeInsets.symmetric(vertical: AppSpacing.md);
  static const EdgeInsets v48 = EdgeInsets.symmetric(vertical: AppSpacing.xxxl);

  // Horizontal only
  static const EdgeInsets h4 = EdgeInsets.symmetric(horizontal: AppSpacing.xs);
  static const EdgeInsets h6 = EdgeInsets.symmetric(horizontal: AppSpacing.s6);
  static const EdgeInsets h8 = EdgeInsets.symmetric(horizontal: AppSpacing.sm);
  static const EdgeInsets h12 = EdgeInsets.symmetric(
    horizontal: AppSpacing.smPlus,
  );
  static const EdgeInsets h16 = EdgeInsets.symmetric(horizontal: AppSpacing.md);
  static const EdgeInsets h20 = EdgeInsets.symmetric(horizontal: AppSpacing.lg);
  static const EdgeInsets h24 = EdgeInsets.symmetric(horizontal: AppSpacing.xl);

  // Symmetric
  static const EdgeInsets h4v2 = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: AppSpacing.xxs,
  );
  static const EdgeInsets h8v2 = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xxs,
  );
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

  // Semantic & Component presets
  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 1.5,
  );
  static const EdgeInsets badgeSm = EdgeInsets.symmetric(
    horizontal: 5,
    vertical: 1.0,
  );
  static const EdgeInsets ratingKeyBadge = EdgeInsets.symmetric(
    horizontal: AppSpacing.xs,
    vertical: 1.0,
  );
  static const EdgeInsets tag = EdgeInsets.symmetric(
    horizontal: AppSpacing.s6,
    vertical: AppSpacing.xxs,
  );
  static const EdgeInsets countBadge = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.s3,
  );
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: AppSpacing.s10,
    vertical: AppSpacing.s6,
  );
  static const EdgeInsets chipSm = EdgeInsets.symmetric(
    horizontal: AppSpacing.sm,
    vertical: AppSpacing.xs,
  );
  static const EdgeInsets modalGrabHandle = EdgeInsets.only(
    top: AppSpacing.s10,
    bottom: AppSpacing.smPlus,
  );
  static const EdgeInsets textField = EdgeInsets.symmetric(
    horizontal: AppSpacing.s14,
    vertical: AppSpacing.s10,
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
  static const double captionPlus = 10.5;
  static const double sub = 11.0;
  static const double subPlus = 11.5;
  static const double xSmall = 12.0;
  static const double xSmallPlus = 12.5;
  static const double nav = 13.0;
  static const double navPlus = 13.5;
  static const double small = 14.0;
  static const double medium = 15.0;
  static const double base = 16.0;
  static const double large = 18.0;
  static const double xLarge = 20.0;
  static const double h4 = 24.0;
  static const double displayLarge = 36.0;

  // Line heights
  static const double lineHeightNormal = 1.35;
  static const double lineHeightTight = 1.2;
  static const double lineHeightBadge = 1.1;
}

/// Flanki Semantic Colors & Rating Palette Tokens.
abstract final class AppColors {
  // Basic & Neutral Utilities
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color mutedGrey = Color(0xFF9E9E9E);

  // FSRS & SM-2 Review Rating Colors
  static const Color ratingAgain = AppColorsExtension.lightRatingAgain;
  static const Color ratingHard = AppColorsExtension.lightRatingHard;
  static const Color ratingGood = AppColorsExtension.lightRatingGood;
  static const Color ratingEasy = AppColorsExtension.lightRatingEasy;

  // Status & Highlights
  static const Color streakFlame = AppColorsExtension.lightStreakFlame;
  static const Color success = AppColorsExtension.lightSuccess;
  static const Color successDark = AppColorsExtension.lightSuccessDark;
  static const Color warning = AppColorsExtension.lightWarning;
  static const Color error = AppColorsExtension.lightError;
  static const Color info = AppColorsExtension.lightInfo;

  // Cram & Custom Study Highlights
  static const Color cramAmber = AppColorsExtension.lightCramAmber;
  static const Color cramAmberBg = AppColorsExtension.lightCramAmberBg;

  // Accent & Domain Colors
  static const Color accentCyan = AppColorsExtension.lightAccentCyan;
  static const Color accentPurple = AppColorsExtension.lightAccentPurple;
  static const Color accentBlue = AppColorsExtension.lightAccentBlue;
  static const Color accentOrange = AppColorsExtension.lightAccentOrange;

  // Card Flag Palette (Anki Compatible)
  static const Color flagRed = AppColorsExtension.lightFlagRed;
  static const Color flagOrange = AppColorsExtension.lightFlagOrange;
  static const Color flagGreen = AppColorsExtension.lightFlagGreen;
  static const Color flagBlue = AppColorsExtension.lightFlagBlue;
  static const Color flagPink = AppColorsExtension.lightFlagPink;
  static const Color flagTurquoise = AppColorsExtension.lightFlagTurquoise;
  static const Color flagPurple = AppColorsExtension.lightFlagPurple;

  // Scratchpad Drawing Palette
  static const Color scratchAmber = AppColorsExtension.lightScratchAmber;
  static const Color scratchCyan = AppColorsExtension.lightScratchCyan;
  static const Color scratchWhite = AppColorsExtension.lightScratchWhite;
  static const Color scratchRed = AppColorsExtension.lightScratchRed;
  static const Color scratchBorder = AppColorsExtension.lightScratchBorder;

  // Stats Heatmap Levels
  static const Color heatmapL1Light = AppColorsExtension.lightHeatmapL1;
  static const Color heatmapL1Dark = AppColorsExtension.darkHeatmapL1;
  static const Color heatmapL2Light = AppColorsExtension.lightHeatmapL2;
  static const Color heatmapL2Dark = AppColorsExtension.darkHeatmapL2;
  static const Color heatmapL3Light = AppColorsExtension.lightHeatmapL3;
  static const Color heatmapL3Dark = AppColorsExtension.darkHeatmapL3;
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
  static const double navIndicatorPillWidth = 64.0;
  static const double navIndicatorPillHeight = 32.0;

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
  static const double bottomSheetClearance = 240.0;

  // Interactive buttons
  static const double ratingButtonMinHeight = 48.0;
  static const double audioButtonSize = 28.0;
  static const double optionCircleSize = 28.0;
  static const double speedDialFabSize = 56.0;
  static const double speedDialOptionSize = 44.0;
  static const double touchTargetMin = 44.0;
  static const double filterChipHeight = 32.0;
  static const double buttonHeightStandard = 42.0;
  static const double fabMobileSize = 52.0;

  // Sidebars & Panes
  static const double noteEditorSidebarWidth = 340.0;
  static const double grammarTocSidebarWidth = 320.0;
  static const double browserDetailPaneWidth = 420.0;

  // Search & Toolbars
  static const double searchToolbarHeight = 38.0;

  // Component Metrics
  static const double cardThumbnailSize = 52.0;
  static const double summaryIconContainerSize = 64.0;
  static const double legendColorDotSize = 10.0;
  static const double statsForecastChartHeight = 128.0;
  static const double toastSpinnerSize = 14.0;
}

/// Flanki Standard Animation Durations.
abstract final class AppDurations {
  static const Duration quick = Duration(milliseconds: 100);
  static const Duration short = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration switchSlide = Duration(milliseconds: 220);
  static const Duration modal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration snap = Duration(milliseconds: 320);
  static const Duration shake = Duration(milliseconds: 360);
  static const Duration long = Duration(milliseconds: 500);
  static const Duration celebration = Duration(milliseconds: 600);
  static const Duration celebrationBounce = Duration(milliseconds: 650);

  // Time-based intervals & calendar offsets
  static const Duration second1 = Duration(seconds: 1);
  static const Duration day1 = Duration(days: 1);
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

/// Standardized [ValueKey] instances and key generators for widget trees and testing.
abstract final class AppWidgetKeys {
  static const ValueKey<String> ratingBar = ValueKey('rating_bar');
  static const ValueKey<String> flipButton = ValueKey('flip_button');

  static ValueKey<String> card(String? id) => ValueKey('card_${id ?? 'none'}');
  static ValueKey<String> deck(String id) => ValueKey('deck_$id');
  static ValueKey<String> deckGroup(String key) => ValueKey('group_$key');
  static ValueKey<String> licensePkg(String pkg) => ValueKey('pkg_$pkg');
  static ValueKey<String> explanationSheet(String id) =>
      ValueKey('explanation_sheet_$id');
}

/// Centralized UI marker symbols and emojis.
abstract final class AppSymbols {
  static const String markCorrect = '✅ ';
  static const String markIncorrect = '❌ ';
}
