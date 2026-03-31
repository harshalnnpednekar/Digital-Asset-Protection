import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // IBM Plex Mono — for all technical/data text, headings, labels
  static TextStyle mono({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) => GoogleFonts.ibmPlexMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );

  // DM Sans — for all body text, descriptions, form inputs
  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0,
  }) => GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
  );

  // Pre-defined named styles
  static final screenTitle = mono(size: 22, weight: FontWeight.w700, color: AppColors.textPrimary);
  static final screenSubtitle = sans(size: 13, color: AppColors.textSecondary);
  static final sectionLabel = mono(size: 11, weight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 2.5);
  static final kpiNumber = mono(size: 34, weight: FontWeight.w700, color: AppColors.textPrimary);
  static final bodyMedium = sans(size: 14, weight: FontWeight.w500, color: AppColors.textPrimary);
  static final bodyRegular = sans(size: 14, color: AppColors.textSecondary);
  static final caption = mono(size: 11, color: AppColors.textMuted);
  static final navLabel = sans(size: 13, weight: FontWeight.w500, color: AppColors.textSecondary);
  static final buttonLabel = mono(size: 13, weight: FontWeight.w700, color: AppColors.textOnAmber, letterSpacing: 1.0);
  static final tagText = mono(size: 10, weight: FontWeight.w600, letterSpacing: 1.5);
}
