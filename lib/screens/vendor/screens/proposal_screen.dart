// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class Proposal {
  final String userImage;
  final String userName;
  final String proposalDescription;
  final double userRating;
  final double totalAmountAcquired;
  final double proposalAmount;
  final double totalPayout;
  final double totalReviews;
  final bool isVerified;

  Proposal(
      {required this.userImage,
      required this.userName,
      required this.proposalDescription,
      required this.userRating,
      required this.totalAmountAcquired,
      required this.proposalAmount,
      required this.totalPayout,
      required this.totalReviews,
      required this.isVerified});
}

class ProposalScreen extends StatefulWidget {
  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  final List<Proposal> proposals = [
    Proposal(
      userImage: 'assets/images/raster/avatar-1.png',
      userName: 'John Doe',
      proposalDescription:
          'Experienced developer specializing in Flutter apps. Experienced developer specializing in Flutter apps.Experienced developer specializing in Flutter apps.Experienced developer specializing in Flutter apps.',
      userRating: 4.5,
      totalAmountAcquired: 5000.0,
      proposalAmount: 1000.0,
      totalReviews: 20,
      totalPayout: 200000,
      isVerified: true,
    ),
    Proposal(
      userImage: 'assets/images/raster/avatar-1.png',
      userName: 'Jane Smith',
      proposalDescription: 'Creative designer with a passion for UI/UX.',
      userRating: 4.8,
      totalAmountAcquired: 7500.0,
      proposalAmount: 1200.0,
      totalReviews: 20,
      totalPayout: 200000,
      isVerified: true,
    ),
    // Add more Proposal objects for additional proposals
  ];

  bool showMore = false;
  // logger
  var logger = Logger();
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KColors.backgroundDark,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Job Proposals',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Container(
        color: Colors.black, // Setting dark background color
        child: StreamBuilder<Map<String, dynamic>>(
            stream: VendorCommonFn().streamDocumentsData(
                colectionId: 'job_posts', uidParam: argument["post_id"]),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? jobData = snapshot.data;
                List<dynamic> applicantsData = jobData!["applicants"];
                return ListView.separated(
                  padding: EdgeInsets.all(8.0),
                  itemCount: applicantsData.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> currentApplicant =
                        applicantsData[index];
                    return _buildProposalCard(currentApplicant);
                  },
                  separatorBuilder: (context, index) => SizedBox(
                    height: 5,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }

  Widget _buildProposalCard(applicant) {
    return Card(
      color: Colors.grey[900], // Setting dark card background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(0),
              horizontalTitleGap: 8,
              leading: CircleAvatar(
                backgroundImage:
                    AssetImage("assets/images/raster/avatar-1.png"),
                radius: 30,
              ),
              title: Row(
                children: [
                  Text(
                    "Test",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(
                    Icons.verified,
                    size: 18,
                    color: Colors.blue,
                  )
                ],
              ),
              subtitle: Row(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18.0,
                      ),
                      Text(
                        "4.2",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.money_dollar_circle,
                        color: Color.fromARGB(255, 7, 160, 48),
                        size: 18.0,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        UtilityFunctions().shortScaleNumbers(20),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.chat_bubble_text_fill,
                        color: Colors.amber,
                        size: 18.0,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        UtilityFunctions().shortScaleNumbers(50),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: UtilityFunctions()
                        .shortScaleNumbers(
                            double.parse(applicant["bid_amount"]))
                        .toString()),
                TextSpan(text: " /hr")
              ])),
            ),
            SizedBox(height: 8.0),
            Text(
              applicant["proposal_description"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
              ),
              maxLines: !showMore ? null : 5,
              overflow: TextOverflow.ellipsis,
            ),
            if (applicant["proposal_description"].length >= 100)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showMore = !showMore;
                    });
                  },
                  child: Text(
                    showMore ? 'Less' : 'More',
                    style: TextStyle(
                      color: Colors
                          .blue, // You can customize the button text color
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
