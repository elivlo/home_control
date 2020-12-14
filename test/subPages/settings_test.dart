import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_control/MainTabWidget.dart';
import 'package:home_control/subPages/settings.dart';

void main() {

  testWidgets('Test Settings Tab', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Settings settings = Settings();
    await tester.pumpWidget(MediaQuery(data: MediaQueryData(), child: MaterialApp(home: HomeController(null, null, false, 4, settings)),));

    expect(find.text("Polling Interval: 4"), findsOneWidget);
    expect(find.text("No Wifi connection: Polling inactive"), findsOneWidget);

  });
}