import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_control/MainTabWidget.dart';

import 'package:home_control/main.dart';

void main() {
  testWidgets('Test Main Tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MediaQuery(data: MediaQueryData(), child: MaterialApp(home: MainTabs(),),));

    expect(find.byType(AppBar), findsOneWidget);

    // Verify that our counter starts at 0.
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.single_bed), findsOneWidget);
    expect(find.byIcon(Icons.house_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

  });
}