// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/screens/vendor/bloc/bloc/vendor_bloc.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:logger/logger.dart';

class BroadcastPage extends StatefulWidget {
  const BroadcastPage({super.key});

  @override
  State<BroadcastPage> createState() => _BroadcastPageState();
}

class _BroadcastPageState extends State<BroadcastPage> {
// variables
// Map variables
  Map<String, dynamic> currentUserData = {};

  // other
  final VendorBloc vendorBloc = VendorBloc();
  var logger = Logger();

  @override
  void initState() {
    initializeUserData();
    vendorBloc.add(VendorBroadcastInitialEvent());
    super.initState();
  }

  Future<void> initializeUserData() async {
    Map<String, dynamic> userData = await VendorCommonFn().fetchUserData();
    setState(() {
      currentUserData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    return Scaffold(
      backgroundColor: Color(0xFF0F1014),
      body: Column(
        children: [
          Stack(children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff4338CA), Color(0xff6D28D9)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(200.0),
                  bottomRight: Radius.circular(0.0),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(12, 26),
                    blurRadius: 50,
                    spreadRadius: 0,
                    color: Colors.grey.withOpacity(.1),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: TextField(
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter keywords",
                          hintStyle: TextStyle(
                            color: const Color.fromARGB(106, 0, 0, 0),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color.fromARGB(106, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 35,
              left: 15,
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/nearbynexus(WL).png',
                    height: 42,
                    width: 42,
                  ),
                  Text(
                    "NearbyNexus",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 35,
              right: 15,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "vendor_notification");
                      },
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.white,
                      )),
                  if (currentUserData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: UserLoadingAvatar(
                        userImage: currentUserData["image"],
                        width: 35,
                        height: 35,
                        onTap: () {
                          Navigator.pushNamed(context, "vendor_profile_one");
                        },
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 65,
              left: 110,
              child: Text(
                "Search, find your ideal job...",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Positioned(
              bottom: 30,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Change the button color as needed
                    shape: CircleBorder()),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Icon(
                    Icons.filter_list,
                    color: Colors.black, // Change the icon color as needed
                  ),
                ),
              ),
            )
          ]),
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('job_posts')
                .where("expiryDate", isGreaterThanOrEqualTo: Timestamp.now())
                .where("isWithdrawn", isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                QuerySnapshot<Map<String, dynamic>>? jobData = snapshot.data;
                if (jobData == null || jobData.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/emptyBox.png",
                          width: 200,
                          height: 200,
                        ),
                        SizedBox(height: 15),
                        Text(
                          "There are no saved jobs, please add some..",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 15),
                        GFButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, "/broadcast_page");
                          },
                          text: 'View Jobs',
                          shape: GFButtonShape.pills,
                          icon: Icon(
                            Icons.open_in_browser_rounded,
                            color: Colors.white,
                          ),
                          size: GFSize.MEDIUM,
                          color: const Color.fromARGB(255, 84, 84, 84),
                        )
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: jobData.docs.length,
                    itemBuilder: (BuildContext context, index) {
                      Map<String, dynamic> fetchData =
                          jobData.docs[index].data();
                      String docId = jobData.docs[index].id;
                      return FutureBuilder<Map<String, dynamic>>(
                        future: VendorCommonFn().fetchUserData(
                          uidParam: fetchData['jobPostedBy'],
                        ),
                        builder: (BuildContext context,
                            AsyncSnapshot<Map<String, dynamic>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            Map<String, dynamic> postedUserData =
                                snapshot.data!;
                            return customCard(
                              fetchData,
                              context,
                              postedUserData,
                              vendorBloc,
                              docId,
                            );
                          } else {
                            return Text('No data available');
                          }
                        },
                      );
                    },
                  );
                }
              } else {
                return Container(); // Placeholder for no data scenario
              }
            },
          )),
        ],
      ),
      // bottomNavigationBar: BottomGNav(
      //   activePage: 0,
      //   isSelectable: true,
      // ),
    );
  }
}

Widget customCard(fetch, BuildContext context, postedByData,
    VendorBloc vendorBloc, String docId) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
    child: InkWell(
      onTap: () {
        // vendorBloc.add(UserPostBroadcastPageNavigateEvent());
        Navigator.pushNamed(context, '/job_detail_page', arguments: {
          'job_data': fetch,
          'posted_user': postedByData,
          'post_id': docId
        });
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: const Color.fromARGB(0, 100, 75, 75),
            border: Border.all(color: Color.fromARGB(28, 255, 255, 255)),
            borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: UserLoadingAvatar(
                userImage: postedByData["image"],
                width: 45,
                height: 45,
                onTap: () {
                  Navigator.pushNamed(context, "vendor_profile_one");
                },
              ),
              title: Text(
                fetch["jobTitle"],
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              trailing: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text:
                          UtilityFunctions().shortScaleNumbers(fetch["budget"]),
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  TextSpan(
                      text: " / hour",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white54))
                ]),
              ),
              subtitle: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: const Color.fromARGB(144, 255, 255, 255),
                    size: 16,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    UtilityFunctions().findTimeDifference(fetch['jobPostDate']),
                    style: TextStyle(
                        color: const Color.fromARGB(144, 255, 255, 255),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_pin),
              horizontalTitleGap: 5,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < fetch["preferredLocation"].length; i++)
                    Container(
                      padding: EdgeInsets.only(
                          right: 5), // Add some spacing between locations
                      child: Text(
                        i < fetch["preferredLocation"].length - 1
                            ? fetch["preferredLocation"][i] + ","
                            : UtilityFunctions().truncateText(
                                fetch["preferredLocation"][i],
                                10), // Adjust the character limit
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: fetch["preferredLocation"].length > 3
                  ? Text("+ ${fetch["preferredLocation"].length - 3} more")
                  : SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 15.0, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (int i = 0; i < fetch["skills"].length && i < 3; i++)
                    bottomChipBuilder(
                        UtilityFunctions().truncateText(fetch["skills"][i], 15))
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget bottomChipBuilder(String title) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(73, 158, 158, 158),
          border: Border.all(
            color: Color.fromARGB(22, 255, 255, 255),
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
      SizedBox(
        width: 10,
      )
    ],
  );
}
