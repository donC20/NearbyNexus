// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestStatusPage extends StatefulWidget {
  const RequestStatusPage({super.key});

  @override
  State<RequestStatusPage> createState() => _RequestStatusPageState();
}

class _RequestStatusPageState extends State<RequestStatusPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    var initData = json.decode(userLoginData ?? '');
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
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 8.0),
          child: Text("Request status",
              style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('service_actions')
              .where('userReference',
                  isEqualTo: _firestore.collection('users').doc(uid))
              .where('clientStatus', isEqualTo: 'requested')
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
                  final docId = documentList[index].id;
                  // Check if the document data is not empty
                  if (documentData.isNotEmpty) {
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
                          Map<String, dynamic> userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          String vendorName = userData['name'];
                          // Replace with actual field name
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
                              child: Column(
                                children: [
                                  NotificationItem(
                                    serviceName: documentData['service_name'],
                                    formattedTimeAgo: formattedTimeAgo,
                                    vendorName: vendorName,
                                    status: documentData['status'],
                                    newPrice: documentData['wage'],
                                    docId: docId,
                                    jobLogs: documentData['jobLogs'],
                                  ),
                                  // Add more NotificationItem widgets as needed for other notifications
                                ],
                              ));
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
                  } else {
                    return Center(
                      child: Text(
                        'No data available for the user.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
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
                'You don\'t have any new request.',
                style: TextStyle(color: Colors.white),
              ));
            }
          },
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String serviceName;
  final String? formattedTimeAgo;
  final String? vendorName;
  final String status;
  final String? newPrice;
  final String docId;
  final List<dynamic> jobLogs;
  NotificationItem({
    super.key,
    required this.serviceName,
    required this.formattedTimeAgo,
    this.vendorName,
    required this.status,
    this.newPrice,
    required this.docId,
    required this.jobLogs,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(50, 158, 158, 158)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              convertToSentenceCase(serviceName),
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formattedTimeAgo ?? "",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        status == 'new'
            ? Text.rich(
                TextSpan(
                  text: "Waiting for ",
                  style: TextStyle(color: Colors.white54),
                  children: [
                    TextSpan(
                      text: vendorName ?? "",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: " to accept the request."),
                  ],
                ),
              )
            : status == 'accepted'
                ? Text.rich(
                    TextSpan(
                      text: "Your request has been accepted by ",
                      style: TextStyle(color: Colors.white54),
                      children: [
                        TextSpan(
                          text: vendorName ?? "",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              ". They will contact you as soon as possible. Please be available.",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : status == 'user negotiated'
                    ? Text.rich(
                        TextSpan(
                          text: "You have negotiated the price for ",
                          style: TextStyle(color: Colors.white54),
                          children: [
                            TextSpan(
                              text: vendorName ?? "",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : status == 'user accepted'
                        ? Text.rich(
                            TextSpan(
                              text:
                                  "You have accepted the negotiated price for ",
                              style: TextStyle(color: Colors.white54),
                              children: [
                                TextSpan(
                                  text: vendorName ?? "",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : status == 'negotiate'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      text: vendorName ?? "",
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " wants to negotiate price",
                                          style: TextStyle(
                                              color: Colors.white54,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: const Color.fromARGB(
                                        116, 158, 158, 158),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Negotiated price",
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.currency_rupee,
                                            color: Color.fromARGB(
                                                137, 136, 225, 2),
                                            size: 16,
                                          ),
                                          Text(
                                            newPrice.toString(),
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    137, 136, 225, 2),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : status == 'completed'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          text: vendorName ?? "",
                                          style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: " has completed the job",
                                              style: TextStyle(
                                                  color: Colors.white54,
                                                  fontWeight:
                                                      FontWeight.normal),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        color: const Color.fromARGB(
                                            116, 158, 158, 158),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Negotiated price",
                                            style: TextStyle(
                                                color: Colors.white54,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.currency_rupee,
                                                color: Color.fromARGB(
                                                    137, 136, 225, 2),
                                                size: 16,
                                              ),
                                              Text(
                                                newPrice.toString(),
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        137, 136, 225, 2),
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : SizedBox(),
      ]),
    );
  }
}
