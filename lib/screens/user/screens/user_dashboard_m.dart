// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/component/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
            Expanded(
              child: ListView(
                children: [
                  Wrap(
                    spacing: 50,
                    runSpacing: 15,
                    children: [
                      cardItems(Icons.work, "Active Jobs", "", context, () {},
                          Colors.green, "active_jobs"),
                      cardItems(Icons.work_history, "Pending Jobs", "", context,
                          () {}, Colors.red, "pending_jobs"),
                      cardItems(Icons.favorite, "Favourites", "", context,
                          () {}, Colors.white, "fd"),
                      cardItems(Icons.history, "Job history", "d", context,
                          () {}, Colors.amber, "fsd"),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  jobandPaymentsSummary(context)
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
  return Container(
    width: MediaQuery.sizeOf(context).width,
    height: 200,
    decoration: BoxDecoration(
        color: Color(0xFF1364ff), borderRadius: BorderRadius.circular(20)),
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
