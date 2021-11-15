import 'package:flutter/material.dart';
import 'package:home_control/MainTabWidget.dart';
import 'package:home_control/communication/sonoffMinFirmware.dart';
import 'package:home_control/communication/tasmota.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';

// SimpleSwitch Widget to use with Tasmota (Sonoff Basic) when only on or off is needed
// Also for use with my MinSonoffBasicFirmware
class SimpleSwitch extends DeviceControl {
  static const deviceType = "SimpleSwitch";
  static const deviceLabel = "Switch";

  SimpleSwitch({
    @required Key key,
    @required data,
  }) : super(key: key, data: data);

  @override
  SwitchButtonState createState() {
    return SwitchButtonState();
  }
}

class SwitchButtonState extends DeviceControlState<SimpleSwitch> {
  bool state = false;

  getState(bool s) {
    return s ? "On" : "Off";
  }

  @override
  void setupCommunicationHandler() {
    if (widget.data.config["tasmota"]) {
      server = TasmotaHTTPConnector(widget.data.hostname);
    } else {
      server = SonoffMinFirmware(widget.data.hostname, 80);
    }
  }

  @override
  void pollDeviceStatus() async {
    if (server != null) {
      var resp = await server.getStateBool(1);
      if (this.mounted) {
        setState(() {
          if (resp != null) {
            state = resp;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController h = HomeController.of(context);

    makeRequest(bool b) async {
      var resp = await server.setStateBool(1, b);
      setState(() {
        if (resp != null) {
          state = resp;
        }
      });
    }

    return Container(
        child: ExpansionTile(
      childrenPadding:
          const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.data.name,
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
          Switch.adaptive(
            value: state,
            activeColor: Colors.amber,
            onChanged: makeRequest,
          ),
        ],
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Edit"),
            ),
            IconButton(
              icon: Icon(Icons.settings),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Text("Delete"),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                h.removeItem(widget.data.page, this.widget);
              },
            )
          ],
        )
      ],
    ));
  }
}

// SimpleSwitchConfig to use with Tasmota (Sonoff Basic) when only on or off is needed
// Also for use with my MinSonoffBasicFirmware
class SimpleSwitchConfig extends DeviceConfig {
  SimpleSwitchConfig({Key key, @required page}) : super(key: key, page: page);

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
                style: TextStyle(fontWeight: FontWeight.w700),
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
                decoration: const InputDecoration(hintText: "Hostname / IP"),
                validator: widget.validateHostname,
              ),
              Row(
                children: [
                  Text("Tasmota:"),
                  Switch.adaptive(
                    value: _tasmota,
                    activeColor: Colors.amber,
                    onChanged: (bool b) {
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
                  if (_formKey.currentState.validate()) {
                    Map<String, dynamic> conf = new Map();
                    conf["tasmota"] = _tasmota;
                    var data = DeviceData(
                        widget.name.text,
                        widget.hostname.text,
                        widget.page,
                        conf,
                        SimpleSwitch.deviceType);
                    Navigator.pop(
                        context, SimpleSwitch(key: UniqueKey(), data: data));
                  }
                },
              ),
            ],
          ),
        ));
  }
}
