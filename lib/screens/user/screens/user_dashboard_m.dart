// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/component/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboardM extends StatefulWidget {
  const UserDashboardM({super.key});

  @override
  State<UserDashboardM> createState() => _UserDashboardMState();
}

class _UserDashboardMState extends State<UserDashboardM> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String imageLink = "";
  String nameLoginned = "";
  bool isimageFetched = false;
  String uid = '';

  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');

    setState(() {
      uid = initData['uid'];
    });
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        imageLink = fetchedData['image'];
        nameLoginned = fetchedData['name'];
        isimageFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Header(
                  pageTitle: "DashBoard",
                  subText: "Manage and view your activities",
                  pageTitleColor: Colors.white,
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "vendor_notification");
                        },
                        icon: Icon(
                          Icons.notifications,
                          color: Colors.white,
                        )),
                    InkWell(
                      key: Key("user_profile_tap"),
                      onTap: () {
                        Navigator.pushNamed(context, "user_profile_one");
                      },
                      child: isimageFetched == true
                          ? Container(
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(color: Colors.black),
                              child: Center(
                                child: LoadingAnimationWidget.fallingDot(
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ))
                          : CircleAvatar(
                              backgroundColor: Colors
                                  .transparent, // Set a transparent background for the avatar
                              child: ClipOval(
                                // Clip the image to an oval (circle) shape
                                child: Image.network(
                                  imageLink,
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else if (loadingProgress
                                                .expectedTotalBytes !=
                                            null &&
                                        loadingProgress.cumulativeBytesLoaded <
                                            loadingProgress
                                                .expectedTotalBytes!) {
                                      return Center(
                                        child: LoadingAnimationWidget
                                            .discreteCircle(
                                          color: Colors.grey,
                                          size: 15,
                                        ),
                                      );
                                    } else {
                                      return SizedBox();
                                    }
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            jobandPaymentsSummary(context),
            SizedBox(
              height: 25,
            ),
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.sizeOf(context).width,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Searching\nfor services?",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontFamily: GoogleFonts.russoOne().fontFamily,
                        ),
                      ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.search),
                        label: Text(
                          "Find services",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 0, 0, 0)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 15,
                  right: 30,
                  child: Image.asset(
                    'assets/images/search_3d.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Wrap(
                      spacing: 50,
                      runSpacing: 15,
                      children: [
                        cardItems(Icons.work, "Active Jobs", "", context, () {},
                            Colors.green, "active_jobs"),
                        cardItems(Icons.work_history, "Pending Jobs", "",
                            context, () {}, Colors.red, "pending_jobs"),
                        cardItems(Icons.favorite, "Favourites", "", context,
                            () {}, Colors.white, "fd"),
                        cardItems(Icons.history, "Job history", "d", context,
                            () {}, Colors.amber, "fsd"),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget jobandPaymentsSummary(BuildContext context) {
  return Stack(
    children: [
      Container(
        padding: EdgeInsets.all(20.0),
        width: MediaQuery.sizeOf(context).width,
        height: 200,
        decoration: BoxDecoration(
          color: Color(0xFF2d4fff),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total payouts",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: GoogleFonts.kanit().fontFamily,
                  ),
                ),
                Divider(
                  color: Colors.white,
                  endIndent: MediaQuery.sizeOf(context).width - 210,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                      size: 18,
                    ),
                    Text(
                      formatCurrency(5000),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Payments",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
      Positioned(
        bottom: 0,
        right: -30,
        child: Image.asset(
          'assets/images/back-bill.png',
          width: 220,
          height: 220,
          fit: BoxFit.cover,
        ),
      ),
    ],
  );
}

Widget cardItems(IconData icon, String title, String ontapRoute,
    BuildContext context, Function onTap, Color iconColor, String key) {
  return InkWell(
      key: Key(key),
      onTap: () {
        if (ontapRoute.isNotEmpty) {
          Navigator.pushNamed(context, ontapRoute);
        }
        onTap();
      },
      child: Container(
        width: 150,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
          borderRadius: BorderRadius.circular(10),
          color: Color.fromARGB(186, 42, 40, 40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: GoogleFonts.play().fontFamily),
            ),
          ],
        ),
      ));
}

String formatCurrency(double amount) {
  String formattedAmount =
      amount.toStringAsFixed(2); // Always keep 2 decimal places

  List<String> parts = formattedAmount.split('.');
  String wholePart = parts[0];
  String decimalPart = parts[1];

  String result = '';
  for (int i = wholePart.length - 1; i >= 0; i--) {
    result = wholePart[i] + result;
    if ((wholePart.length - i) % 3 == 0 && i > 0) {
      result = ',$result';
    }
  }

  return '$result.$decimalPart';
}
