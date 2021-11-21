import 'package:flutter/material.dart';
import 'package:home_control/main_tab_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Control',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const MainTabs(),
    );
  }
}
