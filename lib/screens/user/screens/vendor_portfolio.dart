// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../components/user_list_tile.dart';

class VendorPortfolio extends StatefulWidget {
  const VendorPortfolio({super.key});

  @override
  State<VendorPortfolio> createState() => _VendorPortfolioState();
}

class _VendorPortfolioState extends State<VendorPortfolio> {
  String vendorId = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTheVendor();
    setState(() {
      vendorId = ModalRoute.of(context)!.settings.arguments as String;
    });
  }

  // Variables to be used
  bool isFetching = true;
  String name = "loading...";
  String dpImage =
      "https://dealio.imgix.net/uploads/147885uploadshotel-pool-canaves.jpg";
  String geoLocation = "loading...";
  List<dynamic> serviceList = [];
  List<dynamic> workingDays = ["Monday", "Tuesday", "Friday", "Saturday"];
  Map<String, String> languages = {
    "English": "Excellent proficiency",
    "French": "Intermediate proficiency",
    "Spanish": "Basic proficiency",
  };
  Future<void> getTheVendor() async {
// Get Vendor details by uid
    String vendorId = ModalRoute.of(context)!.settings.arguments as String;
    DocumentSnapshot snaps = await FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId)
        .get();
    if (snaps.exists) {
      Map<String, dynamic> vendorData = snaps.data() as Map<String, dynamic>;
      setState(() {
        name = vendorData['name'];
        dpImage = vendorData['image'];
        geoLocation = vendorData['geoLocation'];
        isFetching = false;
        serviceList = vendorData['services'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isFetching == true
          ? Container(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(
                child: LoadingAnimationWidget.prograssiveDots(
                    color: const Color.fromARGB(255, 255, 255, 255), size: 80),
              ),
            )
          :
          // Profile image and all
          Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height - 550,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(25),
                            bottomLeft: Radius.circular(25)),
                        child: Image.network(
                          dpImage,
                          width: 80,
                          height: 80,
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else if (loadingProgress.expectedTotalBytes !=
                                    null &&
                                loadingProgress.cumulativeBytesLoaded <
                                    loadingProgress.expectedTotalBytes!) {
                              return Center(
                                child: LoadingAnimationWidget.discreteCircle(
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(71, 0, 0, 0),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(25),
                              bottomLeft: Radius.circular(25)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            fontFamily: GoogleFonts.poppins()
                                                .fontFamily),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        geoLocation,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            fontFamily: GoogleFonts.poppins()
                                                .fontFamily),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Flexible(
                                              child: Text(
                                                "Contact",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.work_outlined,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                // Bio of vendor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      children: [
                        // user status rating etc..
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            progressCircles(30, "Jobs done"),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 1.0,
                              height: 55,
                              color: const Color.fromARGB(154, 158, 158, 158),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            progressCircles(5, "Rating"),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 1.0,
                              height: 55,
                              color: const Color.fromARGB(154, 158, 158, 158),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            progressCircles(5, "Experience"),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),

                        // About me container
                        Text("About me",
                            style: TextStyle(
                                color: Color.fromARGB(255, 208, 208, 208),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 0,
                        ),

                        Text(
                          "The project is a location-based service providing application that utilises the user's local location to connect them with available services, ranging from small-scale to large-scale providers. The application caters to users who are in a new town or city and need to contact service providers like taxi drivers, tailors, lawyers, labour and more, without having their contact information readily available.",
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: Color.fromARGB(191, 208, 208, 208),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text("What I do",
                            style: TextStyle(
                                color: Color.fromARGB(255, 208, 208, 208),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        // list of services
                        Wrap(
                            runSpacing: -5.0,
                            spacing: 8.0,
                            children: serviceList.map((e) {
                              return Chip(
                                  labelStyle: TextStyle(color: Colors.white54),
                                  side: BorderSide(
                                      color: const Color.fromARGB(
                                          194, 158, 158, 158)),
                                  backgroundColor: Color.fromARGB(255, 0, 0, 0),
                                  label: Text(convertToSentenceCase(e)));
                            }).toList()),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text("My working days",
                            style: TextStyle(
                                color: Color.fromARGB(255, 208, 208, 208),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        Wrap(
                          spacing: 5.0,
                          children: workingDays.map((e) {
                            return Chip(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color:
                                      const Color.fromARGB(194, 158, 158, 158),
                                ),
                                borderRadius: BorderRadius.circular(
                                    8.0), // Set your desired border radius
                              ),
                              backgroundColor:
                                  Color.fromARGB(255, 255, 255, 255),
                              label: Text(
                                convertToSentenceCase(e),
                                style: TextStyle(
                                  color: const Color.fromARGB(137, 0, 0, 0),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("Languages",
                            style: TextStyle(
                                color: Color.fromARGB(255, 208, 208, 208),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),

                        SizedBox(
                          height: 250,
                          child: ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              String language = languages.keys.elementAt(index);
                              String proficiency =
                                  languages.values.elementAt(index);

                              return ListTile(
                                title: Text(
                                  language,
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  proficiency,
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                        127, 255, 255, 255),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                color: Color.fromARGB(50, 207, 216, 220),
                                thickness: 1.0,
                                indent: 0,
                                endIndent: 0,
                              );
                            },
                            itemCount: languages.length,
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("What others say.",
                            style: TextStyle(
                                color: Color.fromARGB(255, 208, 208, 208),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),

                        UserReviewContainer(
                          review: Review(
                            'John Doe',
                            'The service was excellent! I am very satisfied with their work.',
                            4.5,
                          ),
                        ),
                        UserReviewContainer(
                          review: Review(
                            'John Doe',
                            'The service was excellent! I am very satisfied with their work.',
                            4.5,
                          ),
                        ),

                        SizedBox(
                          height: 15,
                        ),
                        Divider(
                          color: Color.fromARGB(50, 207, 216, 220),
                          thickness: 3.0,
                          indent: 0,
                          endIndent: 0,
                        ),
                        Text("Others with relavent job.",
                            style: TextStyle(
                                color: Color.fromARGB(255, 208, 208, 208),
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 400,
                          child: Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .where('userType', isEqualTo: 'vendor')
                                  .where('services',
                                      arrayContainsAny: serviceList)
                                  .where(FieldPath.documentId,
                                      isNotEqualTo:
                                          vendorId) // Filter by services
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }

                                final vendors = snapshot.data!
                                    .docs; // List of QueryDocumentSnapshot

                                if (vendors.isEmpty) {
                                  return const Center(
                                    child: Text("No users found!"),
                                  );
                                }
                                return ListView.separated(
                                  itemCount: vendors.length,
                                  itemBuilder: (context, item) {
                                    final vendor = vendors[item].data()
                                        as Map<String, dynamic>;
                                    final docId = vendors[item].id;

                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors
                                            .transparent, // Set a transparent background for the avatar
                                        child: SizedBox(
                                          width: 50,
                                          child: ClipOval(
                                            // Clip the image to an oval (circle) shape
                                            child: Image.network(
                                              vendor['image'],
                                              fit: BoxFit.cover,
                                              loadingBuilder:
                                                  (BuildContext context,
                                                      Widget child,
                                                      ImageChunkEvent?
                                                          loadingProgress) {
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
                                                    child:
                                                        LoadingAnimationWidget
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
                                        vendor['name'],
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: FittedBox(
                                        fit: BoxFit.cover,
                                        child: Text(
                                          vendor['geoLocation'],
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  114, 255, 255, 255),
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                      trailing: OutlinedButton(
                                          onPressed: () {
                                            Navigator.pushReplacementNamed(
                                                context,
                                                "vendor_profile_opposite",
                                                arguments: docId);
                                          },
                                          child: Text("View")),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Divider(
                                      color: Color.fromARGB(50, 207, 216, 220),
                                      thickness: 1.0,
                                      indent: 0,
                                      endIndent: 0,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// widgets

Widget progressCircles(int count, String tagline) {
  return Column(
    children: [
      Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(50))),
        child: Center(
          child: Text(
            count.toString(),
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
      SizedBox(
        height: 5,
      ),
      Text(
        tagline,
        style: TextStyle(color: Colors.white54, fontSize: 12),
      ),
    ],
  );
}
