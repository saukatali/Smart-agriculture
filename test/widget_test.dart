import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrismart/main.dart';
import 'package:agrismart/screens/ai_insights_screen.dart';

void main() {
  testWidgets('AgriSmart smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriSmartApp());
    expect(find.byType(AgriSmartApp), findsOneWidget);
  });

  for (final width in [320.0, 360.0, 375.0, 390.0, 412.0]) {
    testWidgets('Insights Smart Selling Recommendation test at width $width',
        (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = Size(width, 844);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiInsightsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Smart Selling Recommendations'), findsOneWidget);
      expect(find.text('Hold Wheat Inventory for 14 Days'), findsOneWidget);
      expect(find.text('Route Roma Tomatoes to North Hub'), findsOneWidget);
      expect(find.text('88% Confidence'), findsOneWidget);
      expect(find.text('91% Confidence'), findsOneWidget);
      expect(find.text('Apply Strategy'), findsOneWidget);
      expect(find.text('Dispatch Route'), findsOneWidget);
    });
  }
}
