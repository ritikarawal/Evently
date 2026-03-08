import 'package:event_planner/theme/app_colors.dart';
import 'package:event_planner/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> _pumpProbe(
    WidgetTester tester, {
    required Brightness brightness,
    required ValueSetter<BuildContext> onContext,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        home: Builder(
          builder: (context) {
            onContext(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  group('ThemeAwareColorsX', () {
    testWidgets('isDarkMode is false in light mode', (tester) async {
      late BuildContext ctx;
      await _pumpProbe(
        tester,
        brightness: Brightness.light,
        onContext: (c) => ctx = c,
      );
      expect(ctx.isDarkMode, isFalse);
    });

    testWidgets('isDarkMode is true in dark mode', (tester) async {
      late BuildContext ctx;
      await _pumpProbe(
        tester,
        brightness: Brightness.dark,
        onContext: (c) => ctx = c,
      );
      expect(ctx.isDarkMode, isTrue);
    });

    testWidgets('themedBackground uses light background', (tester) async {
      late BuildContext ctx;
      await _pumpProbe(
        tester,
        brightness: Brightness.light,
        onContext: (c) => ctx = c,
      );
      expect(ctx.themedBackground, AppColors.background);
    });

    testWidgets('themedBackground uses dark background', (tester) async {
      late BuildContext ctx;
      await _pumpProbe(
        tester,
        brightness: Brightness.dark,
        onContext: (c) => ctx = c,
      );
      expect(ctx.themedBackground, AppColors.darkBackground);
    });

    testWidgets('themedTextPrimary uses dark primary text', (tester) async {
      late BuildContext ctx;
      await _pumpProbe(
        tester,
        brightness: Brightness.dark,
        onContext: (c) => ctx = c,
      );
      expect(ctx.themedTextPrimary, AppColors.darkTextPrimary);
    });

    testWidgets('themedBorder uses light border', (tester) async {
      late BuildContext ctx;
      await _pumpProbe(
        tester,
        brightness: Brightness.light,
        onContext: (c) => ctx = c,
      );
      expect(ctx.themedBorder, AppColors.border);
    });
  });
}
