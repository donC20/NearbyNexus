// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:NearbyNexus/screens/vendor/components/vendor_image_name_update.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorProfile extends StatefulWidget {
  const VendorProfile({super.key});

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? uid = '';
  @override
  void initState() {
    super.initState();
    initUser();
    // Future.delayed(Duration.zero, () {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    //   getTheVendor(uid);
    // });
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
    getTheVendor(uid);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {

    // });
  }

  // Variables to be used

  bool isFetching = true;
  bool isImageUploading = false;
  String name = "loading...";
  String dpImage =
      "https://dealio.imgix.net/uploads/147885uploadshotel-pool-canaves.jpg";
  String geoLocation = "loading...";
  List<dynamic>? serviceList = [];
  List<dynamic>? workingDays = [];
  List<dynamic>? languages = [];
  double rating = 0.0;
  String about = '';
  Map<String, dynamic> summaryData = {};
  var log = Logger();
  void handleImageUploading(bool value) {
    setState(() {
      isImageUploading = value;
    });
  }

// shoe dialog
  void _showDialog(BuildContext context) {
    showDialog(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: ContentBox(
            uid: uid,
            onImageUploading: (value) {
              setState(() {
                isImageUploading = value;
              });
            },
            parentContext: context,
          ),
        );
      },
    );
  }

  Future<void> getTheVendor(uid) async {
// Get Vendor details by uid
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> vendorData =
            snapshot.data() as Map<String, dynamic>;
        log.e(vendorData);

        setState(() {
          name = vendorData['name'];
          dpImage = vendorData['image'] ??
              "https://dealio.imgix.net/uploads/147885uploadshotel-pool-canaves.jpg";
          geoLocation = vendorData['geoLocation'];
          geoLocation = vendorData['geoLocation'];
          isFetching = false;
          serviceList = vendorData['services'];
          languages = vendorData['languages'] ?? [];
          about = vendorData['about'];
          workingDays = vendorData['working_days'];
          rating = vendorData['actualRating'];
        });
      }
    });
    summaryContainerStream();
  }

  summaryContainerStream() {
    // StreamController<dynamic> controller = StreamController<dynamic>();
    _firestore
        .collection('service_actions')
        .where('referencePath',
            isEqualTo: _firestore.collection('users').doc(uid))
        .snapshots()
        .listen((event) {
      int all = event.size;
      int jobCompletedCount =
          event.docs.where((doc) => doc['clientStatus'] == 'finished').length;
      double jobcompConverted = double.parse(jobCompletedCount.toString());
      int active =
          event.docs.where((doc) => doc['status'] == 'accepted').length;
      int rejected =
          event.docs.where((doc) => doc['status'] == 'rejected').length;
      int newJobs = event.docs.where((doc) => doc['status'] == 'new').length;

      List<dynamic> userReferences = [];

      // Get all userReference values
      for (var doc in event.docs) {
        var userReference = doc['userReference'];
        if (userReference != null) {
          userReferences.add(userReference);
        }
      }
      setState(() {
        summaryData = {
          "all": all,
          "active": active,
          "rejected": rejected,
          "jobCompletedCount": jobcompConverted,
          "newJobs": newJobs,
          "userReferences": userReferences,
        };
      });
      // print(summaryData);
      // controller.add(summaryData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: isFetching == true
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: const Color.fromARGB(255, 255, 255, 255), size: 80),
              ),
            )
          :
          // Profile image and all
          Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height - 550,
                      child: isImageUploading
                          ? Center(
                              child: LoadingAnimationWidget.inkDrop(
                                  color: Colors.white, size: 30),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(25)),
                              child: Image.network(
                                dpImage,
                                width: 80,
                                height: 80,
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else if (loadingProgress
                                              .expectedTotalBytes !=
                                          null &&
                                      loadingProgress.cumulativeBytesLoaded <
                                          loadingProgress.expectedTotalBytes!) {
                                    return Center(
                                      child:
                                          LoadingAnimationWidget.discreteCircle(
                                        color: Colors.grey,
                                        size: 40,
                                      ),
                                    );
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              ),
                            ),
                    ),
                    Positioned(
                        right: 10,
                        top: 30,
                        child: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color:
                                  Color.fromARGB(36, 0, 0, 0).withOpacity(0.3)),
                          child: TextButton(
                              onPressed: () {
                                _showDialog(context);
                              },
                              child: Text(
                                "Edit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        )),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(71, 0, 0, 0),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(25),
                              bottomLeft: Radius.circular(25)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    geoLocation,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // Bio of vendor
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 5),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "update_vendor_screen");
                        },
                        icon: Icon(
                          Icons.edit,
                        )),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      children: [
                        // user status rating etc..
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            modernCircularProgressBar(
                                summaryData['jobCompletedCount'] as double,
                                "Jobs done",
                                1000,
                                false,
                                Colors.green),
                            SizedBox(width: 20),
                            modernCircularProgressBar(rating, "Rating", 5, true,
                                Colors.amber), // Adjusted to out of 5
                            SizedBox(width: 20),
                            modernCircularProgressBar(3, "Experience", 5, false,
                                Colors.blue), // Adjusted to out of 5
                          ],
                        ),

                        SizedBox(
                          height: 15,
                        ),

                        // About me container
                        Text("About me",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 0,
                        ),

                        about.isEmpty
                            ? Center(
                                child: Text("Please add your about.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal)),
                              )
                            : Text(
                                about,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 1.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text("What I do",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        // list of services
                        serviceList!.isNotEmpty
                            ? Wrap(
                                runSpacing: -5.0,
                                spacing: 8.0,
                                children: serviceList!.map((e) {
                                  return Chip(
                                      labelStyle:
                                          TextStyle(color: Colors.white54),
                                      side: BorderSide(
                                          color: const Color.fromARGB(
                                              194, 158, 158, 158)),
                                      backgroundColor:
                                          Color.fromARGB(255, 0, 0, 0),
                                      label: Text(convertToSentenceCase(e)));
                                }).toList())
                            : Text("Services not available.",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 1.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text("My working days",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        workingDays!.isNotEmpty
                            ? Wrap(
                                spacing: 5.0,
                                children: workingDays!.map((e) {
                                  return Chip(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: const Color.fromARGB(
                                            194, 158, 158, 158),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Set your desired border radius
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    label: Text(
                                      convertToSentenceCase(e),
                                      style: TextStyle(
                                        color:
                                            const Color.fromARGB(137, 0, 0, 0),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                            : Text("Working days not available.",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 1.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("Languages",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        languages!.isEmpty
                            ? Center(
                                child: Text("Please add your.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal)),
                              )
                            : Wrap(
                                spacing: 10,
                                runSpacing: 15,
                                children: [
                                  for (int index = 0;
                                      index < languages!.length;
                                      index++)
                                    Chip(label: Text(languages![index])),
                                ],
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 1.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("What others say.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),

                        SizedBox(
                          height: 300,
                          child: StreamBuilder<
                              DocumentSnapshot<Map<String, dynamic>>>(
                            stream: _firestore
                                .collection('users')
                                .doc(uid)
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error: ${snapshot.error.toString()}'));
                              } else if (snapshot.hasData &&
                                  snapshot.data!.exists) {
                                Map<String, dynamic> userData = snapshot.data!
                                    .data() as Map<String, dynamic>;
                                List<DocumentReference> allRatings =
                                    List<DocumentReference>.from(
                                        userData['allRatings']);
                                List<Future<Map<String, dynamic>>>
                                    ratingDataFutures =
                                    allRatings.map((ratingRef) async {
                                  DocumentSnapshot ratingSnapshot =
                                      await ratingRef.get();
                                  Map<String, dynamic> ratingData =
                                      ratingSnapshot.data()
                                          as Map<String, dynamic>;

                                  // Fetch user data for this rating
                                  DocumentReference userRef = ratingData[
                                      'ratedBy']; // Assuming 'ratedBy' is the field referencing the user
                                  DocumentSnapshot userSnapshot =
                                      await userRef.get();
                                  Map<String, dynamic> userData = userSnapshot
                                      .data() as Map<String, dynamic>;

                                  return {
                                    'userName': userData['name'],
                                    'userImage': userData['image'],
                                    'feedback': ratingData['feedback'],
                                    'rating': ratingData['rating'],
                                    'timeRated': ratingData['timeRated'],
                                  };
                                }).toList();

                                return FutureBuilder<
                                    List<Map<String, dynamic>>>(
                                  future: Future.wait(ratingDataFutures),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<Map<String, dynamic>>>
                                          ratingSnapshot) {
                                    if (ratingSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (ratingSnapshot.hasError) {
                                      return Center(
                                          child: Text(
                                              'Error: ${ratingSnapshot.error.toString()}'));
                                    } else if (ratingSnapshot.hasData) {
                                      List<Map<String, dynamic>>
                                          ratingDataList = ratingSnapshot.data!;
                                      return ListView.builder(
                                        itemCount: ratingDataList.length,
                                        itemBuilder: (context, index) {
                                          // Extract data from ratingDataList
                                          String reviewerName =
                                              ratingDataList[index]['userName'];
                                          String reviewText =
                                              ratingDataList[index]['feedback'];
                                          String image = ratingDataList[index]
                                              ['userImage'];
                                          double rating =
                                              ratingDataList[index]['rating'];
                                          Timestamp timePosted =
                                              ratingDataList[index]
                                                  ['timeRated'];

                                          return UserReviewContainer(
                                            reviewerName: reviewerName,
                                            reviewText: reviewText,
                                            image: image,
                                            rating: rating,
                                            timePosted: timePosted,
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                          child: Text(
                                        'No data available.',
                                        style: TextStyle(color: Colors.white),
                                      ));
                                    }
                                  },
                                );
                              } else {
                                return Center(
                                    child: Text('No data available.',
                                        style: TextStyle(color: Colors.white)));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

// widgets
  Widget modernCircularProgressBar(double value, String tagline, int maxValue,
      bool isProgressable, Color progressColor) {
    double percentage = (value / maxValue) * 100;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color:
                    Color.fromARGB(0, 255, 255, 255), // Add a background color
              ),
              child: Center(
                child: isProgressable
                    ? Text(
                        '$value/$maxValue',
                        style: TextStyle(
                          color: Color.fromARGB(255, 205, 137, 0),
                          fontSize: 12, // Adjusted font size
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          fontSize: 12, // Adjusted font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(
              width: 75,
              height: 75,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor), // Change color to indicate progress
                backgroundColor: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          tagline,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
