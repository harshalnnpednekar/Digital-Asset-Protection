import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemeColors {
  final bool isDark;
  const AppThemeColors({required this.isDark});

  Color get bgPrimary     => isDark ? AppColors.darkBgPrimary     : AppColors.lightBgPrimary;
  Color get bgSecondary   => isDark ? AppColors.darkBgSecondary   : AppColors.lightBgSecondary;
  Color get bgTertiary    => isDark ? AppColors.darkBgTertiary    : AppColors.lightBgTertiary;
  Color get bgSurface     => isDark ? AppColors.darkBgSurface     : AppColors.lightBgSurface;
  Color get bgOverlay     => isDark ? AppColors.darkBgOverlay     : AppColors.lightBgOverlay;
  Color get borderDefault => isDark ? AppColors.darkBorderDefault : AppColors.lightBorderDefault;
  Color get borderSubtle  => isDark ? AppColors.darkBorderSubtle  : AppColors.lightBorderSubtle;
  Color get borderFocus   => isDark ? AppColors.darkBorderFocus   : AppColors.lightBorderFocus;
  Color get textPrimary   => isDark ? AppColors.darkTextPrimary   : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted     => isDark ? AppColors.darkTextMuted     : AppColors.lightTextMuted;
  Color get accentBlue    => isDark ? AppColors.darkAccentBlue    : AppColors.lightAccentBlue;
  Color get accentBlueDim => isDark ? AppColors.darkAccentBlueDim : AppColors.lightAccentBlueDim;

  // Brand colors — same in both themes
  Color get accentAmber      => AppColors.accentAmber;
  Color get accentAmberDim   => AppColors.accentAmberDim;
  Color get accentCrimson    => AppColors.accentCrimson;
  Color get accentCrimsonDim => AppColors.accentCrimsonDim;
  Color get accentGreen      => AppColors.accentGreen;
  Color get accentGreenDim   => AppColors.accentGreenDim;
  Color get accentPurple     => AppColors.accentPurple;
  Color get textOnAmber      => AppColors.textOnAmber;

  // Scanline texture color
  Color get scanlineColor => isDark
    ? const Color(0xFF141820)
    : const Color(0xFFF1F5F9);

  // Card shadow — none in dark, cool diffuse shadow in light
  List<BoxShadow> get cardShadow => isDark
    ? []
    : [BoxShadow(
        color: const Color(0xFF64748B).withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 4),
      )];

  BoxDecoration cardDecoration({Color? borderColor, double borderWidth = 1}) =>
    BoxDecoration(
      color: bgSurface,
      border: Border.all(color: borderColor ?? borderDefault, width: borderWidth),
      boxShadow: cardShadow,
    );
}

extension ThemeColorsX on BuildContext {
  AppThemeColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return AppThemeColors(isDark: isDark);
  }
}
