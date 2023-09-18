// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/component/infoCard.dart';
import 'package:NearbyNexus/screens/admin/config/size_config.dart';
import 'package:NearbyNexus/screens/admin/style/colors.dart';
import 'package:NearbyNexus/screens/admin/style/style.dart';
import 'package:NearbyNexus/screens/vendor/components/bottom_vendor_nav_global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String imageLink = "";
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
        imageLink = fetchedData['image'];
        nameLoginned = fetchedData['name'];
        isimageFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                colors: const [
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
        padding: const EdgeInsets.only(top: 15),
        child: ListView(
          children: [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('service_actions')
                  .where('referencePath',
                      isEqualTo: _firestore.collection('users').doc(uid))
                  .where('clientStatus', isEqualTo: 'finished')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error.toString()}');
                } else if (snapshot.hasData) {
                  List<QueryDocumentSnapshot> documentList =
                      snapshot.data!.docs;
                  int completedJobsCount = documentList.length;

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _firestore
                        .collection('service_actions')
                        .where('referencePath',
                            isEqualTo: _firestore.collection('users').doc(uid))
                        .where('status', isEqualTo: 'new')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> newJobsSnapshot) {
                      if (newJobsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (newJobsSnapshot.hasError) {
                        return Text(
                            'Error: ${newJobsSnapshot.error.toString()}');
                      } else if (newJobsSnapshot.hasData) {
                        List<QueryDocumentSnapshot> newDocumentList =
                            newJobsSnapshot.data!.docs;
                        int newJobsCount = newDocumentList.length;

                        return Column(
                          children: [
                            summaryContainer(
                                "Jobs completed", completedJobsCount, context),
                            Divider(
                              color: Colors.grey,
                            ),
                            summaryContainer("New Jobs", newJobsCount, context)
                          ],
                        );
                      } else {
                        return Text(
                          'We can\'t find any records associated with this account.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        );
                      }
                    },
                  );
                } else {
                  return Text(
                    'We can\'t find any records associated with this account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  );
                }
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: GlobalBottomNavVendor(),
    );
  }
}

Widget summaryContainer(label, count, BuildContext context) {
  return Container(
    padding: EdgeInsets.all(20),
    width: MediaQuery.sizeOf(context).width,
    height: 80,
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Text(
          count.toString(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
