import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // AppBar title (Events)
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Event card title (Birthday, Wedding, etc.)
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

  // Small labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
}
