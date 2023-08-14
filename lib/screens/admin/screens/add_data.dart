import 'package:NearbyNexus/screens/admin/component/infoCard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../component/appBarActionItems.dart';
import '../component/header.dart';
import '../component/sideMenu.dart';
import '../config/responsive.dart';
import '../style/colors.dart';

class DataEntry extends StatefulWidget {
  const DataEntry({super.key});

  @override
  State<DataEntry> createState() => DataEntryState();
}

class DataEntryState extends State<DataEntry> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: const SizedBox(width: 100, child: SideMenu()),
      appBar: !Responsive.isDesktop(context)
          ? AppBar(
              elevation: 0,
              backgroundColor: AppColors.white,
              leading: IconButton(
                  onPressed: () {
                    _drawerKey.currentState!.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: AppColors.black)),
              actions: const [
                AppBarActionItems(),
              ],
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
              flex: 10,
              child: SafeArea(
                child: DefaultTabController(
                  length: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(
                          pageTitle: 'Data Entry',
                          subText:
                              'Add and modfiy different services\nto the application',
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // add services formatted
                        Expanded(
                          child: ListView(
                            children: [
                              Container(
                                width: 200, // Set the width as needed
                                height: 100, // Set the height as needed
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color.fromARGB(255, 75, 75, 255),
                                      Color.fromARGB(255, 18, 4, 59),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, top: 25),
                                  child: Text(
                                    "Service management",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        fontFamily:
                                            GoogleFonts.lalezar().fontFamily),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
