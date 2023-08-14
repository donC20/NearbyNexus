// ignore_for_file: avoid_print, must_be_immutable

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:NearbyNexus/models/general_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CompleteRegistrationByvendor extends StatefulWidget {
  const CompleteRegistrationByvendor({super.key});

  @override
  State<CompleteRegistrationByvendor> createState() =>
      _CompleteRegistrationByvendorState();
}

class _CompleteRegistrationByvendorState
    extends State<CompleteRegistrationByvendor> {
  final _fieldKey = GlobalKey<FormState>();

  bool showError = false;
  bool showErrorDp = false;
  bool isLoading = false;
  bool isloadingLocation = true;
  String? errorMessage = "Error";
  String userType = "general_user";
  Color borderColor = Colors.black26;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _agecontroller = TextEditingController();
  String? selectedValue;
  File? _profileImage;

  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime.now()) {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final DateFormat yearFormatter = DateFormat('yyyy');
      final String formattedDate = formatter.format(picked);
      final int formattedYear = int.parse(yearFormatter.format(picked));

      final int age = DateTime.now().year - formattedYear;

      _agecontroller.text = age.toString();
      _dateController.text = formattedDate;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // back pressed button event
  Future<bool> _onBackPressed() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Exit"),
            content: const Text(
                "Your in registration process your data may not be saved. Are you sure you want to exit the app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Don't exit
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit
                child: const Text("Yes"),
              ),
            ],
          ),
        )) ??
        false;
  }

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
    _nameController.text = userTransferdData?['name'];
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
                          fontFamily: GoogleFonts.poppins().fontFamily,
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
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _profileImage != null
                            ? InkWell(
                                onTap: () {
                                  _pickImage();
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: FileImage(_profileImage!),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  _pickImage();
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  child: SvgPicture.asset(
                                    "assets/images/vector/add_dp.svg",
                                    width: 100,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Visibility(
                            visible: showErrorDp,
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
                  const SizedBox(height: 30),
                  FormFeildCustom(
                    customController: _nameController,
                    hintText: "Eg. Jhon Doe",
                    labelText: "What do we call you?",
                    inputType: TextInputType.name,
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
                  FormFeildCustom(
                    customController: _phoneController,
                    labelText: "What is your contact number?",
                    hintText: "+91 7845926457",
                    inputType: TextInputType.number,
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
                  FormFeildCustom(
                    customController: _dateController,
                    labelText: "When is your birthday",
                    hintText: "Choose a date",
                    inputType: TextInputType.datetime,
                    onTap: () => _selectDate(context),
                    readOnly: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }

                      return null;
                    },
                  ),

                  FormFeildCustom(
                    customController: _agecontroller,
                    labelText: "What is your age?",
                    hintText: "Eg. 21",
                    inputType: TextInputType.number,
                    readOnly: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }

                      return null;
                    },
                  ),

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
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "You left this field empty!";
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // print(_agecontroller.text);
                                if (_profileImage == null) {
                                  // Show error message in TextFormField
                                  setState(() {
                                    showErrorDp = true;
                                    borderColor = Colors.red;
                                    errorMessage = "Please choose an image";
                                  });
                                } else {
                                  setState(() {
                                    showErrorDp = false;
                                    borderColor = Colors.black26;
                                  });
                                }

                                if (_fieldKey.currentState!.validate() &&
                                    _profileImage != null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Map<String, dynamic> vendorInitialData;
                                  vendorInitialData = {
                                    "uid": userTransferdData?["uid"],
                                    "name": _nameController.text,
                                    "phone": _phoneController.text,
                                    "email": userTransferdData?["email"],
                                    "imageData": _profileImage,
                                    "dob": _dateController.text,
                                    "age": _agecontroller.text,
                                    "location": _locationController.text
                                  };
                                  Navigator.popAndPushNamed(
                                      context, "final_form_vendor",
                                      arguments: vendorInitialData);
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  isLoading == true
                                      ? LoadingAnimationWidget
                                          .staggeredDotsWave(
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0),
                                              size: 50)
                                      : const Flexible(
                                          child: Text(
                                            "Done",
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_right),
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
      ),
    );
  }
}

class FormFeildCustom extends StatelessWidget {
  final TextEditingController customController;
  final String hintText;
  final String labelText;
  final Widget prefix, suffix;
  TextInputType? inputType = TextInputType.text;
  final String? Function(String?)? validator;
  bool readOnly;
  final VoidCallback? onTap;

  FormFeildCustom({
    Key? key,
    required this.customController,
    required this.hintText,
    required this.labelText,
    this.inputType,
    this.validator,
    this.prefix = const SizedBox(),
    this.suffix = const SizedBox(),
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          TextFormField(
            controller: customController,
            keyboardType: inputType,
            readOnly: readOnly,
            onTap: onTap, // Use the provided onTap function
            style: GoogleFonts.poppins(color: Colors.black),
            decoration: InputDecoration(
              prefix: prefix,
              suffix: suffix,
              labelText: labelText,
              contentPadding: const EdgeInsets.only(left: 25, bottom: 35),
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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
            validator: validator,
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
