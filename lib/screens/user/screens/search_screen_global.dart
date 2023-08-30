// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletons/skeletons.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final vendorSearchController = TextEditingController();
  bool isSearching = false;
  String searchKeyWords = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Search for the desired services you need.",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white60,
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: TextFormField(
                  controller: vendorSearchController,
                  onTap: () {},
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 70, 26, 26),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(112, 158, 158, 158),
                    labelText: 'What service you need?',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 240, 237, 237),
                      fontSize: 14,
                    ),
                    labelStyle: const TextStyle(
                      color: Color(0xFF838383),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color.fromARGB(166, 158, 158, 158),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchKeyWords = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "You left this field empty!";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('name', isEqualTo: searchKeyWords)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SkeletonTheme(
                        themeMode: ThemeMode.dark,
                        child: Skeleton(
                          duration: Duration(milliseconds: 800),
                          isLoading: true,
                          skeleton: SkeletonListView(
                            item: SkeletonListTile(
                              contentSpacing: 24,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              hasLeading: true,
                              leadingStyle: SkeletonAvatarStyle(
                                width: 50,
                                height: 50,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              titleStyle: SkeletonLineStyle(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              hasSubtitle: true,
                            ),
                          ),
                          child: Text(
                            "Data",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}',));
                    } else {
                      final searchResults = snapshot.data?.docs
                              .map((doc) => doc['name'])
                              .toList() ??
                          [];
                      return ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(searchResults[index],
                                style: TextStyle(color: Colors.red)),
                          );
                        },
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
