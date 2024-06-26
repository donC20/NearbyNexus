// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewJobs extends StatefulWidget {
  const NewJobs({super.key});

  @override
  State<NewJobs> createState() => _NewJobsState();
}

class _NewJobsState extends State<NewJobs> {
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
    // DocumentSnapshot snapshot =
    //     await FirebaseFirestore.instance.collection('users').doc(uid).get();
    // if (snapshot.exists) {
    //   Map<String, dynamic> fetchedData =
    //       snapshot.data() as Map<String, dynamic>;

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: 150,
            width: MediaQuery.sizeOf(context).height,
            decoration:
                BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255)),
            child: Center(
                child: Text(
              "New Jobs",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: GoogleFonts.aboreto().fontFamily),
            )),
          ),
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('service_actions')
                .where('referencePath',
                    isEqualTo: FirebaseFirestore.instance
                        .collection('users')
                        .doc(ApiFunctions.user?.uid))
                .where('status', isEqualTo: 'new')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error.toString()}'));
              } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                List<QueryDocumentSnapshot> documentList = snapshot.data!.docs;
                logger.d(documentList);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot document = documentList[index];
                      final docId = documentList[index].id;

                      Map<String, dynamic> documentData =
                          document.data() as Map<String, dynamic>;
                      return Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 170,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
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
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            fontFamily:
                                                GoogleFonts.play().fontFamily),
                                      ),
                                      Chip(
                                        backgroundColor: documentData[
                                                    'service_level'] ==
                                                "Very urgent"
                                            ? Colors.red
                                            : documentData['service_level'] ==
                                                    "Urgent"
                                                ? Colors.amber
                                                : Colors.green,
                                        label: Text(
                                            documentData['service_level'] ??
                                                "loading..",
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
                                            color: const Color.fromARGB(
                                                148, 0, 0, 0),
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
                                            color: const Color.fromARGB(
                                                148, 0, 0, 0),
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
                                            color:
                                                Color.fromARGB(230, 7, 211, 38),
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
                                  bottom: 20,
                                  right: 0,
                                  child: OutlinedButton(
                                      onPressed: () {
                                        Map<String, dynamic> docInfo = {
                                          "dataReference": docId,
                                          "userReference":
                                              documentData['userReference'],
                                        };
                                        Navigator.pushNamed(
                                            context, "view_requests",
                                            arguments: docInfo);
                                      },
                                      child: Text(
                                        'Details',
                                        style: TextStyle(color: Colors.black),
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
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/images/vector/ship_wrek.svg",
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      "You don't have any new jobs.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}
