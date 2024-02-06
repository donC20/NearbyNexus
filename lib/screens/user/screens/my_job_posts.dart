// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:getwidget/components/accordion/gf_accordion.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class MyJobPosts extends StatefulWidget {
  @override
  _MyJobPostsState createState() => _MyJobPostsState();
}

class _MyJobPostsState extends State<MyJobPosts> {
  String currentUser = '';
  bool isAnyButtonPressed = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchCurrentUser(); // Call fetchCurrentUser in initState
  }

  // fetch user function
  Future<void> fetchCurrentUser() async {
    final userUID = await VendorCommonFn().getUserUIDFromSharedPreferences();

    setState(() {
      currentUser = userUID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentUser.isNotEmpty
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: KColors.backgroundDark,
              appBar: AppBar(
                backgroundColor: KColors.backgroundDark,
                iconTheme: IconThemeData(color: KColors.primary),
                title: Text(
                  'Back',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                bottom: TabBar(
                  dividerHeight: 0.3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Color.fromARGB(255, 21, 0, 255),
                  indicatorWeight: 0.8,
                  indicator: BoxDecoration(
                      color: Color.fromARGB(25, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  tabs: [
                    Tab(
                      // Replace with your icon for Active Posts
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_alarm,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'My posts',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      // Replace with your icon for Active Posts
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'History',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  // Active Posts Content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('job_posts')
                              .where("jobPostedBy",
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUser))
                              .where("expiryDate",
                                  isGreaterThanOrEqualTo: Timestamp.now())
                              .where("isWithdrawn", isEqualTo: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Display a loading indicator while data is being fetched
                            }

                            if (snapshot.hasError) {
                              logger.e(snapshot.error);
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.red),
                              );
                            }

                            // Check if there is no data
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/emptyBox.png",
                                    width: 200,
                                    height: 200,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Sorry no active jobs found.",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              );
                            }

                            // Extract data from the snapshot
                            List<Map<String, dynamic>> jobPosts =
                                snapshot.data!.docs.map(
                                    (QueryDocumentSnapshot<Map<String, dynamic>>
                                        doc) {
                              Map<String, dynamic> documentData = doc.data();
                              documentData['documentId'] = doc.id;
                              return documentData;
                            }).toList();
                            return Expanded(
                              child: ListView.separated(
                                itemCount: jobPosts.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> postData =
                                      jobPosts[index];
                                  List<dynamic> totalApplicants = [];
                                  int applicantsCount = 0;

                                  if (postData['applicants'] != null &&
                                      postData['applicants'] is List<dynamic> &&
                                      postData['applicants'].isNotEmpty) {
                                    totalApplicants = postData['applicants'];
                                    applicantsCount = totalApplicants.length;
                                  } else {
                                    applicantsCount = 0;
                                  }

                                  return isAnyButtonPressed
                                      ? Center(
                                          child:
                                              GFLoader(type: GFLoaderType.ios),
                                        )
                                      : Container(
                                          padding: EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              GFAccordion(
                                                title: postData['jobTitle'],
                                                contentChild: Column(
                                                  children: [
                                                    // Display your data here using jobPosts list
                                                    // For example:
                                                    tableRows(
                                                      icon:
                                                          Icons.calendar_month,
                                                      title: "Posted on",
                                                      value: UtilityFunctions()
                                                          .findTimeDifference(
                                                              postData[
                                                                  'jobPostDate']),
                                                    ),
                                                    tableRows(
                                                        icon: Icons.timelapse,
                                                        title: "Expires in",
                                                        value: UtilityFunctions()
                                                            .findTimeDifference(
                                                                postData[
                                                                    'expiryDate'],
                                                                trailingText:
                                                                    '')),
                                                    tableRows(
                                                        icon: Icons
                                                            .calendar_month,
                                                        title: "Budget",
                                                        value: UtilityFunctions()
                                                            .formatSalary(
                                                                postData[
                                                                    'budget'])),

                                                    tableRows(
                                                        icon: Icons
                                                            .local_activity,
                                                        title: "Skills",
                                                        value: UtilityFunctions()
                                                            .convertListToCommaSeparatedString(
                                                                postData[
                                                                    'skills'])),
                                                    tableRows(
                                                        icon: Icons
                                                            .location_city_sharp,
                                                        title: "Location",
                                                        value: UtilityFunctions()
                                                            .convertListToCommaSeparatedString(
                                                                postData[
                                                                    'preferredLocation'])),
                                                    Card(
                                                      margin: EdgeInsets.all(0),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 15,
                                                                top: 15,
                                                                right: 15),
                                                        child: tableRows(
                                                            icon: Icons
                                                                .verified_user,
                                                            title: "Applicants",
                                                            value:
                                                                applicantsCount
                                                                    .toString()),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 300,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Html(
                                                          data: postData[
                                                              'jobDescription'],
                                                          style: {
                                                            "body": Style(
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  0,
                                                                  0,
                                                                  0), // Text color for the body
                                                            ),
                                                            "p": Style(
                                                              fontSize: FontSize(
                                                                  14), // Font size for paragraphs
                                                              color: Colors
                                                                  .black, // Text color for paragraphs
                                                            ),
                                                            // Add more styles as needed for different HTML elements
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.grey,
                                                    ),
                                                    // Add more rows based on your data
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        GFButton(
                                                          onPressed: () async {
                                                            try {
                                                              setState(() {
                                                                isAnyButtonPressed =
                                                                    true;
                                                              });
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      title: Text(
                                                                          "Warning"),
                                                                      content: Text(
                                                                          "Are you sure to remove this post?"),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                          child: Text(
                                                                              "OK",
                                                                              style: TextStyle(color: Colors.white)),
                                                                          onPressed:
                                                                              () async {
                                                                            await FirebaseFirestore.instance.collection('job_posts').doc(postData['documentId']).update({
                                                                              "isWithdrawn": true,
                                                                              "expiryDate": Timestamp.fromDate(DateTime.now()), // Replace DateTime(2000, 1, 1) with your desired DateTime
                                                                            }).then((value) {
                                                                              UtilityFunctions().showSnackbar("Post removed", Colors.red, context);
                                                                              setState(() {
                                                                                isAnyButtonPressed = false;
                                                                              });
                                                                              Navigator.of(context).pop();
                                                                            });
                                                                          },
                                                                        ),
                                                                        ElevatedButton(
                                                                          child:
                                                                              Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              isAnyButtonPressed = false;
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  });
                                                            } catch (e) {
                                                              logger.e(e);
                                                              setState(() {
                                                                isAnyButtonPressed =
                                                                    false;
                                                              });
                                                            }
                                                          },
                                                          text: "Withdraw",
                                                          shape: GFButtonShape
                                                              .pills,
                                                          color:
                                                              Colors.redAccent,
                                                          icon: Icon(
                                                            Icons.block,
                                                            size: 18,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        GFButton(
                                                          onPressed: () async {
                                                            await pickDate(
                                                                context,
                                                                postData,
                                                                "posts");
                                                          },
                                                          text: "Extend",
                                                          icon: Icon(
                                                            Icons
                                                                .extension_rounded,
                                                            size: 18,
                                                            color: Colors.white,
                                                          ),
                                                          shape: GFButtonShape
                                                              .pills,
                                                          color: Colors.green,
                                                        ),
                                                        GFButton(
                                                          onPressed: () {
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/proposal_screen',
                                                                arguments: {
                                                                  'post_id':
                                                                      postData[
                                                                          'documentId'],
                                                                  'userType':
                                                                      'normal_user'
                                                                });
                                                          },
                                                          shape: GFButtonShape
                                                              .pills,
                                                          icon: Icon(
                                                            Icons.wysiwyg,
                                                            size: 18,
                                                            color: Colors.white,
                                                          ),
                                                          text: "Proposals",
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                collapsedIcon:
                                                    Icon(Icons.arrow_drop_down),
                                                expandedIcon:
                                                    Icon(Icons.arrow_drop_up),
                                                collapsedTitleBackgroundColor:
                                                    Color.fromARGB(
                                                        255, 255, 255, 255),
                                                contentBorderRadius:
                                                    BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 15,
                                  );
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),

                  // Past Posts Content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('job_posts')
                              .where("jobPostedBy",
                                  isEqualTo: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUser))
                              .where("expiryDate",
                                  isLessThanOrEqualTo: Timestamp.now())
                              .where("isWithdrawn", isEqualTo: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Display a loading indicator while data is being fetched
                            }

                            if (snapshot.hasError) {
                              logger.e(snapshot.error);
                              return Text(
                                'Error: ${snapshot.error}',
                                style: TextStyle(color: Colors.red),
                              );
                            }

                            // Check if there is no data
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/emptyBox.png",
                                    width: 200,
                                    height: 200,
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    "Sorry no history found.",
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              );
                            }

                            // Extract data from the snapshot
                            List<Map<String, dynamic>> jobPosts =
                                snapshot.data!.docs.map(
                                    (QueryDocumentSnapshot<Map<String, dynamic>>
                                        doc) {
                              Map<String, dynamic> documentData = doc.data();
                              documentData['documentId'] = doc.id;
                              return documentData;
                            }).toList();
                            return Expanded(
                              child: ListView.separated(
                                itemCount: jobPosts.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> postData =
                                      jobPosts[index];
                                  List<dynamic> totalApplicants = [];
                                  int applicantsCount = 0;

                                  if (postData['applicants'] != null &&
                                      postData['applicants'] is List<dynamic> &&
                                      postData['applicants'].isNotEmpty) {
                                    totalApplicants = postData['applicants'];
                                    applicantsCount = totalApplicants.length;
                                  } else {
                                    applicantsCount = 0;
                                  }

                                  return Container(
                                    padding: EdgeInsets.all(0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        GFAccordion(
                                          title: postData['jobTitle'],
                                          contentChild: Column(
                                            children: [
                                              // Display your data here using jobPosts list
                                              // For example:
                                              tableRows(
                                                icon: Icons.calendar_month,
                                                title: "Posted on",
                                                value: UtilityFunctions()
                                                    .findTimeDifference(
                                                        postData[
                                                            'jobPostDate']),
                                              ),
                                              tableRows(
                                                  icon: Icons.timelapse,
                                                  title: "Expires in",
                                                  value:
                                                      "Expired ${UtilityFunctions().findTimeDifference(postData['expiryDate'], trailingText: 'ago')}"),
                                              tableRows(
                                                  icon: Icons.calendar_month,
                                                  title: "Budget",
                                                  value: UtilityFunctions()
                                                      .formatSalary(
                                                          postData['budget'])),

                                              tableRows(
                                                  icon: Icons.local_activity,
                                                  title: "Skills",
                                                  value: UtilityFunctions()
                                                      .convertListToCommaSeparatedString(
                                                          postData['skills'])),
                                              tableRows(
                                                  icon:
                                                      Icons.location_city_sharp,
                                                  title: "Location",
                                                  value: UtilityFunctions()
                                                      .convertListToCommaSeparatedString(
                                                          postData[
                                                              'preferredLocation'])),
                                              Card(
                                                margin: EdgeInsets.all(0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15,
                                                          top: 15,
                                                          right: 15),
                                                  child: tableRows(
                                                      icon: Icons.verified_user,
                                                      title: "Applicants",
                                                      value: applicantsCount
                                                          .toString()),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 300,
                                                child: SingleChildScrollView(
                                                  child: Html(
                                                    data: postData[
                                                        'jobDescription'],
                                                    style: {
                                                      "body": Style(
                                                        color: const Color
                                                            .fromARGB(255, 0, 0,
                                                            0), // Text color for the body
                                                      ),
                                                      "p": Style(
                                                        fontSize: FontSize(
                                                            14), // Font size for paragraphs
                                                        color: Colors
                                                            .black, // Text color for paragraphs
                                                      ),
                                                      // Add more styles as needed for different HTML elements
                                                    },
                                                  ),
                                                ),
                                              ),
                                              Divider(
                                                color: Colors.grey,
                                              ),
                                              // Add more rows based on your data
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  GFButton(
                                                    onPressed: () {
                                                      pickDate(context,
                                                          postData, "history");
                                                    },
                                                    text: "Repost",
                                                    shape: GFButtonShape.pills,
                                                    color: Colors.redAccent,
                                                    fullWidthButton: true,
                                                    icon: Icon(
                                                      Icons.redo,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  GFButton(
                                                    onPressed: () {},
                                                    shape: GFButtonShape.pills,
                                                    fullWidthButton: true,
                                                    icon: Icon(
                                                      Icons.wysiwyg,
                                                      size: 18,
                                                      color: Colors.white,
                                                    ),
                                                    text: "Proposals",
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          collapsedIcon:
                                              Icon(Icons.arrow_drop_down),
                                          expandedIcon:
                                              Icon(Icons.arrow_drop_up),
                                          collapsedTitleBackgroundColor:
                                              Color.fromARGB(
                                                  255, 255, 255, 255),
                                          contentBorderRadius:
                                              BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 15,
                                  );
                                },
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}

pickDate(BuildContext context, postData, from) async {
  DateTime selectedDate = DateTime.now();

  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2030),
  );
  if (pickedDate != null) {
    selectedDate = pickedDate;
    if (from == "posts") {
      await FirebaseFirestore.instance
          .collection('job_posts')
          .doc(postData['documentId'])
          .update({"expiryDate": selectedDate}).then((value) =>
              UtilityFunctions()
                  .showSnackbar("Date extended", Colors.green, context));
    } else {
      await FirebaseFirestore.instance
          .collection('job_posts')
          .doc(postData['documentId'])
          .update({"expiryDate": selectedDate, "isWithdrawn": false}).then(
              (value) => UtilityFunctions().showSnackbar(
                  "Job posted successfully with extended date",
                  Colors.green,
                  context));
    }
  }
}

Widget tableRows({IconData? icon, required String title, required value}) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      SizedBox(
        height: 15,
      ),
    ],
  );
}
