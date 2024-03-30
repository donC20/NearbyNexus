// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors, no_leading_underscores_for_local_identifiers

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/screens/user/screens/create_job_post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:getwidget/getwidget.dart';
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
    setState(() {
      currentUser = ApiFunctions.user!.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return currentUser.isNotEmpty
        ? DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              appBar: AppBar(
                title: Text(
                  'Manage Posts',
                  style: TextStyle(fontSize: 16),
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
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'My posts',
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
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'History',
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
                    padding: const EdgeInsets.all(5.0),
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
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.separated(
                                  itemCount: jobPosts.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> postData =
                                        jobPosts[index];

                                    List<dynamic> totalApplicants = [];
                                    int applicantsCount = 0;

                                    if (postData['applications'] != null &&
                                        postData['applications']
                                            is List<dynamic> &&
                                        postData['applications'].isNotEmpty) {
                                      totalApplicants =
                                          postData['applications'];
                                      applicantsCount = totalApplicants.length;
                                    } else {
                                      applicantsCount = 0;
                                    }
                                    final gap_10 = SizedBox(
                                      height: 8,
                                    );
                                    return isAnyButtonPressed
                                        ? Center(
                                            child: GFLoader(
                                                type: GFLoaderType.ios),
                                          )
                                        : tileForPostData(postData, gap_10,
                                            applicantsCount, 'active');
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      height: 20,
                                    );
                                  },
                                ),
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

                                  if (postData['applications'] != null &&
                                      postData['applications']
                                          is List<dynamic> &&
                                      postData['applications'].isNotEmpty) {
                                    totalApplicants = postData['applications'];
                                    applicantsCount = totalApplicants.length;
                                  } else {
                                    applicantsCount = 0;
                                  }
                                  final gap_10 = SizedBox(
                                    height: 8,
                                  );
                                  return tileForPostData(postData, gap_10,
                                      applicantsCount, 'expired');
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

  Widget tileForPostData(
    postData,
    gap_10,
    applicantsCount,
    status,
  ) {
    final ThemeData theme = Theme.of(context);

    Widget _buildExpansionTile() {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(CupertinoIcons.book_circle),
        title: Text("Read description"),
        children: [
          Container(
            constraints: BoxConstraints(minHeight: 50, maxHeight: 300),
            child: SingleChildScrollView(
              child: Html(
                data: postData['jobDescription'],
                style: {
                  "body": Style(
                    color: theme
                        .colorScheme.onSecondary, // Text color for the body
                  ),
                  "p": Style(
                    fontSize: FontSize(14), // Font size for paragraphs
                    color:
                        theme.colorScheme.tertiary, // Text color for paragraphs
                  ),
                  // Add more styles as needed for different HTML elements
                },
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildActionButtonRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GFButton(
            onPressed: () async {
              try {
                setState(() {
                  isAnyButtonPressed = true;
                });
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Warning"),
                      content: Text("Are you sure to remove this post?"),
                      actions: [
                        ElevatedButton(
                          child:
                              Text("OK", style: TextStyle(color: Colors.white)),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('job_posts')
                                .doc(postData['documentId'])
                                .update({
                              "isWithdrawn": true,
                              "expiryDate": Timestamp.fromDate(DateTime.now()),
                            }).then((value) {
                              UtilityFunctions().showSnackbar(
                                "Post removed",
                                Colors.red,
                                context,
                              );
                              setState(() {
                                isAnyButtonPressed = false;
                              });
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                        ElevatedButton(
                          child: Text("Cancel",
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            setState(() {
                              isAnyButtonPressed = false;
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              } catch (e) {
                logger.e(e);
                setState(() {
                  isAnyButtonPressed = false;
                });
              }
            },
            text: "Withdraw",
            shape: GFButtonShape.pills,
            color: Colors.redAccent,
            icon: Icon(
              Icons.block,
              size: 18,
              color: Colors.white,
            ),
          ),
          GFButton(
            onPressed: () async {
              await pickDate(context, postData, "posts");
            },
            text: "Extend",
            icon: Icon(
              Icons.extension_rounded,
              size: 18,
              color: Colors.white,
            ),
            shape: GFButtonShape.pills,
            color: Colors.green,
          ),
          GFButton(
            onPressed: () {
              Navigator.pushNamed(context, '/proposal_screen', arguments: {
                'post_id': postData['documentId'],
                'userType': 'normal_user'
              });
            },
            shape: GFButtonShape.pills,
            icon: Icon(
              Icons.wysiwyg,
              size: 18,
              color: Colors.white,
            ),
            text: "Proposals",
          ),
        ],
      );
    }

    Widget _buildInactiveActionButtonColumn() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GFButton(
            onPressed: () {
              pickDate(context, postData, "history");
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
      );
    }

    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.onSecondaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                UtilityFunctions.convertToSenenceCase(postData['jobTitle']),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              GFButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateJobPost(openedFor: 'update'),
                      settings: RouteSettings(arguments: {'jobData': postData}),
                    ),
                  );
                },
                shape: GFButtonShape.pills,
                color: Color.fromARGB(255, 148, 0, 239),
                icon: Icon(
                  Icons.edit_document,
                  size: 18,
                  color: Colors.white,
                ),
                text: 'Update',
              )
            ],
          ),
          gap_10,
          Divider(color: theme.colorScheme.outline),
          gap_10,
          tableRows(
            icon: Icons.local_activity,
            title: "Skills",
            value: UtilityFunctions()
                .convertListToCommaSeparatedString(postData['skills']),
          ),
          gap_10,
          tableRows(
            icon: CupertinoIcons.money_dollar_circle_fill,
            title: "Budget",
            value: UtilityFunctions().formatSalary(postData['budget']),
          ),
          // gap_10,
          // tableRows(
          //   icon: Icons.location_city_sharp,
          //   title: "Location",
          //   value: UtilityFunctions().convertListToCommaSeparatedString(
          //       postData['preferredLocation']),
          // ),
          gap_10,
          tableRows(
            icon: Icons.verified_user,
            title: "Applicants",
            value: applicantsCount.toString(),
          ),
          gap_10,
          tableRows(
            icon: Icons.calendar_month,
            title: "Posted on",
            value: UtilityFunctions()
                .convertTimestampToDateString(postData['jobPostDate']),
          ),
          gap_10,
          tableRows(
            icon: Icons.timer,
            title: "Expires on",
            value: UtilityFunctions()
                .convertTimestampToDateString(postData['expiryDate']),
          ),
          gap_10,
          _buildExpansionTile(),
          gap_10,
          status == 'active'
              ? _buildActionButtonRow()
              : _buildInactiveActionButtonColumn(),
        ],
      ),
    );
  }

  Widget tableRows({IconData? icon, required String title, required value}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              UtilityFunctions().truncateText(value, 25),
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
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
}
