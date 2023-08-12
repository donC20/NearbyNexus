// ignore_for_file: avoid_print

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
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CompleteRegistrationByUser extends StatefulWidget {
  const CompleteRegistrationByUser({super.key});

  @override
  State<CompleteRegistrationByUser> createState() =>
      _CompleteRegistrationByUserState();
}

class _CompleteRegistrationByUserState
    extends State<CompleteRegistrationByUser> {
  final _fieldKey = GlobalKey<FormState>();

  bool showError = false;
  bool showErrorDp = false;
  bool isLoading = false;
  bool isloadingLocation = true;
  bool _isChecked = false;
  String? errorMessage = "Error";
  String userType = "general_user";
  Color borderColor = Colors.black26;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String? selectedValue;
  File? _profileImage;
  String? _imageUrl;

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
    Future<void> submitApplication(
        String name,
        String emailId,
        int phone,
        double latitude,
        double longitude,
        String userType,
        String currentGeoLocation) async {
      // ?check if the user uploaded image
      if (_profileImage != null) {
        try {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('profile_images/dp-${userTransferdData?['uid']}.jpg');
          UploadTask uploadTask = ref.putFile(_profileImage!);
          TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
          String downloadUrl = await snapshot.ref.getDownloadURL();

          setState(() {
            _imageUrl = downloadUrl;
          });

          print('Image uploaded: $_imageUrl');
        } catch (error) {
          print('Image upload error: $error');
        }
      }
      UserModel user = UserModel(
          name: name,
          emailId: emailId,
          phone: phone,
          latitude: latitude,
          longitude: longitude,
          image: _imageUrl,
          userType: userType,
          currentGeoLocation: currentGeoLocation,
          status: 'active');
      Map<String, dynamic> userData = user.toJson();
      String uid = userTransferdData?['uid'];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData)
          .then((value) {
        // insert success
        showSnackbar("Registration Successful", Colors.green);
        Navigator.popAndPushNamed(context, "login_screen");
        setState(() {
          isLoading = false;
        });
      }).catchError((error) {
        // insert error
        showSnackbar(error.message, Colors.red);
      });
    }

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
                        onPressed: isLoading
                            ? null
                            : () {
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
                                  submitApplication(
                                      _nameController.text,
                                      userTransferdData?['email'],
                                      int.parse(_phoneController.text),
                                      0.0,
                                      0.0,
                                      "general_user",
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
                                            "Continue",
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
