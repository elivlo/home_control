import 'package:flutter/material.dart';

import 'package:home_control/subPages/pageNewDevice.dart';

import 'deviceControlWidgets/switchButton.dart';

class MainTabs extends StatefulWidget {
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  List<Widget> firstList = [
    SwitchButton(key: UniqueKey(), name: "Eins Licht"),
    SwitchButton(key: UniqueKey(),name: "Zwei"),
    SwitchButton(key: UniqueKey(),name: "Drei"),
    SwitchButton(key: UniqueKey(),name: "Vier")
  ];

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
            ReorderableListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              children: firstList,
              onReorder: _reorderFirstList,
            ),
            ReorderableListView(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              children: firstList,
              onReorder: _reorderFirstList,
            ),
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

  void _reorderFirstList(int oldIndex, int newIndex) {
    setState(() {
      final Widget tmp = firstList.removeAt(oldIndex);
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      firstList.insert(newIndex, tmp);
    });
  }
}