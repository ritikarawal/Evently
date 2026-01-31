import 'package:event_planner/features/onboarding/presentation/pages/onboarding2_screen.dart';
import 'package:event_planner/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Should display welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen1())),
    );

    await tester.pump();

    Finder title = find.text('Welcome to Evently!');
    expect(title, findsOneWidget);

    Finder subtitle = find.text(' Plan Your Perfect Event');
    expect(subtitle, findsOneWidget);
  });

  testWidgets('Should have Skip button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen1())),
    );

    await tester.pump();

    Finder skipButton = find.text('Skip');
    expect(skipButton, findsOneWidget);
  });

  testWidgets('Should have Next button that navigates to Onboarding2Screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: OnboardingScreen1())),
    );

    await tester.pump();

    Finder nextButton = find.text('Next');
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    expect(find.byType(Onboarding2Screen), findsOneWidget);
  });
}
