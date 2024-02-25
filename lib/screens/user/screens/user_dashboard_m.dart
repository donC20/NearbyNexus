// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/component/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
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
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  // ignore: non_constant_identifier_names
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

  Stream<dynamic> summaryContainerStream() {
    StreamController<dynamic> controller = StreamController<dynamic>();

    // Ensure uid is not null or empty
    if (uid.isNotEmpty) {
      _firestore
          .collection('service_actions')
          .where('userReference',
              isEqualTo: _firestore.collection('users').doc(uid))
          .snapshots()
          .listen((event) async {
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
          var userReference = doc['referencePath'];
          if (userReference != null) {
            userReferences.add(userReference);
          }
        }

        // Calculate total wage where paymentStatus is 'paid'
        QuerySnapshot wageSnapshot = await _firestore
            .collection('service_actions')
            .where('userReference',
                isEqualTo: _firestore.collection('users').doc(uid))
            .where('paymentStatus', isEqualTo: 'paid')
            .get();

        double totalWage = wageSnapshot.docs
            .fold(0, (sum, doc) => sum + (double.parse(doc['wage'] ?? '0')));

        Map<String, dynamic> summaryData = {
          "all": all,
          "active": active,
          "rejected": rejected,
          "jobCompletedCount": jobCompletedCount,
          "newJobs": newJobs,
          "userReferences": userReferences,
          "totalWage": totalWage, // Add total wage to summaryData
        };

        print(summaryData);
        controller.add(summaryData);
      });
    } else {
      print("Error: uid is null or empty");
    }

    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('DashBoard'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "request_status_page");
              },
              icon: Icon(
                Icons.notifications,
              )),
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
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
                  : imageLink.isEmpty
                      ? LoadingAnimationWidget.discreteCircle(
                          color: Colors.grey,
                          size: 15,
                        )
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
                                } else if (loadingProgress.expectedTotalBytes !=
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
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<dynamic>(
                  stream: summaryContainerStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> summaryData = snapshot.data;
                        List<dynamic> userReferences =
                            summaryData['userReferences'];
                        return ListView(
                          children: [
                            jobandPaymentsSummary(
                                context, summaryData['totalWage']),
                            SizedBox(
                              height: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "More actions",
                                ),
                                cardItems(
                                    Icons.post_add_outlined,
                                    "Post new job",
                                    "/create_job_post",
                                    context,
                                    () {},
                                    Colors.blueAccent,
                                    "post_add",
                                    "Create new job post, and make the post public."),
                                cardItems(
                                    Icons.view_agenda,
                                    "My jobs",
                                    "/view_my_job_post",
                                    context,
                                    () {},
                                    Colors.amberAccent,
                                    "post_add",
                                    "Manage and view the jobs you have created."),
                                cardItems(
                                    Icons.work,
                                    "Active Jobs",
                                    "user_active_jobs",
                                    context,
                                    () {},
                                    Colors.green,
                                    "active_jobs",
                                    "See all the jobs that are currently active."),
                                cardItems(
                                    Icons.work_history,
                                    "Pending Jobs",
                                    "user_pending_requets",
                                    context,
                                    () {},
                                    Colors.red,
                                    "pending_jobs",
                                    "View all jobs that need your attention."),
                                cardItems(
                                    Icons.favorite,
                                    "Favourite connections",
                                    "/my_favourites",
                                    context,
                                    () {},
                                    Theme.of(context).colorScheme.onTertiary,
                                    "fd",
                                    "View all the favourite connections of yours."),
                                cardItems(
                                    Icons.history,
                                    "Job history",
                                    "/user_job_history",
                                    context,
                                    () {},
                                    Colors.amber,
                                    "fsd",
                                    "All the transactions are listed here."),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "Recent workers",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                  fontFamily: GoogleFonts.play().fontFamily),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: userReferences.isNotEmpty
                                  ? Wrap(
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

                                                return recentUsers(imageUrl,
                                                    userName, userId, context);
                                              }
                                            }
                                            return SizedBox();
                                          },
                                        );
                                      }).toList(),
                                    )
                                  : Center(
                                      child: Text(
                                        "No past workers found ):",
                                      ),
                                    ),
                            )
                          ],
                        );
                      }
                    }
                    return SizedBox();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

Widget recentUsers(
    String imagePath, String userName, docId, BuildContext context) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, "vendor_profile_opposite", arguments: docId);
    },
    child: Column(
      children: [
        UserLoadingAvatar(userImage: imagePath),
        SizedBox(
          height: 5,
        ),
        Text(
          userName,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              fontFamily: GoogleFonts.play().fontFamily),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    ),
  );
}

Widget jobandPaymentsSummary(BuildContext context, double amount) {
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
                      formatCurrency(amount),
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
                  onPressed: () {
                    Navigator.pushNamed(context, "user_payment_log");
                  },
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

Widget cardItems(
  IconData icon,
  String title,
  String ontapRoute,
  BuildContext context,
  Function onTap,
  Color iconColor,
  String key,
  String subtitle,
) {
  return Column(
    children: [
      ListTile(
        onTap: () {
          Navigator.pushNamed(context, ontapRoute);
        },
        leading: Icon(
          icon,
          color: iconColor,
        ),
        trailing: Icon(
          Icons.arrow_right_alt_sharp,
          color: Theme.of(context).colorScheme.onTertiary,
        ),
        title: Text(
          title,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: GoogleFonts.play().fontFamily),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary, fontSize: 10),
        ),
      ),
      Divider(
        color: Color.fromARGB(109, 158, 158, 158),
      ),
    ],
  );
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
