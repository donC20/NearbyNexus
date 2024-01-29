// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, avoid_print

import 'dart:async';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:getwidget/getwidget.dart';
import 'package:logger/logger.dart';

class JobDetailPage extends StatefulWidget {
  const JobDetailPage({super.key});

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
// controller
  late StreamController<Map<String, dynamic>> _streamController;

  bool isExpanded = false;
  var logger = Logger();

  // user
  Map<String, dynamic> currentUserData = {};

  // bool
  bool isApplied = false;
  bool isSaved = false;
  bool isPageLoaded = false;
  bool isPressDelay = false;

  @override
  void initState() {
    _streamController = StreamController<Map<String, dynamic>>();
    initializeUserData();
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<void> initializeUserData() async {
    setState(() {
      isPageLoaded = false;
    });
    VendorCommonFn().streamUserData().listen((userData) {
      if (userData.isNotEmpty) {
        setState(() {
          currentUserData = userData;
          isPageLoaded = true;
        });
      } else {
        setState(() {
          isPageLoaded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    //
    if (argument['post_id'] != null && currentUserData.isNotEmpty) {
      List<dynamic> jobsApplied = currentUserData["jobs_applied"];
      List<dynamic> savedJobs = currentUserData["saved_jobs"];
      if (jobsApplied.contains(argument['post_id'])) {
        setState(() {
          isApplied = true;
        });
      } else {
        setState(() {
          isApplied = false;
        });
      }

      // saved jobs
      if (savedJobs.contains(argument['post_id'])) {
        setState(() {
          isSaved = true;
        });
      } else {
        setState(() {
          isSaved = false;
        });
      }
    }
    //
    return Scaffold(
      backgroundColor: KColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: KColors.backgroundDark,
        iconTheme: IconThemeData(color: KColors.primary),
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GFButton(
              onPressed: () {},
              shape: GFButtonShape.pills,
              icon: Icon(
                Icons.face,
                color: Colors.white,
                size: 20,
              ),
              text: "Bids",
              size: GFSize.MEDIUM,
              color: Color.fromARGB(193, 5, 5, 5),
              borderSide: BorderSide(color: Color.fromARGB(75, 255, 255, 255)),
            ),
          )
        ],
      ),
      body: isPageLoaded
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    _header(context, argument),
                    _jobDescription(context, argument),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _apply(context, argument['post_id']),
                )
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

// functions

  Widget _header(BuildContext context, argument) {
    return Container(
      color: KColors.backgroundDark,
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(100)),
                child: UserLoadingAvatar(
                  userImage: argument["posted_user"]["image"],
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    argument["job_data"]["jobTitle"],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KColors.titleDark,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    UtilityFunctions().findTimeDifference(
                        argument["job_data"]["jobPostDate"]),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: KColors.subtitle,
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerStatic("Salary",
                  "₹ ${UtilityFunctions().formatSalary(argument["job_data"]["budget"])}"),
              _headerStatic("Applicants", "45"),
              _headerStatic(
                  "Expiry",
                  UtilityFunctions().findTimeDifference(
                      argument["job_data"]["expiryDate"],
                      trailingText: "left")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStatic(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: KColors.subtitle,
          ),
        ),
        SizedBox(height: 5),
        Text(
          sub,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: KColors.subTextColors,
          ),
        )
      ],
    );
  }

  Widget _jobDescription(BuildContext context, argument) {
    final PageController pageController = PageController(initialPage: 0);
    int currentPage = 0;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight =
        screenHeight > 455 ? screenHeight - 455 : screenHeight;
    return Column(
      children: [
        SizedBox(
          height:
              50, // Set a fixed height for the CustomSlidingSegmentedControl
          child: CustomSlidingSegmentedControl<int>(
            padding: 35,
            initialValue: 1,
            children: {
              1: Row(
                children: [
                  Image.asset("assets/icons/document.png",
                      height: 20, color: KColors.primary),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Description",
                    style: TextStyle(
                        color: const Color.fromARGB(126, 255, 255, 255)),
                  )
                ],
              ),
              2: Row(
                children: [
                  Image.asset("assets/icons/user.png",
                      height: 20, color: KColors.primary),
                  SizedBox(
                    width: 10,
                  ),
                  Text("More info",
                      style: TextStyle(
                          color: const Color.fromARGB(126, 255, 255, 255)))
                ],
              ),
            },
            decoration: BoxDecoration(
              color: CupertinoColors.darkBackgroundGray,
              borderRadius: BorderRadius.circular(50),
            ),
            thumbDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 43, 43, 43),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: Offset(
                    0.0,
                    2.0,
                  ),
                ),
              ],
            ),
            curve: Curves.easeInCubic,
            onValueChanged: (v) {
              setState(() {
                currentPage = v - 1; // Subtract 1 from v
                pageController.animateToPage(
                  currentPage,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
          ),
        ),
        Container(
          height: containerHeight,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            controller: pageController,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
            },
            children: [
              SingleChildScrollView(
                child: Html(
                  data: argument["job_data"]["jobDescription"],
                  style: {
                    "body": Style(
                      color: Colors.white, // Text color for the body
                    ),
                    "p": Style(
                      fontSize: FontSize(14), // Font size for paragraphs
                      color: Colors.white, // Text color for paragraphs
                    ),
                    // Add more styles as needed for different HTML elements
                  },
                ),
              ),

              // Add your content for the "More info" tab here
              Container(
                padding: EdgeInsets.all(16),
                child: additionalInfo(argument),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget additionalInfo(argument) {
    Map<String, dynamic> employerDetails = {
      "name": argument["posted_user"]["name"],
      "Job posted": 0,
      "Last active": "10 days ago"
    };

    Map<String, IconData> iconMapEmployer = {
      "name": Icons.person,
      "Job posted": Icons.work,
      "Last active": Icons.access_time,
    };
    Map<String, IconData> iconMapJobInfo = {
      "Location": Icons.location_pin,
      "Skills": Icons.attractions,
      "Job posted on": Icons.date_range,
    };

    Map<String, dynamic> jobInfo = {
      "Location": argument["job_data"]["preferredLocation"],
      "Skills": argument["job_data"]["skills"],
      "Job posted on": UtilityFunctions()
          .convertTimestampToDateString(argument["job_data"]["jobPostDate"]),
    };
    print(argument["job_data"]["expiryDate"]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "Employer Details",
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(198, 255, 255, 255)),
      ),
      SizedBox(
        height: 15,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: employerDetails.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          iconMapEmployer[entry.key],
                          size: 20,
                          color: Color.fromARGB(179, 198, 198, 198),
                        ),
                        SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: Color.fromARGB(179, 244, 244, 244),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
            .toList(), // Convert the iterable to a list
      ),
      SizedBox(
        height: 15,
      ),
      Text(
        "Job Details",
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(198, 255, 255, 255)),
      ),
      SizedBox(
        height: 15,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: jobInfo.entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              iconMapJobInfo[entry.key],
                              size: 20,
                              color: Color.fromARGB(179, 198, 198, 198),
                            ),
                            SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: Color.fromARGB(179, 244, 244, 244),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        // Check if the entry value is a List
                        if (entry.value is List)
                          Text(
                            (entry.value as List).join(", "),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        else
                          Text(
                            entry.value.toString(),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(), // Convert the iterable to a list
      )
    ]);
  }

  Widget _apply(BuildContext context, docId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(top: 54),
      child: Row(
        children: [
          isApplied
              ? Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(KColors.primary),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 16))),
                    onPressed: () {
                      Navigator.pushNamed(context, "");
                    },
                    child: Text(
                      "View my application",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(KColors.primary),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 16))),
                    onPressed: () {
                      Navigator.pushNamed(context, "/bid_for_job",
                          arguments: {"post_id": docId});
                    },
                    child: Text(
                      "I'm interested",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          SizedBox(width: 12),
          SizedBox(
            height: 50,
            width: 60,
            child: OutlinedButton(
              onPressed: () async {
                try {
                  if (isSaved) {
                    await removeFromSavedJobs(docId);
                    print("Removed from saved jobs");
                  } else {
                    await addToSavedJobs(docId);
                    print("Added to saved jobs");
                  }
                } catch (e) {
                  print("Error: $e");
                }

                setState(() {
                  isSaved = !isSaved;
                });
              },
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(color: KColors.primary),
                ),
              ),
              child: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: KColors.primary,
              ),
            ),
          )
        ],
      ),
    );
  }

  addToSavedJobs(jobId) async {
    try {
      print('Adding job: $jobId');
      setState(() {
        isPressDelay = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(await VendorCommonFn().getUserUIDFromSharedPreferences())
          .update({
        'saved_jobs': FieldValue.arrayUnion([jobId])
      });

      // Optional: Add any additional logic upon successful addition.
    } catch (error) {
      print('Error adding job: $error');
      // Handle the error as needed, e.g., show a snackbar or display an error message.
    } finally {
      setState(() {
        isPressDelay = false;
      });
    }
  }

  removeFromSavedJobs(jobId) async {
    try {
      print('Removing job: $jobId');
      setState(() {
        isPressDelay = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(await VendorCommonFn().getUserUIDFromSharedPreferences())
          .update({
        'saved_jobs': FieldValue.arrayRemove([jobId])
      });

      setState(() {
        isPressDelay = false;
      });
    } catch (error) {
      print('Error removing job: $error');
      // Handle the error as needed, e.g., show a snackbar or display an error message.
    } finally {
      setState(() {
        isPressDelay = false;
      });
    }
  }
}
