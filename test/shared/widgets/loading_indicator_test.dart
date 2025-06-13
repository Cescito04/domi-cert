import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:domicert/shared/widgets/loading/loading_indicator.dart';

void main() {
  testWidgets('LoadingIndicator displays correctly',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(
            message: 'Loading...',
          ),
        ),
      ),
    );

    // Verify that the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });

  testWidgets('LoadingIndicator without message', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(),
        ),
      ),
    );

    // Verify that only the loading indicator is displayed
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('LoadingIndicator with custom color',
      (WidgetTester tester) async {
    const customColor = Colors.red;

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoadingIndicator(
            color: customColor,
          ),
        ),
      ),
    );

    // Verify that the loading indicator has the custom color
    final CircularProgressIndicator indicator = tester.widget(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.color, equals(customColor));
  });
}
