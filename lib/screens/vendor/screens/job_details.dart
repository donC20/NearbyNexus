// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MyJobs extends StatefulWidget {
  @override
  _MyJobsState createState() => _MyJobsState();
}

class _MyJobsState extends State<MyJobs> {
  // Sample job and customer information
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');

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
    var initData = json.decode(userLoginData ??'');
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

  // Function to launch the phone call

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('My current jobs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('service_actions')
              .where('referencePath',
                  isEqualTo:
                      FirebaseFirestore.instance.collection('users').doc(uid))
              .where('status', isEqualTo: 'accepted')
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
                        documentData['userReference'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: vendorReference
                          .get(), // Fetch user data asynchronously
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // If user data is still loading, show a loading indicator
                          return CircularProgressIndicator();
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

                          return Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width - 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(43, 158, 158, 158)),
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
                                      UserLoadingAvatar(
                                          userImage: userData['image']),
                                      Text(
                                        convertToSentenceCase(userData['name']),
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              final Uri _emailLaunchUri = Uri(
                                                scheme: 'mailto',
                                                path: 'donbenny916@gmail.com',
                                                // queryParameters: {
                                                //   'subject':
                                                //       Uri.encodeComponent(subject),
                                                //   'body': Uri.encodeComponent(body),
                                                // },
                                              );

                                              final url =
                                                  _emailLaunchUri.toString();
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 251, 101, 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Adjust the radius as needed
                                              ),
                                            ),
                                            icon: Icon(Icons.mail),
                                            label: Text("Mail"),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              final phoneNumber = userData[
                                                      'phone']['number']
                                                  .toString(); // Replace with the recipient's phone number
                                              const messageBody =
                                                  'Hello, there,';

                                              final Uri _smsLaunchUri = Uri(
                                                scheme: 'sms',
                                                path: phoneNumber,
                                                queryParameters: {
                                                  'body': messageBody,
                                                },
                                              );

                                              final url =
                                                  _smsLaunchUri.toString();

                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 0, 173, 203),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Adjust the radius as needed
                                              ),
                                            ),
                                            icon: Icon(Icons.sms),
                                            label: Text("SMS"),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              FlutterPhoneDirectCaller
                                                  .callNumber(userData['phone']
                                                          ['number']
                                                      .toString());
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Adjust the radius as needed
                                              ),
                                            ),
                                            icon: Icon(Icons.call),
                                            label: Text("Call"),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 15,
                                            top: 10,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.email,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              userData['emailId']['id'],
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white54,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 15,
                                            top: 10,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.phone,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              "+91 ${userData['phone']['number'].toString()}",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white54,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 15,
                                            top: 10,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(
                                              Icons.location_on_rounded,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              documentData['location']
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                color: Colors.white54,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
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
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Service details",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: const Color.fromARGB(
                                          123, 158, 158, 158),
                                    ),
                                    serviceDetaisl("Service name",
                                        documentData['service_name']),
                                    serviceDetaisl(
                                        "Date requested", formattedTimeAgo),
                                    serviceDetaisl(
                                        "Needed on",
                                        timeStampConverter(
                                            documentData['day'])),
                                    serviceDetaisl(
                                        "Location", documentData['location']),
                                    Text(
                                      "Description",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.white54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(
                                      color: const Color.fromARGB(
                                          123, 158, 158, 158),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      convertToSentenceCase(
                                          documentData['description']),
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.white54,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        _service_actions_collection
                                            .doc(docId)
                                            .update({
                                          'status': 'completed',
                                          'dateRequested': DateTime.now()
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 117, 76, 175),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20.0), // Adjust the radius as needed
                                        ),
                                      ),
                                      icon: Icon(Icons.done_all),
                                      label: Text("Mark this job as completed"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
              return Center(child: Text('No data available.'));
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

String timeStampConverter(Timestamp timeAndDate) {
  DateTime dateTime = timeAndDate.toDate();
  String formattedDateTime = DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
  return formattedDateTime;
}

Widget serviceDetaisl(serviceTitle, serviceName) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          serviceTitle,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          convertToSentenceCase(serviceName),
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white54,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
