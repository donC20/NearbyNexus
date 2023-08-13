// ignore_for_file: avoid_print, unused_element, non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  @override
  void initState() {
    super.initState();
    _onSearchChanged();
    _searchController.addListener(_onSearchChanged);
  }

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
      _searchResults = results.isEmpty ? ["No results found 🥺"] : results;
    });
  }

  final List<String> _selectedItems = [];

  void _addToSelectedItems(String item) {
    bool isAlreadyAdded = false;

    for (dynamic service in _selectedItems) {
      if (service.toString() == item) {
        isAlreadyAdded = true;
        break;
      }
    }

    if (!isAlreadyAdded) {
      setState(() {
        _selectedItems.add(item);
      });
    } else {
      print("Already added");
    }

    print(_selectedItems);
  }

  void _removeFromSelectedItems(String item) {
    setState(() {
      _selectedItems.remove(item);
    });
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // const SizedBox(height: 80),
                  Transform.translate(
                    offset: const Offset(
                        20, 40.0), // Adjust the vertical offset as needed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                            children: const [
                              TextSpan(
                                text: "Tell us about your desired",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: " Field of service",
                                style: TextStyle(color: Color(0xFFFD5301)),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          "This will help us to recommend jobs for you.",
                          style: TextStyle(color: Color.fromARGB(164, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  Column(
                    children: [
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SizedBox(
                          height: 55,
                          child: TextFormField(
                            controller: _searchController,
                            style: GoogleFonts.poppins(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: "Search your relevant jobs",
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding:
                                  const EdgeInsets.only(left: 25, bottom: 35),
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(182, 0, 0, 0),
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(166, 158, 158, 158),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color.fromARGB(166, 158, 158, 158),
                                ),
                              ),
                              suffixIcon:
                                  const Icon(Icons.search, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Container(
                        height: MediaQuery.sizeOf(context).height - 360,
                        padding: const EdgeInsets.all(5),
                        width: MediaQuery.sizeOf(context).width - 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color.fromARGB(132, 158, 158, 158),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            String result = _searchResults[index];
                            bool isSelected = _selectedItems.contains(result);

                            return ListTile(
                              title: Text(
                                convertToSentenceCase(result),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                ),
                              ),
                              trailing: isSelected
                                  ? IconButton(
                                      onPressed: () {
                                        _removeFromSelectedItems(result);
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        size: 18.0,
                                        color: Color.fromARGB(255, 223, 59, 9),
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        _addToSelectedItems(result);
                                      },
                                      icon: const Icon(
                                        Icons.add,
                                        size: 18.0,
                                        color: Color.fromARGB(255, 9, 87, 223),
                                      ),
                                    ),
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(
                            color: Color.fromARGB(150, 158, 158, 158),
                          ),
                        ),
                      ),

                      // Add code to display the selected items above the search bar

                      // Add code to display the selected items above the search bar
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(
                        "${_selectedItems.length} jobs added",
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.poppins().fontFamily),
                      ),
                      trailing: ContinueButton(isLoading),
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

Widget ContinueButton(bool isLoading) {
  return SizedBox(
    height: 50,
    width: 150,
    child: ElevatedButton(
      onPressed: isLoading
          ? null
          : () {
              // if (_profileImage == null) {
              //   // Show error message in TextFormField
              //   setState(() {
              //     showErrorDp = true;
              //     borderColor = Colors.red;
              //     errorMessage = "Please choose an image";
              //   });
              // } else {
              //   setState(() {
              //     showErrorDp = false;
              //     borderColor = Colors.black26;
              //   });
              // }

              // if (_fieldKey.currentState!.validate() &&
              //     _profileImage != null) {
              //   setState(() {
              //     isLoading = true;
              //   });
              //   submitApplication(
              //       _nameController.text,
              //       userTransferdData?['email'],
              //       int.parse(_phoneController.text),
              //       0.0,
              //       0.0,
              //       "general_user",
              //       _locationController.text);
              // }
            },
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF25211E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: const Color.fromARGB(255, 0, 0, 0), size: 50)
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
  );
}
