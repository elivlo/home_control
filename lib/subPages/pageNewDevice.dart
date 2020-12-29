import 'package:flutter/material.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';
import 'package:home_control/deviceControlWidgets/switchButton.dart';

// NewDevicePage Widget shown when clicked on FloatingActionButton
class NewDevicePage extends StatefulWidget {
  NewDevicePage(this.page);

  final int page;

  @override
  _NewDevicePage createState() => _NewDevicePage();
}

class _NewDevicePage extends State<NewDevicePage> {
  String selDeviceName;
  Map<String, DeviceConfig> devs;
  DeviceConfig config;

  @override
  void initState() {
    selDeviceName = SimpleSwitch().deviceNAME;
    devs = {
      SimpleSwitch().deviceNAME: SimpleSwitchConfig(page: widget.page)
    };
    config = devs[SimpleSwitch().deviceNAME];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add new device"),
      ),
      body: Center(
        child: Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selDeviceName,
                    onChanged: (String value) {
                      setState(() {
                        selDeviceName = value;
                        config = devs[value];
                        config.clearFields();
                      });
                      print(selDeviceName);
                    },
                    items: devs.keys.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                config
              ]
            )
          )
        ),
    );
  }

}
