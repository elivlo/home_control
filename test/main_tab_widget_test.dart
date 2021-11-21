import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_control/main_tab_widget.dart';

void main() {
  test("Test HomeController", () {
    final con = HomeController(
        pollingTime: 2,
        wifiConnection: true,
        addItem: (i, deviceControl) {},
        changePollingTimer: (i) {},
        removeItem: (i, deviceControl) {},
        child: const Text(""));
    expect(true, con.wifiConnection);
    expect(2, con.pollingTime);

    expect(false, con.updateShouldNotify(con));
  });

  testWidgets('Test Main Tabs', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(
        home: MainTabs(),
      ),
    ));

    expect(find.byType(AppBar), findsOneWidget);

    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.single_bed), findsOneWidget);
    expect(find.byIcon(Icons.house_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
  });
}
