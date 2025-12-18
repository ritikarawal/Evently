import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: const Color(0xFFF8DCDC),

    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7F0F23)),

    fontFamily: 'OpenSans Bold',

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7F0F23),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
