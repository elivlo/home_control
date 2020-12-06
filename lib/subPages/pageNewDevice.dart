import 'package:flutter/material.dart';
import 'package:home_control/deviceControlWidgets/switchButton.dart';

class NewDevicePage extends StatefulWidget {
  NewDevicePage(this.page);

  final int page;

  @override
  _NewDevicePage createState() => _NewDevicePage();
}

String selDeviceName = 'Eins';
Map<String, Widget> dev = {
  "Eins": SwitchButtonConfig(),
  "Zwei": Text("z"),
  "Drei": Text("d")
};

class _NewDevicePage extends State<NewDevicePage> {
  _NewDevicePage() {
    column.add(
      DropdownButton<String>(
        isExpanded: true,
        value: selDeviceName,
        onChanged: (String value) {
          setState(() {
            selDeviceName = value;
            _showDevConfig(value);
          });
        },
        items: dev.keys.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      )
    );
    column.add(dev["Eins"]);
  }

  List<Widget> column = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new device"),
      ),
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(30),
            child: ListView.builder(
              itemCount: column.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Center(
                    child: column[index],
                  ),
                );
              },
            )
          )
        ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        elevation: 3.0,
        onPressed: () {
          print("add");
          Navigator.pop(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showDevConfig(String value){
    column[1] = (dev[value]);
  }
}
