// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_key_in_widget_constructors, unused_field, unused_local_variable, non_constant_identifier_names, prefer_const_declarations, avoid_print, sized_box_for_whitespace

import 'dart:async';
import 'dart:convert';
import 'package:NearbyNexus/components/user_bottom_nav.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
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
import '../components/custom_floating_search_bar.dart';
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
  late StreamSubscription subscription;
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
  // location fetching
  var logger = Logger();
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
    var initData = json.decode(userLoginData ?? '');
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
              children: [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                        "assets/images/vector/location_pin.svg")),
                SizedBox(width: 8.0),
                Text(
                  yrCurrentLocation,
                  style: TextStyle(
                    color: Color.fromARGB(255, 178, 176, 176),
                    fontWeight: FontWeight.normal,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 16.0,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF838383),
                ),
              ],
            ),
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
                padding: const EdgeInsets.only(top: 15.0),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: <Widget>[
                      ButtonsTabBar(
                        backgroundColor: Color(0xFF2d4fff),
                        contentPadding: EdgeInsets.symmetric(horizontal: 30),
                        radius: 20,
                        labelSpacing: 2,
                        unselectedBackgroundColor: Colors.grey[300],
                        unselectedLabelStyle: TextStyle(color: Colors.black),
                        labelStyle: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(
                            icon: Icon(Icons.location_on),
                            text: "My Location",
                          ),
                          Tab(
                            icon: Icon(Icons.travel_explore),
                            text: "Off location",
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[
                            onLocationServices(yrCurrentLocation),
                            offLocationServices(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomGNavUser(
        activePage: 0,
        isSelectable: true,
      ),
    );
  }
}

Widget onLocationServices(yrCurrentLocation) {
  bool isExpanded = false;
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'vendor')
          .where('activityStatus', isEqualTo: 'available')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final userDocumentData = snapshot.data!.docs;

        bool matchesFound = false;

        if (userDocumentData.isEmpty) {
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
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        }

        List<Widget> resultList = [];

        for (int index = 0; index < userDocumentData.length; index++) {
          final userData =
              userDocumentData[index].data() as Map<String, dynamic>;

          final docId = userDocumentData[index].id;

          final geoLocation = userData['geoLocation'];

          List<String> yrCurrentLocationWords = yrCurrentLocation.split(' ');
          List<String> geoLocationWords = removeComma(geoLocation);

          bool atLeastOneWordPresent = yrCurrentLocationWords.any((word) =>
              geoLocationWords.any((geoWord) =>
                  geoWord.toLowerCase().contains(word.toLowerCase())));

          if (atLeastOneWordPresent) {
            matchesFound = true;
            resultList.add(
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: vendorDisplayTile(context, userData, docId)),
            );
          }
        }

        if (!matchesFound) {
          resultList.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  height: 250,
                  width: 250,
                  "assets/images/vector/user_not_found.svg",
                ),
                SizedBox(height: 15),
                Text(
                  "Sorry, no users found!",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView(
          children: resultList,
        );
      },
    ),
  );
}

Widget offLocationServices() {
  return StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'vendor')
        .where('activityStatus', isEqualTo: 'available')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }
      final userDocumentData = snapshot.data!.docs;

      return ListView.separated(
        itemBuilder: (context, index) {
          Map<String, dynamic> userData = userDocumentData[index].data();
          String docId = userDocumentData[index].id;
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: vendorDisplayTile(context, userData, docId));
        },
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
            indent: 20,
            endIndent: 20,
          );
        },
        itemCount: userDocumentData.length,
      );
    },
  );
}

Widget vendorDisplayTile(BuildContext context, userData, docId) {
  return Container(
    padding: EdgeInsets.all(15),
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: convertToSentenceCase(userData['services'][0]),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' ( + ${userData['services'].length.toString()} more )',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 18,
                    color: Colors
                        .black, // You may adjust the color to your preference
                  ),
                  SizedBox(width: 5),
                  Text(
                    userData['actualRating'].toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        Divider(
          color: Color.fromARGB(255, 116, 115, 115),
        ),
        ExpansionTile(
          onExpansionChanged: (value) {},
          leading: UserLoadingAvatar(userImage: userData['image']),
          title: Row(
            children: [
              Text(
                userData['name'],
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(Icons.arrow_drop_down)
            ],
          ),
          subtitle: Text(
            userData['geoLocation'],
            style: TextStyle(
              color: const Color.fromARGB(121, 0, 0, 0),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "vendor_profile_opposite",
                    arguments: docId);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF2d4fff),
                shape: StadiumBorder(),
              ),
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          children: [
            Text(
              userData['about'],
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 10.0),
            //   child: Row(
            //     children: [
            //       Icon(
            //         Icons.work_history,
            //         color: Colors.blueGrey,
            //       ),
            //       SizedBox(
            //         width: 5,
            //       ),
            //       Text(
            //         '${userData['paymentLogs'].length.toString()} works done',
            //         style: TextStyle(
            //           color: const Color.fromARGB(122, 0, 0, 0),
            //           fontSize: 12,
            //           fontWeight: FontWeight.w300,
            //         ),
            //       ),
            //     ],
            //   ),
            // )
          ],
        ),
      ],
    ),
  );
}

List<String> removeComma(String value) {
  return value
      .replaceAll(RegExp(r',+'), ',')
      .split(',')
      .map((word) => word.trim())
      .where((word) => word.isNotEmpty)
      .toList();
}
