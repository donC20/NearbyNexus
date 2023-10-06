// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomGNavUser extends StatefulWidget {
  final int activePage;
  final bool isSelectable;
  const BottomGNavUser(
      {super.key, required this.activePage, required this.isSelectable});
  @override
  State<BottomGNavUser> createState() => _BottoGmNavUserState();
}

class _BottoGmNavUserState extends State<BottomGNavUser> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 31, 30, 30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12),
        child: GNav(
            backgroundColor: const Color.fromARGB(255, 31, 30, 30),
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            padding: EdgeInsets.all(16),
            selectedIndex: widget.activePage,
            curve: Curves.decelerate,
            gap: 5,
            onTabChange: (index) {
              if (widget.activePage != index) {
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, "user_home");
                  case 1:
                    Navigator.pushReplacementNamed(context, "user_dashboard");
                  case 2:
                    Navigator.pushNamed(context, "search_screen_vendor");
                }
              }
            },
            tabs: [
              GButton(
                icon: EvaIcons.activity,
                text: 'Users',
              ),
              GButton(
                icon: Icons.dashboard,
                text: 'Dashboard',
              ),
              GButton(
                icon: Icons.search,
                text: 'Search',
              ),
            ]),
      ),
    );
  }
}
