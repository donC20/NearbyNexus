// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:timeline_tile/timeline_tile.dart';

class JobLogTimeline extends StatefulWidget {
  const JobLogTimeline({super.key});

  @override
  State<JobLogTimeline> createState() => _JobLogTimelineState();
}

class _JobLogTimelineState extends State<JobLogTimeline> {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
  // DocumentReference<Map<String, dynamic>> uid =
  //     FirebaseFirestore.instance.collection('collectionName').doc('documentID');
  String uid = '';

  var log = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initUser();
  }

  void initUser() async {
    // Ensure that context is not null
    Map<String, dynamic> parsedUid =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      uid = parsedUid['docId'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> logData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    setState(() {
      uid = logData['docId'];
    });
    log.e(uid);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Job logs",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(left: 30.0, top: 30),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_actions')
              .doc(uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else if (snapshot.hasData && snapshot.data!.exists) {
              Map<String, dynamic> documentData =
                  snapshot.data!.data() as Map<String, dynamic>;
              List<dynamic> history = documentData['jobLogs'];
              // Use documentData to access the data in the document

              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final isLastItem = index == history.length - 1;

                  IconData iconData;
                  Color iconColor;
                  String labelText;
                  String labelTextforUser;

                  switch (history[index]) {
                    case "new_job":
                      iconData = Icons.work;
                      iconColor = Colors.blue;
                      labelText = "New job received";
                      labelTextforUser = "You have requested a service";
                      break;
                    case "negotiate":
                      iconData = Icons.money;
                      iconColor = Colors.orange;
                      labelText = "Negotiated the job";
                      labelTextforUser = "Provider have negotiated the amount";
                      break;
                    case "user negotiated":
                      iconData = Icons.attach_money;
                      iconColor = Colors.orange;
                      labelText = "User negotiated the price";
                      labelTextforUser = "You have negotiated the amount";

                      break;
                    case "rejected":
                      iconData = Icons.close;
                      iconColor = Colors.red;
                      labelText = "Declined the request";
                      labelTextforUser = "Provider declined the request";

                      break;
                    case "user rejected":
                      iconData = Icons.remove_circle;
                      iconColor = Colors.red;
                      labelText = "User removed the request";
                      labelTextforUser = "You have revoked the service";

                      break;
                    case "completed":
                      iconData = Icons.check_circle;
                      iconColor = Colors.green;
                      labelText = "Tagged the job as completed";
                      labelTextforUser =
                          "Provider tagged the job as completed.";

                      break;
                    case "finished":
                      iconData = Icons.check_circle;
                      iconColor = Colors.green;
                      labelText = "Job is complete";
                      labelTextforUser = "You have agreed that job is complete";

                      break;
                    case "unfinished":
                      iconData = Icons.highlight_off;
                      iconColor = Colors.red;
                      labelText = "Job is not complete";
                      labelTextforUser =
                          "You have tagged the job is not complete.";

                      break;
                    case "paid":
                      iconData = Icons.attach_money;
                      iconColor = Colors.blue;
                      labelText = "User has paid you";
                      labelTextforUser = "You have paid them.";

                      break;
                    case "accepted":
                      iconData = Icons.thumb_up;
                      iconColor = Colors.green;
                      labelText = "Agreed to the terms";
                      labelTextforUser =
                          "The provider has accepted your request.";

                      break;
                    case "user accepted":
                      iconData = Icons.thumb_up;
                      iconColor = Colors.green;
                      labelText = "User accepted your request";
                      labelTextforUser =
                          "You have accepted to the providers terms";

                      break;
                    default:
                      iconData = Icons.info;
                      iconColor = Colors.grey;
                      labelText = "Unknown";
                      labelTextforUser = "Unknown";
                  }

                  return TimelineTile(
                    axis: TimelineAxis.vertical,
                    indicatorStyle: IndicatorStyle(
                      color: isLastItem && history[index] == "paid"
                          ? Colors.blue
                          : iconColor,
                      height: 30,
                      width: 30,
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: iconData,
                      ),
                    ),
                    isFirst: index == 0 ? true : false,
                    isLast: isLastItem,
                    beforeLineStyle:
                        LineStyle(color: Colors.grey, thickness: 1),
                    afterLineStyle: LineStyle(color: Colors.grey, thickness: 1),
                    alignment: TimelineAlign.start,
                    endChild: Row(
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(top: 5, bottom: 30),
                          width: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(blurRadius: 1, color: Colors.grey),
                            ],
                            color: Colors.white,
                          ),
                          constraints: BoxConstraints(
                            minHeight: 50, // Minimum height
                            maxHeight: 200, // Maximum height
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                logData['from'] == 'vendor'
                                    ? labelText
                                    : labelTextforUser,
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 61, 61, 61),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                timeStampConverter(
                                    documentData['dateRequested']),
                                style: TextStyle(
                                  color: Color.fromARGB(142, 61, 61, 61),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text("Can't load data"),
              );
            }
          },
        ),
      )),
    );
  }
}
