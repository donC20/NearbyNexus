// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:NearbyNexus/models/rating_modal.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateUserScreen extends StatefulWidget {
  const RateUserScreen({super.key});

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');
  TextEditingController _feedbackController = TextEditingController();
  StreamSubscription<DocumentSnapshot>? vendorStreamSubscription;
  StreamSubscription<DocumentSnapshot>? userStreamSubscription;

  double rating = 0;
  double totalUserRating = 0.0;
  String uid = '';
  String vendorName = "";
  String vendorImage = "";
  bool isratingSubmitting = false;
  var logger = Logger();
  List<DocumentReference> allRatings = [];
  List<DocumentReference> iamRated = [];
  late Map<String, dynamic> vendorUser;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      vendorUser =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    });
    initUser();

    fetchVendor();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  void stopListening() {
    vendorStreamSubscription?.cancel();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });

    // fetchfrom firebase
    userStreamSubscription = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          iamRated = List<DocumentReference>.from(userData['iamRated']);
        });
      }
    });
  }

  void fetchVendor() {
    vendorStreamSubscription = _firestore
        .collection('users')
        .doc(vendorUser['uid'])
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> vendorData =
            snapshot.data() as Map<String, dynamic>;
        setState(() {
          vendorName = vendorData['name'];
          vendorImage = vendorData['image'];
          totalUserRating = vendorData['totalRating'];
          allRatings = List<DocumentReference>.from(vendorData['allRatings']);
        });
      }
    });
  }

  // snackbar
  final snackBar = SnackBar(
    /// need to set following properties for best effect of awesome_snackbar_content
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'On Snap!',
      message:
          'This is an example error message that will be shown in the body of snackbar!',

      /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
      contentType: ContentType.failure,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(186, 42, 40, 40),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  vendorImage,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else if (loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.cumulativeBytesLoaded <
                            loadingProgress.expectedTotalBytes!) {
                      return Center(
                        child: LoadingAnimationWidget.discreteCircle(
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
              SizedBox(
                height: 15,
              ),
              Text(
                vendorName,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 5.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rates) {
                  setState(() {
                    rating = rates;
                  });
                },
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  maxLines: null,
                  controller: _feedbackController,
                  keyboardType: TextInputType.multiline,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Have any feedbacks?',
                    labelStyle: TextStyle(
                        color: Color.fromARGB(255, 164, 162, 162),
                        fontSize: 12),
                    // Display remaining character count
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(74, 158, 158, 158),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(74, 158, 158, 158),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) async {},
                ),
              ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: isratingSubmitting
                      ? null
                      : () async {
                          setState(() {
                            isratingSubmitting = true;
                          });
                          RateUser userRated = RateUser(
                              rating: rating,
                              feedback: _feedbackController.text,
                              jobReference: _service_actions_collection
                                  .doc(vendorUser['jobId']),
                              ratedBy: _firestore.collection('users').doc(uid),
                              ratedTo: _firestore
                                  .collection('users')
                                  .doc(vendorUser['uid']),
                              timeRated: DateTime.now());
                          Map<String, dynamic> ratingData = userRated.toJson();
                          _firestore
                              .collection('ratings')
                              .add(ratingData)
                              .then((value) {
                            double averageRating = 0.0;
                            if (allRatings.isNotEmpty) {
                              // Calculate the rating global
                              averageRating =
                                  totalUserRating / allRatings.length;
                              double minimizedRating = min(5.0, averageRating);
                              double newTotal = totalUserRating + rating;
// add neccessory docs to the corresponding fields
                              allRatings.add(_firestore
                                  .collection('ratings')
                                  .doc(value.id));
                              iamRated.add(_firestore
                                  .collection('ratings')
                                  .doc(value.id));
                              // Update corressponding fields for USERS/general_user
                              _firestore
                                  .collection('users')
                                  .doc(uid)
                                  .update({'iamRated': iamRated});
                              // Update corressponding fields for USERS/Vendors
                              _firestore
                                  .collection('users')
                                  .doc(vendorUser['uid'])
                                  .update({
                                'totalRating': newTotal,
                                'actualRating': minimizedRating,
                                'allRatings': allRatings
                              });
                              allRatings.clear();
                              iamRated.clear();
                              setState(() {
                                isratingSubmitting = false;
                              });
                              Navigator.popAndPushNamed(
                                  context, "user_dashboard");
                            } else {
                              allRatings.add(_firestore
                                  .collection('ratings')
                                  .doc(value.id));
                              iamRated.add(_firestore
                                  .collection('ratings')
                                  .doc(value.id));
                              // Update corressponding fields for USERS/general_user
                              _firestore
                                  .collection('users')
                                  .doc(uid)
                                  .update({'iamRated': iamRated});
                              _firestore
                                  .collection('users')
                                  .doc(vendorUser['uid'])
                                  .update({
                                'totalRating': rating,
                                'actualRating': rating,
                                'allRatings': allRatings
                              });
                              allRatings.clear();
                              setState(() {
                                isratingSubmitting = false;
                              });
                              Navigator.popAndPushNamed(
                                  context, "user_dashboard");
                            }
                          });
                        },
                  child: isratingSubmitting
                      ? CircularProgressIndicator.adaptive(
                          backgroundColor: Colors.white,
                        )
                      : Text("Rate")),
            ],
          ),
        ),
      ),
    );
  }
}
