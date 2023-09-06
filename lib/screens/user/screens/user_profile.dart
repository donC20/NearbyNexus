// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});
  static String verifyPhone = "";
  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final GlobalKey<_UserProfileState> backgroundContainerKeyWhite =
      GlobalKey<_UserProfileState>();
  String nameLoginned = "Jhon Doe";
  String imageLink = "";
  String email = "";
  String city = "";
  int phone = 0;
  bool isFetching = true;
  bool verifiedEmail = false;
  bool verifiedPhone = false;
  bool isVerifyStarted = false;
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
        phone = fetchedData['phone']['number'];
        city = fetchedData['geoLocation'];
        isFetching = false;
        verifiedEmail = fetchedData['emailId']['verified'];
        verifiedPhone = fetchedData['phone']['verified'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // BuildContext? whiteContainer = backgroundContainerKeyWhite.currentContext;

    return Scaffold(
      backgroundColor: Colors.black,
      body: isFetching == true
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: const Color.fromARGB(255, 255, 255, 255), size: 80),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      Container(
                        key: backgroundContainerKeyWhite,
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Color.fromARGB(128, 0, 0, 0),
                            ], // Black to white gradient
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: MediaQuery.sizeOf(context).width / 2 - 50,
                        child: Stack(
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(85, 0, 0, 0),
                                      blurRadius: 20.0,
                                      spreadRadius: 8.0,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
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
                                          loadingProgress
                                                  .cumulativeBytesLoaded <
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Handle edit picture action
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            nameLoginned,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      profileLists(context, Icons.mail, email, "Email", false,
                          true, verifiedEmail),
                      profileLists(context, Icons.phone, "+91 $phone", "Phone",
                          true, true, verifiedPhone),
                      profileLists(context, Icons.location_city_outlined, city,
                          "City", true, false, verifiedEmail),
                      profileLists(context, Icons.home_work, city, "Address",
                          true, false, verifiedEmail),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.work_history_rounded,
                                  color: Colors.white38,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Recent hirings",
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            proposedJobs(
                                "Auto rickshaw",
                                "Koovapally, Kerala, India",
                                "27/08/2023",
                                false,
                                "Mohan Babu"),
                            proposedJobs(
                                "Auto rickshaw",
                                "Koovapally, Kerala, India",
                                "27/08/2023",
                                true,
                                "Mohan Babu"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

Widget profileLists(BuildContext context, IconData icon, value, title,
    isEditable, isVerifiable, isVerified) {
  return Padding(
    padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white38,
                  size: 22,
                ),
                SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white38,
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            isEditable == true
                ? IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.edit,
                      color: Colors.white,
                    ))
                : SizedBox(),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                color: Color.fromARGB(215, 255, 255, 255),
                fontSize: 14,
              ),
            ),
            isVerifiable == true
                ? isVerified == false
                    ? TextButton.icon(
                        onPressed: () async {
                          if (title == "Phone") {
                            await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: value,
                              verificationCompleted:
                                  (PhoneAuthCredential credential) {},
                              verificationFailed: (FirebaseAuthException e) {},
                              timeout: const Duration(seconds: 120),
                              codeSent:
                                  (String verificationId, int? resendToken) {
                                UserProfile.verifyPhone = verificationId;
                                
                                Navigator.popAndPushNamed(
                                    context, "user_otp_screen");
                              },
                              codeAutoRetrievalTimeout:
                                  (String verificationId) {},
                            );
                          } else {
                            print("undermaintenence");
                          }
                        },
                        label: Text(
                          "Verify",
                          style: TextStyle(
                              color: Color.fromARGB(255, 228, 30, 19),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        icon: Icon(
                          Icons.error,
                          color: Color.fromARGB(255, 228, 30, 19),
                          size: 16,
                        ),
                      )
                    : TextButton.icon(
                        onPressed: null,
                        label: Text(
                          "Verified",
                          style: TextStyle(
                              color: Color.fromARGB(255, 4, 255, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        icon: Icon(
                          Icons.check_circle_sharp,
                          color: Color.fromARGB(255, 4, 255, 0),
                          size: 16,
                        ),
                      )
                : SizedBox(),
          ],
        ),
        SizedBox(height: 10),
        Divider(
          color: const Color.fromARGB(178, 158, 158, 158),
        ),
      ],
    ),
  );
}

Widget proposedJobs(type, city, date, isCompleted, by) {
  return Column(
    children: [
      ListTile(
        tileColor: const Color.fromARGB(255, 23, 23, 23),
        isThreeLine: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        title: Text(
          type,
          style: TextStyle(
            color: Color.fromARGB(183, 255, 255, 255),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              by,
              style: TextStyle(
                color: Color.fromARGB(183, 255, 255, 255),
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
            ),
            Text(
              city + ", " + date,
              style: TextStyle(
                color: Color.fromARGB(183, 255, 255, 255),
                fontWeight: FontWeight.normal,
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: isCompleted == true
            ? Icon(
                Icons.done,
                color: Colors.green[700],
              )
            : Icon(
                Icons.do_not_disturb,
                color: Color.fromARGB(255, 176, 2, 2),
              ),
      ),
      SizedBox(
        height: 10,
      ),
    ],
  );
}
