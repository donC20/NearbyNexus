// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class JobDetailPage extends StatefulWidget {
  const JobDetailPage({Key? key}) : super(key: key);

  @override
  _JobDetailPageState createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool isExpanded = false;
  Widget _header(BuildContext context, argument) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 26),
      child: Column(
        children: [
          Row(
            children: [
              UserLoadingAvatar(
                userImage: argument["posted_user"]["image"],
              ),
              SizedBox(
                width: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    argument["job_data"]["jobTitle"],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: KColors.title,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    UtilityFunctions().findTimeDifference(
                        argument["job_data"]["jobPostDate"]),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: KColors.subtitle,
                    ),
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerStatic(
                  "Salary",
                  UtilityFunctions()
                      .formatSalary(argument["job_data"]["budget"])),
              _headerStatic("Applicants", "45"),
              _headerStatic(
                  "Expiry",
                  UtilityFunctions().findTimeDifference(
                      argument["job_data"]["expiryDate"],
                      trailingText: "left")),
            ],
          ),
          // SizedBox(height: 40),
          // Row(
          //   children: [
          //     Expanded(
          //       child: Image.asset("assets/icons/document.png",
          //           height: 20, color: KColors.primary),
          //     ),
          //     Expanded(
          //       child: Image.asset("assets/icons/user.png",
          //           height: 20, color: KColors.icon),
          //     ),
          //   ],
          // ),
          // Divider(
          //   color: KColors.icon,
          //   height: 25,
          // )
        ],
      ),
    );
  }

  Widget _headerStatic(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: KColors.subtitle,
          ),
        ),
        SizedBox(height: 5),
        Text(
          sub,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: KColors.title,
          ),
        )
      ],
    );
  }

  Widget _jobDescription(BuildContext context, argument) {
    final PageController pageController = PageController(initialPage: 0);
    int currentPage = 0;
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight =
        screenHeight > 455 ? screenHeight - 455 : screenHeight;
    return Column(
      children: [
        SizedBox(
          height:
              50, // Set a fixed height for the CustomSlidingSegmentedControl
          child: CustomSlidingSegmentedControl<int>(
            padding: 35,
            initialValue: 1,
            children: {
              1: Row(
                children: [
                  Image.asset("assets/icons/document.png",
                      height: 20, color: KColors.primary),
                  SizedBox(
                    width: 10,
                  ),
                  Text("Description")
                ],
              ),
              2: Row(
                children: [
                  Image.asset("assets/icons/user.png",
                      height: 20, color: KColors.primary),
                  SizedBox(
                    width: 10,
                  ),
                  Text("More info")
                ],
              ),
            },
            decoration: BoxDecoration(
              color: CupertinoColors.lightBackgroundGray,
              borderRadius: BorderRadius.circular(50),
            ),
            thumbDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.3),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: Offset(
                    0.0,
                    2.0,
                  ),
                ),
              ],
            ),
            curve: Curves.easeInCubic,
            onValueChanged: (v) {
              setState(() {
                currentPage = v - 1; // Subtract 1 from v
                pageController.animateToPage(
                  currentPage,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            },
          ),
        ),
        Container(
          height: containerHeight,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: PageView(
            controller: pageController,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
            },
            children: [
              SingleChildScrollView(
                child: Html(
                  data: argument["job_data"]["jobDescription"],
                ),
              ),
              // Add your content for the "More info" tab here
              Container(
                padding: EdgeInsets.all(16),
                child: Text("Additional Information"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _jobDescription(BuildContext context, argument) {
  //   return Container(
  //       height: MediaQuery.sizeOf(context).height - 485,
  //       padding: EdgeInsets.symmetric(horizontal: 16),
  //       child: SingleChildScrollView(
  //         child: Html(
  //           data: argument["job_data"]["jobDescription"],
  //         ),
  //       ));
  // }

  Widget _apply(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      margin: EdgeInsets.only(top: 54),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(KColors.primary),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16))),
              onPressed: () {},
              child: Text(
                "I'm interested",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          SizedBox(
            height: 50,
            width: 60,
            child: OutlinedButton(
              onPressed: () {},
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(color: KColors.primary),
                ),
              ),
              child: Icon(
                Icons.bookmark_border,
                color: KColors.primary,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.background,
        iconTheme: IconThemeData(color: KColors.primary),
        elevation: 1,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              _header(context, argument),
              _jobDescription(context, argument),
            ],
          ),
          // _ourPeople(context),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _apply(context),
          )
        ],
      ),
    );
  }
}
