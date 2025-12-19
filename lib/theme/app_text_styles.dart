import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // AppBar title
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Event card title
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Normal label text
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Large heading (Onboarding / Splash)
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );
}
