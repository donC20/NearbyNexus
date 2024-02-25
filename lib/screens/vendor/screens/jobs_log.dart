// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobLogs extends StatefulWidget {
  const JobLogs({super.key});

  @override
  State<JobLogs> createState() => _JobLogsState();
}

class _JobLogsState extends State<JobLogs> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');

    setState(() {
      uid = initData['uid'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Job logs'),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: <Widget>[
                ButtonsTabBar(
                  backgroundColor: Color(0xFF2d4fff),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  radius: 20,
                  unselectedBackgroundColor: Colors.grey[300],
                  unselectedLabelStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.run_circle_rounded),
                      text: "Ongoing",
                    ),
                    Tab(
                      icon: Icon(Icons.check_circle),
                      text: "Completed",
                    ),
                    Tab(
                      icon: Icon(Icons.dangerous),
                      text: "Rejected",
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      tabCompleted(uid, _firestore, "ongoing"),
                      tabCompleted(uid, _firestore, "completed"),
                      tabCompleted(uid, _firestore, "rejected"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Stream<QuerySnapshot> getServiceActionsStream(String uid, String tab) {
  CollectionReference serviceActionsCollection =
      FirebaseFirestore.instance.collection('service_actions');

  Query query = serviceActionsCollection.where('referencePath',
      isEqualTo: FirebaseFirestore.instance.collection('users').doc(uid));

  switch (tab) {
    case "completed":
      query = query.where('clientStatus', isEqualTo: 'finished');
      break;
    case "rejected":
      query = query.where('status', whereIn: ['rejected', 'user rejected']);
      break;
    case "ongoing":
      query = query.where('status', whereIn: [
        'completed',
        'accepted',
        'user accepted',
        'negotiate',
        'user negotiated'
      ]);
      break;
  }

  return query.snapshots();
}

Widget tabCompleted(uid, firestore, tab) {
  var logger = Logger();

  return Column(
    children: [
      Expanded(
          child: StreamBuilder<QuerySnapshot>(
        stream:
            uid.isNotEmpty ? getServiceActionsStream(uid, tab) : Stream.empty(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List<QueryDocumentSnapshot> documentList = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot document = documentList[index];
                  final docId = documentList[index].id;

                  Map<String, dynamic> documentData =
                      document.data() as Map<String, dynamic>;
                  return Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromARGB(43, 158, 158, 158)),
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      boxShadow: Theme.of(context).brightness == Brightness.dark
                          ? [] // Empty list for no shadow in dark theme
                          : [
                              BoxShadow(
                                color: Color.fromARGB(38, 67, 65, 65)
                                    .withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 1,
                              ),
                            ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    documentData['service_name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily:
                                            GoogleFonts.play().fontFamily),
                                  ),
                                  Chip(
                                    backgroundColor: documentData['status'] ==
                                            "new"
                                        ? const Color.fromARGB(
                                            255, 54, 244, 133)
                                        : documentData['clientStatus'] ==
                                                "finished"
                                            ? Colors.green
                                            : documentData['clientStatus'] ==
                                                        "canceled" ||
                                                    documentData['status'] ==
                                                        'rejected'
                                                ? Color.fromARGB(255, 255, 0, 0)
                                                : Colors.amber,
                                    label: Text(
                                        documentData['status'] == 'new'
                                            ? 'New'
                                            : documentData['clientStatus'] ==
                                                    'finished'
                                                ? "Completed"
                                                : documentData[
                                                            'clientStatus'] ==
                                                        "canceled"
                                                    ? "Canceled"
                                                    : documentData['status'] ==
                                                            "rejected"
                                                        ? "Rejected"
                                                        : "Ongoing",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                              Divider(
                                color: Colors.grey,
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    timeStampConverter(
                                        documentData['dateRequested']),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        fontFamily:
                                            GoogleFonts.play().fontFamily),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    documentData['location'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily:
                                            GoogleFonts.play().fontFamily),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee,
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    documentData['wage'],
                                    style: TextStyle(
                                        color: Color.fromARGB(230, 7, 211, 38),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily:
                                            GoogleFonts.play().fontFamily),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  icon: Icon(
                                    Icons.arrow_circle_right,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    Map<String, dynamic> logData = {
                                      "docId": docId,
                                      "from": "vendor"
                                    };

                                    Navigator.pushNamed(
                                        context, "job_log_timeline",
                                        arguments: logData);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .all<Color>(const Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255)), // Set button color to green
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      StadiumBorder(), // Use stadium border
                                    ),
                                  ),
                                  label: Text("Logs",
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0))),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                ElevatedButton.icon(
                                  key: Key("${index.toString()}_button"),
                                  icon: Icon(
                                    Icons.arrow_circle_right,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                  onPressed: () {
                                    if (documentData['status'] == 'accepted' ||
                                        documentData['status'] ==
                                            'user accepted') {
                                      Map<String, dynamic> docInfo = {
                                        "dataReference": docId,
                                        "userReference":
                                            documentData['userReference'],
                                      };
                                      Navigator.pushNamed(
                                          context, "vendor_accepted_job",
                                          arguments: docInfo);
                                    } else {
                                      Map<String, dynamic> docInfo = {
                                        "dataReference": docId,
                                        "userReference":
                                            documentData['userReference'],
                                      };
                                      logger.e(docInfo);
                                      Navigator.pushNamed(
                                          context, "view_requests",
                                          arguments: docInfo);
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .all<Color>(Color.fromARGB(255, 154, 81,
                                            250)), // Set button color to green
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      StadiumBorder(), // Use stadium border
                                    ),
                                  ),
                                  label: Text("View",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255))),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: 15,
                  );
                },
                itemCount: documentList.length,
              ),
            );
          }
          return Center(
            child: Text(
              "Sorry, No new jobs are added or completed.",
            ),
          );
        },
      ))
    ],
  );
}
