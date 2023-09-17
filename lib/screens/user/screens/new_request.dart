// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names, library_private_types_in_public_api, use_key_in_widget_constructors, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/models/new_request_model.dart';
import 'package:NearbyNexus/screens/common_screens/location_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewServiceRequest extends StatefulWidget {
  @override
  _NewServiceRequestState createState() => _NewServiceRequestState();
}

class _NewServiceRequestState extends State<NewServiceRequest> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _serviceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var logger = Logger();

  String? service_name;
  String? description;
  String? service_level;
  String? location;
  String selectedName = "";
  String vendorId = "";

  List<Map<String, dynamic>> resultList = [];
  List<String> matchedServices = [];
  bool isLocationFetchingList = false;
  bool isCurrentLocationFetching = false;
  bool isListEmpty = false;
  bool isLoadingserviceList = false;
  bool isListServiceEmpty = false;
  DateTime? day;
  int? wage;
  final _aboutController = TextEditingController();
  int maxLetters = 1000;

  String? uid = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
    setState(() {
      vendorId = ModalRoute.of(context)!.settings.arguments as String;
    });
    initUser();
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

// Search places api
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    setState(() {
      isLocationFetchingList = true;
    });
    const apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';

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

  Future<void> searchServices(String keyword) async {
    setState(() {
      isLoadingserviceList = true;
      matchedServices.clear(); // Clear the previous matched services.
    });

    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc('service_list')
              .get();

      List<dynamic> serviceList = snapshot.data()?['service'];
      Set<String> uniqueMatchedServices =
          {}; // Use a Set to store unique values

      List<dynamic> lowerCaseServiceList = serviceList
          .map((service) => service.toString().toLowerCase())
          .toList();

      for (dynamic service in lowerCaseServiceList) {
        if (service.toString().contains(keyword.toLowerCase())) {
          uniqueMatchedServices.add(service.toString());
        }
      }

      // Convert the Set back to a List for your use if needed
      matchedServices = uniqueMatchedServices.toList();

      setState(() {
        isLoadingserviceList = false;
        isListServiceEmpty = matchedServices.isEmpty;
      });
    } catch (e) {
      // Handle the error here
      logger.d('Error occurred while searching for services: $e');
      setState(() {
        isLoadingserviceList = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Service Request'),
        backgroundColor: Colors.black, // Set a dark app bar background color
      ),
      backgroundColor: Colors.black, // Set a dark background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              headings("What service do you need?",
                  "Provide the service that you need. Be specific about the service name this will help providers to review the request."),
              TextFormField(
                controller: _serviceController,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  prefix: Icon(
                    Icons.handshake,
                    color: Colors.white,
                  ),
                  labelText: 'Service name',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
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
                onChanged: (value) {
                  searchServices(value);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return "You left this field empty!";
                  }
                  return null;
                },
                onSaved: (value) => service_name = value,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: isLoadingserviceList == false
                    ? isListServiceEmpty
                        ? Center(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Sorry, service not found.",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 243, 70, 58),
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " No worrys just type in your service name and continue.",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 58, 135, 243),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double containerHeight =
                                  matchedServices.length * 90.0;
                              containerHeight = containerHeight.clamp(0, 200);
                              return Container(
                                height: containerHeight,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(138, 53, 52, 52),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.separated(
                                  itemCount: matchedServices.length,
                                  itemBuilder: (context, index) {
                                    String name = matchedServices[index];
                                    return ListTile(
                                      title: Text(
                                        name,
                                        style: TextStyle(color: Colors.white60),
                                      ),
                                      onTap: () {
                                        setState(() {});
                                        selectedName = matchedServices[index];
                                        _serviceController.text = selectedName;
                                        setState(() {
                                          matchedServices.clear();
                                        });
                                        // Handle the selection logic here
                                      },
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      color: Color.fromARGB(48, 189, 189, 189),
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
                        child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.white, size: 20),
                      ),
              ),
              headings("Describe your need.",
                  "Describe your project in detail so the the providers can understand your project."),
              TextFormField(
                style: TextStyle(color: Colors.white),
                maxLength: maxLetters,
                maxLines: null,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Describe your need.',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  counterText: "${_aboutController.text.length}/$maxLetters",
                  counterStyle: TextStyle(
                    color: Colors.white,
                  ), // Display remaining character count
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
                validator: (value) {
                  if (value!.isEmpty) {
                    return "You left this field empty!";
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
              ),
              headings("Choose the level of need.",
                  "This will help the providers to understand the urgency of the service."),
              Theme(
                data: ThemeData.dark(), // Set dark theme for the dropdown
                child: DropdownButtonFormField<String>(
                  value: service_level,
                  decoration: InputDecoration(
                    labelText: 'Choose the service level',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),

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
                  items: <String>['Very urgent', 'Urgent', 'Normal']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      service_level = value;
                    });
                  },
                ),
              ),
              headings("Location", "Provide the place where to be serviced."),
              isCurrentLocationFetching
                  ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      LoadingAnimationWidget.beat(
                        color: const Color.fromARGB(255, 135, 130, 129),
                        size: 20,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Fetching your location...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ])
                  : TextFormField(
                      controller: _locationController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Provide location',
                        labelStyle:
                            TextStyle(color: Colors.white, fontSize: 12),
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
                            : IconButton(
                                onPressed: () async {
                                  final fetchLocation = FetchCurrentLocation();
                                  await fetchLocation.fetchLocation();
                                  String location =
                                      fetchLocation.yrCurrentLocation;
                                  setState(() {
                                    _locationController.text = location;
                                  });
                                },
                                icon: Icon(
                                  Icons.my_location_sharp,
                                  color: Colors.white54,
                                ),
                              ),
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
                      onChanged: (value) {
                        searchPlaces(value);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "You left this field empty!";
                        }
                        return null;
                      },
                      onSaved: (value) => location = value,
                    ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: isLocationFetchingList == false
                    ? isListEmpty
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
                              double containerHeight = resultList.length * 90.0;
                              containerHeight = containerHeight.clamp(0, 200);
                              return Container(
                                height: containerHeight,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(138, 53, 52, 52),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.separated(
                                  itemCount: resultList.length,
                                  itemBuilder: (context, index) {
                                    String name = resultList[index]["name"] ??
                                        resultList[index]["formatted"] ??
                                        "";
                                    String country =
                                        resultList[index]["country"] ?? "";
                                    String state = resultList[index]["state"] ??
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
                                        style: TextStyle(color: Colors.white60),
                                      ),
                                      subtitle: Text(
                                          "$state, $county, $country",
                                          style:
                                              TextStyle(color: Colors.white60)),
                                      onTap: () {
                                        setState(() {});
                                        selectedName = resultList[index]
                                                ["name"] ??
                                            resultList[index]["formatted"] ??
                                            "";
                                        _locationController.text = selectedName;
                                        setState(() {
                                          resultList.clear();
                                        });
                                        // Handle the selection logic here
                                      },
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      color: Color.fromARGB(48, 189, 189, 189),
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
                        child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.white, size: 20),
                      ),
              ),
              headings("Day & Time", "Date that the service is expected"),
              Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                ),
                child: ListTile(
                  title: Text(
                    day == null
                        ? 'Select Day'
                        : '${day.toString().substring(0, 16)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          day = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              headings("Budget", "What is the proposed wage of this project"),
              TextFormField(
                controller: _budgetController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefix: Icon(Icons.currency_rupee, color: Colors.white),
                  labelText: 'Provide budget',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),

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
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  wage = int.tryParse(value ?? '');
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      final DocumentReference defaultRef = _firestore
                          .collection('payments')
                          .doc('payments/docs');
                      NewRequestModal sendRequestData = NewRequestModal(
                          description: _descriptionController.text,
                          service_level: service_level,
                          location: _locationController.text,
                          dateRequested: DateTime.now(),
                          day: day,
                          wage: int.tryParse(_budgetController.text),
                          service_name: _serviceController.text,
                          vendor_reference: FirebaseFirestore.instance
                              .doc('/users/$vendorId'),
                          user_reference:
                              FirebaseFirestore.instance.doc('/users/$uid'),
                          status: 'new',
                          clientStatus: 'requested',
                          paymentStatus: 'unPaid',
                          paymentLog: defaultRef);
                      Map<String, dynamic> requestData =
                          sendRequestData.toJson();
                      await _firestore
                          .collection('service_actions')
                          .add(requestData);

                      // Clear the text fields
                      _descriptionController.clear();
                      _locationController.clear();
                      _budgetController.clear();
                      _serviceController.clear();
                      Navigator.pop(context);
                    } catch (e) {
                      logger.e(e);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Set text color to white
                ),
                child: Text('Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }
}

Widget headings(String heading, String subheading) {
  return Column(
    children: [
      SizedBox(
        height: 15,
      ),
      RichText(
        textAlign: TextAlign.start,
        text: TextSpan(children: [
          TextSpan(
            text: "$heading\n",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          WidgetSpan(
              child: Divider(
            color: const Color.fromARGB(134, 158, 158, 158),
          )),
          TextSpan(
            text: subheading,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(151, 255, 255, 255),
            ),
          ),
        ]),
      ),
      SizedBox(
        height: 15,
      ),
    ],
  );
}
