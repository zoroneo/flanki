import 'package:flutter/material.dart';

/// Extension chứa toàn bộ Semantic Color Tokens của Flanki,
/// hỗ trợ cấu hình động riêng biệt cho Light Theme & Dark Theme
/// với hiệu ứng lerp chuyển đổi mượt mà.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Review Ratings (FSRS & SM-2)
  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;

  // Status & Highlights
  final Color streakFlame;
  final Color success;
  final Color successDark;
  final Color warning;
  final Color error;
  final Color info;

  // Custom Study & Cram
  final Color cramAmber;
  final Color cramAmberBg;

  // Accents & Domain Colors
  final Color accentCyan;
  final Color accentPurple;
  final Color accentBlue;
  final Color accentOrange;

  // Card Flags (Anki Compatible)
  final Color flagRed;
  final Color flagOrange;
  final Color flagGreen;
  final Color flagBlue;
  final Color flagPink;
  final Color flagTurquoise;
  final Color flagPurple;

  // Scratchpad Drawing Palette
  final Color scratchAmber;
  final Color scratchCyan;
  final Color scratchWhite;
  final Color scratchRed;
  final Color scratchBorder;

  // Stats Heatmap Levels
  final Color heatmapL1;
  final Color heatmapL2;
  final Color heatmapL3;

  // Underlying static const tokens for Light Theme
  static const Color lightRatingAgain = Color(0xFFE53935);
  static const Color lightRatingHard = Color(0xFFF57C00);
  static const Color lightRatingGood = Color(0xFF1E88E5);
  static const Color lightRatingEasy = Color(0xFF43A047);
  static const Color lightStreakFlame = Color(0xFFFF5722);
  static const Color lightSuccess = Color(0xFF4CAF50);
  static const Color lightSuccessDark = Color(0xFF388E3C);
  static const Color lightWarning = Color(0xFFFF9800);
  static const Color lightError = Color(0xFFF44336);
  static const Color lightInfo = Color(0xFF2196F3);
  static const Color lightCramAmber = Color(0xFFFFB300);
  static const Color lightCramAmberBg = Color(0x26FFB300);
  static const Color lightAccentCyan = Color(0xFF00BCD4);
  static const Color lightAccentPurple = Color(0xFF8E24AA);
  static const Color lightAccentBlue = Color(0xFF1E88E5);
  static const Color lightAccentOrange = Color(0xFFF57C00);
  static const Color lightFlagRed = Color(0xFFE53935);
  static const Color lightFlagOrange = Color(0xFFF57C00);
  static const Color lightFlagGreen = Color(0xFF43A047);
  static const Color lightFlagBlue = Color(0xFF1E88E5);
  static const Color lightFlagPink = Color(0xFFE91E63);
  static const Color lightFlagTurquoise = Color(0xFF00BCD4);
  static const Color lightFlagPurple = Color(0xFF8E24AA);
  static const Color lightScratchAmber = Color(0xFFFFE082);
  static const Color lightScratchCyan = Color(0xFF80DEEA);
  static const Color lightScratchWhite = Color(0xFFFFFFFF);
  static const Color lightScratchRed = Color(0xFFEF5350);
  static const Color lightScratchBorder = Color(0x42000000);
  static const Color lightHeatmapL1 = Color(0xFFA5D6A7);
  static const Color lightHeatmapL2 = Color(0xFF4CAF50);
  static const Color lightHeatmapL3 = Color(0xFF2E7D32);

  // Underlying static const tokens for Dark Theme
  static const Color darkRatingAgain = Color(0xFFF87171);
  static const Color darkRatingHard = Color(0xFFFB923C);
  static const Color darkRatingGood = Color(0xFF60A5FA);
  static const Color darkRatingEasy = Color(0xFF34D399);
  static const Color darkStreakFlame = Color(0xFFFF7043);
  static const Color darkSuccess = Color(0xFF22C55E);
  static const Color darkSuccessDark = Color(0xFF4ADE80);
  static const Color darkWarning = Color(0xFFFB923C);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkInfo = Color(0xFF38BDF8);
  static const Color darkCramAmber = Color(0xFFFBBF24);
  static const Color darkCramAmberBg = Color(0x26FBBF24);
  static const Color darkAccentCyan = Color(0xFF22D3EE);
  static const Color darkAccentPurple = Color(0xFFC084FC);
  static const Color darkAccentBlue = Color(0xFF60A5FA);
  static const Color darkAccentOrange = Color(0xFFFB923C);
  static const Color darkFlagRed = Color(0xFFF87171);
  static const Color darkFlagOrange = Color(0xFFFB923C);
  static const Color darkFlagGreen = Color(0xFF34D399);
  static const Color darkFlagBlue = Color(0xFF60A5FA);
  static const Color darkFlagPink = Color(0xFFF472B6);
  static const Color darkFlagTurquoise = Color(0xFF22D3EE);
  static const Color darkFlagPurple = Color(0xFFC084FC);
  static const Color darkScratchAmber = Color(0xFFFFE082);
  static const Color darkScratchCyan = Color(0xFF80DEEA);
  static const Color darkScratchWhite = Color(0xFFF1F5F9);
  static const Color darkScratchRed = Color(0xFFEF5350);
  static const Color darkScratchBorder = Color(0x33FFFFFF);
  static const Color darkHeatmapL1 = Color(0xFF1B5E20);
  static const Color darkHeatmapL2 = Color(0xFF388E3C);
  static const Color darkHeatmapL3 = Color(0xFF66BB6A);

  const AppColorsExtension({
    required this.ratingAgain,
    required this.ratingHard,
    required this.ratingGood,
    required this.ratingEasy,
    required this.streakFlame,
    required this.success,
    required this.successDark,
    required this.warning,
    required this.error,
    required this.info,
    required this.cramAmber,
    required this.cramAmberBg,
    required this.accentCyan,
    required this.accentPurple,
    required this.accentBlue,
    required this.accentOrange,
    required this.flagRed,
    required this.flagOrange,
    required this.flagGreen,
    required this.flagBlue,
    required this.flagPink,
    required this.flagTurquoise,
    required this.flagPurple,
    required this.scratchAmber,
    required this.scratchCyan,
    required this.scratchWhite,
    required this.scratchRed,
    required this.scratchBorder,
    required this.heatmapL1,
    required this.heatmapL2,
    required this.heatmapL3,
  });

  /// Preset màu chuẩn cho Light Theme
  static const light = AppColorsExtension(
    ratingAgain: lightRatingAgain,
    ratingHard: lightRatingHard,
    ratingGood: lightRatingGood,
    ratingEasy: lightRatingEasy,
    streakFlame: lightStreakFlame,
    success: lightSuccess,
    successDark: lightSuccessDark,
    warning: lightWarning,
    error: lightError,
    info: lightInfo,
    cramAmber: lightCramAmber,
    cramAmberBg: lightCramAmberBg,
    accentCyan: lightAccentCyan,
    accentPurple: lightAccentPurple,
    accentBlue: lightAccentBlue,
    accentOrange: lightAccentOrange,
    flagRed: lightFlagRed,
    flagOrange: lightFlagOrange,
    flagGreen: lightFlagGreen,
    flagBlue: lightFlagBlue,
    flagPink: lightFlagPink,
    flagTurquoise: lightFlagTurquoise,
    flagPurple: lightFlagPurple,
    scratchAmber: lightScratchAmber,
    scratchCyan: lightScratchCyan,
    scratchWhite: lightScratchWhite,
    scratchRed: lightScratchRed,
    scratchBorder: lightScratchBorder,
    heatmapL1: lightHeatmapL1,
    heatmapL2: lightHeatmapL2,
    heatmapL3: lightHeatmapL3,
  );

  /// Preset màu chuẩn cho Dark Theme
  static const dark = AppColorsExtension(
    ratingAgain: darkRatingAgain,
    ratingHard: darkRatingHard,
    ratingGood: darkRatingGood,
    ratingEasy: darkRatingEasy,
    streakFlame: darkStreakFlame,
    success: darkSuccess,
    successDark: darkSuccessDark,
    warning: darkWarning,
    error: darkError,
    info: darkInfo,
    cramAmber: darkCramAmber,
    cramAmberBg: darkCramAmberBg,
    accentCyan: darkAccentCyan,
    accentPurple: darkAccentPurple,
    accentBlue: darkAccentBlue,
    accentOrange: darkAccentOrange,
    flagRed: darkFlagRed,
    flagOrange: darkFlagOrange,
    flagGreen: darkFlagGreen,
    flagBlue: darkFlagBlue,
    flagPink: darkFlagPink,
    flagTurquoise: darkFlagTurquoise,
    flagPurple: darkFlagPurple,
    scratchAmber: darkScratchAmber,
    scratchCyan: darkScratchCyan,
    scratchWhite: darkScratchWhite,
    scratchRed: darkScratchRed,
    scratchBorder: darkScratchBorder,
    heatmapL1: darkHeatmapL1,
    heatmapL2: darkHeatmapL2,
    heatmapL3: darkHeatmapL3,
  );

  @override
  AppColorsExtension copyWith({
    Color? ratingAgain,
    Color? ratingHard,
    Color? ratingGood,
    Color? ratingEasy,
    Color? streakFlame,
    Color? success,
    Color? successDark,
    Color? warning,
    Color? error,
    Color? info,
    Color? cramAmber,
    Color? cramAmberBg,
    Color? accentCyan,
    Color? accentPurple,
    Color? accentBlue,
    Color? accentOrange,
    Color? flagRed,
    Color? flagOrange,
    Color? flagGreen,
    Color? flagBlue,
    Color? flagPink,
    Color? flagTurquoise,
    Color? flagPurple,
    Color? scratchAmber,
    Color? scratchCyan,
    Color? scratchWhite,
    Color? scratchRed,
    Color? scratchBorder,
    Color? heatmapL1,
    Color? heatmapL2,
    Color? heatmapL3,
  }) {
    return AppColorsExtension(
      ratingAgain: ratingAgain ?? this.ratingAgain,
      ratingHard: ratingHard ?? this.ratingHard,
      ratingGood: ratingGood ?? this.ratingGood,
      ratingEasy: ratingEasy ?? this.ratingEasy,
      streakFlame: streakFlame ?? this.streakFlame,
      success: success ?? this.success,
      successDark: successDark ?? this.successDark,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      cramAmber: cramAmber ?? this.cramAmber,
      cramAmberBg: cramAmberBg ?? this.cramAmberBg,
      accentCyan: accentCyan ?? this.accentCyan,
      accentPurple: accentPurple ?? this.accentPurple,
      accentBlue: accentBlue ?? this.accentBlue,
      accentOrange: accentOrange ?? this.accentOrange,
      flagRed: flagRed ?? this.flagRed,
      flagOrange: flagOrange ?? this.flagOrange,
      flagGreen: flagGreen ?? this.flagGreen,
      flagBlue: flagBlue ?? this.flagBlue,
      flagPink: flagPink ?? this.flagPink,
      flagTurquoise: flagTurquoise ?? this.flagTurquoise,
      flagPurple: flagPurple ?? this.flagPurple,
      scratchAmber: scratchAmber ?? this.scratchAmber,
      scratchCyan: scratchCyan ?? this.scratchCyan,
      scratchWhite: scratchWhite ?? this.scratchWhite,
      scratchRed: scratchRed ?? this.scratchRed,
      scratchBorder: scratchBorder ?? this.scratchBorder,
      heatmapL1: heatmapL1 ?? this.heatmapL1,
      heatmapL2: heatmapL2 ?? this.heatmapL2,
      heatmapL3: heatmapL3 ?? this.heatmapL3,
    );
  }

  @override
  AppColorsExtension lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      ratingAgain: Color.lerp(ratingAgain, other.ratingAgain, t)!,
      ratingHard: Color.lerp(ratingHard, other.ratingHard, t)!,
      ratingGood: Color.lerp(ratingGood, other.ratingGood, t)!,
      ratingEasy: Color.lerp(ratingEasy, other.ratingEasy, t)!,
      streakFlame: Color.lerp(streakFlame, other.streakFlame, t)!,
      success: Color.lerp(success, other.success, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      cramAmber: Color.lerp(cramAmber, other.cramAmber, t)!,
      cramAmberBg: Color.lerp(cramAmberBg, other.cramAmberBg, t)!,
      accentCyan: Color.lerp(accentCyan, other.accentCyan, t)!,
      accentPurple: Color.lerp(accentPurple, other.accentPurple, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      flagRed: Color.lerp(flagRed, other.flagRed, t)!,
      flagOrange: Color.lerp(flagOrange, other.flagOrange, t)!,
      flagGreen: Color.lerp(flagGreen, other.flagGreen, t)!,
      flagBlue: Color.lerp(flagBlue, other.flagBlue, t)!,
      flagPink: Color.lerp(flagPink, other.flagPink, t)!,
      flagTurquoise: Color.lerp(flagTurquoise, other.flagTurquoise, t)!,
      flagPurple: Color.lerp(flagPurple, other.flagPurple, t)!,
      scratchAmber: Color.lerp(scratchAmber, other.scratchAmber, t)!,
      scratchCyan: Color.lerp(scratchCyan, other.scratchCyan, t)!,
      scratchWhite: Color.lerp(scratchWhite, other.scratchWhite, t)!,
      scratchRed: Color.lerp(scratchRed, other.scratchRed, t)!,
      scratchBorder: Color.lerp(scratchBorder, other.scratchBorder, t)!,
      heatmapL1: Color.lerp(heatmapL1, other.heatmapL1, t)!,
      heatmapL2: Color.lerp(heatmapL2, other.heatmapL2, t)!,
      heatmapL3: Color.lerp(heatmapL3, other.heatmapL3, t)!,
    );
  }
}

/// Tiện ích lấy màu nhanh từ [BuildContext]
extension AppThemeColorsExtension on BuildContext {
  /// Lấy semantic colors tương ứng với theme hiện tại.
  /// Tự động fallback sang [AppColorsExtension.light] nếu chưa được gắn vào Theme tree.
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
