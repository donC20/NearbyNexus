// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unnecessary_new

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ProposalViewScreen extends StatefulWidget {
  const ProposalViewScreen({Key? key}) : super(key: key);

  @override
  State<ProposalViewScreen> createState() => _ProposalViewScreenState();
}

class _ProposalViewScreenState extends State<ProposalViewScreen> {
  // logger
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    logger.e(argument['proposal']);
    return Scaffold(
      backgroundColor: KColors.backgroundDark,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(50)),
              child: Text(
                "Under Review",
                style: TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
        backgroundColor: KColors.backgroundDark,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Back',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(150.0),
            )),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: VendorCommonFn().streamUserData(
            uidParam: FirebaseFirestore.instance
                .collection('users')
                .doc(argument['proposal']['applicant_id']),
          ),
          builder: (context, snapshot) {
            logger.d(snapshot);
            if (snapshot.hasData) {
              Map<String, dynamic> userData = snapshot.data!;
              List<dynamic> allRatings = [];
              allRatings = userData['allRatings'] ?? [];

              return Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 80, top: 15, right: 15),
                      child: ListTile(
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
                                color: Colors.white,
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
                                  UtilityFunctions().shortScaleNumbers(
                                      allRatings.length.toDouble()),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Divider(
                        color: Color.fromARGB(41, 255, 255, 255),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.sizeOf(context).width - 50,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(54, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Proposed amount',
                            style: TextStyle(
                                color: Colors.amber,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.currency_rupee_sharp,
                                size: 15,
                                color: Colors.white,
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: UtilityFunctions()
                                            .shortScaleNumbers(double.parse(
                                                argument['proposal']
                                                    ["bid_amount"]))
                                            .toString()),
                                    TextSpan(text: " /hr")
                                  ],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Proposed on',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatTimestamp(
                                argument['proposal']["applicationPostedTime"]),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SingleChildScrollView(
                          child: Text(
                            argument['proposal']['proposal_description'],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text('Something went wrong!'),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: argument['userType'] == "normal_user"
          ? StreamBuilder<Map<String, dynamic>>(
              stream: VendorCommonFn().streamDocumentsData(
                  colectionId: 'applications',
                  uidParam: argument['application_id']),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic>? docData = snapshot.data;
                  return Container(
                    padding: const EdgeInsets.all(15.0),
                    color: Colors.grey[900],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        docData!["status"] == "pending"
                            ? GFButton(
                                onPressed: () async {
                                  updateStatus(argument, context,
                                      "Successfully accepted", "accept");
                                },
                                shape: GFButtonShape.pills,
                                size: GFSize.MEDIUM,
                                color: Colors.green,
                                icon: Icon(
                                  Icons.handshake,
                                  color: Colors.white,
                                ),
                                text: 'Accept offer',
                              )
                            : docData["status"] == "accepted"
                                ? GFButton(
                                    onPressed: () async {
                                      updateStatus(argument, context,
                                          "Successfully revoked", "revoked");
                                    },
                                    shape: GFButtonShape.pills,
                                    size: GFSize.MEDIUM,
                                    color: Colors.red,
                                    icon: Icon(
                                      Icons.handshake,
                                      color: Colors.white,
                                    ),
                                    text: 'Revoke offer',
                                  )
                                : docData["status"] == "revoked"
                                    ? GFButton(
                                        onPressed: () async {
                                          updateStatus(
                                              argument,
                                              context,
                                              "Successfully revoked",
                                              "accepted");
                                        },
                                        shape: GFButtonShape.pills,
                                        size: GFSize.MEDIUM,
                                        color: Colors.green,
                                        icon: Icon(
                                          Icons.handshake,
                                          color: Colors.white,
                                        ),
                                        text: 'Reconsider',
                                      )
                                    : SizedBox(),
                        // GFButton(
                        //   onPressed: () {
                        //     updateStatus(
                        //                       argument,
                        //                       context,
                        //                       "Successfully canceled",
                        //                       "canceled");
                        //   },
                        //   shape: GFButtonShape.pills,
                        //   size: GFSize.MEDIUM,
                        //   color: Color.fromARGB(255, 172, 33, 23),
                        //   icon: Icon(
                        //     Icons.close,
                        //     color: Colors.white,
                        //   ),
                        //   text: 'Not interested',
                        // ),
                        GFButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/chat_screen");
                          },
                          shape: GFButtonShape.pills,
                          size: GFSize.MEDIUM,
                          icon: Icon(
                            Icons.message_rounded,
                            color: Colors.white,
                          ),
                          text: 'Chat',
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }
              })
          : SizedBox(),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
    return DateFormat('dd MMM yyyy')
        .format(dateTime); // Format the DateTime object
  }
}

dialogContent(BuildContext context, message) {
  return Stack(
    children: <Widget>[
      Container(
        padding: EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 20,
          right: 20,
        ),
        margin: EdgeInsets.only(top: 20),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Text(
              'Success!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 24.0),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // To close the dialog
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

updateStatus(argument, BuildContext context, message, status) async {
  await FirebaseFirestore.instance
      .collection('applications')
      .doc(argument['application_id'])
      .update({"status": status}).then((value) => {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: dialogContent(context, message),
                );
              },
            )
          });
}
