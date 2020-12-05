import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:home_control/subPages/pageNewDevice.dart';

import 'controllableDevices/light.dart';

class MainTabs extends StatefulWidget {

  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabIndex);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndex() {
    setState(() {});
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
            ListView(
              children: [
                SwitchButton("Eins Licht")
              ],
            ),
            Icon(Icons.single_bed),
            Icon(Icons.settings),
          ],
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
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) {
                return NewDevicePage(_tabController.index);
              }));
        },
      );
    }
  }
}