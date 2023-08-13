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

 Future<List<String>> searchServices(String keyword) async {
   try {
     final querySnapshot = await FirebaseFirestore.instance.collection('service_list')
         .where('service', arrayContains: keyword)
         .get();
     
     return querySnapshot.docs.map((doc) => doc['service'] as String).toList();
   } catch (e) {
     // Handle the error here
     print('Error occurred while searching for services: $e');
     return []; // Return an empty list or another appropriate value
   }
 }
 

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() async {
    String keyword = _searchController.text;
    List results = await searchServices(keyword);
    setState(() {
      _searchResults = results;
    });
  }

  List<String> _selectedItems = [];

  void _addToSelectedItems(String item) {
    setState(() {
      _selectedItems.add(item);
    });
  }

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
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          String result = _searchResults[index];
                          return ListTile(
                            title: Text(result),
                            onTap: () {
                              // Handle when a search result is clicked
                              _addToSelectedItems(result);
                            },
                          );
                        },
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
