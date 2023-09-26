// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/main.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../user/components/view_job_details.dart';

class VendorNotificationScreen extends StatefulWidget {
  const VendorNotificationScreen({super.key});

  @override
  State<VendorNotificationScreen> createState() =>
      _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  // StreamController<List<Map<String, dynamic>>> _streamController =
  //     StreamController<List<Map<String, dynamic>>>.broadcast();
  String uid = '';
  String? formattedTimeAgo;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime currentTime = DateTime.now();
    DateTime postTime = timestamp.toDate();
    Duration difference = currentTime.difference(postTime);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}d ago";
    } else {
      return DateFormat('MMM dd, yyyy').format(postTime);
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails(
      DocumentReference userReference) async {
    try {
      DocumentSnapshot userDetailsSnapshot = await userReference.get();
      return userDetailsSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user details: $e');
      return null; // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Notifications",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('service_actions')
              .where('referencePath',
                  isEqualTo:
                      FirebaseFirestore.instance.collection('users').doc(uid))
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              List<QueryDocumentSnapshot> documentList = snapshot.data!.docs;

              return ListView.separated(
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot document = documentList[index];
                  Map<String, dynamic> documentData =
                      document.data() as Map<String, dynamic>;

                  // notification manager

                  final docId = documentList[index].id;
                  // Check if the document data is not empty
                  if (documentData.isNotEmpty) {
                    DocumentReference userReference =
                        documentData['userReference'];

                    return FutureBuilder<DocumentSnapshot>(
                      future:
                          userReference.get(), // Fetch user data asynchronously
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
                          Map<String, dynamic> userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          String userName = userData['name'];
                          String imagePath = userData['image'];
                          formattedTimeAgo =
                              formatTimestamp(documentData['dateRequested']);
                          return Container(
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
                            child: ListTile(
                              onTap: () {
                                if (documentData['clientStatus'] ==
                                    'finished') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewJobDetails(),
                                      settings: RouteSettings(
                                        arguments: {
                                          'jobId': docId,
                                        }, // Pass your arguments here
                                      ),
                                    ),
                                  );
                                } else {
                                  Map<String, dynamic> docInfo = {
                                    "dataReference": docId,
                                    "userReference":
                                        documentData['userReference'],
                                  };
                                  Navigator.pushNamed(context, "view_requests",
                                      arguments: docInfo);
                                }
                              },
                              leading: UserLoadingAvatar(
                                userImage: imagePath,
                              ),
                              title: Text(
                                convertToSentenceCase(
                                    documentData['service_name']),
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 252, 252),
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: documentData['paymentStatus'] == 'paid'
                                  ? Text.rich(
                                      TextSpan(
                                        text: userName,
                                        style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " has paid you \u20B9",
                                            style: TextStyle(
                                              color: Colors.white54,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          TextSpan(
                                            text: documentData['wage'],
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  252, 110, 247, 6),
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : documentData['status'] == 'new'
                                      ? Text.rich(
                                          TextSpan(
                                            text: userName,
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            children: [
                                              TextSpan(
                                                text:
                                                    " has requested for your service.",
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : documentData['status'] ==
                                              'user negotiated'
                                          ? Text.rich(
                                              TextSpan(
                                                text: userName,
                                                style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        " updated the price. take a look",
                                                    style: TextStyle(
                                                      color: Colors.white54,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : documentData['status'] ==
                                                  'user canceled'
                                              ? Text.rich(
                                                  TextSpan(
                                                    text: userName,
                                                    style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            " has cancelled their serivce request.",
                                                        style: TextStyle(
                                                          color: Colors.white54,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  documentData['location'],
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12),
                                                ),
                              trailing: Text(
                                formattedTimeAgo ?? "",
                                style: TextStyle(
                                  color: Color.fromARGB(218, 255, 252, 252),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Text(
                            'No data available for the user.',
                            style: TextStyle(color: Colors.white),
                          );
                        }
                      },
                    );
                  } else {
                    return Container(); // You can decide how to handle empty data
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
                itemCount: documentList.length,
              );
            } else {
              return Center(
                  child: Text(
                '): you don\'t have any new notification.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ));
            }
          },
        ),
      ),
      bottomNavigationBar: BottomGNav(
        activePage: 5,
        isSelectable: true,
      ),
    );
  }
}
