// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewRequests extends StatefulWidget {
  const ViewRequests({super.key});

  @override
  State<ViewRequests> createState() => _ViewRequestsState();
}

class _ViewRequestsState extends State<ViewRequests> {
  var logger = Logger();
  String yrCurrentLocation = "loading..";
  String nameUser = "Jhon Doe";
  String query = '';
  String imageLinkUser = "";
  Map<String, dynamic> docIds = {};
  Map<String, dynamic> rawData = {};

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
      fetchUserData(docIds['userReference']);
      fetchRequestData(docIds['referencePath']);
    });
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

  Future<void> fetchUserData(DocumentReference userRef) async {
    try {
      DocumentSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;

        // Update UI with the fetched data
        setState(() {
          imageLinkUser = fetchedData['image'];
          nameUser = fetchedData['name'];
        });
      } else {}
    } catch (e) {
      logger.d("Error fetching user data: $e");
    }
  }

  Future<void> fetchRequestData(DocumentReference requestDataRef) async {
    try {
      DocumentSnapshot snapshot = await requestDataRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;

        // Update UI with the fetched data
        setState(() {
          rawData = fetchedData;
        });
      } else {}
    } catch (e) {
      logger.d("Error fetching user data: $e");
    }
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
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width - 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("From,",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(56, 255, 255, 255),
                                  fontWeight: FontWeight.bold)),
                          Chip(
                            backgroundColor:
                                rawData['service_level'] == "Very urgent"
                                    ? Colors.red
                                    : rawData['service_level'] == "Urgent"
                                        ? Colors.amber
                                        : Colors.green,
                            label: Text(rawData['service_level'] ?? "loading..",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      ListTile(
                        leading: UserLoadingAvatar(userImage: imageLinkUser),
                        title: Text(
                          nameUser,
                          style: TextStyle(color: Colors.white54),
                        ),
                        subtitle: Text(
                            timeStampConverter(rawData['dateRequested']),
                            style:
                                TextStyle(color: Colors.white54, fontSize: 10)),
                      ),
                      Divider(
                        color: Color.fromARGB(137, 158, 158, 158),
                      ),
                      Text("Service required",
                          style: TextStyle(
                              color: const Color.fromARGB(56, 255, 255, 255),
                              fontWeight: FontWeight.bold)),
                      Text(
                        convertToSentenceCase(rawData['service_name']),
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
                  border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Needed on",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(56, 255, 255, 255),
                                  fontWeight: FontWeight.bold)),
                          Text(
                            timeStampConverter(rawData['day']),
                            style:
                                TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Location",
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(56, 255, 255, 255),
                                  fontWeight: FontWeight.bold)),
                          Text(
                            convertToSentenceCase(rawData['location']),
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Budget",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          56, 255, 255, 255),
                                      fontWeight: FontWeight.bold)),
                              Row(
                                children: [
                                  Icon(Icons.currency_rupee_sharp,
                                      size: 16, color: Colors.white54),
                                  Text(
                                    rawData['wage'].toString(),
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.change_circle,
                              color: Color.fromARGB(170, 51, 89, 204),
                              size: 20,
                            ),
                            label: Text(
                              "Negotiate",
                              style: TextStyle(
                                  color: Color.fromARGB(170, 51, 89, 204)),
                            ),
                          )
                        ],
                      ),
                      Divider(
                        color: Color.fromARGB(137, 158, 158, 158),
                      ),
                      Text("Description",
                          style: TextStyle(
                              color: const Color.fromARGB(56, 255, 255, 255),
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        rawData['description'],
                        textAlign: TextAlign.justify,
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Wrap(
                          spacing: 15,
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(170, 51, 204, 51),
                              ),
                              onPressed: () {},
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Accept",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(170, 204, 51, 51),
                              ),
                              onPressed: () {},
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Decline",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
