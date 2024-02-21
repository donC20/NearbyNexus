// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, avoid_unnecessary_containers

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:logger/logger.dart';

class MyApplications extends StatefulWidget {
  const MyApplications({Key? key}) : super(key: key);

  @override
  _MyApplicationsState createState() => _MyApplicationsState();
}

class _MyApplicationsState extends State<MyApplications> {
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
      backgroundColor: KColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: KColors.backgroundDark,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Applications",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final userData = snapshot.data?.data();
        if (userData == null) {
          return Text('No user data found');
        }

        final jobsApplied = userData['jobs_applied'];
        if (jobsApplied == null || jobsApplied.isEmpty) {
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
                  style: TextStyle(color: Colors.white),
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
          );
        } else {
          return ListView.builder(
            itemCount: jobsApplied.length,
            itemBuilder: (context, index) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .doc(jobsApplied[index])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final applicationData = snapshot.data?.data();
                  if (applicationData == null) {
                    return Text('No application data found');
                  }

                  // Cast applicationData to Map<String, dynamic>
                  final Map<String, dynamic> applicationDataMap =
                      applicationData as Map<String, dynamic>;

                  // Access the jobId from the applicationData
                  final jobId = applicationDataMap['jobId'];
                  // Now fetch the document from the job_posts collection using the jobId
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('job_posts')
                        .doc(jobId)
                        .snapshots(),
                    builder: (context, jobSnapshot) {
                      if (jobSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (jobSnapshot.hasError) {
                        return Text('Error: ${jobSnapshot.error}');
                      }

                      final jobData = jobSnapshot.data?.data();
                      if (jobData == null) {
                        return Text('No job data found for jobId: $jobId');
                      }
                      final Map<String, dynamic> jobDataMap =
                          jobData as Map<String, dynamic>;
                      return StreamBuilder<Map<String, dynamic>>(
                        stream: VendorCommonFn().streamUserData(
                            uidParam: jobDataMap['jobPostedBy']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final jobPostedByData = snapshot.data;
                          if (jobPostedByData == null) {
                            return Text('No user data found');
                          }

                          // Filter the applicants list to get data for the current user

                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/job_detail_page',
                                  arguments: {
                                    'job_data': jobData,
                                    'posted_user': jobPostedByData,
                                    'post_id': jobId
                                  });
                            },
                            child: Card(
                              margin: EdgeInsets.all(8),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(
                                  minHeight: 250,
                                  maxHeight:
                                      300, // Set a minimum height for the card
                                ),
                                child: Stack(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        UtilityFunctions().truncateText(
                                            jobData['jobTitle'], 20),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      // Display the name of the user who posted the job
                                      subtitle: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: jobPostedByData['name'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextSpan(
                                              text:
                                                  ", ${UtilityFunctions().findTimeDifference(jobData["jobPostDate"])}",
                                              style: TextStyle(
                                                color: const Color.fromARGB(
                                                    255, 79, 79, 79),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Display the image of the user who posted the job
                                      leading: UserLoadingAvatar(
                                        userImage: jobPostedByData['image'],
                                      ),
                                      trailing: PopupMenuButton<String>(
                                        position: PopupMenuPosition.under,
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                          PopupMenuItem<String>(
                                            value: 'revoke',
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 15),
                                                Text(
                                                  'Revoke application',
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
                                            case 'revoke':
                                              removeFromSavedJobs(
                                                  jobsApplied[index],
                                                  jobId,
                                                  context);
                                              break;
                                          }
                                        },
                                      ),
                                      // Add a custom connecting line
                                    ),
                                    Positioned(
                                      left: 30,
                                      top: 56,
                                      child: SvgPicture.asset(
                                        "assets/images/line_one.svg",
                                        height: 45,
                                      ),
                                    ),
                                    Positioned(
                                      left: 60.5,
                                      top: 88.5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "You ,",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black54),
                                          ),
                                          SizedBox(
                                            width: MediaQuery.sizeOf(context)
                                                    .width -
                                                110,
                                            child: Text(
                                              UtilityFunctions().truncateText(
                                                  applicationDataMap[
                                                      'proposal_description'],
                                                  190),
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: const Color.fromARGB(
                                                      255, 126, 126, 126),
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  removeFromSavedJobs(jobId, jobUniqueId, BuildContext context) async {
    logger.f(jobId);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(await VendorCommonFn().getUserUIDFromSharedPreferences())
          .update({
        'jobs_applied': FieldValue.arrayRemove([jobId])
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(await VendorCommonFn().getUserUIDFromSharedPreferences())
          .update({
        'jobs_applied_list': FieldValue.arrayRemove([jobUniqueId])
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
}