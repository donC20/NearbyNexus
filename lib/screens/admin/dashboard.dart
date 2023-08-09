// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:NearbyNexus/screens/admin/component/appBarActionItems.dart';
import 'package:NearbyNexus/screens/admin/component/header.dart';
import 'package:NearbyNexus/screens/admin/component/infoCard.dart';
import 'package:NearbyNexus/screens/admin/component/paymentDetailList.dart';
import 'package:NearbyNexus/screens/admin/component/sideMenu.dart';
import 'package:NearbyNexus/screens/admin/config/responsive.dart';
import 'package:NearbyNexus/screens/admin/config/size_config.dart';
import 'package:NearbyNexus/screens/admin/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int userCount = 0;
  @override
  void initState()  {
    super.initState();
    
  }

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30, horizontal: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Header(),
                        SizedBox(height: SizeConfig.blockSizeVertical! * 2),
                        SizedBox(
                          width: SizeConfig.screenWidth,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  } else {
                                    int userCount =
                                        snapshot.data?.docs.length ??
                                            0; // Get the length of snapshots
                                    return InfoCard(
                                      icon:
                                          'assets/images/vector/userOnline.svg',
                                      label: 'Users',
                                      amount: '$userCount',
                                    );
                                  }
                                },
                              ),
                              const InfoCard(
                                  icon: 'assets/images/vector/onlineGlobe.svg',
                                  label: 'Users online',
                                  amount: '0'),
                              StreamBuilder<int>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('userType',
                                        isEqualTo: 'general_user')
                                    .snapshots()
                                    .map((querySnapshot) =>
                                        querySnapshot.docs.length),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  } else {
                                    int generalUserCount = snapshot.data ?? 0;
                                    return InfoCard(
                                      icon:
                                          'assets/images/vector/generalUser.svg',
                                      label: 'General users',
                                      amount: '$generalUserCount',
                                    );
                                  }
                                },
                              ),
                              StreamBuilder<int>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .where('userType', isEqualTo: 'vendor')
                                    .snapshots()
                                    .map((querySnapshot) =>
                                        querySnapshot.docs.length),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  } else {
                                    int vendorCount = snapshot.data ?? 0;
                                    return InfoCard(
                                      icon:
                                          'assets/images/vector/serviceProvider.svg',
                                      label: 'Service providers',
                                      amount: '$vendorCount',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              final SharedPreferences sharedpreferences =
                                  await SharedPreferences.getInstance();
                              sharedpreferences.remove("userSessionData");
                              sharedpreferences.remove("uid");
                              Navigator.popAndPushNamed(context, "login_screen");
                            },
                            child: const Text("Logout"))
                      ],
                    ),
                  ),
                )),
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 4,
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: SizeConfig.screenHeight,
                    decoration:
                        const BoxDecoration(color: AppColors.secondaryBg),
                    child: const SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                      child: Column(
                        children: [
                          AppBarActionItems(),
                          PaymentDetailList(),
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
