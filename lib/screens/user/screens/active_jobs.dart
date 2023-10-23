// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:NearbyNexus/components/user_bottom_nav.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserActiveJobs extends StatefulWidget {
  const UserActiveJobs({super.key});

  @override
  State<UserActiveJobs> createState() => _UserActiveJobsState();
}

class _UserActiveJobsState extends State<UserActiveJobs> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = '';
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
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
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40),
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            decoration: BoxDecoration(
              color: Color(0xFF2d4fff),
            ),
            child: Text(
              "Active Jobs",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Shadow color
                    spreadRadius: 4, // Spread radius
                    blurRadius: 8, // Blur radius
                    offset: Offset(0, 3), // Offset
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: uid.isNotEmpty
                        ? _firestore
                            .collection('service_actions')
                            .where('userReference',
                                isEqualTo: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid))
                            .where('status', whereNotIn: [
                            'new',
                            'completed',
                            'user rejected'
                          ]) // Add the statuses you want to include
                            .snapshots()
                        : Stream.empty(),
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
                          padding: const EdgeInsets.all(18.0),
                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              QueryDocumentSnapshot document =
                                  documentList[index];
                              final docId = documentList[index].id;

                              Map<String, dynamic> documentData =
                                  document.data() as Map<String, dynamic>;
                              return Container(
                                width: 100,
                                height: 170,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.2), // Shadow color
                                      spreadRadius: 2, // Spread radius
                                      blurRadius: 5, // Blur radius
                                      offset: Offset(0, 3), // Offset
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
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        GoogleFonts.play()
                                                            .fontFamily),
                                              ),
                                              Chip(
                                                backgroundColor: documentData[
                                                            'service_level'] ==
                                                        "Very urgent"
                                                    ? Colors.red
                                                    : documentData[
                                                                'service_level'] ==
                                                            "Urgent"
                                                        ? Colors.amber
                                                        : Colors.green,
                                                label: Text(
                                                    documentData[
                                                            'service_level'] ??
                                                        "loading..",
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
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                timeStampConverter(documentData[
                                                    'dateRequested']),
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        148, 0, 0, 0),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        GoogleFonts.play()
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
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                documentData['location'],
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        148, 0, 0, 0),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    fontFamily:
                                                        GoogleFonts.play()
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
                                                    fontFamily:
                                                        GoogleFonts.play()
                                                            .fontFamily),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Positioned(
                                          bottom: 20,
                                          right: 0,
                                          child: OutlinedButton(
                                              key: Key(
                                                  "${index.toString()}_button_user"),
                                              onPressed: () {
                                                Map<String, dynamic> docInfo = {
                                                  "dataReference": docId,
                                                  "vendor": documentData[
                                                      'referencePath'],
                                                };
                                                Navigator.pushNamed(
                                                    context, "job_review_page",
                                                    arguments: docInfo);
                                              },
                                              child: Text(
                                                'Details',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )))
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
                      } else {
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/vector/ship_wrek.svg",
                                width: 300,
                                height: 300,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "No active jobs found!",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily:
                                        GoogleFonts.blackHanSans().fontFamily),
                              )
                            ]);
                      }
                    },
                  ))
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomGNavUser(
        activePage: 5,
        isSelectable: true,
      ),
    );
  }
}
