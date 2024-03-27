// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Active jobs"),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: <Widget>[
                ButtonsTabBar(
                  backgroundColor: Color(0xFF2d4fff),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  radius: 20,
                  unselectedBackgroundColor: Colors.grey[300],
                  unselectedLabelStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.check_circle),
                      text: "Direct jobs",
                    ),
                    Tab(
                      icon: Icon(Icons.dangerous),
                      text: "My jobs",
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[directJobs()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget directJobs() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: uid.isNotEmpty
          ? _firestore
              .collection('service_actions')
              .where('userReference',
                  isEqualTo:
                      FirebaseFirestore.instance.collection('users').doc(uid))
              .where('status', whereNotIn: [
              'new',
              'completed',
              'user rejected'
            ]) // Add the statuses you want to include
              .snapshots()
          : Stream.empty(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List<QueryDocumentSnapshot> documentList = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView.separated(
              itemBuilder: (context, index) {
                QueryDocumentSnapshot document = documentList[index];
                final docId = documentList[index].id;

                Map<String, dynamic> documentData =
                    document.data() as Map<String, dynamic>;
                return Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Color.fromARGB(43, 158, 158, 158)),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? [] // Empty list for no shadow in dark theme
                        : [
                            BoxShadow(
                              color: Color.fromARGB(38, 67, 65, 65)
                                  .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  documentData['service_name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily:
                                          GoogleFonts.play().fontFamily),
                                ),
                                Chip(
                                  backgroundColor:
                                      documentData['service_level'] ==
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
                                      color: Color.fromARGB(230, 7, 211, 38),
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
                                key: Key("${index.toString()}_button_user"),
                                onPressed: () {
                                  Map<String, dynamic> docInfo = {
                                    "dataReference": docId,
                                    "vendor": documentData['referencePath'],
                                  };
                                  Navigator.pushNamed(
                                      context, "job_review_page",
                                      arguments: docInfo);
                                },
                                child: Text(
                                  'Details',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                )))
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 15,
                );
              },
              itemCount: documentList.length,
            ),
          );
        } else {
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  fontFamily: GoogleFonts.blackHanSans().fontFamily),
            )
          ]);
        }
      },
    ));
  }

  // Widget myjobs() {
  //   return StreamBuilder(stream: FirebaseFirestore.instance.collection('applications'), builder: builder)
  // }
}
