// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:flutter/material.dart';

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
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: Image.asset("assets/icons/document.png",
                    height: 20, color: KColors.primary),
              ),
              Expanded(
                child: Image.asset("assets/icons/user.png",
                    height: 20, color: KColors.icon),
              ),
            ],
          ),
          Divider(
            color: KColors.icon,
            height: 25,
          )
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Job Description",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  argument["job_data"]["jobDescription"],
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: isExpanded ? null : 3, // Limit to 3 lines initially
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                SizedBox(height: 10),
                !isExpanded
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = true;
                          });
                        },
                        child: Text(
                          "Read more",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = false;
                          });
                        },
                        child: Text(
                          "Read less",
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _ourPeople(BuildContext context) {
  //   return Container(
  //     height: 92,
  //     padding: EdgeInsets.only(left: 16),
  //     margin: EdgeInsets.only(top: 30),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text("Our People",
  //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  //         SizedBox(height: 12),
  //         Expanded(
  //           child: ListView(
  //             scrollDirection: Axis.horizontal,
  //             children: [
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //               _people(context,
  //                   img:
  //                       "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnxlbnwwfHwwfHx8MA%3D%3D",
  //                   name: "J. Smith"),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _people(BuildContext context, {String? img, String? name}) {
  //   return Container(
  //     margin: EdgeInsets.only(right: 18),
  //     child: Column(
  //       children: [
  //         CircleAvatar(
  //           backgroundImage: AssetImage(img!),
  //         ),
  //         SizedBox(height: 8),
  //         Text(name!, style: TextStyle(fontSize: 10, color: KColors.subtitle)),
  //       ],
  //     ),
  //   );
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
