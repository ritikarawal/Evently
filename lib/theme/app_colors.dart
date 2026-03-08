import 'package:flutter/material.dart';

class AppColors {
  // Light Mode - Backgrounds
  static const Color background = Color(0xFFF2E7EB);
  static const Color surface = Color(0xCCFFFFFF);

  // Dark Mode - Backgrounds
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);

  // Primary
  static const Color primary = Color(0xFF7F0F23);
  static const Color primaryLight = Color(0xFFF3C6CC);

  // Light Mode - Text
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF6D6D6D);

  // Dark Mode - Text
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  // Navigation Bar
  static const Color navBackground = Color(0xFF7F0F23);
  static const Color navSelected = Colors.white;
  static const Color navUnselected = Color(0x99FFFFFF);

  // Cards
  static const Color cardBackground = Color(0x66FFFFFF);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color cardShadow = Color(0x22000000);
  static const Color glassBorder = Color(0x80FFFFFF);
  static const Color glassHighlight = Color(0x99FFFFFF);

  // Borders
  static const Color border = Color(0xFFD9D9D9);
  static const Color darkBorder = Color(0xFF3A3A3A);

  static Color? get accent => null;

  // Helper methods for theme-aware colors
  static Color getBackground(Brightness brightness) {
    return brightness == Brightness.dark ? darkBackground : background;
  }

  static Color getSurface(Brightness brightness) {
    return brightness == Brightness.dark ? darkSurface : surface;
  }

  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextPrimary : textPrimary;
  }

  static Color getTextSecondary(Brightness brightness) {
    return brightness == Brightness.dark ? darkTextSecondary : textSecondary;
  }

  static Color getCardBackground(Brightness brightness) {
    return brightness == Brightness.dark ? darkCardBackground : cardBackground;
  }

  static Color getBorder(Brightness brightness) {
    return brightness == Brightness.dark ? darkBorder : border;
  }
}
