// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class VendorPortfolio extends StatefulWidget {
  const VendorPortfolio({super.key});

  @override
  State<VendorPortfolio> createState() => _VendorPortfolioState();
}

class _VendorPortfolioState extends State<VendorPortfolio> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getTheVendor();
  }

  // Variables to be used
  bool isFetching = true;
  String name = "loading...";
  String dpImage =
      "https://dealio.imgix.net/uploads/147885uploadshotel-pool-canaves.jpg";
  String geoLocation = "loading...";

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
                          child: Column(
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
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily),
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
                                        fontFamily:
                                            GoogleFonts.poppins().fontFamily),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                // Bio of vendor
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      children: [
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
                            fontWeight: FontWeight.bold,
                          ),
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
                          height: 0,
                        ),
                        
                      ],
                    ),
                  ),
                ),

                // bottom buttons
                Container(
                  padding: EdgeInsets.only(bottom: 15, right: 20),
                  width: MediaQuery.sizeOf(context).width,
                  height: 70,
                  decoration: BoxDecoration(),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      height: 40,
                      width: 120,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                                  const Flexible(
                                    child: Text(
                                      "Contact",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
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
                  ),
                ),
              ],
            ),
    );
  }
}
