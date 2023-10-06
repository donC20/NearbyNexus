// ignore_for_file: prefer_const_constructors

import 'package:NearbyNexus/screens/user/screens/search_screen_global.dart';
import 'package:NearbyNexus/screens/user/screens/user_dashboard.dart';
import 'package:NearbyNexus/screens/user/screens/user_dashboard_m.dart';
import 'package:NearbyNexus/screens/user/screens/user_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class GlobalBottomNavUser extends StatefulWidget {
  const GlobalBottomNavUser({super.key});

  @override
  State<GlobalBottomNavUser> createState() => _GlobalBottomNavUserState();
}

class _GlobalBottomNavUserState extends State<GlobalBottomNavUser> {
  Gradient selectedGradient = const LinearGradient(colors: [
    Color.fromARGB(255, 8, 89, 210),
    Color.fromARGB(255, 24, 18, 1)
  ]);
  Gradient unselectedGradient = const LinearGradient(
      colors: [Color.fromARGB(255, 54, 89, 244), Colors.blueGrey]);

  String imageLink = "";
  String nameLoginned = "";
  bool isimageFetched = false;
  int _selectedItemPosition = 2;
  String uid = '';
  SnakeShape snakeShape = SnakeShape.circle;
  Color unselectedColor = Colors.blueGrey;
  Color selectedColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    return SnakeNavigationBar.gradient(
      // height: 80,
      behaviour: SnakeBarBehaviour.floating,
      snakeShape: SnakeShape.circle,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      padding: const EdgeInsets.all(12),

      // /configuration for SnakeNavigationBar.gradient
      snakeViewGradient: selectedGradient,
      selectedItemGradient:
          snakeShape == SnakeShape.indicator ? selectedGradient : null,
      unselectedItemGradient: unselectedGradient,

      showUnselectedLabels: false,
      showSelectedLabels: false,

      currentIndex: _selectedItemPosition,
      onTap: (index) async {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => GeneralUserHome()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDashboardM()),
          );
        } else if (index == 4) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserDashboard()),
          );
        }
        setState(() => _selectedItemPosition = index);
      },
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.ads_click_outlined), label: 'tickets'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded), label: 'calendar'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.podcasts), label: 'microphone'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search')
      ],
      selectedLabelStyle: const TextStyle(fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
    );
  }
}
