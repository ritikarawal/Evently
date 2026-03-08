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
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.appBarTitle,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xCC7F0F23),
      selectedItemColor: AppColors.navSelected,
      unselectedItemColor: AppColors.navUnselected,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shadowColor: AppColors.cardShadow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}

ThemeData getDarkApplicationTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: base.appBarTheme.copyWith(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
