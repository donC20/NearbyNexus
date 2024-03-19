// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:NearbyNexus/components/my_date_util.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:NearbyNexus/screens/vendor/screens/gmap_view.dart';
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
    // _streamController = StreamController<Map<String, dynamic>>();
    initializeUserData();
    fetchCurrentUserId();
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

  String currentUser = '';
  Future<void> fetchCurrentUserId() async {
    final userUID = await VendorCommonFn().getUserUIDFromSharedPreferences();

    setState(() {
      currentUser = userUID;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    //
    // int documentCount = 0;
    // print(argument);
    // FirebaseFirestore.instance
    //     .collection('job_posts')
    //     .where("jobPostedBy",
    //         isEqualTo: FirebaseFirestore.instance
    //             .collection('users')
    //             .doc(ApiFunctions.user?.uid))
    //     .get()
    //     .then((querySnapshot) {
    //   // Get the count of documents
    //   setState(() {
    //     documentCount = querySnapshot.size;
    //   });
    //   print('Document count: $documentCount');
    // });
    //
    logger.e(currentUserData);
    if (argument['post_id'] != null && currentUserData.isNotEmpty) {
      List<dynamic> jobsApplied = currentUserData["jobs_applied_list"] ?? [];
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: KColors.primary),
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GFButton(
              onPressed: () {
                Navigator.pushNamed(context, '/proposal_screen',
                    arguments: {'post_id': argument['post_id']});
              },
              shape: GFButtonShape.pills,
              icon: Icon(
                Icons.all_out,
                size: 20,
              ),
              text: "Proposals",
              size: GFSize.MEDIUM,
              textColor: Theme.of(context).colorScheme.onSecondary,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          _apply(context, argument['post_id']),
          IconButton(
              onPressed: () async {
                try {
                  if (isSaved) {
                    await removeFromSavedJobs(argument['post_id']);
                    print("Removed from saved jobs");
                  } else {
                    await addToSavedJobs(argument['post_id']);
                    print("Added to saved jobs");
                  }
                } catch (e) {
                  print("Error: $e");
                }

                setState(() {
                  isSaved = !isSaved;
                });
              },
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: KColors.primary,
              )),
        ],
      ),
      body: isPageLoaded
          ? Column(
              children: [
                _header(context, argument),
                _jobDescription(context, argument),
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
      color: Theme.of(context).colorScheme.background,
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
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
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    UtilityFunctions().convertTimestampToDateString(
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _headerStatic("Salary",
                  "₹ ${UtilityFunctions().formatSalary(argument["job_data"]["budget"])}"),
              SizedBox(
                width: 30,
              ),
              _headerStatic("Applicants", "45"),
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
          ),
        ),
        SizedBox(height: 5),
        Text(
          sub,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: KColors.primary,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomSlidingSegmentedControl<int>(
                padding: 35,
                initialValue: 1,
                children: {
                  1: Row(
                    children: [
                      Image.asset("assets/icons/document.png",
                          height: 20, color: KColors.primary),
                    ],
                  ),
                  2: Icon(
                    Icons.info,
                    color: KColors.primary,
                  ),
                  // 2: Image.asset("assets/images/vector/info_circle.svg",
                  //     height: 20, color: KColors.primary),
                },
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  border:
                      Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(50),
                ),
                thumbDecoration: BoxDecoration(
                  color: Color.fromARGB(111, 79, 79, 79),
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
            ],
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
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary, // Text color for the body
                    ),
                    "p": Style(
                      fontSize: FontSize(14), // Font size for paragraphs
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary, // Text color for paragraphs
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
      // "Job posted": FirebaseFirestore.instance.collection('job_posts').where(
      //     "jobPostedBy",
      //     isEqualTo: FirebaseFirestore.instance
      //         .collection('users')
      //         .doc(ApiFunctions.user?.uid)),
      "Last active": MyDateUtil.getLastActiveTime(
          context: context, lastActive: argument["posted_user"]["last_seen"])
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
        ),
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
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onTertiary,
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
        ),
      ),
      SizedBox(
        height: 15,
      ),
      // ListTile(trailing: ,),
      SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.location_pin),
              SizedBox(
                width: 8,
              ),
              Text("Location")
            ],
          ),
          GFButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GmapView(
                          userLocation: argument["job_data"]
                              ["preferredLocation"])));
            },
            icon: Icon(CupertinoIcons.map),
            text: "Open in map",
            shape: GFButtonShape.pills,
            color: Theme.of(context).colorScheme.onTertiary,
            textStyle:
                TextStyle(color: Theme.of(context).colorScheme.onSecondary),
            type: GFButtonType.outline,
          )
        ],
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
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontSize: 12),
                          )
                        else
                          Text(
                            entry.value.toString(),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontSize: 12),
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
    return GFButton(
      onPressed: () async {
        if (isApplied) {
          try {
            // Fetch the user document containing the list of applied jobs
            Map<String, dynamic>? userDoc = await VendorCommonFn()
                .fetchParticularDocument('users', currentUser);

            logger.e('userData $userDoc');

            if (userDoc != null) {
              List<dynamic> appliedJobsList = userDoc['jobs_applied'] ?? [];
              logger.e('applied job list $appliedJobsList');

              // Iterate through the list of applied jobs
              for (String jobId in appliedJobsList) {
                // Fetch the application document based on the jobId
                DocumentSnapshot applicationSnapshot = await FirebaseFirestore
                    .instance
                    .collection('applications')
                    .doc(jobId)
                    .get();

                if (applicationSnapshot.exists) {
                  // Get the application data
                  Map<String, dynamic> applicationData =
                      applicationSnapshot.data() as Map<String, dynamic>;
                  // Check if the jobId matches the argument jobId
                  if (applicationData['jobId'] == docId) {
                    // Navigate to proposal_view_screen with the application data
                    Navigator.pushNamed(context, '/proposal_view_screen',
                        arguments: {'proposal': applicationData});
                    return; // Exit the loop if a matching application is found
                  }
                }
              }

              // If no matching application is found
              logger.e("No matching application found for jobId: $docId");
            } else {
              logger.e("User document not found");
            }
          } catch (e) {
            print("Error: $e"); // Handle the error as needed
          }
        } else {
          Navigator.pushNamed(context, "/bid_for_job",
              arguments: {"post_id": docId});
        }
      },
      text: isApplied ? 'View application' : 'Apply',
      color: KColors.primary,
      shape: GFButtonShape.pills,
      size: GFSize.MEDIUM,
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
