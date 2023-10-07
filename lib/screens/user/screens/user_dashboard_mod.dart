// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/user/components/recent_user_tile.dart';
import 'package:NearbyNexus/screens/user/screens/payout_log.dart';
import 'package:NearbyNexus/screens/user/screens/request_pending_user.dart';
import 'package:NearbyNexus/screens/user/screens/service_completed_logs.dart';
import 'package:NearbyNexus/screens/user/screens/service_rejected.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String imageLink = "";
  String nameLoginned = "";
  bool isimageFetched = false;
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        shadowColor: Color.fromARGB(92, 158, 158, 158),
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.green
                ], // Adjust gradient colors as needed
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
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
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else if (loadingProgress.expectedTotalBytes !=
                                    null &&
                                loadingProgress.cumulativeBytesLoaded <
                                    loadingProgress.expectedTotalBytes!) {
                              return Center(
                                child: LoadingAnimationWidget.discreteCircle(
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Text(
              "Quick actions",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(
              height: 15,
            ),
            Wrap(
              runSpacing: 15,
              spacing: 15,
              children: [
                topTiles(context, "Service logs", Icons.multiple_stop_sharp,
                    Colors.blue[900], "", RequestsPendingUser()),
                topTiles(
                    context,
                    "Service completed",
                    Icons.check_circle_outline_outlined,
                    const Color.fromARGB(255, 13, 161, 97),
                    "",
                    ServiceCompleted()),
                topTiles(context, "Service Rejected", Icons.close,
                    Color.fromARGB(255, 161, 35, 13), "", ServiceRejected()),
                topTiles(context, "Payouts", Icons.payment,
                    Color.fromARGB(255, 67, 54, 52), "", PayoutLogs()),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "request_status_page");
              },
              child: ListTile(
                shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                title: Text(
                  "Request status",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14),
                ),
                trailing: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // InkWell(
            //   onTap: () {},
            //   child: ListTile(
            //     shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
            //     title: Text(
            //       "Service status",
            //       style: TextStyle(
            //           color: const Color.fromARGB(255, 255, 255, 255),
            //           fontSize: 14),
            //     ),
            //     trailing: Icon(
            //       Icons.query_stats_rounded,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
            // SizedBox(
            //   height: 15,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "People you worked with",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  "view more",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 170, // Adjust the height as needed
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('service_actions')
                    .where('userReference',
                        isEqualTo: _firestore.collection('users').doc(uid))
                    .where('clientStatus', isEqualTo: 'finished')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error.toString()}'));
                  } else if (snapshot.hasData &&
                      snapshot.data!.docs.isNotEmpty) {
                    List<QueryDocumentSnapshot> documentList =
                        snapshot.data!.docs;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: documentList.length,
                      itemBuilder: (BuildContext context, int index) {
                        QueryDocumentSnapshot document = documentList[index];
                        Map<String, dynamic> documentData =
                            document.data() as Map<String, dynamic>;
                        // final docId = documentList[index].id;
                        DocumentReference vendorReference =
                            documentData['referencePath'];
                        return FutureBuilder<DocumentSnapshot>(
                          future: vendorReference
                              .get(), // Fetch user data asynchronously
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              // If user data is still loading, show a loading indicator
                              return Center(child: CircularProgressIndicator());
                            } else if (userSnapshot.hasError) {
                              // Handle errors if any
                              return Text(
                                  'Error: ${userSnapshot.error.toString()}');
                            } else if (userSnapshot.hasData) {
                              // User data is available
                              Map<String, dynamic> userData = userSnapshot.data!
                                  .data() as Map<String, dynamic>;

                              // Replace with actual field name

                              return RecentUserTile(
                                callerContext: context,
                                vendorName: userData['name'],
                                jobName: documentData['service_name'],
                                payment: documentData['wage'],
                                location: documentData['location'],
                                vendorImage: userData['image'],
                              );
                            } else {
                              return Center(
                                child: Text(
                                  'No data available for the user.',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          width: 15,
                        );
                      },
                    );
                  } else {
                    return Center(
                        child: Text(
                      'You have\'nt work with any one yet!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ));
                  }
                },
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your favourites",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                Text(
                  "view more",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 70, // Adjust the height as needed
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    width: MediaQuery.sizeOf(context).width - 30,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromARGB(43, 158, 158, 158)),
                      borderRadius:
                          BorderRadius.circular(10), // Add border radius
                      color: Color.fromARGB(186, 42, 40, 40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: UserLoadingAvatar(
                          userImage:
                              "https://images.unsplash.com/photo-1639149888905-fb39731f2e6c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTd8fHVzZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60"),
                      title: Text(
                        "Rohan Thomas",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      subtitle: Text(
                        "Kanjirapally, Kerala, India",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 15,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: GlobalBottomNavUser(),
    );
  }
}

Widget topTiles(
    BuildContext context, text, icon, bgcolor, screen, constructors) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => constructors,
        ),
      );
    },
    child: Container(
      width: MediaQuery.of(context).size.width / 2 - 25,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgcolor.withOpacity(0.9), bgcolor.withOpacity(0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 36,
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
