import 'package:event_planner/widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Common Widgets', () {
    testWidgets('AuthToggle renders Sign Up and Log in labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthToggle(
              isLogin: true,
              onLoginTap: () {},
              onSignupTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets('AuthToggle login tab tap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthToggle(
              isLogin: true,
              onLoginTap: () => tapped = true,
              onSignupTap: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Log in'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AuthToggle sign up tab tap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthToggle(
              isLogin: true,
              onLoginTap: () {},
              onSignupTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AuthTextField renders provided label', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(label: 'Email', controller: controller),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('AuthTextField respects obscureText', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              label: 'Password',
              controller: controller,
              obscureText: true,
            ),
          ),
        ),
      );

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, isTrue);
    });

    testWidgets('PrimaryButton renders title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(title: 'Continue', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('PrimaryButton tap triggers callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              title: 'Continue',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AuthScreenWrapper shows child and scroll view', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [AuthScreenWrapper(child: Text('Wrapped Child'))],
            ),
          ),
        ),
      );

      expect(find.text('Wrapped Child'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
