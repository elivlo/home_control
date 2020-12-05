import 'package:flutter/material.dart';

class NewDevicePage extends StatefulWidget {
  NewDevicePage(this.page);

  final int page;

  @override
  _NewDevicePage createState() => _NewDevicePage();
}

class _NewDevicePage extends State<NewDevicePage> {
  String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new device"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print(widget.page);
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
