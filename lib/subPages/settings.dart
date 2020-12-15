import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import '../MainTabWidget.dart';

// Settings Widget shown in settings tab
class Settings extends StatefulWidget {
  static String owner = "Elias Floetzinger";
  static String gitproject = "https://github.com/elivlo/home_control";

  @override
  SettingsState createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {

  String info = "";

  @override
  void initState() {
    super.initState();
    getInfo();
  }

  void getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    info = packageInfo.appName + ": v" + packageInfo.version + " Build: " + packageInfo.buildNumber;
  }

  @override
  Widget build(BuildContext context) {
    final HomeController h = HomeController.of(context);

    return Container(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            Container(
              alignment: Alignment(0, 0),
              child: Text("Settings", textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              height: 40,
            ),
            Container(
              alignment: Alignment(0, 0),
              color: Colors.grey.shade200,
              child: Row(
                children: [
                  Expanded(
                    child: Text("Polling Interval: ", textAlign: TextAlign.center),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      initialValue: h.pollingTime.toString(),
                      decoration: const InputDecoration(
                        hintText: "Polling time in seconds",
                      ),
                      onChanged: (value){
                        h.changePollingTimer(int.parse(value));
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      autovalidateMode: AutovalidateMode.always,
                    )
                  ),
                ],
              ),
              height: 40,
            ),
            Container(
              alignment: Alignment(0, 0),
              child: Text(h.wifiConnection ? "Wifi connection: Polling active" : "No Wifi connection: Polling inactive", textAlign: TextAlign.center),
              height: 40,
            ),
            Container(
              alignment: Alignment(0, 0),
              color: Colors.grey.shade200,
              child: Text(info, textAlign: TextAlign.center),
              height: 40,
            ),
            Container(
              alignment: Alignment(0, 0),
              child: RichText(text: TextSpan(
                children: [
                  TextSpan(
                    text: Settings.owner + " - ",
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: Settings.gitproject,
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      _launchBrowser(Settings.gitproject);
                    }
                  )
                ]
              ),),
              height: 40,
            ),
          ],
        ),
    );
  }

  void _launchBrowser(String url) async {
    if (await canLaunch(url) != null) {
      await launch(url);
    }
  }
}