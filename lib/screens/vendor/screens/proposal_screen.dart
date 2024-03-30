// ignore_for_file: prefer_const_constructors, avoid_print, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ProposalScreen extends StatefulWidget {
  @override
  State<ProposalScreen> createState() => _ProposalScreenState();
}

class _ProposalScreenState extends State<ProposalScreen> {
  bool showMore = false;
  // logger
  var logger = Logger();
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Job Proposals',
        ),
      ),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: VendorCommonFn().streamDocumentsData(
          colectionId: 'job_posts',
          uidParam: argument["post_id"],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic>? jobData = snapshot.data;
            List<dynamic> applicantsDataDocs = [];
            if (jobData!["applications"] != null) {
              applicantsDataDocs = jobData["applications"];
            }
            if (applicantsDataDocs.isNotEmpty) {
              return ListView.separated(
                padding: EdgeInsets.all(8.0),
                itemCount: applicantsDataDocs.length,
                itemBuilder: (context, index) {
                  final currentApplicantId = applicantsDataDocs[index];
                  return StreamBuilder<Map<String, dynamic>>(
                    stream: VendorCommonFn().streamDocumentsData(
                      colectionId: 'applications',
                      uidParam: currentApplicantId,
                    ),
                    builder: (context, snapshots) {
                      if (snapshots.hasData) {
                        Map<String, dynamic> applicationDataFullVolume =
                            snapshots.data as Map<String, dynamic>;
                        logger.f(applicationDataFullVolume['applicant_id']);
                        return StreamBuilder<Map<String, dynamic>>(
                          stream: VendorCommonFn().streamUserData(
                            uidParam: FirebaseFirestore.instance
                                .collection('users')
                                .doc(applicationDataFullVolume['applicant_id']),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic>? userData = snapshot.data;
                              return _buildProposalCard(
                                  applicationDataFullVolume,
                                  userData,
                                  argument,
                                  currentApplicantId);
                            } else {
                              return Center(
                                child: Text(
                                  'User data not found',
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            'Application data not found',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                    },
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 5),
              );
            } else {
              return Center(
                child: Text(
                  'No proposals found!',
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildProposalCard(
      applicant, userData, argument, currentApplicationId) {
    List<dynamic> allRatings = [];

    if (userData != null && userData is Map<String, dynamic>) {
      allRatings = userData['allRatings'] ?? [];
    }
    return (userData != null && userData != "") &&
            (applicant != null && applicant != "")
        ? GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/proposal_view_screen',
                arguments: {
                  'proposal': applicant,
                  'userType': argument['userType'],
                  'application_id': currentApplicationId,
                }),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                border:
                    Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.24),
                    offset: Offset(-1, 3),
                    blurRadius: 12,
                    spreadRadius: 3,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.all(0),
                      horizontalTitleGap: 10,
                      leading: UserLoadingAvatar(
                        userImage: userData['image'],
                      ),
                      title: Row(
                        children: [
                          Text(
                            userData['name'],
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          userData['kyc']['verified']
                              ? Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: Colors.blue,
                                )
                              : SizedBox(),
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
                                userData['actualRating'].toString(),
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   width: 10,
                          // ),
                          // Row(
                          //   children: [
                          //     Icon(
                          //       CupertinoIcons.money_dollar_circle,
                          //       color: Color.fromARGB(255, 7, 160, 48),
                          //       size: 18.0,
                          //     ),
                          //     SizedBox(
                          //       width: 5,
                          //     ),
                          //     Text(
                          //       UtilityFunctions().shortScaleNumbers(20),
                          //       style: TextStyle(
                          //         fontSize: 12.0,
                          //       ),
                          //     ),
                          //   ],
                          // ),
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
                                UtilityFunctions().shortScaleNumbers(
                                    allRatings.length.toDouble()),
                                style: TextStyle(
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
                        color: Theme.of(context).colorScheme.tertiary,
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
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
