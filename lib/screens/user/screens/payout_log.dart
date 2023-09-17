// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayoutLogs extends StatefulWidget {
  const PayoutLogs({super.key});

  @override
  State<PayoutLogs> createState() => _PayoutLogsState();
}

class _PayoutLogsState extends State<PayoutLogs> {
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
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 8.0),
          child: Text("Payout",
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
              .where('clientStatus', isEqualTo: 'finished')
              .where('paymentStatus', isEqualTo: 'paid')
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

                          // Replace with actual field name
                          formattedTimeAgo =
                              formatTimestamp(documentData['dateRequested']);

                          return Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(81, 42, 40, 40),
                            ),
                            child: ListTile(
                              leading: UserLoadingAvatar(
                                  userImage: userData['image']),
                              title: Text(
                                  convertToSentenceCase(
                                      documentData['service_name']),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  timeStampConverter(
                                      documentData['dateRequested']),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                              ),
                            ),
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
                'We can\'t find any records associated with this account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ));
            }
          },
        ),
      ),
    );
  }
}

String timeStampConverter(Timestamp timeAndDate) {
  DateTime dateTime = timeAndDate.toDate();
  String formattedDateTime = DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
  return formattedDateTime;
}
