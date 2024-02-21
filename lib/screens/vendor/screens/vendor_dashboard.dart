// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, sort_child_properties_last

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/screens/initial_kyc_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  State<VendorDashboard> createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  String imageLink = "https://icons8.com/icon/tZuAOUGm9AuS/user-default";
  String nameLoginned = "";
  bool isimageFetched = false;
  String uid = '';
  bool activityStatusTapped = false;
  SnakeShape snakeShape = SnakeShape.circle;
  Color unselectedColor = Colors.blueGrey;
  Color selectedColor = Colors.black;
  bool kycStatus = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
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
        imageLink = fetchedData['image'] ??
            "https://firebasestorage.googleapis.com/v0/b/nearbynexus1.appspot.com/o/profile_images%2Ficons8-user-default-96.png?alt=media&token=0ffd4c8b-fc40-4f19-a457-1ef1e0ba6ae5";
        nameLoginned = fetchedData['name'];
        isimageFetched = false;
        kycStatus = fetchedData['kyc']['verified'];
      });
      summaryContainerStream();
    }
  }

  Stream<dynamic> summaryContainerStream() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    // Ensure uid is not null or empty
    if (uid.isNotEmpty) {
      _firestore
          .collection('service_actions')
          .where('referencePath',
              isEqualTo: _firestore.collection('users').doc(uid))
          .snapshots()
          .listen((event) {
        int all = event.size;

        int jobCompletedCount =
            event.docs.where((doc) => doc['clientStatus'] == 'finished').length;
        int active =
            event.docs.where((doc) => doc['status'] == 'accepted').length;
        int rejected =
            event.docs.where((doc) => doc['status'] == 'rejected').length;
        int newJobs = event.docs.where((doc) => doc['status'] == 'new').length;

        List<dynamic> userReferences = [];

        // Get all userReference values
        for (var doc in event.docs) {
          var userReference = doc['userReference'];
          if (userReference != null) {
            userReferences.add(userReference);
          }
        }

        Map<String, dynamic> summaryData = {
          "all": all,
          "active": active,
          "rejected": rejected,
          "jobCompletedCount": jobCompletedCount,
          "newJobs": newJobs,
          "userReferences": userReferences,
        };

        print(summaryData);
        controller.add(summaryData);
      });
    } else {
      print("Error: uid is null or empty");
    }

    return controller.stream;
  }

  Future<void> _refreshData() async {
    FetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.backgroundDark,
        automaticallyImplyLeading: false,
        title: Text(
          "Dashboard",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: GoogleFonts.play().fontFamily),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "vendor_notification");
              },
              icon: Icon(
                Icons.notifications,
                color: Colors.white,
              )),
          UserLoadingAvatar(
            userImage: imageLink,
            width: 30,
            height: 30,
            onTap: () {
              Navigator.pushNamed(context, "vendor_profile_one");
            },
          ),
          SizedBox(
            width: 15,
          )
        ],
      ),
      backgroundColor: KColors.backgroundDark,
      body: isimageFetched == true
          ? Container(
              margin: EdgeInsets.only(right: 10),
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.fallingDot(
                  color: Colors.white,
                  size: 30,
                ),
              ))
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: _refreshData,
              child: StreamBuilder<dynamic>(
                stream: summaryContainerStream(),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      Map<String, dynamic> summaryData = snapshot.data;
                      List<dynamic> userReferences =
                          summaryData['userReferences'];
                      List<Bricks> brickData = [
                        Bricks(
                            icon: Icons.bar_chart_rounded,
                            countData: summaryData['all'],
                            type: 'All Jobs'),
                        Bricks(
                            icon: EvaIcons.activity,
                            countData: summaryData['active'],
                            type: 'Active Jobs'),
                        Bricks(
                            icon: Icons.cancel,
                            countData: summaryData['rejected'],
                            type: 'Rejected Jobs'),
                        Bricks(
                            icon: Icons.check_circle_outline,
                            countData: summaryData['jobCompletedCount'],
                            type: 'Completed'),
                      ];
                      // Use summaryData in your UI
                      return Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: ListView(
                          children: [
                            SizedBox(
                              height: 90,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (BuildContext context, int index) {
                                  var containerData = brickData[index];
                                  return StatContainers(
                                      containerData.icon,
                                      containerData.countData,
                                      containerData.type);
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(width: 15);
                                },
                                itemCount: brickData.length,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            // KYC container
                            Visibility(
                              visible: !kycStatus,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  width: MediaQuery.sizeOf(context).width,
                                  height: 150,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromARGB(
                                              81, 255, 255, 255)),
                                      color: Color.fromARGB(45, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Stack(
                                    children: [
                                      Text(
                                        'Take a moment to\ncomplete KYC.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: GoogleFonts.aBeeZee()
                                                .fontFamily,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Positioned(
                                        bottom: -30,
                                        right: 0,
                                        child: Image.asset(
                                          'assets/images/man_with_key.png',
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        KYCInstructionScreen()),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white),
                                            child: Text(
                                              "I'm ready",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            newJobsContainer(context, summaryData['newJobs']),

                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Explore more",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  fontFamily: GoogleFonts.play().fontFamily),
                            ),
                            SizedBox(
                              height: 15,
                            ),

                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(43, 158, 158, 158),
                                  borderRadius: BorderRadius.circular(15)),
                              child: Wrap(
                                alignment: WrapAlignment.start,
                                spacing: 40,
                                runSpacing: 40,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, "payment_vendor_log");
                                    },
                                    child: cardItems(
                                      Icons.payment,
                                      "Payments",
                                      "payment_vendor_log",
                                      context,
                                      () {},
                                      Colors.blueAccent,
                                    ),
                                  ),
                                  InkWell(
                                    key: Key('job_logs_btn'),
                                    onTap: () {
                                      Navigator.pushNamed(context, "job_logs");
                                    },
                                    child: cardItems(Icons.history, "Job log",
                                        "job_logs", context, () {}, Colors.red),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, "add_services_screen");
                                    },
                                    child: cardItems(
                                      Icons.design_services,
                                      "Add services",
                                      "add_services_screen",
                                      context,
                                      () {},
                                      Colors.white,
                                    ),
                                  ),
                                  activityStatusTapped == true
                                      ? InkWell(
                                          key: Key('set_offline'),
                                          onTap: () {
                                            setState(() {
                                              activityStatusTapped = false;
                                            });
                                            _firestore
                                                .collection('users')
                                                .doc(uid)
                                                .update({
                                              'activityStatus': 'available'
                                            });
                                          },
                                          child: cardItems(
                                            Icons.online_prediction,
                                            "Go online",
                                            "",
                                            context,
                                            () {},
                                            Colors.green,
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {
                                            setState(() {
                                              activityStatusTapped = true;
                                            });
                                            _firestore
                                                .collection('users')
                                                .doc(uid)
                                                .update(
                                                    {'activityStatus': 'busy'});
                                          },
                                          child: cardItems(
                                              Icons.wifi_off,
                                              "Go offline",
                                              "",
                                              context,
                                              () {},
                                              Colors.amber),
                                        ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, "/view_saved_jobs_screen");
                                    },
                                    child: cardItems(
                                        Icons.bookmark,
                                        "Saved jobs",
                                        "",
                                        context,
                                        () {},
                                        Colors.white),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context,
                                          "/view_my_applications_screen");
                                    },
                                    child: cardItems(
                                        Icons.book_sharp,
                                        "My applications",
                                        "",
                                        context,
                                        () {},
                                        Color.fromARGB(255, 122, 255, 82)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Recent peoples",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
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
                                children: userReferences
                                    .toSet()
                                    .map<Widget>((userReference) {
                                  String userId = userReference.id;
                                  return StreamBuilder<DocumentSnapshot>(
                                    stream: _firestore
                                        .collection('users')
                                        .doc(userId)
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            userSnapshot) {
                                      if (userSnapshot.connectionState ==
                                          ConnectionState.active) {
                                        if (userSnapshot.hasData) {
                                          String imageUrl =
                                              userSnapshot.data?['image'];
                                          String userName =
                                              userSnapshot.data?['name'];

                                          return recentUsers(
                                              imageUrl, userName);
                                        }
                                      }
                                      return SizedBox();
                                    },
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  } else {
                    return Container(); // or some placeholder widget
                  }
                },
              ),
            ),
      // bottomNavigationBar: BottomGNav(
      //   activePage: 2,
      //   isSelectable: true,
      // ),
    );
  }

  Widget StatContainers(IconData icon, counts, String type) {
    return Container(
      constraints:
          BoxConstraints(minWidth: MediaQuery.sizeOf(context).width / 2 - 50),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.black,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                counts.toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            type,
            style: TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
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

  Widget summaryContainer(
      int all, int active, int rejected, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, "job_logs");
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${all.toString()}\n",
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
                text: "${active.toString()}\n",
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
                text: "${rejected.toString()}\n",
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

  Widget cardItems(IconData icon, String title, String ontapRoute,
      BuildContext context, Function onTap, Color iconColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
            fontFamily: GoogleFonts.play().fontFamily,
          ),
        ),
      ],
    );
  }

  Widget recentUsers(String imagePath, String userName) {
    return Column(
      children: [
        UserLoadingAvatar(userImage: imagePath),
        SizedBox(
          height: 5,
        ),
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

  Widget newJobsContainer(BuildContext context, int amount) {
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
                    "${amount.toString()}  New job \nrequest is pending..",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: GoogleFonts.kanit().fontFamily,
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "new_jobs");
                    },
                    child: Text(
                      "View request",
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
          right: 10,
          child: Image.asset(
            'assets/images/new_job.png',
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}

class Bricks {
  final IconData icon;
  final dynamic countData;
  final String type;
  Bricks({required this.icon, required this.countData, required this.type});
}
