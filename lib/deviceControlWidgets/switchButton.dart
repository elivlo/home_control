import 'package:flutter/material.dart';
import 'package:home_control/communication/sonoffMinFirmware.dart';
import 'package:home_control/communication/tasmota.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';

class SimpleSwitch extends DeviceControl {
  SimpleSwitch({Key key, String name, hostname, this.tasmota}) : super(key: key, name: name, hostname: hostname);

  final bool tasmota;

  @override
  SwitchButtonState createState() {
    return SwitchButtonState();
  }

  @override
  String getDeviceName() {
    return "Simple Switch";
  }
}

class SwitchButtonState extends State<SimpleSwitch> {
  bool state = false;

  getState(bool s) {
    return s ? "On" : "Off";
  }

  @override
  Widget build(BuildContext context) {
    var server;
    if (widget.tasmota) {
      server = TasmotaHTTPConnector(widget.hostname);
    } else {
      server = SonoffMinFirmware(widget.hostname, 80);
    }

    _makeRequest(bool b) async {
      var resp = await server.setState(b);
      setState(() {
        if (resp != null) {
          state = resp;
        }
      });
    }

    return Container(
        padding: const EdgeInsets.only(bottom: 20),
        height: 67,
        width: 500,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                    getState(state),
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  )
                ],
              ),
            ),
            Switch(
              value: state,
              activeColor: Colors.amber,
              onChanged: _makeRequest,
            ),
          ],
        )
    );
  }
}

class SimpleSwitchConfig extends DeviceConfig {
  SimpleSwitchConfig({Key key, addItem}) : super(key: key, addItem: addItem);

  @override
  SwitchButtonConfigState createState() => new SwitchButtonConfigState();

  @override
  void clearFields() {
    name.clear();
    hostname.clear();
  }
}

class SwitchButtonConfigState extends State<SimpleSwitchConfig> {
  final _formKey = GlobalKey<FormState>();
  bool _tasmota = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(5),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Simple Switch:",
              style: TextStyle(
                  fontWeight: FontWeight.w700
              ),
            ),
            TextFormField(
              controller: widget.name,
              decoration: const InputDecoration(
                hintText: "Device name",
              ),
              validator: widget.validateName,
            ),
            TextFormField(
              controller: widget.hostname,
              decoration: const InputDecoration(
                  hintText: "Hostname / IP"
              ),
              validator: widget.validateHostname,
            ),
            Row(
              children: [
                Text("Tasmota:"),
                Switch(
                  value: _tasmota,
                  activeColor: Colors.amber,
                  onChanged: (bool b){
                    setState(() {
                      _tasmota = b;
                    });
                  },
                ),
              ],
            ),
            FloatingActionButton(
              child: Icon(Icons.check),
              elevation: 3.0,
              onPressed: () {
                if (_formKey.currentState.validate()){
                  widget.addItem(SimpleSwitch(key: UniqueKey(), name: widget.name.text, hostname: widget.hostname.text, tasmota: _tasmota));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      )
    );
  }
}
