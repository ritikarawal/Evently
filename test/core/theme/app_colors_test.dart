import 'package:event_planner/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('getBackground returns light background in light mode', () {
      expect(AppColors.getBackground(Brightness.light), AppColors.background);
    });

    test('getBackground returns dark background in dark mode', () {
      expect(
        AppColors.getBackground(Brightness.dark),
        AppColors.darkBackground,
      );
    });

    test('getTextPrimary returns dark text in dark mode', () {
      expect(
        AppColors.getTextPrimary(Brightness.dark),
        AppColors.darkTextPrimary,
      );
    });
  });
}
