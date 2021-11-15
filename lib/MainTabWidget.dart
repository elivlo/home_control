import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';
import 'package:home_control/deviceControlWidgets/onePhaseDimmer.dart';
import 'package:home_control/deviceControlWidgets/switchButton.dart';

import 'package:home_control/subPages/pageNewDevice.dart';
import 'package:home_control/subPages/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import 'package:sqflite/sqflite.dart';

// HomeController contains data and methods used by other child widgets
class HomeController extends InheritedWidget {
  final void Function(int page, DeviceControl d) addItem;
  final void Function(int page, DeviceControl d) removeItem;
  final void Function(int time) changePollingTimer;

  final bool wifiConnection;
  final int pollingTime;

  const HomeController({@required this.addItem, @required this.removeItem, @required this.changePollingTimer,
    @required this.wifiConnection, @required this.pollingTime, @required Widget child})
      : super(child: child);

  static HomeController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeController>();
  }

  @override
  bool updateShouldNotify(HomeController oldWidget) {
    return oldWidget.removeItem != removeItem || oldWidget.addItem != addItem
        || oldWidget.wifiConnection != wifiConnection || oldWidget.pollingTime != pollingTime;
  }
}

// MainTabs shows two Tabs for Devices and one settings tab
class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  
  int _pollingTime;
  bool _wifiConnection = true;
  var connection;

  List<DeviceControl> firstList = [];
  List<DeviceControl> secondList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _loadConfig();
    connection = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        result == ConnectivityResult.wifi ? _wifiConnection = true : _wifiConnection = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    connection.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.house_rounded),),
              Tab(icon: Icon(Icons.single_bed),),
              Tab(icon: Icon(Icons.settings),)
            ],
          ),
        ),
        body: HomeController(
          pollingTime: _pollingTime,
          wifiConnection: _wifiConnection,
          addItem: _addControlItem,
          removeItem: _removeControlItem,
          changePollingTimer: _changePollingTimer,
          child: TabBarView(
            controller: _tabController,
            children: [
              ReorderableListView(
                padding: const EdgeInsets.only(top: 10),
                children: firstList,
                onReorder: _reorderFirstList,
              ),
              ReorderableListView(
                padding: const EdgeInsets.only(top: 10),
                children: secondList,
                onReorder: _reorderSecondList,
              ),
              Settings(),
            ],
          ),
        ),
        floatingActionButton: _bottomButtons(),
      ),
    );


  }

  // _bottomButtons() returns FloatingButtons for adding Devices
  Widget _bottomButtons() {
    if (_tabController.index + 1 == _tabController.length) {
      return null;
    } else {
      return FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 3.0,
        mini: true,
        onPressed: () async {
          DeviceControl device = await Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) {
                return NewDevicePage(_tabController.index);
              }));
          if (device != null) {
            _addControlItem(device.data.page, device);
          }
        },
      );
    }
  }

  // _loadConfig() loads App Preferences
  void _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _pollingTime = prefs.getInt("polling_time");
    if (_pollingTime == null || _pollingTime.isNaN) {
      _pollingTime = 2;
    }

    final devicesOne = prefs.getStringList("devicesOne");
    if (devicesOne == null) {
      prefs.setStringList("devicesOne", []);
    } else {
      List<String> save = [];
      for (var device in devicesOne) {
        try {
          firstList.add(_loadFromJson(jsonDecode(device)));
          save.add(device);
        } on MissingPluginException {
          print("Remove " + device.toString());
        }
      }
      prefs.setStringList("devicesOne", save);
    }

    final devicesTwo = prefs.getStringList("devicesTwo");
    if (devicesTwo == null) {
      prefs.setStringList("devicesTwo", []);
    } else {
      List<String> save = [];
      for (var device in devicesTwo) {
        try {
          secondList.add(_loadFromJson(jsonDecode(device)));
          save.add(device);
        } on MissingPluginException {
          print("Remove " + device.toString());
        }
      }
      prefs.setStringList("devicesTwo", save);
    }
  }

  void _appendDeviceToConfig(int page, DeviceControl d) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonString = jsonEncode(d.data.toJson());
    if (page == 0) {
      var devicesOne = prefs.getStringList("devicesOne");
      devicesOne.add(jsonString);
      prefs.setStringList("devicesOne", devicesOne);
    } else {
      var devicesTwo = prefs.getStringList("devicesTwo");
      devicesTwo.add(jsonString);
      prefs.setStringList("devicesTwo", devicesTwo);
    }
  }

  DeviceControl _loadFromJson(Map<String, dynamic> json) {
    var data = DeviceData.fromJson(json);
    var key = UniqueKey();

    switch (data.type) {
      case SimpleSwitch.deviceType:
        return SimpleSwitch(key: key, data: data);
      case OnePhaseDimmer.deviceType:
        return OnePhaseDimmer(key: key, data: data);
    }
    throw MissingPluginException(sprintf("Device %s not found!", [data.type]));
  }

  void _handleTabIndex() {
    setState(() {});
  }

  Future<void> _reorderFirstList(int oldIndex, int newIndex) async {
    setState(() {
      final Widget tmp = firstList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      firstList.insert(newIndex, tmp);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("devicesOne");
    list.insert(newIndex, list.removeAt(oldIndex));
    prefs.setStringList("devicesOne", list);
  }

  Future<void> _reorderSecondList(int oldIndex, int newIndex) async {
    setState(() {
      final Widget tmp = secondList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      secondList.insert(newIndex, tmp);
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList("devicesTwo");
    list.insert(newIndex, list.removeAt(oldIndex));
    prefs.setStringList("devicesTwo", list);
  }

  void _addControlItem(int page, DeviceControl d) async {
    setState(() {
      if (page == 0) {
        firstList.add(d);
      } else {
        secondList.add(d);
      }
    });
    _appendDeviceToConfig(page, d);
  }

  void _removeControlItem(int page, DeviceControl d) async {
    setState(() {
      if (page == 0) {
        firstList.remove(d);
      } else {
        secondList.remove(d);
      }
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var jsonString = jsonEncode(d.data.toJson());
    if (page == 0) {
      var devicesOne = prefs.getStringList("devicesOne");
      devicesOne.remove(jsonString);
      prefs.setStringList("devicesOne", devicesOne);
    } else {
      var devicesTwo = prefs.getStringList("devicesTwo");
      devicesTwo.remove(jsonString);
      prefs.setStringList("devicesTwo", devicesTwo);
    }
  }

  void _changePollingTimer(int time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("polling_time", time);
    setState(() {
      this._pollingTime = time;
    });
  }
}
