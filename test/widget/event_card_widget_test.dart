import 'package:event_planner/widget/event_categories_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EventCard renders label and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventCard(
            icon: Icons.cake,
            label: 'Birthday',
            color: Colors.red,
            categoryKey: 'birthday',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Birthday'), findsOneWidget);
    expect(find.byIcon(Icons.cake), findsOneWidget);
  });

  testWidgets('EventCard tap triggers callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventCard(
            icon: Icons.cake,
            label: 'Birthday',
            color: Colors.red,
            categoryKey: 'birthday',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('EventCard contains InkWell for interactions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventCard(
            icon: Icons.cake,
            label: 'Birthday',
            color: Colors.red,
            categoryKey: 'birthday',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(InkWell), findsOneWidget);
  });
}
