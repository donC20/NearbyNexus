// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:flutter/material.dart';
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
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  Future<void> initializeUserData() async {
    Map<String, dynamic> userData = await VendorCommonFn().fetchUserData();
    setState(() {
      currentUserData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1014),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 250,
            floating: false,
            pinned: true,
            leading: Image.asset(
              'assets/images/nearbynexus(WL).png',
              height: 42,
              width: 42,
            ),
            title: Text(
              "NearbyNexus",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            actions: [
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
            titleSpacing: 1.5,
            flexibleSpace: Stack(children: [
              Container(
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
                bottom: 75,
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
          ),
          // Other SliverList, SliverGrid, or SliverWhatever widgets go here
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // Build your list item here
                return Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 10, right: 10, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(0, 100, 75, 75),
                        border: Border.all(
                            color: Color.fromARGB(28, 255, 255, 255)),
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: UserLoadingAvatar(
                            userImage: currentUserData["image"],
                            width: 45,
                            height: 45,
                            onTap: () {
                              Navigator.pushNamed(
                                  context, "vendor_profile_one");
                            },
                          ),
                          title: Text(
                            "Software developer",
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "10k ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              TextSpan(
                                  text: "/ month",
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
                                "6 days ago",
                                style: TextStyle(
                                    color: const Color.fromARGB(
                                        144, 255, 255, 255),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.location_pin),
                          horizontalTitleGap: 5,
                          title: Text(
                            "Kochi, Karnataka, Mangalore...",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          trailing: Text("+ 5 more"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                color: const Color.fromARGB(255, 115, 115, 115),
                                size: 18,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "21 applied",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 15.0, bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(73, 158, 158, 158),
                                    border: Border.all(
                                      color: Color.fromARGB(22, 255, 255, 255),
                                    ),
                                    borderRadius: BorderRadius.circular(50)),
                                child: Text(
                                  "Chip",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: 10, // Adjust the number of items as needed
            ),
          ),
        ],
      ),
    );
  }
}
