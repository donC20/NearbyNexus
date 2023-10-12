// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Job logs'),
      ),
      body: uid.isNotEmpty
          ? Column(
              children: [
                Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _firestore
                      .collection('service_actions')
                      .where('referencePath',
                          isEqualTo: FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid))
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
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.separated(
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot document =
                                documentList[index];
                            final docId = documentList[index].id;

                            Map<String, dynamic> documentData =
                                document.data() as Map<String, dynamic>;
                            return Container(
                              width: MediaQuery.sizeOf(context).width,
                              height: 170,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(43, 158, 158, 158)),
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(186, 42, 40, 40),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 15, 14, 14)
                                        .withOpacity(0.9),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              documentData['service_name'],
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  fontFamily: GoogleFonts.play()
                                                      .fontFamily),
                                            ),
                                            Chip(
                                              backgroundColor: documentData[
                                                          'status'] ==
                                                      "new"
                                                  ? Colors.red
                                                  : documentData[
                                                              'clientStatus'] ==
                                                          "finished"
                                                      ? Colors.green
                                                      : Colors.amber,
                                              label: Text(
                                                  documentData['status'] ==
                                                          'new'
                                                      ? 'New'
                                                      : documentData[
                                                                  'clientStatus'] ==
                                                              'finished'
                                                          ? "Completed"
                                                          : "Ongoing",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold)),
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
                                              color: Color.fromARGB(
                                                  147, 255, 255, 255),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              timeStampConverter(documentData[
                                                  'dateRequested']),
                                              style: TextStyle(
                                                  color: Colors.white30,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  fontFamily: GoogleFonts.play()
                                                      .fontFamily),
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
                                              color: Color.fromARGB(
                                                  147, 255, 255, 255),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              documentData['location'],
                                              style: TextStyle(
                                                  color: Colors.white30,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  fontFamily: GoogleFonts.play()
                                                      .fontFamily),
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
                                              color: Color.fromARGB(
                                                  147, 255, 255, 255),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              documentData['wage'],
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      230, 7, 211, 38),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  fontFamily: GoogleFonts.play()
                                                      .fontFamily),
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
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                          Color>(
                                                      const Color.fromARGB(
                                                          255,
                                                          255,
                                                          255,
                                                          255)), // Set button color to green
                                              shape: MaterialStateProperty.all<
                                                  OutlinedBorder>(
                                                StadiumBorder(), // Use stadium border
                                              ),
                                            ),
                                            label: Text("Status",
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 0, 0, 0))),
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          ElevatedButton.icon(
                                            key: Key(
                                                "${index.toString()}_button"),
                                            icon: Icon(
                                              Icons.arrow_circle_right,
                                              color: const Color.fromARGB(
                                                  255, 255, 255, 255),
                                            ),
                                            onPressed: () {
                                              Map<String, dynamic> docInfo = {
                                                "dataReference": docId,
                                                "userReference": documentData[
                                                    'userReference'],
                                              };
                                              Navigator.pushNamed(
                                                  context, "view_requests",
                                                  arguments: docInfo);
                                            },
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty
                                                  .all<Color>(Color.fromARGB(
                                                      255,
                                                      154,
                                                      81,
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
                            return Divider(
                              color: Colors.grey,
                            );
                          },
                          itemCount: documentList.length,
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ))
              ],
            )
          : Center(
              child: Text(
              "Please wait..",
              style: TextStyle(color: Colors.white),
            )),
      bottomNavigationBar: BottomGNav(
        activePage: 5,
        isSelectable: true,
      ),
    );
  }
}
