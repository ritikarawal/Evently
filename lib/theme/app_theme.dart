import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: AppColors.background,

    fontFamily: 'OpenSans',

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      background: AppColors.background,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: AppTextStyles.appBarTitle,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        shape: const StadiumBorder(),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.navBackground,
      selectedItemColor: AppColors.navSelected,
      unselectedItemColor: AppColors.navUnselected,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
    ),

    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 4,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
