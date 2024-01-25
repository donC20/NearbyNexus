// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_key_in_widget_constructors, unused_field, unused_local_variable, non_constant_identifier_names, prefer_const_declarations, avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/screens/vendor/components/user_vendor_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../user/components/custom_floating_search_bar.dart';

import 'package:http/http.dart' as http;

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  Gradient selectedGradient = const LinearGradient(colors: [
    Color.fromARGB(255, 8, 89, 210),
    Color.fromARGB(255, 24, 18, 1)
  ]);
  Gradient unselectedGradient = const LinearGradient(
      colors: [Color.fromARGB(255, 54, 89, 244), Colors.blueGrey]);

  final int _page = 0;
  final GlobalKey<_VendorHomeState> _bottomNavigationKey = GlobalKey();
  late StreamSubscription subscription;
  var logger = Logger();
  String yrCurrentLocation = "loading..";
  String nameLoginned = "Jhon Doe";
  String query = '';
  String imageLink = "";
  bool isloadingLocation = true;
  bool isLocationSearch = false;
  bool isLocationFetching = false;
  bool isimageFetched = true;
  bool isDeviceOnline = false;
  int _selectedItemPosition = 2;
  Color selectedColor = Colors.black;
  Color unselectedColor = Colors.blueGrey;
  SnakeShape snakeShape = SnakeShape.circle;
  List<String> searchWithLocation = [];
  Map<String, dynamic> placesQuery = {};
  List<dynamic> userFavourites = [];
  // location fetching
  String? uid = "";
  Position? _currentPosition;
  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndSetAddress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
    initUser();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
    FetchUserData(uid);
  }

  Future<void> FetchUserData(uid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;

        // Update UI with the fetched data
        setState(() {
          imageLink = fetchedData['image'];
          nameLoginned = fetchedData['name'];
          isimageFetched = false;
          // userFavourites = fetchedData['userFavourites'];
        });
      }
    });
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

  // function for userTiles fetching
  // Future<void> FetchGeneralUserTiles() {}

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
        leadingWidth: MediaQuery.sizeOf(context).width - 100,
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            elevation: 2,
            color: Color.fromARGB(17, 255, 255, 255),
            shadowColor: Color.fromARGB(46, 158, 158, 158),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: InkWell(
                onTap: () async {
                  setState(() {
                    isLocationSearch = true;
                    showSearch(
                        context: context,
                        delegate: CustomSearchDelegate(
                            searchPlaces: searchPlaces,
                            onItemSelected: handleItemSelection,
                            getMyLocation: _getCurrentLocationAndSetAddress));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                            width: 15,
                            height: 15,
                            child: SvgPicture.asset(
                                "assets/images/vector/location_pin.svg")),
                        SizedBox(width: 8.0),
                        Text(
                          yrCurrentLocation,
                          style: TextStyle(
                            color: Color.fromARGB(255, 241, 240, 240),
                            fontWeight: FontWeight.normal,
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Color.fromARGB(255, 241, 240, 240),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "vendor_profile_one");
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
          ),
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
                child: ListView(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Peoples nearby",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    SizedBox(
                      height: 260,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('userType', isEqualTo: 'general_user')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final userDocumentData = snapshot.data!.docs;

                          bool matchesFound = false;
                          bool addedToFav = false;

                          if (userDocumentData.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    height: 200,
                                    width: 250,
                                    "assets/images/vector/404_error.svg",
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Sorry, Something went wrong",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          List<Widget> resultList = [];

                          for (int index = 0;
                              index < userDocumentData.length;
                              index++) {
                            final generalUser = userDocumentData[index].data()
                                as Map<String, dynamic>;

                            final docId = userDocumentData[index].id;
                            final geoLocation = generalUser['geoLocation'];
                            // get user favourites

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
                              resultList.add(InkWell(
                                onTap: () {},
                                child: GeneralUserTiles(
                                  userName: generalUser['name'],
                                  userLocation: generalUser['geoLocation'],
                                  jobsOffered: 50,
                                  paymentVerified:
                                      generalUser['paymentVerified'],
                                  ratings: 3.2,
                                  userImage: generalUser['image'],
                                  emailVerified: generalUser['emailId']
                                      ['verified'],
                                  docId: docId,
                                ),
                              ));
                            }
                          }

                          return !matchesFound
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        height: 200,
                                        width: 200,
                                        "assets/images/vector/user_not_found.svg",
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        "): Sorry, currently no users at your location!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: resultList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: resultList[index],
                                    );
                                  },
                                );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Others around you",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    SizedBox(
                      height: 260,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('userType', isEqualTo: 'general_user')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final userDocumentData = snapshot.data!.docs;

                          bool addedToFav = false;

                          if (userDocumentData.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    height: 200,
                                    width: 250,
                                    "assets/images/vector/404_error.svg",
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    "Sorry, Something went wrong",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: userDocumentData.length,
                            itemBuilder: (context, index) {
                              final generalUser = userDocumentData[index].data()
                                  as Map<String, dynamic>;

                              final docId = userDocumentData[index].id;
                              final geoLocation = generalUser['geoLocation'];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: GeneralUserTiles(
                                    userName: generalUser['name'],
                                    userLocation: generalUser['geoLocation'],
                                    jobsOffered: 50,
                                    paymentVerified:
                                        generalUser['paymentVerified'],
                                    ratings: 3.2,
                                    userImage: generalUser['image'],
                                    emailVerified: generalUser['emailId']
                                        ['verified'],
                                    docId: docId,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Other actions",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomGNav(
        activePage: 1,
        isSelectable: true,
      ),
    );
  }
}
