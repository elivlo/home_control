import 'package:flutter/material.dart';
import 'package:home_control/main_tab_widget.dart';
import 'package:home_control/communication/sonoff_min_firmware.dart';
import 'package:home_control/communication/tasmota.dart';
import 'package:home_control/deviceControlWidgets/device_template.dart';

// SimpleSwitch Widget to use with Tasmota (Sonoff Basic) when only on or off is needed
// Also for use with my MinSonoffBasicFirmware
class SimpleSwitch extends DeviceControl {
  static const deviceType = "SimpleSwitch";
  static const deviceLabel = "Switch";

  const SimpleSwitch({
    required Key key,
    required data,
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
    if (widget.data.config?["tasmota"]) {
      server = TasmotaHTTPConnector(widget.data.hostname);
    } else {
      server = SonoffMinFirmware(widget.data.hostname, 80);
    }
  }

  @override
  void pollDeviceStatus() async {
    if (server != null) {
      var resp = await server?.getStateBool(1);
      if (mounted) {
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
    super.build(context);
    final HomeController? h = HomeController.of(context);

    makeRequest(bool b) async {
      var resp = await server?.setStateBool(1, b);
      setState(() {
        if (resp != null) {
          state = resp;
        }
      });
    }

    return ExpansionTile(
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
                    style: const TextStyle(
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
            const Expanded(
              child: Text("Edit"),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {}, // TODO
            )
          ],
        ),
        Row(
          children: [
            const Expanded(
              child: Text("Delete"),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                h?.removeItem(widget.data.page, widget);
              },
            )
          ],
        )
      ],
    );
  }
}

// SimpleSwitchConfig to use with Tasmota (Sonoff Basic) when only on or off is needed
// Also for use with my MinSonoffBasicFirmware
class SimpleSwitchConfig extends DeviceConfig {
  SimpleSwitchConfig({@required page}) : super(page: page);
  bool _tasmota = false;

  @override
  void createDeviceControl(BuildContext context, String name, String hostname) {
    var data = DeviceData(
        name, hostname, page, {"tasmota": _tasmota}, SimpleSwitch.deviceType);
    Navigator.pop(
        context,
        SimpleSwitch(
          key: UniqueKey(),
          data: data,
        ));
  }

  @override
  Widget customConfigWidgets(void Function(void Function() fn) setState) {
    return Row(
      children: [
        const Text("Tasmota:"),
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
    );
  }
}
