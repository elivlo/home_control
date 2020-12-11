import 'package:flutter/material.dart';
import 'package:home_control/deviceControlWidgets/deviceTemplate.dart';
import 'package:home_control/deviceControlWidgets/switchButton.dart';

import 'package:home_control/subPages/pageNewDevice.dart';
import 'package:sqflite/sqflite.dart';

class HomeController extends InheritedWidget {
  final void Function(int page, DeviceControl d) addItem;
  final void Function(int page, DeviceControl d) removeItem;

  const HomeController(this.addItem, this.removeItem, child): super(child: child);

  static HomeController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeController>();
  }

  @override
  bool updateShouldNotify(HomeController oldWidget) =>
    removeItem != removeItem || addItem != addItem;

}

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
        body: HomeController(
          _addControlItem,
          _removeControlItem,
          TabBarView(
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
                onReorder: _reorderFirstList,
              ),
              Icon(Icons.settings),
            ],
          ),
        ),
        floatingActionButton: _bottomButtons(),
      ),
    );


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
        onPressed: () async {
          DeviceControl device = await Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) {
                return NewDevicePage(_tabController.index);
              }));
          _addControlItem(device.page, device);
        },
      );
    }
  }

  void _createAndLoadDB() async {
    var db = await openDatabase("state.db", onCreate: (db, version) async {
      await db.execute('CREATE TABLE Devices (id INTEGER PRIMARY KEY, page INTEGER, type TEXT, name TEXT, hostname TEXT, tasmota INTEGER)');
    }, onUpgrade: (db, oldDB, newDB) async {
      await db.execute('ALTER TABLE Devices ADD tasmota INTEGER');
    }, version: 1, );
    List<Map> list = await db.rawQuery('SELECT * FROM Devices');
    setState(() {
      for (var item in list) {
        var type = item["type"].toString();

        switch (type) {
          case "Simple Switch": {
            _loadDBItem(item["page"], SimpleSwitch(key: UniqueKey(), name: item["name"].toString(), hostname: item["hostname"].toString(), page: item["page"], tasmota: item["tasmota"] == 1 ? true : false));
            break;
          }
          default: {
            db.delete("Devices", where: "id", whereArgs: item["id"]);
            break;
          }
        }
      }
    });
  }

  void _handleTabIndex() {
    setState(() {});
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

  void _loadDBItem(int page, DeviceControl d) {
    if (page == 0) {
      firstList.add(d);
    } else {
      secondList.add(d);
    }
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

  void _removeControlItem(int page, DeviceControl d) async {
    setState(() {
      if (page == 0) {
        firstList.remove(d);
      } else {
        secondList.remove(d);
      }
    });
    var db = await openDatabase("state.db");
    await db.delete("Devices", where: "name = ? AND hostname = ?", whereArgs: [d.name, d.hostname]);
  }
}