// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, prefer_const_declarations, non_constant_identifier_names

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class EditNameLocation extends StatefulWidget {
  const EditNameLocation({super.key});

  @override
  State<EditNameLocation> createState() => _EditNameLocationState();
}

class _EditNameLocationState extends State<EditNameLocation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  bool isLocationFetchingList = false;
  bool isListEmpty = false;
  bool isEmailVerified = false;
  bool initEmailStoreVal = false;
  bool duplicateEmailId = true;
  bool isFetchingDetails = false;
  bool emailRegex = false;
  String selectedName = "";
  String yrCurrentLocation = "loading..";
  String nameLoginned = "Jhon Doe";
  String email = "";

  String? uid = "";
  List<Map<String, dynamic>> resultList = [];
  var logger = Logger();

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    setState(() {
      isLocationFetchingList = true;
    });
    final apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';

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

      setState(() {
        isLocationFetchingList = false;
        resultList = features.map((feature) {
          final properties = feature["properties"] as Map<String, dynamic>;
          return properties;
        }).toList();
      });
      setState(() {
        isListEmpty = resultList.isEmpty;
      });
      return resultList;
    } else {
      // Handle errors here.
      logger.d('Error: ${response.statusCode}');
      return []; // Return an empty list in case of an error.
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
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
        // Assing admin data to the UI
        setState(() {
          _nameController.text = fetchedData['name'];
          _locationController.text = fetchedData['geoLocation'];
          _emailController.text = fetchedData['emailId']['id'];
          email = fetchedData['emailId']['id'];
          isFetchingDetails = false;
          isEmailVerified = fetchedData['emailId']['verified'];
          initEmailStoreVal = fetchedData['emailId']['verified'];
        });
        logger.d(isEmailVerified);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
            borderRadius: BorderRadius.circular(10), // Add border radius
            color: Color.fromARGB(186, 42, 40, 40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update details",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Divider(
                color: Color.fromARGB(89, 255, 255, 255),
                height: 30,
              ),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 226, 223, 223)),
                          decoration: new InputDecoration(
                            // prefixIcon: Icon(Icons.account_circle_rounded,
                            //     color: Colors.white54),
                            suffixIcon: _emailController.text.isEmpty ||
                                    !emailRegex ||
                                    duplicateEmailId
                                ? SizedBox()
                                : isEmailVerified
                                    ? Chip(
                                        backgroundColor: Color.fromARGB(
                                            255,
                                            10,
                                            164,
                                            17), // Set the background color
                                        labelPadding: EdgeInsets.all(1),
                                        label: Text(
                                          "Verified",
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () async {
                                       
                                        },
                                        child: Chip(
                                          backgroundColor: Color.fromARGB(
                                              255,
                                              227,
                                              23,
                                              5), // Set the background color
                                          labelPadding: EdgeInsets.all(1),
                                          label: Text(
                                            "Verify me",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                            hintStyle: TextStyle(color: Colors.white38),
                            hintText: 'Eg : example@gmail.com',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(232, 255, 255, 255)),
                            labelText: 'What\'s your email id?',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white54, // Set your desired border color here
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(137, 255, 255,
                                    255), // Set your desired border color here
                              ),
                            ),
                          ),
                          onChanged: (value) async {
                            try {
                              final existingMethods = await FirebaseAuth
                                  .instance
                                  .fetchSignInMethodsForEmail(value);
                              if (existingMethods.isEmpty) {
                                setState(() {
                                  duplicateEmailId = false;
                                });
                                if (initEmailStoreVal) {
                                  if (value != email) {
                                    setState(() {
                                      isEmailVerified = false;
                                    });
                                  } else if (value == email) {
                                    setState(() {
                                      isEmailVerified = true;
                                    });
                                  }
                                }
                              } else {
                                setState(() {
                                  duplicateEmailId = true;
                                });
                              }
                            } catch (e) {
                              logger.d(e);
                            }
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "You left this field empty!";
                            }

                            emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value);
                            if (!emailRegex) {
                              return "Invalid email!";
                            } else if (duplicateEmailId) {
                              return "This email id already exists!";
                            } else if (!isEmailVerified) {
                              return "Please verify your email. Tap on verify me";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 226, 223, 223)),
                          decoration: new InputDecoration(
                            // prefixIcon: Icon(Icons.account_circle_rounded,
                            //     color: Colors.white54),
                            hintStyle: TextStyle(color: Colors.white38),
                            hintText: 'Eg : Jhon Doe',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(232, 255, 255, 255)),
                            labelText: 'What\'s your name?',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white54, // Set your desired border color here
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(137, 255, 255,
                                    255), // Set your desired border color here
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "You left this field empty!";
                            }
                            bool nameRegex =
                                RegExp(r'^[a-zA-Z]{3,}(?: [a-zA-Z]+)*$')
                                    .hasMatch(value);
                            if (!nameRegex) {
                              return "Must contain atleast 3 characters & avoid any numbers.";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          controller: _locationController,
                          keyboardType: TextInputType.name,
                          style: GoogleFonts.poppins(
                            color: const Color.fromARGB(255, 226, 223, 223),
                          ),
                          decoration: InputDecoration(
                            // prefixIcon: Icon(Icons.account_circle_rounded,
                            //     color: Colors.white54),
                            suffixIcon: _locationController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _locationController.clear();
                                        resultList.clear();
                                        isListEmpty = false;
                                        selectedName = "";
                                      });
                                    },
                                  )
                                : Icon(
                                    Icons.my_location_sharp,
                                    color: Colors.white54,
                                  ),
                            hintStyle: TextStyle(color: Colors.white38),
                            hintText: 'Eg : California',
                            labelStyle: TextStyle(
                                color: Color.fromARGB(232, 255, 255, 255)),
                            labelText: 'What\'s your location?',
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors
                                    .white54, // Set your desired border color here
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(137, 255, 255,
                                    255), // Set your desired border color here
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            searchPlaces(value);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "You left this field empty!";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: isLocationFetchingList == false
                            ? isListEmpty
                                ? Center(
                                    child: Text(
                                      "Sorry, Location not found",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 227, 8, 8)),
                                    ),
                                  )
                                : LayoutBuilder(
                                    builder: (BuildContext context,
                                        BoxConstraints constraints) {
                                      double containerHeight =
                                          resultList.length * 90.0;
                                      containerHeight =
                                          containerHeight.clamp(0, 170);
                                      return Container(
                                        height: containerHeight,
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(138, 53, 52, 52),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: ListView.separated(
                                          itemCount: resultList.length,
                                          itemBuilder: (context, index) {
                                            String name = resultList[index]
                                                    ["name"] ??
                                                resultList[index]
                                                    ["formatted"] ??
                                                "";
                                            String country = resultList[index]
                                                    ["country"] ??
                                                "";
                                            String state = resultList[index]
                                                    ["state"] ??
                                                resultList[index]["suburb"] ??
                                                "";
                                            String county = resultList[index]
                                                    ["county"] ??
                                                resultList[index]["postcode"] ??
                                                resultList[index]
                                                    ["state_code"] ??
                                                "";
                                            return ListTile(
                                              title: Text(
                                                name,
                                                style: TextStyle(
                                                    color: Colors.white60),
                                              ),
                                              subtitle: Text(
                                                  "$state, $county, $country",
                                                  style: TextStyle(
                                                      color: Colors.white60)),
                                              onTap: () {
                                                setState(() {});
                                                selectedName = resultList[index]
                                                        ["name"] ??
                                                    resultList[index]
                                                        ["formatted"] ??
                                                    "";
                                                _locationController.text =
                                                    selectedName;
                                                // setState(() {
                                                //   resultList.clear();
                                                // });
                                                // Handle the selection logic here
                                              },
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return Divider(
                                              color: Color.fromARGB(
                                                  48, 189, 189, 189),
                                              thickness: 1.0,
                                              indent: 0,
                                              endIndent: 0,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  )
                            : Center(
                                child: LoadingAnimationWidget
                                    .horizontalRotatingDots(
                                        color: Colors.white, size: 20),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 25.0, left: 15.0, right: 15.0, bottom: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate() &&
                                    selectedName.isNotEmpty &&
                                    isEmailVerified) {
                                  Map<String, dynamic> emailNew = {
                                    "id": _emailController.text,
                                    "verified": true,
                                  };

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .update({
                                    "emailId": emailNew,
                                    "name": _nameController.text,
                                    "geoLocation": selectedName
                                  }).then((value) => {Navigator.pop(context)});
                                }
                              },
                              style: ButtonStyle(
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adjust the border radius as needed
                                  ),
                                ),
                                side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(
                                    color: Colors
                                        .white, // Set your desired border color here
                                    width:
                                        1.0, // Set the border width as needed
                                  ),
                                ),
                              ),
                              child: Text(
                                "Update",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 243, 243, 243),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8.0), // Adjust the border radius as needed
                                  ),
                                ),
                                side: MaterialStateProperty.all<BorderSide>(
                                  BorderSide(
                                    color: Colors
                                        .white, // Set your desired border color here
                                    width:
                                        1.0, // Set the border width as needed
                                  ),
                                ),
                              ),
                              child: Text(
                                "Close",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 243, 243, 243),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ))
            ],
          )),
    );
  }
}
