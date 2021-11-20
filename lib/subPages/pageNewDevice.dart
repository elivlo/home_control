import 'package:flutter/material.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';
import 'package:home_control/deviceControlWidgets/onePhaseDimmer.dart';
import 'package:home_control/deviceControlWidgets/switchButton.dart';
import 'package:string_validator/string_validator.dart';

// NewDevicePage Widget shown when clicked on FloatingActionButton
class NewDevicePage extends StatefulWidget {
  NewDevicePage(this.page);

  final int page;

  @override
  _NewDevicePage createState() => _NewDevicePage();
}

class _NewDevicePage extends State<NewDevicePage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  Map<String, DeviceConfig>? devs;
  DeviceConfig? config;

  var name = TextEditingController();
  var hostname = TextEditingController();

  @override
  void initState() {
    devs = {
      SimpleSwitch.deviceLabel: SimpleSwitchConfig(page: widget.page),
      OnePhaseDimmer.deviceLabel: OnePhaseDimmerConfig(page: widget.page)
    };
    config = devs![SimpleSwitch.deviceLabel];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add new device"),
        ),
        body: Container(
          child: Stepper(
            type: StepperType.vertical,
            physics: ScrollPhysics(),
            currentStep: _currentStep,
            onStepTapped: (step) => tapped(step),
            onStepContinue: continued,
            onStepCancel: cancel,
            elevation: 0,
            controlsBuilder: (BuildContext context,
                {onStepContinue, onStepCancel}) {
              return Row(
                children: [],
              );
            },
            steps: [
              Step(title: Text("Device Selector"), content: chipList()),
              Step(
                  title: Text("Device Settings"),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: name,
                          decoration: const InputDecoration(
                            hintText: "Device name",
                          ),
                          validator: _validateName,
                        ),
                        TextFormField(
                          controller: hostname,
                          decoration:
                              const InputDecoration(hintText: "Hostname / IP"),
                          validator: _validateHostname,
                        ),
                        config!.customConfigWidgets(setState)
                      ],
                    ),
                  ))
            ],
          ),
        ),
        floatingActionButton: _floatingButton(context));
  }

  tapped(int step) {
    if (step == 0) {
      setState(() => _currentStep = step);
    }
  }

  continued() {
    _currentStep < 1 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  Wrap chipList() {
    List<Widget> childs = [];
    devs?.forEach((key, value) {
      childs.add(_buildChip(key, value));
    });
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: childs,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      runAlignment: WrapAlignment.start,
    );
  }

  Widget _buildChip(String label, DeviceConfig conf) {
    return ActionChip(
      avatar: null,
      label: Text(
        label,
        style: TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
      ),
      backgroundColor: Colors.deepOrange,
      elevation: 2,
      padding: EdgeInsets.all(2),
      onPressed: () {
        config = conf;
        continued();
      },
    );
  }

  Widget? _floatingButton(BuildContext context) {
    if (_currentStep == 1) {
      return FloatingActionButton(
        child: Icon(Icons.check),
        elevation: 3.0,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            config?.createDeviceControl(context, name.text, hostname.text);
          }
        },
      );
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value!.isEmpty) {
      return "Please enter a name";
    }
    return null;
  }

  String? _validateHostname(String? value) {
    RegExp hostname = RegExp(
        r'^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$');

    if (value!.isEmpty) {
      return "Please enter a hostname";
    }
    if (!hostname.hasMatch(value)) {
      if (!isIP(value)) {
        return "Please enter a valid IP or hostname";
      }
      return null;
    }
    return null;
  }
}
