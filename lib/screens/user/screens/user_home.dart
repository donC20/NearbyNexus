// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_key_in_widget_constructors, unused_field, unused_local_variable, non_constant_identifier_names

import 'dart:convert';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
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
  Gradient selectedGradient = const LinearGradient(colors: [
    Color.fromARGB(255, 8, 89, 210),
    Color.fromARGB(255, 24, 18, 1)
  ]);
  Gradient unselectedGradient = const LinearGradient(
      colors: [Color.fromARGB(255, 54, 89, 244), Colors.blueGrey]);

  final int _page = 0;
  final GlobalKey<_GeneralUserHomeState> _bottomNavigationKey = GlobalKey();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final vendorSearchController = TextEditingController();
  bool isloadingLocation = true;
  String yrCurrentLocation = "loading..";
  int _selectedItemPosition = 0;
  SnakeShape snakeShape = SnakeShape.circle;
  Color selectedColor = Colors.black;
  Color unselectedColor = Colors.blueGrey;
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
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        elevation: 1,
        shadowColor: Colors.white30,
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
                    color: Color.fromARGB(255, 178, 176, 176),
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
                  // SizedBox(
                  //   width: MediaQuery.sizeOf(context).width - 80,
                  //   height: 50,
                  //   child: TextFormField(
                  //     controller: vendorSearchController,
                  //     style: GoogleFonts.poppins(color: Colors.black),
                  //     decoration: InputDecoration(
                  //       labelText: 'What\'s service you need?',
                  //       hintStyle:
                  //           const TextStyle(color: Colors.grey, fontSize: 14),
                  //       labelStyle: const TextStyle(
                  //           color: Color(0xFF838383), fontSize: 14),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(10),
                  //         borderSide: const BorderSide(
                  //           color: Color.fromARGB(166, 158, 158, 158),
                  //         ),
                  //       ),
                  //       focusedBorder: OutlineInputBorder(
                  //         borderSide: const BorderSide(
                  //           color: Color.fromARGB(166, 158, 158, 158),
                  //         ),
                  //         borderRadius: BorderRadius.circular(10),
                  //       ),
                  //       prefixIcon: Icon(Icons.search),
                  //     ),
                  //     validator: (value) {
                  //       if (value!.isEmpty) {
                  //         return "You left this field empty!";
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ),
                ],
              ),
              SizedBox(
                height: 40,
                width: MediaQuery.sizeOf(context).width,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Chip(
                      label: Text("Popular"),
                    ),
                    SizedBox(width: 10),
                    Chip(label: Text("New")),
                    SizedBox(width: 10),
                    Chip(label: Text("Emergency")),
                    SizedBox(width: 10),
                    Chip(label: Text("Administration")),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Suggested services",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  InkWell(
                    child: SizedBox(
                      width: 50,
                      height: 40,
                      child: SvgPicture.asset(
                          "assets/images/vector/equalizer.svg",
                          color: Color(0xFF838383)),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 1,
              ),
              Divider(
                color: const Color.fromARGB(145, 158, 158, 158),
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
                        return ModernServiceCard(
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
      bottomNavigationBar: SnakeNavigationBar.gradient(
        // height: 80,
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.circle,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(12),

        // /configuration for SnakeNavigationBar.gradient
        snakeViewGradient: selectedGradient,
        selectedItemGradient:
            snakeShape == SnakeShape.indicator ? selectedGradient : null,
        unselectedItemGradient: unselectedGradient,

        showUnselectedLabels: false,
        showSelectedLabels: false,

        currentIndex: _selectedItemPosition,
        onTap: (index) async {
          if (index == 4) {
            final SharedPreferences sharedpreferences =
                await SharedPreferences.getInstance();
            sharedpreferences.remove("userSessionData");
            sharedpreferences.remove("uid");
            Navigator.popAndPushNamed(context, "login_screen");
            await _googleSignIn.signOut();
          }
          setState(() => _selectedItemPosition = index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'tickets'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded), label: 'calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.podcasts), label: 'microphone'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search')
        ],
        selectedLabelStyle: const TextStyle(fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}
