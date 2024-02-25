// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, use_build_context_synchronously

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:logger/logger.dart';

class SavedJobsScreen extends StatefulWidget {
  @override
  _SavedJobsScreenState createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();
  String currentUser = '';
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

  Future<void> _refreshData() async {
    // Implement the logic to refresh the data
    // For example, you can refetch the user data
    fetchCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Saved Jobs",
        ),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: _refreshData,
        child: _buildSavedJobsList(),
      ),
    );
  }

  Widget _buildSavedJobsList() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child:
                  CircularProgressIndicator()); // Return a loading indicator while waiting for data
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final userData = snapshot.data?.data();
        if (userData == null) {
          return Text(
              'No user data found'); // Return a message if no user data is found
        }

        final List<dynamic> jobsAppliedIds = userData['saved_jobs'] ?? [];

        if (jobsAppliedIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  "There are no saved jobs please add some..",
                ),
                SizedBox(
                  height: 15,
                ),
                GFButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/broadcast_page");
                  },
                  text: 'View jobs',
                  shape: GFButtonShape.pills,
                  icon: Icon(
                    Icons.open_in_browser_rounded,
                    color: Colors.white,
                  ),
                  size: GFSize.MEDIUM,
                  color: const Color.fromARGB(255, 84, 84, 84),
                )
              ],
            ),
          ); // Return a message if no user data is found
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              itemCount: jobsAppliedIds.length,
              itemBuilder: (context, index) {
                final jobId = jobsAppliedIds[index];
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('job_posts')
                      .doc(jobId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                          child:
                              CircularProgressIndicator()); // Return a loading indicator while waiting for data
                    }

                    if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Return an error message if there's an error
                    }

                    final jobData = snapshot.data
                        ?.data(); // Extract the job data from the snapshot

                    if (jobData == null) {
                      return Text(
                          'No job data found'); // Return a message if no job data is found
                    }

                    final DocumentReference jobPostBy = jobData[
                        'jobPostedBy']; // Extract the user ID who posted the job
                    return StreamBuilder<Map<String, dynamic>>(
                      stream:
                          VendorCommonFn().streamUserData(uidParam: jobPostBy),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child:
                                  CircularProgressIndicator()); // Return a loading indicator while waiting for data
                        }

                        if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); // Return an error message if there's an error
                        }

                        final jobPostByData = snapshot
                            .data; // Extract the user data who posted the job

                        if (jobPostByData == null) {
                          return Text(
                              'No user data found'); // Return a message if no user data is found
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/job_detail_page',
                                arguments: {
                                  'job_data': jobData,
                                  'posted_user': jobPostByData,
                                  'post_id': jobId
                                });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(43, 158, 158, 158)),
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                              boxShadow: Theme.of(context).brightness ==
                                      Brightness.dark
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
                            child: ListTile(
                              title: Text(
                                UtilityFunctions()
                                    .truncateText(jobData['jobTitle'], 20),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              // Display the name of the user who posted the job
                              subtitle: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiary, // Default text color
                                    fontSize: 16, // Default font size
                                  ),
                                  children: [
                                    TextSpan(
                                      text: jobPostByData['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text:
                                          ", ${UtilityFunctions().findTimeDifference(jobData["jobPostDate"])}",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Display the image of the user who posted the job
                              leading: UserLoadingAvatar(
                                  userImage: jobPostByData['image']),

                              trailing: PopupMenuButton<String>(
                                position: PopupMenuPosition.under,
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  PopupMenuItem<String>(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 15),
                                        Text(
                                          'Remove',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 14,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (String value) {
                                  // Handle the selected option
                                  switch (value) {
                                    case 'remove':
                                      removeFromSavedJobs(jobId, context);
                                      break;
                                  }
                                },
                              ),
                              // Add more fields as needed
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  height: 15,
                );
              },
            ),
          );
        }
      },
    );
  }
}

removeFromSavedJobs(jobId, BuildContext context) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(await VendorCommonFn().getUserUIDFromSharedPreferences())
        .update({
      'saved_jobs': FieldValue.arrayRemove([jobId])
    });
    UtilityFunctions().showSnackbar(
        "Removed from your bookmarks!", Colors.greenAccent, context);
  } catch (error) {
    print('Error removing job: $error');
    UtilityFunctions()
        .showSnackbar("Something went wrong!", Colors.red, context);
    // Handle the error as needed, e.g., show a snackbar or display an error message.
  } finally {}
}
