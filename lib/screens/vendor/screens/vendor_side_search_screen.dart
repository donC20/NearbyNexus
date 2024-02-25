// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:skeletons/skeletons.dart';

class VendorSideSearchScreen extends StatefulWidget {
  const VendorSideSearchScreen({super.key});

  @override
  State<VendorSideSearchScreen> createState() => _VendorSideSearchScreenState();
}

class _VendorSideSearchScreenState extends State<VendorSideSearchScreen> {
  final vendorSearchController = TextEditingController();
  bool isSearching = false;
  String searchKeyWords = "";
  final searchResults = [];
  var log = Logger();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: TextFormField(
                  controller: vendorSearchController,
                  onTap: () {
                    searchResults.clear();
                  },
                  style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSecondary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(112, 158, 158, 158),
                    labelText: 'Search name, services, email etc.',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
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
                      .where('userType', isEqualTo: 'vendor')
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
                          child: Text(''),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                        ),
                      );
                    } else {
                      final searchResults = snapshot.data?.docs.where((doc) {
                            final name = (doc['name'] as String).toLowerCase();
                            final emailId =
                                (doc['emailId']['id'] as String).toLowerCase();
                            final services = (doc['services'] as List)
                                .map((service) =>
                                    service.toString().toLowerCase())
                                .toList();
                            final geoLocation =
                                (doc['geoLocation'] as String).toLowerCase();
                            return name
                                    .contains(searchKeyWords.toLowerCase()) ||
                                geoLocation
                                    .contains(searchKeyWords.toLowerCase()) ||
                                emailId
                                    .contains(searchKeyWords.toLowerCase()) ||
                                services.any((service) => service
                                    .contains(searchKeyWords.toLowerCase()));
                          }).toList() ??
                          [];
                      if (searchKeyWords.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                height: 250,
                                width: 250,
                                "assets/images/vector/search_for_user.svg",
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Enter any keyword to search.',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      } else if (searchResults.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                height: 250,
                                width: 250,
                                "assets/images/vector/alone.svg",
                              ),
                              SizedBox(height: 15),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text:
                                        '): Sorry, We could\'nt find anything!\n',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                    children: [
                                      TextSpan(
                                          text: 'Try changing the keywords.',
                                          style: TextStyle(fontSize: 16)),
                                    ]),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final uid = searchResults[index].id;
                          final userData = searchResults[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                  context, "vendor_profile_opposite",
                                  arguments: uid);
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors
                                    .transparent, // Set a transparent background for the avatar
                                child: SizedBox(
                                  width: 50,
                                  child: ClipOval(
                                    // Clip the image to an oval (circle) shape
                                    child: Image.network(
                                      userData['image'],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else if (loadingProgress
                                                    .expectedTotalBytes !=
                                                null &&
                                            loadingProgress
                                                    .cumulativeBytesLoaded <
                                                loadingProgress
                                                    .expectedTotalBytes!) {
                                          return Center(
                                            child: LoadingAnimationWidget
                                                .discreteCircle(
                                              color: Colors.grey,
                                              size: 15,
                                            ),
                                          );
                                        } else {
                                          return SizedBox();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                userData['name'],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary),
                              ),
                              subtitle: Text(
                                userData['geoLocation'],
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: const Color.fromARGB(118, 158, 158, 158),
                            thickness: 1.0,
                            indent: 0,
                            endIndent: 0,
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
