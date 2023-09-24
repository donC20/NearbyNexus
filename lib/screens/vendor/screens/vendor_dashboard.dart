// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/vendor/components/bottom_vendor_nav_global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String imageLink = "https://icons8.com/icon/tZuAOUGm9AuS/user-default";
  String nameLoginned = "";
  bool isimageFetched = false;
  int _selectedItemPosition = 2;
  String uid = '';
  SnakeShape snakeShape = SnakeShape.circle;
  Color unselectedColor = Colors.blueGrey;
  Color selectedColor = Colors.black;

  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);

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
        imageLink = fetchedData['image'] ??
            "https://firebasestorage.googleapis.com/v0/b/nearbynexus1.appspot.com/o/profile_images%2Ficons8-user-default-96.png?alt=media&token=0ffd4c8b-fc40-4f19-a457-1ef1e0ba6ae5";
        nameLoginned = fetchedData['name'];
        isimageFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height - 550,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Dashboard",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: GoogleFonts.play().fontFamily),
                      ),
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.notifications)),
                          UserLoadingAvatar(
                            userImage: imageLink,
                            width: 30,
                            height: 30,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                jobDoneContainer(12),
                SizedBox(
                  height: 20,
                ),
                summaryContainer(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: ListView(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color(0xFF8B5FEC),
                        borderRadius: BorderRadius.circular(5)),
                    child: ListTile(
                      onTap: () {},
                      title: Text(
                        "New jobs",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: GoogleFonts.play().fontFamily),
                      ),
                      trailing: Text(
                        "2",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: GoogleFonts.play().fontFamily),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Explore more",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        fontFamily: GoogleFonts.play().fontFamily),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromARGB(43, 158, 158, 158)),
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
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 40,
                      runSpacing: 30,
                      children: [
                        cardItems(Icons.work, "New jobs", "", context),
                        cardItems(Icons.payment, "Payments", "", context),
                        cardItems(Icons.pending_actions, "Pending\npayments",
                            "", context),
                        cardItems(Icons.history, "Job log", "", context),
                        cardItems(Icons.access_time_sharp, "Change status", "",
                            context),
                        cardItems(Icons.heart_broken_outlined, "Favourites", "",
                            context),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Recent peoples",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.normal,
                        fontSize: 12,
                        fontFamily: GoogleFonts.play().fontFamily),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                        recentUsers("https://shorturl.at/BHKT1", "Nova Elin"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget jobDoneContainer(value) {
  return Container(
    height: 200,
    width: 200,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFF09E063).withOpacity(0.1),
    ),
    child: Center(
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF09E063).withOpacity(0.2),
        ),
        child: Center(
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF09E063),
            ),
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toString(),
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w900,
                          fontSize: 25,
                          fontFamily: GoogleFonts.play().fontFamily),
                    ),
                    Text(
                      "Jobs done",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          fontFamily: GoogleFonts.play().fontFamily),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget summaryContainer() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      SizedBox(),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "10\n",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: "All",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      Container(
        height: 40,
        width: 1,
        color: Colors.grey, // Vertical line color
        margin: const EdgeInsets.symmetric(horizontal: 10),
      ),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "5\n",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: "Active",
              style: TextStyle(
                color: Colors.green, // Change color to match your theme
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      Container(
        height: 40,
        width: 1,
        color: Colors.grey, // Vertical line color
        margin: const EdgeInsets.symmetric(horizontal: 10),
      ),
      RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: "3\n",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: "Rejected",
              style: TextStyle(
                color: Colors.red, // Change color to match your theme
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget cardItems(
    IconData icon, String title, String ontapRoute, BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, ontapRoute);
    },
    child: Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.normal,
              fontSize: 12,
              fontFamily: GoogleFonts.play().fontFamily),
        ),
      ],
    ),
  );
}

Widget recentUsers(String imagePath, String userName) {
  return Column(
    children: [
      UserLoadingAvatar(userImage: imagePath),
      Text(
        userName,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: const Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.normal,
            fontSize: 12,
            fontFamily: GoogleFonts.play().fontFamily),
      ),
    ],
  );
}
