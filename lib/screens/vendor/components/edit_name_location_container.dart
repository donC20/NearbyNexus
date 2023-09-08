// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, prefer_const_declarations

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';

class EditNameLocation extends StatefulWidget {
  const EditNameLocation({super.key});

  @override
  State<EditNameLocation> createState() => _EditNameLocationState();
}

class _EditNameLocationState extends State<EditNameLocation> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool isLocationFetchingList = false;
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
      logger.d(resultList);
      return resultList;
    } else {
      // Handle errors here.
      logger.d('Error: ${response.statusCode}');
      return []; // Return an empty list in case of an error.
    }
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
                "Update name",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Divider(
                color: Color.fromARGB(89, 255, 255, 255),
                height: 30,
              ),
              Form(
                  child: Column(
                children: [
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
                        ? resultList.isEmpty
                            ? Center(
                                child: Text(
                                  "Sorry, Location not found",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 227, 8, 8)),
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
                                      color: Color.fromARGB(138, 53, 52, 52),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ListView.separated(
                                      itemCount: resultList.length,
                                      itemBuilder: (context, index) {
                                        String name = resultList[index]
                                                ["name"] ??
                                            resultList[index]["formatted"] ??
                                            "";
                                        String country =
                                            resultList[index]["country"] ?? "";
                                        String state = resultList[index]
                                                ["state"] ??
                                            resultList[index]["suburb"] ??
                                            "";
                                        String county = resultList[index]
                                                ["county"] ??
                                            resultList[index]["postcode"] ??
                                            resultList[index]["state_code"] ??
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
                                            final selectedName =
                                                resultList[index]["name"] ??
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
                                          (BuildContext context, int index) {
                                        return Divider(
                                          color:
                                              Color.fromARGB(48, 189, 189, 189),
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
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
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
                          onPressed: () {},
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Adjust the border radius as needed
                              ),
                            ),
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(
                                color: Colors
                                    .white, // Set your desired border color here
                                width: 1.0, // Set the border width as needed
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
                            shape: MaterialStateProperty.all<OutlinedBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Adjust the border radius as needed
                              ),
                            ),
                            side: MaterialStateProperty.all<BorderSide>(
                              BorderSide(
                                color: Colors
                                    .white, // Set your desired border color here
                                width: 1.0, // Set the border width as needed
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
