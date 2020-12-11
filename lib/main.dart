import 'package:flutter/material.dart';
import 'package:home_control/MainTabWidget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Control',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MainTabs(),
    );
  }
}