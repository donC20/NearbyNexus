// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_key_in_widget_constructors, unused_field, unused_local_variable, non_constant_identifier_names, prefer_const_declarations, avoid_print

import 'dart:convert';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/user/screens/search_screen_global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/custom_floating_search_bar.dart';
import '../components/user_list_tile.dart';
import 'package:http/http.dart' as http;

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
  String yrCurrentLocation = "loading..";
// Load user data
  String nameLoginned = "Jhon Doe";
  String query = '';
  String imageLink = "";
  bool isloadingLocation = true;
  bool isLocationSearch = false;
  bool isLocationFetching = false;
  bool isimageFetched = true;
  int _selectedItemPosition = 2;
  Color selectedColor = Colors.black;
  Color unselectedColor = Colors.blueGrey;
  SnakeShape snakeShape = SnakeShape.circle;
  List<String> searchWithLocation = [];
  Map<String, dynamic> placesQuery = {};
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
        isimageFetched = false;
      });
    }
  }

  List<String> removeComma(String value) {
    return value
        .replaceAll(RegExp(r',+'), ',')
        .split(',')
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  Future<void> _getCurrentLocationAndSetAddress() async {
    try {
      _currentPosition = await getCurrentLocation();
      if (_currentPosition != null) {
        String? address = await getAddressFromLocation(_currentPosition!);
        if (address != null) {
          setState(() {
            yrCurrentLocation = address;
            // searchWithLocation = removeComma(yrCurrentLocation);
            isloadingLocation = false;
            print(searchWithLocation);
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
        String address = "${placemark.locality}";
        return address;
      }
      return null;
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }

  // search places APi
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';
    final apiUrl =
        'https://geoapify-address-autocomplete.p.rapidapi.com/v1/geocode/autocomplete';
    final headers = {
      'X-RapidAPI-Host': 'geoapify-address-autocomplete.p.rapidapi.com',
      'X-RapidAPI-Key': apiKey,
    };
    final params = {'text': query};

    final uri = Uri.https(
      'geoapify-address-autocomplete.p.rapidapi.com',
      '/v1/geocode/autocomplete',
      params,
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data["features"] as List<dynamic>;

      final List<Map<String, dynamic>> resultList = features.map((feature) {
        final properties = feature["properties"] as Map<String, dynamic>;
        return properties;
      }).toList();

      return resultList;
    } else {
      // Handle errors here.
      print('Error: ${response.statusCode}');
      return []; // Return an empty list in case of an error.
    }
  }

  void handleItemSelection(String locationName) {
    setState(() {
      yrCurrentLocation = locationName;
      // searchWithLocation = removeComma(yrCurrentLocation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      extendBody: true,
      backgroundColor: Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        shadowColor: Colors.grey,
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: SvgPicture.asset(
                      "assets/images/vector/location_pin.svg")),
              SizedBox(width: 8.0),
              InkWell(
                onTap: () async {
                  // _getCurrentLocationAndSetAddress();
                  setState(() {
                    isLocationSearch = true;
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(
                            searchPlaces: searchPlaces,
                            onItemSelected: handleItemSelection));
                  });
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
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "user_profile_one");
              },
              child: isimageFetched == true
                  ? Container(
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(color: Colors.black),
                      child: Center(
                        child: LoadingAnimationWidget.fallingDot(
                          color: Colors.white,
                          size: 30,
                        ),
                      ))
                  : CircleAvatar(
                      backgroundColor: Colors
                          .transparent, // Set a transparent background for the avatar
                      child: ClipOval(
                        // Clip the image to an oval (circle) shape
                        child: Image.network(
                          imageLink,
                          width: 30,
                          height: 30,
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
          )
        ],
      ),
      body: isloadingLocation == true
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: const Color.fromARGB(255, 255, 255, 255), size: 80),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
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

                          final userDocumentData = snapshot.data!.docs;

                          bool matchesFound = false;

                          if (userDocumentData == null ||
                              userDocumentData.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    height: 250,
                                    width: 250,
                                    "assets/images/vector/404_error.svg",
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Sorry, Something went wrong",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }

                          List<Widget> resultList = [];

                          for (int index = 0;
                              index < userDocumentData.length;
                              index++) {
                            final vendor = userDocumentData[index].data()
                                as Map<String, dynamic>;

                            List<String> allServices =
                                List<String>.from(vendor['services']);
                            String concatenatedServices =
                                allServices.join(', ');
                            const int maxTruncatedLength = 30;
                            String truncatedServices = concatenatedServices
                                        .length >
                                    maxTruncatedLength
                                ? '${concatenatedServices.substring(0, maxTruncatedLength)}...'
                                : concatenatedServices;

                            final docId = userDocumentData[index].id;
                            final geoLocation = vendor['geoLocation'];

                            List<String> yrCurrentLocationWords =
                                yrCurrentLocation.split(' ');
                            List<String> geoLocationWords =
                                removeComma(geoLocation);

                            bool atLeastOneWordPresent =
                                yrCurrentLocationWords.any((word) =>
                                    geoLocationWords.any((geoWord) => geoWord
                                        .toLowerCase()
                                        .contains(word.toLowerCase())));

                            if (atLeastOneWordPresent) {
                              matchesFound = true;
                              resultList.add(
                                ModernServiceCard(
                                  name: vendor['name'],
                                  image: vendor['image'],
                                  salary: "500 - 1000/day",
                                  serviceNames:
                                      convertToSentenceCase(truncatedServices),
                                  uid: docId,
                                ),
                              );
                            }
                          }

                          if (!matchesFound) {
                            resultList.add(
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      height: 250,
                                      width: 250,
                                      "assets/images/vector/user_not_found.svg",
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      "Sorry, no users found!",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView(
                            children: resultList,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
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
