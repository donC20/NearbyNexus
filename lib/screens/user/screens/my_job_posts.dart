// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, use_key_in_widget_constructors

import 'package:NearbyNexus/misc/colors.dart';
import 'package:flutter/material.dart';

class MyJobPosts extends StatefulWidget {
  @override
  _MyJobPostsState createState() => _MyJobPostsState();
}

class _MyJobPostsState extends State<MyJobPosts> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: KColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: KColors.backgroundDark,
          iconTheme: IconThemeData(color: KColors.primary),
          title: Text(
            'Back',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          bottom: TabBar(
            dividerHeight: 0.3,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: Color.fromARGB(255, 21, 0, 255),
            indicatorWeight: 0.8,
            indicator: BoxDecoration(
                color: Color.fromARGB(25, 255, 255, 255),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            tabs: [
              Tab(
                // Replace with your icon for Active Posts
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_alarm,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'My posts',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Tab(
                // Replace with your icon for Active Posts
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'History',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active Posts Content
            Center(
              child: Text('Active Posts Content'),
            ),

            // Past Posts Content
            Center(
              child: Text('Past Posts Content'),
            ),
          ],
        ),
      ),
    );
  }
}
