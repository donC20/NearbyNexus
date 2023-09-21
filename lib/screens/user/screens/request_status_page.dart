// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  NotificationItem({
    super.key,
    required this.serviceName,
    required this.formattedTimeAgo,
    this.vendorName,
    required this.status,
    this.newPrice,
    required this.docId,
  });
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(50, 158, 158, 158)),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  :status == 'user negotiated'
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
                  :status == 'user accepted'
                  ? Text.rich(
                      TextSpan(
                        text: "You have accepted the negotiated price for ",
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
                  :  status == 'negotiate'
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
                              color: const Color.fromARGB(116, 158, 158, 158),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      color: Color.fromARGB(137, 136, 225, 2),
                                      size: 16,
                                    ),
                                    Text(
                                      newPrice.toString(),
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(137, 136, 225, 2),
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
                                        text: " has completed the job",
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color:
                                      const Color.fromARGB(116, 158, 158, 158),
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
                                          color:
                                              Color.fromARGB(137, 136, 225, 2),
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
                          : SizedBox(),
          SizedBox(
            height: 20,
          ),
          status != "completed"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    status != 'new'
                        ? status == 'accepted'
                            ? SizedBox()
                            : IconButton.outlined(
                                onPressed: () {
                                  _service_actions_collection
                                      .doc(docId)
                                      .update({
                                    'status': 'user accepted',
                                    'dateRequested': DateTime.now()
                                  });
                                },
                                icon: Icon(Icons.check, color: Colors.green))
                        : SizedBox(),
                    status != 'new'
                        ? status == 'accepted'
                            ? SizedBox()
                            : IconButton.outlined(
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
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    "Negotiate the price",
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            170, 0, 0, 0),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Text(
                                                  "Enter amount",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          170, 0, 0, 0),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                SizedBox(
                                                  child: TextFormField(
                                                    controller:
                                                        _amountController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style:
                                                        GoogleFonts.poppins(
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
                                                              255, 22, 0, 0),
                                                          fontSize: 12),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide(
                                                          color:
                                                              Color.fromARGB(
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
                                                          color:
                                                              Color.fromARGB(
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
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
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
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        _service_actions_collection
                                                            .doc(docId)
                                                            .update({
                                                          'status':
                                                              'user negotiated',
                                                          'wage':
                                                              _amountController
                                                                  .text,
                                                          'dateRequested':
                                                              DateTime.now()
                                                        });
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Text(
                                                      "Negotiate",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              252,
                                                              252,
                                                              252),
                                                          fontWeight:
                                                              FontWeight.bold),
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
                                icon: Icon(Icons.change_circle,
                                    color: Colors.blue))
                        : SizedBox(),
                    IconButton.outlined(
                        onPressed: () {
                          _service_actions_collection.doc(docId).update({
                            'status': 'user rejected',
                            'clientStatus': 'canceled',
                            'dateRequested': DateTime.now()
                          });
                        },
                        icon: Icon(Icons.close, color: Colors.red)),
                  ],
                )
              : Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "job_review_page",
                          arguments: docId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 111, 76, 175),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the radius as needed
                      ),
                    ),
                    icon: Icon(Icons.rate_review_rounded),
                    label: Text("Reivew job"),
                  ),
                ),
        ],
      ),
    );
  }
}