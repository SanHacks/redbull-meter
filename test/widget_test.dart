// This is a basic Flutter widget test for the Red Bull Meter app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:redbull_meter/main.dart';

void main() {
  testWidgets('Red Bull Meter app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RedBullMeterApp());

    // Verify that the app title is displayed
    expect(find.text('Red Bull Meter'), findsOneWidget);
    
    // Verify that the app bar has the correct background color
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, const Color(0xFFFF0000)); // Red Bull red
  });
}
