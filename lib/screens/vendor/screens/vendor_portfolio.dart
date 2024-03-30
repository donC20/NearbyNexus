// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:NearbyNexus/screens/user/screens/chatScreen/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorPortfolio extends StatefulWidget {
  const VendorPortfolio({super.key});

  @override
  State<VendorPortfolio> createState() => _VendorPortfolioState();
}

class _VendorPortfolioState extends State<VendorPortfolio> {
  String vendorId = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      vendorId = ModalRoute.of(context)!.settings.arguments as String;
    });
    fetchUserData();
    getTheVendor(vendorId);
  }

  // Variables to be used
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isFetching = true;
  bool isImageUploading = false;
  bool isFavourited = false;
  String name = "loading...";
  double totalRating = 0.0;
  String dpImage =
      "https://dealio.imgix.net/uploads/147885uploadshotel-pool-canaves.jpg";
  String geoLocation = "loading...";
  List<dynamic> serviceList = [];
  List<dynamic> workingDays = [];
  List<dynamic>? languages = [];
  String activityStatus = "available";
  String about = '';
  String uid = '';
  var logger = Logger();
  Map<String, dynamic> summaryData = {};

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
        logger.d(vendorData);
        setState(() {
          name = vendorData['name'];
          totalRating = vendorData['actualRating'].toDouble();
          dpImage = vendorData['image'];
          geoLocation = vendorData['geoLocation'];
          isFetching = false;
          serviceList = vendorData['services'];
          languages = vendorData['languages'] ?? [];
          about = vendorData['about'];
          workingDays = vendorData['working_days'];
          activityStatus = vendorData['activityStatus'];
        });
        summaryContainerStream(uid);
      }
    });
  }

  // fetch user
  Future<void> fetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
    _firestore.collection('users').doc(uid).snapshots().listen((event) {
      if (event.exists) {
        var data = event.data() as Map<String, dynamic>;
        List<String> userFavourites = List<String>.from(data['userFavourites']);
        // List<String> favList = [];
        if (userFavourites.contains(vendorId)) {
          setState(() {
            isFavourited = true;
          });
        }
      }
    });
  }

  summaryContainerStream(uid) {
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25)),
                        child: Image.network(
                          dpImage.isEmpty
                              ? "https://static.vecteezy.com/system/resources/previews/004/141/669/non_2x/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg"
                              : dpImage,
                          width: 80,
                          height: 80,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else if (loadingProgress.expectedTotalBytes !=
                                    null &&
                                loadingProgress.cumulativeBytesLoaded <
                                    loadingProgress.expectedTotalBytes!) {
                              return Center(
                                child: LoadingAnimationWidget.discreteCircle(
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
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                var data = await _firestore
                                    .collection('users')
                                    .doc(uid)
                                    .get();

                                if (data.exists) {
                                  List<String> userFavourites =
                                      List<String>.from(data['userFavourites']);

                                  if (!userFavourites.contains(vendorId)) {
                                    // Vendor ID not in the list, add it and update Firestore
                                    userFavourites.add(vendorId);
                                    setState(() {
                                      isFavourited = true;
                                    });
                                  } else {
                                    // Vendor ID already in the list, remove it and update Firestore
                                    userFavourites.remove(vendorId);
                                    setState(() {
                                      isFavourited = false;
                                    });
                                  }

                                  await _firestore
                                      .collection('users')
                                      .doc(uid)
                                      .update({
                                    'userFavourites': userFavourites,
                                  });

                                  final snackBar = SnackBar(
                                    duration: Duration(seconds: 1),
                                    content: Text(
                                      isFavourited
                                          ? "Added to favorites."
                                          : "Removed from favorites.",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Colors.white,
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              icon: Icon(
                                isFavourited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 25,
                              ))
                        ],
                      ),
                    ),
                  ],
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
                            modernCircularProgressBar(totalRating, "Rating", 5,
                                true, Colors.amber), // Adjusted to out of 5
                            SizedBox(width: 20),
                            modernCircularProgressBar(3, "Experience", 5, false,
                                Colors.blue), // Adjusted to out of 5
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GFButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                              userId: vendorId,
                                            )));
                              },
                              shape: GFButtonShape.pills,
                              size: GFSize.LARGE,
                              fullWidthButton: false,
                              icon: Icon(
                                Icons.message_rounded,
                                color: Colors.white,
                              ),
                              text: 'Chat',
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            activityStatus == "available"
                                ? ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "new_request",
                                          arguments: vendorId);
                                    },
                                    icon: Icon(
                                      Icons
                                          .work, // Change this to the desired icon
                                      color: Colors
                                          .black, // Change the icon color as needed
                                    ),
                                    label: Text(
                                      "Request",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight
                                              .bold), // Change the label color as needed
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .white, // Set the background color to white
                                    ),
                                  )
                                : Container(
                                    width: 110,
                                    height: 40,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Text(
                                      "Unavailable",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
                                child: Text("About unavailable.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal)),
                              )
                            : Text(
                                about,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                  fontSize: 12,
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
                        serviceList.isNotEmpty
                            ? Wrap(
                                runSpacing: -5.0,
                                spacing: 8.0,
                                children: serviceList.map((e) {
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
                                    color: Color.fromARGB(255, 208, 208, 208),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
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
                        workingDays.isNotEmpty
                            ? Wrap(
                                spacing: 5.0,
                                children: workingDays.map((e) {
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
                            : Center(
                                child: Text("Working days not available.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal)),
                              ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("Languages",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        languages!.isEmpty
                            ? Center(
                                child: Text("Languages unavailable.",
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

                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _firestore
                              .collection('users')
                              .doc(vendorId)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      'Error: ${snapshot.error.toString()}'));
                            } else if (snapshot.hasData &&
                                snapshot.data!.exists) {
                              Map<String, dynamic> userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              List<DocumentReference> allRatings =
                                  List<DocumentReference>.from(
                                      userData['allRatings']);
                              List<Future<Map<String, dynamic>>>
                                  ratingDataFutures =
                                  allRatings.map((ratingRef) async {
                                DocumentSnapshot ratingSnapshot =
                                    await ratingRef.get();
                                Map<String, dynamic> ratingData = ratingSnapshot
                                    .data() as Map<String, dynamic>;

                                // Fetch user data for this rating
                                DocumentReference userRef = ratingData[
                                    'ratedBy']; // Assuming 'ratedBy' is the field referencing the user
                                DocumentSnapshot userSnapshot =
                                    await userRef.get();
                                Map<String, dynamic> userData =
                                    userSnapshot.data() as Map<String, dynamic>;

                                return {
                                  'userName': userData['name'],
                                  'userImage': userData['image'],
                                  'feedback': ratingData['feedback'],
                                  'rating': ratingData['rating'],
                                  'timeRated': ratingData['timeRated'],
                                };
                              }).toList();

                              return FutureBuilder<List<Map<String, dynamic>>>(
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
                                    List<Map<String, dynamic>> ratingDataList =
                                        ratingSnapshot.data!;

                                    List<Widget> reviews =
                                        ratingDataList.map((ratingData) {
                                      String userName = ratingData['userName'];
                                      String userImage =
                                          ratingData['userImage'];
                                      String feedback = ratingData['feedback'];
                                      double rating = ratingData['rating'];
                                      Timestamp timeRated =
                                          ratingData['timeRated'];

                                      return UserReviewContainer(
                                        reviewerName: userName,
                                        reviewText: feedback,
                                        image: userImage,
                                        rating: rating,
                                        timePosted: timeRated,
                                      );
                                    }).toList();

                                    return Column(
                                      children: reviews,
                                    );
                                  } else {
                                    return Center(
                                        child: Text('No data available.',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 208, 208, 208),
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.normal)));
                                  }
                                },
                              );
                            } else {
                              return Center(
                                  child: Text('No data available.',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 208, 208, 208),
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal)));
                            }
                          },
                        ),

                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("Others with relavent job.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 400,
                          child: Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('userType', isEqualTo: 'vendor')
                                  .where('services',
                                      arrayContainsAny: serviceList)
                                  .where(FieldPath.documentId,
                                      isNotEqualTo:
                                          vendorId) // Filter by services
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                final vendors = snapshot.data!
                                    .docs; // List of QueryDocumentSnapshot

                                if (vendors.isEmpty) {
                                  return const Center(
                                    child: Text("No users found!",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 208, 208, 208),
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal)),
                                  );
                                }
                                return ListView.separated(
                                  itemCount: vendors.length,
                                  itemBuilder: (context, item) {
                                    final vendor = vendors[item].data()
                                        as Map<String, dynamic>;
                                    final docId = vendors[item].id;

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color.fromARGB(
                                                  43, 158, 158, 158)),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                          boxShadow: Theme.of(context)
                                                      .brightness ==
                                                  Brightness.dark
                                              ? [] // Empty list for no shadow in dark theme
                                              : [
                                                  BoxShadow(
                                                    color: Color.fromARGB(
                                                            38, 67, 65, 65)
                                                        .withOpacity(0.5),
                                                    blurRadius: 20,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors
                                                .transparent, // Set a transparent background for the avatar
                                            child: SizedBox(
                                              width: 50,
                                              child: ClipOval(
                                                // Clip the image to an oval (circle) shape
                                                child: Image.network(
                                                  vendor['image'],
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    } else if (loadingProgress
                                                                .expectedTotalBytes !=
                                                            null &&
                                                        loadingProgress
                                                                .cumulativeBytesLoaded <
                                                            loadingProgress
                                                                .expectedTotalBytes!) {
                                                      return Center(
                                                        child:
                                                            LoadingAnimationWidget
                                                                .discreteCircle(
                                                          color: Colors.grey,
                                                          size: 15,
                                                        ),
                                                      );
                                                    } else {
                                                      return SizedBox();
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            vendor['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            vendor['geoLocation'],
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onTertiary,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          trailing: OutlinedButton(
                                              onPressed: () {
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    "vendor_profile_opposite",
                                                    arguments: docId);
                                              },
                                              child: Text(
                                                "View",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      color: Color.fromARGB(50, 207, 216, 220),
                                      thickness: 1.0,
                                      indent: 0,
                                      endIndent: 0,
                                    );
                                  },
                                );
                              },
                            ),
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
}

// widgets

// widgets
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
              color: Color.fromARGB(0, 255, 255, 255), // Add a background color
            ),
            child: Center(
              child: isProgressable
                  ? Text(
                      '$value/$maxValue',
                      style: TextStyle(
                        color: Color.fromARGB(255, 239, 255, 9),
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
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    ],
  );
}
