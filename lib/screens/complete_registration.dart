// ignore_for_file: avoid_print

import 'package:NearbyNexus/models/general_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CompleteRegistration extends StatefulWidget {
  const CompleteRegistration({super.key});

  @override
  State<CompleteRegistration> createState() => _CompleteRegistrationState();
}

class _CompleteRegistrationState extends State<CompleteRegistration> {
  final _fieldKey = GlobalKey<FormState>();
  final GlobalKey<DropdownButton2State<String>> _dropdownKey = GlobalKey();

  bool showError = false;
  bool isloadingLocation = true;
  bool _isChecked = false;
  String? errorMessage = "Error";
  String userType = "general_user";
  Color borderColor = Colors.black26;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String? selectedValue;
  List<String> listItems = ['Here for hire', 'Here for work'];

  void showSnackbar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

// location fetching

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndSetAddress();
  }

  Future<void> _getCurrentLocationAndSetAddress() async {
    try {
      _currentPosition = await getCurrentLocation();
      if (_currentPosition != null) {
        String? address = await getAddressFromLocation(_currentPosition!);
        if (address != null) {
          setState(() {
            _locationController.text = address;
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
    Map<String, dynamic>? userTransferdData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    Future<void> submitApplication(
        String name,
        String emailId,
        int phone,
        double latitude,
        double longitude,
        String image,
        String userType,
        String currentGeoLocation) async {
      GeneralUser user = GeneralUser(
          name: name,
          emailId: emailId,
          phone: phone,
          latitude: latitude,
          longitude: longitude,
          image: image,
          userType: userType,
          currentGeoLocation: currentGeoLocation);
      Map<String, dynamic> userData = user.toJson();
      String uid = userTransferdData?['uid'];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData)
          .then((value) {
        // insert success
        showSnackbar("Registration Successful", Colors.green);
      }).catchError((error) {
        // insert error
        showSnackbar(error.message, Colors.red);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _fieldKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const SizedBox(height: 80),
                Transform.translate(
                  offset: const Offset(
                      20, 40.0), // Adjust the vertical offset as needed
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.aBeeZee().fontFamily,
                      ),
                      children: const [
                        TextSpan(
                          text: "Please complete the,\n",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "Registration",
                          style: TextStyle(color: Color(0xFFFD5301)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Whats your name?',
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      hintText: "Eg : John Doe",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }
                      bool nameRegex = RegExp(r'^[a-zA-Z]{3,}(?: [a-zA-Z]+)*$')
                          .hasMatch(value);
                      if (!nameRegex) {
                        return "Must contain atleast 3 characters & avoid any numbers.";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      prefix: const Text("+91 "),
                      labelText: 'Whats is your phone number?',
                      hintText: "7516482450",
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }
                      bool passwordRegex =
                          RegExp(r'^[6789]\d{9}$').hasMatch(value);
                      if (!passwordRegex) {
                        return "Invalid phone number.";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          key: _dropdownKey,
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'What you are looking for?',
                                  style: TextStyle(
                                      color: Color.fromARGB(182, 0, 0, 0),
                                      fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: listItems
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                          color: Color.fromARGB(182, 0, 0, 0),
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: selectedValue,
                          onChanged: (String? value) {
                            setState(() {
                              selectedValue = value;
                            });
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 60,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: borderColor,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 0,
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                            ),
                            iconSize: 14,
                            iconEnabledColor: Color.fromARGB(255, 0, 0, 0),
                            iconDisabledColor: Colors.grey,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            padding: const EdgeInsets.only(left: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all<double>(6),
                              thumbVisibility:
                                  MaterialStateProperty.all<bool>(true),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                            padding: EdgeInsets.only(left: 0, right: 0),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Visibility(
                          visible: showError,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _locationController,
                    style: GoogleFonts.poppins(color: Colors.black),
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: Visibility(
                        visible: isloadingLocation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LoadingAnimationWidget.beat(
                              color: const Color.fromARGB(255, 135, 130, 129),
                              size: 20,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text("Fetching your location..."),
                          ],
                        ),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isloadingLocation = true;
                            });
                            _locationController.clear();
                            _getCurrentLocationAndSetAddress();
                          },
                          icon: const Icon(Icons.my_location_sharp)),
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    // validator: (value) {
                    //   if (value!.isEmpty) {
                    //     return "You left this field empty!";
                    //   } else if (_phoneController.text != value) {
                    //     return "Passwords do not match!";
                    //   }

                    //   return null;
                    // },
                  ),
                ),

                const SizedBox(height: 5),
                CheckboxListTile(
                  title: const Text("I agree to the terms and conditions"),
                  value: _isChecked,
                  onChanged: (newValue) {
                    setState(() {
                      _isChecked = newValue ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity
                      .leading, // Checkbox appears before the title
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if drop-down value is empty using GlobalKey
                        if (selectedValue == null || selectedValue!.isEmpty) {
                          // Show error message in TextFormField
                          setState(() {
                            showError = true;
                            borderColor = Colors.red;
                            errorMessage = "You must select an option";
                          });
                        } else {
                          setState(() {
                            showError = false;
                            borderColor = Colors.black26;
                          });
                        }

                        if (_fieldKey.currentState!.validate() &&
                            selectedValue!.isNotEmpty &&
                            selectedValue != null) {
                          // check user type

                          if (selectedValue == "Here for work") {
                            setState(() {
                              userType = "vendor";
                            });
                          } else {
                            setState(() {
                              userType = "general_user";
                            });
                          }

                          submitApplication(
                              _nameController.text,
                              userTransferdData!['email'],
                              int.parse(_phoneController.text),
                              0.0,
                              0.0,
                              "null",
                              userType,
                              _locationController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: const Color(0xFF25211E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Continue",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_right),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
