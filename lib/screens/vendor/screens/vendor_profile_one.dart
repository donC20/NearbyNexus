// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/providers/common_provider.dart';
import 'package:NearbyNexus/screens/common_screens/gmaps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorProfileOne extends StatefulWidget {
  const VendorProfileOne({super.key});

  @override
  State<VendorProfileOne> createState() => _VendorProfileOneState();
}

class _VendorProfileOneState extends State<VendorProfileOne> {
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
    var initData = json.decode(userLoginData ?? '');
    String uid = initData['uid'];
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
        email = fetchedData['emailId']['id'];
        isFetching = false;
        isimageFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shadowColor: Color.fromARGB(92, 255, 255, 255),
        title: Text(
          "Manage Account",
          style: TextStyle(fontWeight: FontWeight.bold),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      email,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.normal,
                          fontSize: 12),
                    ),
                    trailing: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "vendor_profile");
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
                    leading: SvgPicture.asset(
                      'assets/icons/svg/hanger.svg',
                      height: 20,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    title: Text(
                      "Theme",
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: OutlinedButton.icon(
                      onPressed: () {
                        Provider.of<CommonProvider>(context, listen: false)
                            .toggleTheme();
                      },
                      label: Text(
                        Theme.of(context).brightness == Brightness.dark
                            ? "Dark Mode"
                            : "Light Mode",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      icon: Icon(
                        Theme.of(context).brightness != Brightness.dark
                            ? Icons.light_mode
                            : Icons.dark_mode_sharp,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.amber[400],
                      ),
                    ),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      'assets/icons/svg/hanger.svg',
                      height: 20,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    title: Text(
                      "Maps",
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: OutlinedButton.icon(
                      onPressed: () {
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) => Gmaps()));
                      },
                      label: Text(
                        "Maps openn",
                      ),
                      icon: Icon(
                        Icons.dark_mode_sharp,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.amber[400],
                      ),
                    ),
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
                    ),
                    title: Text(
                      "Support",
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                        onPressed: () async {
                          final Uri _emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'hexated100@gmail.com',
                            queryParameters: {
                              'subject': 'Support ticket',
                              'body': 'Hello, this is the body of the email!'
                            },
                          );

                          final String url = _emailLaunchUri.toString();
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        icon: Icon(
                          Icons.arrow_right_alt,
                        )),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.edit_document,
                    ),
                    title: Text(
                      "Terms and conditions",
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "terms_Conditions");
                        },
                        icon: Icon(
                          Icons.arrow_right_alt,
                        )),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.language,
                    ),
                    title: Text(
                      "Language",
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: Text("English", style: TextStyle(fontSize: 14)),
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
                    ),
                  ),
                  // SizedBox(
                  //   child: Center(
                  //     child: Column(
                  //       children: [
                  //         Image.asset(
                  //           width: 100,
                  //           height: 100,
                  //           'assets/images/nearbynexus(WL).png',
                  //         ),
                  //         Text(
                  //           "NearbyNexus",
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.normal,
                  //             fontSize: 16,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
    );
  }
}
