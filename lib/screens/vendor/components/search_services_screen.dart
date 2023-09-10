// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:NearbyNexus/components/bottom_sheet_contents.dart';
import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:NearbyNexus/models/vendor_model.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SearchScreenServices extends StatefulWidget {
  const SearchScreenServices({super.key});

  @override
  State<SearchScreenServices> createState() => _SearchScreenServicesState();
}

class _SearchScreenServicesState extends State<SearchScreenServices> {
  final _fieldKey = GlobalKey<FormState>();

  bool showError = false;
  bool showErrorDp = false;
  bool isLoading = false;
  bool isLoadingList = true;
  var l = Logger();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  String? uid = '';
  @override
  void initState() {
    super.initState();
    _onSearchChanged();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      uid = Provider.of<UserProvider>(context, listen: false).uid;
    });
  }

  Future<bool> _onBackPressed() async {
    // back pressed button event

    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Exit"),
            content: const Text(
                "Your data may not be saved. Are you sure you want to exit?"),
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
      setState(() {
        isLoadingList = false;
      });
      return matchedServices;
    } catch (e) {
      // Handle the error here
      l.d('Error occurred while searching for services: $e');
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
      l.d("Already added");
    }

    l.d(_selectedItems);
  }

  void _removeFromSelectedItems(String item) {
    setState(() {
      _selectedItems.remove(item);
    });
  }

  Future<void> submitApplication(List<String> servicesList) async {
    // ?check if the user uploaded image

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({"services": servicesList}).then((value) {
      // insert success
      showSnackbar("Service list updated", Colors.green);
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    }).catchError((error) {
      // insert error
      showSnackbar(error.message, Colors.red);
    });
  }

  // ?----------------------------Searching ends------------------------------------

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _fieldKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const SizedBox(height: 80),
                Transform.translate(
                  offset: const Offset(20, 0.0),
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
                          children: [
                            TextSpan(
                              text: "Tell us about your desired",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                            ),
                            WidgetSpan(
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    colors: [
                                      Colors.blue,
                                      Colors.green,
                                    ], // Adjust gradient colors as needed
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  "Field of services",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "This will help us to recommend jobs for you.",
                        style: TextStyle(
                            color: Color.fromARGB(163, 255, 255, 255)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: SizedBox(
                        height: 55,
                        child: TextFormField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Search your relevant jobs",
                            hintStyle: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(114, 255, 255, 255)),
                            contentPadding:
                                const EdgeInsets.only(left: 25, bottom: 35),
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(74, 158, 158, 158),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(74, 158, 158, 158),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(74, 158, 158, 158),
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
                      child: isLoadingList == false
                          ? ListView.separated(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                String result = _searchResults[index];
                                bool isSelected =
                                    _selectedItems.contains(result);

                                return ListTile(
                                  title: Text(
                                    convertToSentenceCase(result),
                                    style: TextStyle(
                                      color: Color.fromARGB(180, 255, 255, 255),
                                      fontSize: 14,
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
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
                                            color:
                                                Color.fromARGB(255, 223, 59, 9),
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () {
                                            _addToSelectedItems(result);
                                          },
                                          icon: const Icon(
                                            Icons.add,
                                            size: 18.0,
                                            color:
                                                Color.fromARGB(255, 9, 87, 223),
                                          ),
                                        ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                color: Color.fromARGB(150, 158, 158, 158),
                              ),
                            )
                          : LoadingAnimationWidget.flickr(
                              leftDotColor: Colors.black,
                              rightDotColor: Colors.deepOrange,
                              size: 40),
                    ),

                    // Add code to display the selected items above the search bar

                    // Add code to display the selected items above the search bar
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _openBottomSheet(context, _selectedItems,
                              _removeFromSelectedItems);
                        },
                        child: Text(
                          "${_selectedItems.length} jobs added",
                          style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.poppins().fontFamily),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape
                              .circle, // You can adjust the shape as needed
                        ),
                        child: IconButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_fieldKey.currentState!.validate() &&
                                      _selectedItems.isNotEmpty) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    submitApplication(_selectedItems);
                                  }
                                },
                          icon: isLoading == true
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                  size: 20)
                              : Icon(
                                  Icons.arrow_right_alt,
                                  color: Colors.black,
                                ),
                        ),
                      ),
                    ],
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

void _openBottomSheet(BuildContext context, List<String> selectedItems,
    void Function(String) removeItem) {
  showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return BottomSheetContent(
        selectedItems: selectedItems,
        removeItem: (item) {
          removeItem(item);
        },
      );
    },
  );
}
