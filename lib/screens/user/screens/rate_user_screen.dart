// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:math';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/models/rating_modal.dart';
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

  double rating = 0;
  double totalUserRating = 0.0;
  String uid = '';
  String vendorName = "";
  String vendorImage = "";
  var logger = Logger();
  List<DocumentReference> allRatings = [];
  late Map<String, dynamic> vendorUser;
  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      vendorUser =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    });
    fetchVendor();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });
  }

  Future<void> fetchVendor() async {
    logger.d("this is vendor UID  :  $vendorUser['uid']");
    DocumentSnapshot snaps =
        await _firestore.collection('users').doc(vendorUser['uid']).get();
    if (snaps.exists) {
      Map<String, dynamic> vendorData = snaps.data() as Map<String, dynamic>;
      setState(() {
        vendorName = vendorData['name'];
        vendorImage = vendorData['image'];
        totalUserRating = vendorData['totalRating'];
        allRatings = vendorData['allRatings'];
      });
    }
  }

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
                  onPressed: () async {
                    RateUser userRated = RateUser(
                        rating: rating,
                        feedback: _feedbackController.text,
                        jobReference:
                            _service_actions_collection.doc('somedocs'),
                        ratedBy: _firestore.collection('users').doc('ratedBy'),
                        ratedTo: _firestore.collection('users').doc('ratedto'),
                        timeRated: DateTime.now());
                    Map<String, dynamic> ratingData = userRated.toJson();
                    _firestore
                        .collection('ratings')
                        .add(ratingData)
                        .then((value) {
                      double averageRating = 0.0;
                      if (allRatings.isNotEmpty) {
                        averageRating = totalUserRating / allRatings.length;
                        double newTotal = totalUserRating + rating;
                        allRatings.add(
                            _firestore.collection('ratings').doc(value.id));
                        _firestore
                            .collection('users')
                            .doc(vendorUser['uid'])
                            .update({
                          'totalRating': newTotal,
                          'actualRating': min(5.0, averageRating),
                          'allRatings': allRatings
                        });
                      } else {
                        allRatings.add(
                            _firestore.collection('ratings').doc(value.id));
                        _firestore
                            .collection('users')
                            .doc(vendorUser['uid'])
                            .update({
                          'totalRating': rating,
                          'actualRating': rating,
                          'allRatings': allRatings
                        });
                      }
                    });
                  },
                  child: Text("Rate")),
            ],
          ),
        ),
      ),
    );
  }
}
