// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/vendor/components/progress_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewRequests extends StatefulWidget {
  const ViewRequests({super.key});

  @override
  State<ViewRequests> createState() => _ViewRequestsState();
}

class _ViewRequestsState extends State<ViewRequests> {
  // final _firebase = FirebaseFirestore.instance;
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var logger = Logger();
  String yrCurrentLocation = "loading..";
  String nameUser = "Jhon Doe";
  String query = '';
  String imageLinkUser = "";
  Map<String, dynamic> docIds = {};
  Map<String, dynamic> rawData = {};
  bool isloadingPage = true;

  String? uid = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initUser();
    setState(() {
      docIds =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    });
    fetchUserData(docIds['userReference']);
    fetchRequestData(docIds['dataReference']);
    logger.d(docIds);
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
  }

  Future<void> fetchUserData(DocumentReference userRef) async {
    setState(() {
      isloadingPage = true;
    });
    try {
      DocumentSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;
        // Update UI with the fetched data
        setState(() {
          imageLinkUser = fetchedData['image'];
          nameUser = fetchedData['name'];
          isloadingPage = false;
        });
      } else {}
    } catch (e) {
      setState(() {
        isloadingPage = false;
      });
      logger.d("Error fetching user data: $e");
    }
  }

  Future<void> fetchRequestData(requestDataRef) async {
    setState(() {
      isloadingPage = true;
    });
    _service_actions_collection
        .doc(requestDataRef)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;
        setState(() {
          rawData = fetchedData;
          isloadingPage = false;
        });
      }
    });
  }

  String timeStampConverter(Timestamp timeAndDate) {
    DateTime dateTime = timeAndDate.toDate();
    String formattedDateTime =
        DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isloadingPage == true
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: const Color.fromARGB(255, 255, 255, 255), size: 80),
              ),
            )
          : uid!.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(43, 158, 158, 158)),
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(186, 42, 40, 40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("From,",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                56, 255, 255, 255),
                                            fontWeight: FontWeight.bold)),
                                    Chip(
                                      backgroundColor:
                                          rawData['service_level'] ==
                                                  "Very urgent"
                                              ? Colors.red
                                              : rawData['service_level'] ==
                                                      "Urgent"
                                                  ? Colors.amber
                                                  : Colors.green,
                                      label: Text(
                                          rawData['service_level'] ??
                                              "loading..",
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                ),
                                ListTile(
                                  leading: UserLoadingAvatar(
                                      userImage: imageLinkUser),
                                  title: Text(
                                    nameUser,
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  subtitle: Text(
                                      rawData['dateRequested'] != null
                                          ? timeStampConverter(
                                              rawData['dateRequested'])
                                          : "loading..",
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 10)),
                                ),
                                Divider(
                                  color: Color.fromARGB(137, 158, 158, 158),
                                ),
                                Text("Service required",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            56, 255, 255, 255),
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  rawData['service_name'] != null
                                      ? convertToSentenceCase(
                                          rawData['service_name'])
                                      : "loading...",
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color.fromARGB(43, 158, 158, 158)),
                            borderRadius: BorderRadius.circular(10),
                            color: Color.fromARGB(186, 42, 40, 40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Needed on",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                56, 255, 255, 255),
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      rawData['day'] != null
                                          ? timeStampConverter(rawData['day'])
                                          : "loading..",
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Location",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                56, 255, 255, 255),
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      rawData['location'] != null
                                          ? convertToSentenceCase(
                                              rawData['location'])
                                          : "loading..",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Budget",
                                            style: TextStyle(
                                                color: const Color.fromARGB(
                                                    56, 255, 255, 255),
                                                fontWeight: FontWeight.bold)),
                                        Row(
                                          children: [
                                            Icon(Icons.currency_rupee_sharp,
                                                size: 16,
                                                color: Colors.white54),
                                            Text(
                                              rawData['wage'] != null
                                                  ? rawData['wage'].toString()
                                                  : "loading...",
                                              style: TextStyle(
                                                  color: Colors.white54),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    TextButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          // barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              ),
                                              elevation: 0,
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Container(
                                                padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Text(
                                                          "Negotiate the price",
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromARGB(170,
                                                                      0, 0, 0),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Text(
                                                        "Enter amount",
                                                        style: TextStyle(
                                                            color:
                                                                Color.fromARGB(
                                                                    170,
                                                                    0,
                                                                    0,
                                                                    0),
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      SizedBox(
                                                        child: TextFormField(
                                                          controller:
                                                              _amountController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color: const Color
                                                                .fromARGB(
                                                                255, 0, 0, 0),
                                                          ),
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Enter amount',
                                                            labelStyle: TextStyle(
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    22,
                                                                    0,
                                                                    0),
                                                                fontSize: 12),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color
                                                                    .fromARGB(
                                                                        73,
                                                                        0,
                                                                        0,
                                                                        0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                                color: Color
                                                                    .fromARGB(
                                                                        73,
                                                                        0,
                                                                        0,
                                                                        0),
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0),
                                                            ),
                                                          ),
                                                          onChanged: (value) {
                                                            setState(() {});
                                                            // _formKey.currentState!.validate();
                                                          },
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return "You left this field empty!";
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomCenter,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                              List<dynamic>
                                                                  jobLog =
                                                                  rawData[
                                                                      'jobLogs'];
                                                              setState(() {
                                                                jobLog.add(
                                                                    'negotiate');
                                                              });
                                                              _service_actions_collection
                                                                  .doc(docIds[
                                                                      'dataReference'])
                                                                  .update({
                                                                'status':
                                                                    'negotiate',
                                                                'wage':
                                                                    _amountController
                                                                        .text,
                                                                'dateRequested':
                                                                    DateTime
                                                                        .now(),
                                                                'jobLogs':
                                                                    jobLog
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          },
                                                          child: Text(
                                                            "Negotiate",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        252,
                                                                        252,
                                                                        252),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.change_circle,
                                        color: Color.fromARGB(170, 51, 89, 204),
                                        size: 20,
                                      ),
                                      label: Text(
                                        "Negotiate",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                170, 51, 89, 204)),
                                      ),
                                    )
                                  ],
                                ),
                                Divider(
                                  color: Color.fromARGB(137, 158, 158, 158),
                                ),
                                Text("Description",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            56, 255, 255, 255),
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  rawData['description'] ?? "loadng..",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(color: Colors.white54),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                rawData['status'] == 'new' ||
                                        rawData['status'] == 'negotiate' ||
                                        rawData['status'] == 'user negotiated'
                                    ? Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Wrap(
                                          spacing: 15,
                                          children: [
                                            ElevatedButton.icon(
                                              key: Key("accept_btn"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    170, 51, 204, 51),
                                              ),
                                              onPressed: () {
                                                if (docIds['dataReference']
                                                    .isNotEmpty) {
                                                  List<dynamic> jobLog =
                                                      rawData['jobLogs'];
                                                  setState(() {
                                                    jobLog.add('accepted');
                                                  });
                                                  _service_actions_collection
                                                      .doc(docIds[
                                                          'dataReference'])
                                                      .update({
                                                    'status': 'accepted',
                                                    'dateRequested':
                                                        DateTime.now(),
                                                    'jobLogs': jobLog
                                                  });
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(docIds[
                                                          'referencePath'])
                                                      .update({
                                                    'activityStatus': 'busy',
                                                    'jobLogs': jobLog
                                                  });
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            CongratulatoryScreen()),
                                                  );
                                                }
                                              },
                                              icon: Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                "Accept",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    170, 204, 51, 51),
                                              ),
                                              onPressed: () {
                                                List<dynamic> jobLog =
                                                    rawData['jobLogs'];
                                                setState(() {
                                                  jobLog.add('rejected');
                                                });
                                                _service_actions_collection
                                                    .doc(
                                                        docIds['dataReference'])
                                                    .update({
                                                  'status': 'rejected',
                                                  'dateRequested': DateTime.now,
                                                  'jobLogs': jobLog
                                                });
                                                Navigator.pop(context);
                                              },
                                              icon: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                "Decline",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    "Please wait...",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
      bottomNavigationBar: BottomGNav(
        activePage: 5,
        isSelectable: true,
      ),
    );
  }
}
