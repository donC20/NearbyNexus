// ignore_for_file: avoid_print, unused_element

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'complete_registration_vendor.dart';

class FinalSubmitFormVendor extends StatefulWidget {
  const FinalSubmitFormVendor({super.key});

  @override
  State<FinalSubmitFormVendor> createState() => _FinalSubmitFormVendorState();
}

class _FinalSubmitFormVendorState extends State<FinalSubmitFormVendor> {
  final _fieldKey = GlobalKey<FormState>();

  bool showError = false;
  bool showErrorDp = false;
  bool isLoading = false;
  bool _isChecked = false;
  String? errorMessage = "Error";
  Color borderColor = Colors.black26;
  String? selectedValue;
  File? _profileImage;
  String? _imageUrl;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

//? ------------------------Function for picking profile image----------------------------------------

  Future<void> _pickImage() async {
    // function used to pick image dp
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

//? --------------------------Function ends--------------------------------------

  Future<bool> _onBackPressed() async {
    // back pressed button event

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

  // ?----------------------------Snack bar (Reusable)------------------------------------

  void showSnackbar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // ?----------------------------Snack bar (ends)------------------------------------

  // ?---------------------------Convert to sentence case--------------------------------
  String convertToSentenceCase(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  // ?---------------------------ends--------------------------------

  // ?---------------------------Function to search  services in a list--------------------------------

  Future<List> searchServices(String keyword) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('services')
              .doc('service_list')
              .get();

      List<dynamic> serviceList = snapshot.data()?['service'];
      List<dynamic> loweCaseServiceList = serviceList
          .map((service) => service.toString().toLowerCase())
          .toList();

      List<String> matchedServices = [];

      for (dynamic service in loweCaseServiceList) {
        if (service.toString().contains(keyword)) {
          matchedServices.add(service.toString());
        }
      }

      return matchedServices;
    } catch (e) {
      // Handle the error here
      print('Error occurred while searching for services: $e');
      return []; // Return an empty list or another appropriate value
    }
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text;
    List results = await searchServices(keyword);
    setState(() {
      _searchResults = results.isEmpty ? ["No results found. 🥺"] : results;
    });
  }

  final List<String> _selectedItems = [];

  void _addToSelectedItems(String item) {
    setState(() {
      _selectedItems.add(item);
    });
    print(_selectedItems);
  }

  // ?----------------------------Searching ends------------------------------------

  @override
  Widget build(BuildContext context) {
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
                            text: "Your Infomation are kept,\n",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: "Confidential",
                            style: TextStyle(color: Color(0xFFFD5301)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),

                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextFormField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(color: Colors.black),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(left: 25, bottom: 35),
                            labelStyle: const TextStyle(
                                color: Color.fromARGB(182, 0, 0, 0),
                                fontSize: 14),
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
                      const SizedBox(height: 10),
                      Visibility(
                        visible: _searchController.text.isNotEmpty,
                        child: SizedBox(
                          height: null,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 250),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              width: MediaQuery.sizeOf(context).width - 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(132, 158, 158, 158),
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  String result = _searchResults[index];
                                  return ListTile(
                                    title: Text(convertToSentenceCase(result)),
                                    onTap: () {
                                      // Handle when a search result is clicked
                                      _addToSelectedItems(result);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Add code to display the selected items above the search bar
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 15),
                  //   child: SizedBox(
                  //     height: 60,
                  //     child: ElevatedButton(
                  //       onPressed: isLoading
                  //           ? null
                  //           : () {
                  //               // if (_profileImage == null) {
                  //               //   // Show error message in TextFormField
                  //               //   setState(() {
                  //               //     showErrorDp = true;
                  //               //     borderColor = Colors.red;
                  //               //     errorMessage = "Please choose an image";
                  //               //   });
                  //               // } else {
                  //               //   setState(() {
                  //               //     showErrorDp = false;
                  //               //     borderColor = Colors.black26;
                  //               //   });
                  //               // }

                  //               // if (_fieldKey.currentState!.validate() &&
                  //               //     _profileImage != null) {
                  //               //   setState(() {
                  //               //     isLoading = true;
                  //               //   });
                  //               //   submitApplication(
                  //               //       _nameController.text,
                  //               //       userTransferdData?['email'],
                  //               //       int.parse(_phoneController.text),
                  //               //       0.0,
                  //               //       0.0,
                  //               //       "general_user",
                  //               //       _locationController.text);
                  //               // }
                  //             },
                  //       style: ElevatedButton.styleFrom(
                  //         textStyle: const TextStyle(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //         backgroundColor: const Color(0xFF25211E),
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(30),
                  //         ),
                  //       ),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Expanded(
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: [
                  //                 isLoading == true
                  //                     ? LoadingAnimationWidget
                  //                         .staggeredDotsWave(
                  //                             color: const Color.fromARGB(
                  //                                 255, 0, 0, 0),
                  //                             size: 50)
                  //                     : const Flexible(
                  //                         child: Text(
                  //                           "Continue",
                  //                           textAlign: TextAlign.center,
                  //                         ),
                  //                       ),
                  //               ],
                  //             ),
                  //           ),
                  //           const Icon(Icons.arrow_right),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
