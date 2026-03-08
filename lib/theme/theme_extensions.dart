import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeAwareColorsX on BuildContext {
  /// Get the current theme brightness
  Brightness get brightness {
    return Theme.of(this).brightness;
  }

  /// Check if dark mode is enabled
  bool get isDarkMode {
    return brightness == Brightness.dark;
  }

  /// Get background color based on current theme
  Color get themedBackground {
    return AppColors.getBackground(brightness);
  }

  /// Get surface color based on current theme
  Color get themedSurface {
    return AppColors.getSurface(brightness);
  }

  /// Get primary text color based on current theme
  Color get themedTextPrimary {
    return AppColors.getTextPrimary(brightness);
  }

  /// Get secondary text color based on current theme
  Color get themedTextSecondary {
    return AppColors.getTextSecondary(brightness);
  }

  /// Get card background color based on current theme
  Color get themedCardBackground {
    return AppColors.getCardBackground(brightness);
  }

  /// Get border color based on current theme
  Color get themedBorder {
    return AppColors.getBorder(brightness);
  }
}
