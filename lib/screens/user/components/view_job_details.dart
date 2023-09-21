// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/user_circle_avatar.dart';
import '../../admin/screens/user_list_admin.dart';

class ViewJobDetails extends StatefulWidget {
  const ViewJobDetails({super.key});

  @override
  State<ViewJobDetails> createState() => _ViewJobDetailsState();
}

class _ViewJobDetailsState extends State<ViewJobDetails> {
  // Sample job and customer information
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');

  bool isChecked = false;
  bool isPaymentClicked = false;
  String uid = '';
  String? formattedTimeAgo;
  var logger = Logger();
  Map<String, dynamic>? paymentIntent;
  final List<String> paymentLogs = [];
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
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Review job'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('service_actions')
                .doc(arguments['jobId'])
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error.toString()}'));
              } else if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(child: Text('No data available'));
              } else {
                Map<String, dynamic> documentData =
                    snapshot.data!.data()! as Map<String, dynamic>;
                // Access data here
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
                                        "Completed", formattedTimeAgo),
                                    serviceDetaisl(
                                        "Needed on",
                                        timeStampConverter(
                                            documentData['day'])),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Budjet",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.white54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            documentData['wage'],
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.white54,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
              }
            },
          )),
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