import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // OUTFIT — For Display, Headings, Numbers, and Brand Elements
  static TextStyle display({
    double size = 16,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 0,
    double? height,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) => GoogleFonts.outfit(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: fontStyle,
    shadows: shadows,
  );

  // INTER — For UI labels, body text, and general navigation
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
    double? height,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: fontStyle,
    shadows: shadows,
  );

  // Corporate Mono/Technical — Consistently using Inter/Outfit for all UI
  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double letterSpacing = 0,
    double? height,
    FontStyle? fontStyle,
    List<Shadow>? shadows,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: fontStyle,
    shadows: shadows,
  );

  // New Standardized Styles
  static TextStyle screenTitle = display(size: 26, weight: FontWeight.w700);
  static TextStyle screenSubtitle = body(size: 14, weight: FontWeight.w400);
  static TextStyle sectionHeading = display(size: 14, weight: FontWeight.w700, letterSpacing: 1.5);
  static TextStyle kpiLabel = display(size: 12, weight: FontWeight.w600, letterSpacing: 1.2);
  static TextStyle kpiNumber = display(size: 38, weight: FontWeight.w800, letterSpacing: -1.0);
  
  static TextStyle cardTitle = display(size: 15, weight: FontWeight.w700);
  static TextStyle cardBody = body(size: 13, weight: FontWeight.w500);
  
  static TextStyle navLabel = body(size: 13, weight: FontWeight.w600);
  static TextStyle buttonLabel = display(size: 14, weight: FontWeight.w700, letterSpacing: 0.5);
  
  // Legacy stubs (for quick migration)
  static TextStyle sans({double size = 14, FontWeight weight = FontWeight.w400, Color? color, double letterSpacing = 0, double? height}) 
    => body(size: size, weight: weight, color: color, letterSpacing: letterSpacing, height: height);
}
