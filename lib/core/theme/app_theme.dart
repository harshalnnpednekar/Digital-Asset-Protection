import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    bgPrimary: AppColors.darkBgPrimary,
    bgSurface: AppColors.darkBgSurface,
    textPrimary: AppColors.darkTextPrimary,
    borderColor: AppColors.darkBorderDefault,
    fillColor: AppColors.darkBgPrimary,
    hintColor: AppColors.darkTextMuted,
    focusColor: AppColors.darkBorderFocus,
    accentBlue: AppColors.darkAccentBlue,
  );

  static ThemeData get light => _build(
    brightness: Brightness.light,
    bgPrimary: AppColors.lightBgPrimary,
    bgSurface: AppColors.lightBgSurface,
    textPrimary: AppColors.lightTextPrimary,
    borderColor: AppColors.lightBorderDefault,
    fillColor: AppColors.lightBgSurface,
    hintColor: AppColors.lightTextMuted,
    focusColor: AppColors.lightBorderFocus,
    accentBlue: AppColors.lightAccentBlue,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color bgPrimary,
    required Color bgSurface,
    required Color textPrimary,
    required Color borderColor,
    required Color fillColor,
    required Color hintColor,
    required Color focusColor,
    required Color accentBlue,
  }) =>
    ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accentAmber,
        onPrimary: AppColors.textOnAmber,
        secondary: accentBlue,
        onSecondary: Colors.white,
        error: AppColors.accentCrimson,
        onError: Colors.white,
        surface: bgSurface,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: bgSurface,
        elevation: brightness == Brightness.dark ? 0 : 2,
        shadowColor: brightness == Brightness.dark
          ? Colors.transparent
          : const Color(0xFF8B7D6B).withValues(alpha: 0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      dividerTheme: DividerThemeData(color: borderColor, thickness: 1, space: 0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        hintStyle: AppTextStyles.body(size: 13, color: hintColor),
      ),
      textTheme: GoogleFonts.interTextTheme(
        brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(borderColor),
        thickness: WidgetStateProperty.all(4),
        radius: Radius.zero,
      ),
    );
}
