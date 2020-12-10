import 'package:flutter/material.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';
import 'package:home_control/deviceControlWidgets/switchButton.dart';

import 'package:home_control/subPages/pageNewDevice.dart';
import 'package:sqflite/sqflite.dart';

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<DeviceControl> firstList = [];

  List<DeviceControl> secondList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
    _createAndLoadDB();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
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
        body: TabBarView(
          controller: _tabController,
          children: [
            ReorderableListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              children: firstList,
              onReorder: _reorderFirstList,
            ),
            ReorderableListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              children: secondList,
              onReorder: _reorderFirstList,
            ),
            Icon(Icons.settings),
          ],
        ),
        floatingActionButton: _bottomButtons(),
      ),
    );


  }

  void _createAndLoadDB() async {
    var db = await openDatabase("state.db", onCreate: (db, version) async {
      await db.execute('CREATE TABLE Devices (id INTEGER PRIMARY KEY, type TEXT, name TEXT, hostname TEXT, tasmota INTEGER)');
    }, version: 1);
    List<Map> list = await db.rawQuery('SELECT * FROM Devices');
    setState(() {
      for (var item in list) {
        bool t;
        if (item["tasmota"] == 1) {
          t = true;
        } else {
          t = false;
        }
        firstList.add(SimpleSwitch(key: UniqueKey(), name: item["name"].toString(), hostname: item["hostname"].toString(), tasmota: t));
      }
    });
  }

  void _handleTabIndex() {
    setState(() {});
  }

  Widget _bottomButtons() {
    if (_tabController.index + 1 == _tabController.length) {
      return FloatingActionButton(
        elevation: 3.0,
        mini: true,
        onPressed: null,
      );
    } else {
      return FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 3.0,
        mini: true,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) {
                return NewDevicePage(_tabController.index, _addControlItem);
              }));
        },
      );
    }
  }

  void _reorderFirstList(int oldIndex, int newIndex) {
    setState(() {
      final Widget tmp = firstList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      firstList.insert(newIndex, tmp);
    });
  }

  void _addControlItem(int page, DeviceControl d) async {
    setState(() {
      if (page == 0) {
        firstList.add(d);
      } else {
        secondList.add(d);
      }
    });
    d.saveToDataBase();
  }
}