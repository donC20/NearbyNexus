// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileOne extends StatefulWidget {
  const UserProfileOne({super.key});

  @override
  State<UserProfileOne> createState() => _UserProfileOneState();
}

class _UserProfileOneState extends State<UserProfileOne> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String nameLoginned = "Jhon Doe";
  String imageLink = "";
  String email = "";
  bool isFetching = true;
  bool isimageFetched = true;
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
    String uid = initData['uid'];
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        imageLink = fetchedData['image'];
        nameLoginned = fetchedData['name'];
        email = fetchedData['emailId']['id'];
        isFetching = false;
        isimageFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 1,
        shadowColor: Color.fromARGB(92, 255, 255, 255),
        backgroundColor: Colors.black,
        title: Text(
          "Manage Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isFetching == true
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: const Color.fromARGB(255, 255, 255, 255), size: 80),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 25, left: 10, right: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
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
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                imageLink,
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
                                          loadingProgress.expectedTotalBytes!) {
                                    return Center(
                                      child:
                                          LoadingAnimationWidget.discreteCircle(
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
                    title: Text(
                      nameLoginned,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      email,
                      style: TextStyle(
                          color: Color.fromARGB(108, 255, 255, 255),
                          fontWeight: FontWeight.normal,
                          fontSize: 12),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "user_profile");
                      },
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          color: Color.fromARGB(255, 10, 131, 238),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Settings",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    horizontalTitleGap: -5,
                    trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                        )),
                  ),
                  Divider(
                    color: const Color.fromARGB(87, 158, 158, 158),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.support,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Support",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    horizontalTitleGap: -5,
                    trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                        )),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.edit_document,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Terms and conditions",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    horizontalTitleGap: -5,
                    trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.arrow_right_alt,
                          color: Colors.white,
                        )),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Language",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    horizontalTitleGap: -5,
                    trailing: Text("English",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  InkWell(
                    onTap: () async {
                      final SharedPreferences sharedpreferences =
                          await SharedPreferences.getInstance();
                      sharedpreferences.remove("userSessionData");
                      sharedpreferences.remove("uid");
                      Navigator.pushNamedAndRemoveUntil(
                          context, "login_screen", (route) => false);
                      await _googleSignIn.signOut();
                    },
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Color.fromARGB(212, 156, 40, 40),
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                            color: Color.fromARGB(212, 156, 40, 40),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      horizontalTitleGap: -5,
                    ),
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  SizedBox(
                    child: Center(
                      child: Column(
                        children: [
                          Image.asset(
                            width: 100,
                            height: 100,
                            'assets/images/nearbynexus(WL).png',
                          ),
                          Text(
                            "NearbyNexus",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
