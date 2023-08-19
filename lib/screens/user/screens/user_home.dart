// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_key_in_widget_constructors, unused_field, unused_local_variable, non_constant_identifier_names

import 'dart:convert';
import 'dart:html';

import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/user_list_tile.dart';

class GeneralUserHome extends StatefulWidget {
  const GeneralUserHome({super.key});

  @override
  State<GeneralUserHome> createState() => _GeneralUserHomeState();
}

class _GeneralUserHomeState extends State<GeneralUserHome> {
  int _page = 0;
  final GlobalKey<_GeneralUserHomeState> _bottomNavigationKey = GlobalKey();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final vendorSearchController = TextEditingController();
  bool isloadingLocation = true;
  String yrCurrentLocation = "loading..";

// Load user data
  String nameLoginned = "Jhon Doe";
  String imageLink = "";

  // location fetching

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    FetchUserData();
    _getCurrentLocationAndSetAddress();
  }

  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    String uid = initData['uid'];
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        imageLink = fetchedData['image'];
        nameLoginned = fetchedData['name'];
      });
    }
  }

  Future<void> _getCurrentLocationAndSetAddress() async {
    try {
      _currentPosition = await getCurrentLocation();
      if (_currentPosition != null) {
        String? address = await getAddressFromLocation(_currentPosition!);
        if (address != null) {
          setState(() {
            yrCurrentLocation = address;
            isloadingLocation = false;
          });
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  Future<String?> getAddressFromLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        // Choose the desired fields to form the address
        String address =
            "${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
        return address;
      }
      return null;
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                  width: 20,
                  child: SvgPicture.asset(
                      "assets/images/vector/location_pin.svg")),
              SizedBox(width: 8.0),
              InkWell(
                onTap: () async {
                  _getCurrentLocationAndSetAddress();
                },
                child: Text(
                  yrCurrentLocation,
                  style: TextStyle(
                    color: Color(0xFF838383),
                    fontWeight: FontWeight.normal,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF838383),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: Colors
                  .transparent, // Set a transparent background for the avatar
              child: ClipOval(
                // Clip the image to an oval (circle) shape
                child: Image.network(
                  imageLink,
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
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(
                height: 1,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 80,
                    height: 50,
                    child: TextFormField(
                      controller: vendorSearchController,
                      style: GoogleFonts.poppins(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'What\'s service you need?',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: const TextStyle(
                            color: Color(0xFF838383), fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(166, 158, 158, 158),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(166, 158, 158, 158),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "You left this field empty!";
                        }
                        return null;
                      },
                    ),
                  ),
                  InkWell(
                    child: SizedBox(
                      width: 50,
                      height: 40,
                      child: SvgPicture.asset(
                          "assets/images/vector/equalizer.svg",
                          color: Color(0xFF838383)),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Suggested services",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('userType', isEqualTo: 'vendor')
                      .where('geoLocation', isEqualTo: yrCurrentLocation)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final vendors =
                        snapshot.data!.docs; // List of QueryDocumentSnapshot

                    if (vendors.isEmpty) {
                      return const Center(
                        child: Text("No users found!"),
                      );
                    }
                    return ListView.builder(
                      itemCount: vendors.length,
                      itemBuilder: (context, item) {
                        final vendor =
                            vendors[item].data() as Map<String, dynamic>;
                        final docId = vendors[item].id;
                        List<String> allServices =
                            List<String>.from(vendor['services']);
                        String concatenatedServices = allServices.join(', ');
                        const int maxTruncatedLength =
                            30; // Adjust this length as needed

                        String truncatedServices = concatenatedServices.length >
                                maxTruncatedLength
                            ? '${concatenatedServices.substring(0, maxTruncatedLength)}...'
                            : concatenatedServices;
                        return ServiceOnLocationContainer(
                          name: vendor['name'],
                          image: vendor['image'],
                          salary: "500 - 1000/day",
                          serviceNames:
                              convertToSentenceCase(truncatedServices),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 60.0,
        items: <Widget>[
          Icon(Icons.add, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.compare_arrows, size: 30),
          Icon(Icons.call_split, size: 30),
          Icon(Icons.login, size: 30),
        ],
        color: Colors.white,
        buttonBackgroundColor: Color.fromARGB(255, 37, 80, 255),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) async {
          if (index == 4) {
            final SharedPreferences sharedpreferences =
                await SharedPreferences.getInstance();
            sharedpreferences.remove("userSessionData");
            sharedpreferences.remove("uid");
            Navigator.popAndPushNamed(context, "login_screen");
            await _googleSignIn.signOut();
          }
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}
