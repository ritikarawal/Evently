import 'package:event_planner/common/mysnackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget _host() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                showMySnackBar(context: context, message: 'Snack message');
              },
              child: const Text('Show'),
            );
          },
        ),
      ),
    );
  }

  testWidgets('showMySnackBar displays message', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('Show'));
    await tester.pump();

    expect(find.text('Snack message'), findsOneWidget);
  });

  testWidgets('showMySnackBar uses default green color', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.text('Show'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.green);
  });

  testWidgets('showMySnackBar applies custom color', (tester) async {
    const custom = Colors.purple;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showMySnackBar(
                    context: context,
                    message: 'Custom',
                    color: custom,
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, custom);
  });
}
