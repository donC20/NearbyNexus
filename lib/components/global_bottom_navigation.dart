// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/user/screens/chatScreen/user_inbox.dart';
import 'package:NearbyNexus/screens/user/screens/user_dashboard_m.dart';
import 'package:NearbyNexus/screens/user/screens/user_home.dart';
import 'package:NearbyNexus/screens/vendor/screens/broadcasts.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_dashboard.dart';
import 'package:NearbyNexus/screens/vendor/screens/vendor_side_search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';

class GlobalBottomNavigation extends StatefulWidget {
  const GlobalBottomNavigation({Key? key, required this.userType})
      : super(key: key);

  final String userType;

  @override
  _GlobalBottomNavigationState createState() => _GlobalBottomNavigationState();
}

class _GlobalBottomNavigationState extends State<GlobalBottomNavigation>
    with TickerProviderStateMixin {
  late MotionTabBarController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        MotionTabBarController(initialIndex: 0, vsync: this, length: 4);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<IconData> bottomIcons = [];
    List<String> bottomIconsLabels = [];
    List<Widget> bottomScreenList = [];
    if (widget.userType == "general_user") {
      bottomIcons = [
        Icons.dashboard,
        Icons.people_alt,
        CupertinoIcons.chat_bubble_2_fill,
        Icons.search
      ];
      bottomIconsLabels = ["Dashboard", "Users", "Chats", "Search user"];
      bottomScreenList = [
        UserDashboardM(),
        GeneralUserHome(),
        UserInbox(),
        VendorSideSearchScreen(),
      ];
    } else if (widget.userType == "vendor") {
      bottomIcons = [
        Icons.dashboard,
        CupertinoIcons.compass_fill,
        CupertinoIcons.chat_bubble_2_fill,
        Icons.search
      ];
      bottomIconsLabels = ["Dashboard", "Job Feeds", "Chats", "Search"];
      bottomScreenList = [
        VendorDashboard(),
        BroadcastPage(),
        UserInbox(),
        VendorSideSearchScreen(),
      ];
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        bottomNavigationBar: MotionTabBar(
          controller:
              _tabController, // ADD THIS if you need to change your tab programmatically
          initialSelectedTab: "Dashboard",
          useSafeArea: true, // default: true, apply safe area wrapper
          labels: bottomIconsLabels,
          icons: bottomIcons,

          tabSize: 50,
          tabBarHeight: 55,
          textStyle: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          tabIconColor: Colors.blue[600],
          tabIconSize: 28.0,
          tabIconSelectedSize: 26.0,
          tabSelectedColor: Colors.blue[900],
          tabIconSelectedColor: Colors.white,
          tabBarColor: Color.fromARGB(255, 255, 255, 255),
          onTabItemSelected: (int value) {
            setState(() {
              _tabController.index = value;
            });
          },
        ),
        body: TabBarView(
          controller: _tabController,
          children: bottomScreenList,
        ));
  }
}
