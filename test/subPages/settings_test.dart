import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_control/main_tab_widget.dart';
import 'package:home_control/subPages/settings.dart';

void main() {
  testWidgets('Test Settings Tab', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    Settings settings = const Settings();
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(),
      child: MaterialApp(
          home: Scaffold(
        body: HomeController(
            pollingTime: 4,
            wifiConnection: false,
            addItem: (i, deviceControl) {},
            changePollingTimer: (i) {},
            removeItem: (i, deviceControl) {},
            child: settings),
      )),
    ));

    expect(find.text("Polling Interval: "), findsOneWidget);
    expect(find.text("No Wifi connection: Polling inactive"), findsOneWidget);
  });
}
