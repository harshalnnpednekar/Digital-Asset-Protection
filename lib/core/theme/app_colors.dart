import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds — layered dark system
  static const Color bgPrimary       = Color(0xFF0A0C10);  // deepest layer
  static const Color bgSecondary     = Color(0xFF111318);  // sidebar, panels
  static const Color bgTertiary      = Color(0xFF1A1E27);  // cards, elevated
  static const Color bgSurface       = Color(0xFF1E2330);  // card surfaces
  static const Color bgOverlay       = Color(0xFF242838);  // hover states

  // Borders
  static const Color borderDefault   = Color(0xFF2A3040);
  static const Color borderSubtle    = Color(0xFF1E2535);
  static const Color borderFocus     = Color(0xFF00D4FF);

  // Accent — Primary: Amber/Gold (alerts, CTAs, selection)
  static const Color accentAmber     = Color(0xFFF0A500);
  static const Color accentAmberDim  = Color(0x26F0A500);  // 15% opacity

  // Accent — Info: Ice Blue (data, links, status)
  static const Color accentBlue      = Color(0xFF00D4FF);
  static const Color accentBlueDim   = Color(0x1A00D4FF);  // 10% opacity

  // Accent — Threat: Crimson (piracy, danger, warnings)
  static const Color accentCrimson   = Color(0xFFFF2D55);
  static const Color accentCrimsonDim= Color(0x26FF2D55);  // 15% opacity

  // Accent — Safe: Green (confirmed safe, vaulted, online)
  static const Color accentGreen     = Color(0xFF00E676);
  static const Color accentGreenDim  = Color(0x1A00E676);  // 10% opacity

  // Accent — Review: Purple (pending analysis)
  static const Color accentPurple    = Color(0xFFB388FF);
  static const Color accentPurpleDim = Color(0x1AB388FF);

  // Text
  static const Color textPrimary     = Color(0xFFEAEDF3);
  static const Color textSecondary   = Color(0xFF8892A4);
  static const Color textMuted       = Color(0xFF4A5568);
  static const Color textOnAmber     = Color(0xFF0A0C10);  // text on amber buttons
}
