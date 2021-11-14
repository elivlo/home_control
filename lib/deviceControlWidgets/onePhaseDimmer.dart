import 'package:flutter/material.dart';
import 'package:home_control/MainTabWidget.dart';
import 'package:sprintf/sprintf.dart';
import 'package:home_control/communication/tasmota.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';

// OnePhaseDimmer Widget to use with Tasmota e.g. a LED strip
class OnePhaseDimmer extends DeviceControl {
  OnePhaseDimmer({@required Key key, @required data})
      : super(key: key, data: data);
  static const deviceType = "One Phase Dimmer";

  @override
  OnePhaseDimmerState createState() {
    return OnePhaseDimmerState();
  }
}

class OnePhaseDimmerState extends DeviceControlState<OnePhaseDimmer> {
  double _sliderValue = 0;
  bool state = false;
  int dimm = 0;

  getStateString(bool s) {
    String state = s ? "On" : "Off";
    state += sprintf("\t%d%%", [dimm]);
    return state;
  }

  @override
  void setupCommunicationHandler() {
    server = TasmotaHTTPConnector(widget.data.hostname);
  }

  @override
  void pollDeviceStatus() async {
    if (server != null) {
      var s = await server.getStateBool(1);
      var d = await server.getDimmState(1);
      if (this.mounted) {
        setState(() {
          if (s != null) {
            state = s;
          }
          if (d != null) {
            dimm = d;
          }
        });
        if (d != null) {
          _sliderValue = d.toDouble();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeController h = HomeController.of(context);

    switchDimmer(bool b) async {
      var resp = await server.setStateBool(1, b);
      setState(() {
        if (resp != null) {
          state = resp;
        }
      });
    }

    dimmDimmer(int d) async {
      var resp = await server.setDimmState(1, d);
      setState(() {
        if (resp != null) {
          dimm = resp;
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
                  getStateString(state),
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
            onChanged: switchDimmer,
          ),
        ],
      ),
      children: [
        Slider(
            min: 0,
            max: 100,
            value: _sliderValue,
            onChanged: (double value) {
              setState(() {
                if (value.round() == 0) {
                  _sliderValue = 0.0;
                  switchDimmer(false);
                } else {
                  _sliderValue = value;
                  dimmDimmer(value.round());
                }
              });
            }),
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
class OnePhaseDimmerConfig extends DeviceConfig {
  OnePhaseDimmerConfig({Key key, @required page}) : super(key: key, page: page);

  @override
  OnePhaseDimmerConfigState createState() => new OnePhaseDimmerConfigState();

  @override
  void clearFields() {
    name.clear();
    hostname.clear();
  }
}

class OnePhaseDimmerConfigState extends State<OnePhaseDimmerConfig> {
  final _formKey = GlobalKey<FormState>();

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
                "One Phase Dimmer:",
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
              FloatingActionButton(
                child: Icon(Icons.check),
                elevation: 3.0,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    var data = DeviceData(
                        widget.name.text,
                        widget.hostname.text,
                        widget.page,
                        null,
                        OnePhaseDimmer.deviceType);
                    Navigator.pop(
                        context,
                        OnePhaseDimmer(
                          key: UniqueKey(),
                          data: data,
                        ));
                  }
                },
              ),
            ],
          ),
        ));
  }
}
