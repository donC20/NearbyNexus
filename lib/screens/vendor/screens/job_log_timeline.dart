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
    initUser();
  }

  void initUser() async {
    setState(() {
      uid = ModalRoute.of(context)!.settings.arguments as String;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {

    // });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      uid = ModalRoute.of(context)!.settings.arguments as String;
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
                  return TimelineTile(
                    axis: TimelineAxis.vertical,
                    indicatorStyle: IndicatorStyle(
                      color: Colors.green,
                      height: 30,
                      width: 30,
                      iconStyle: IconStyle(
                        color: Colors.white,
                        iconData: Icons.check,
                      ),
                    ),
                    isFirst: index == 0 ? true : false,
                    // isLast: index == -1 ? true : false,
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
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(top: 5, bottom: 30),
                          width: 280,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(blurRadius: 1, color: Colors.grey),
                            ],
                            color: Colors.white,
                          ),
                          // Optionally, you can add constraints like this:
                          constraints: BoxConstraints(
                            minHeight: 50, // Minimum height
                            maxHeight: 200, // Maximum height
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                history[index] == "new_job"
                                    ? "New job received"
                                    : history[index] == "negotiate"
                                        ? "You have negotiated the job"
                                        : history[index] == "user negotiated"
                                            ? "You user has negotiated the price"
                                            : history[index] == "rejected"
                                                ? "You declined the request"
                                                : history[index] ==
                                                        "user rejeted"
                                                    ? "User has removed the request"
                                                    : history[index] ==
                                                            "completed"
                                                        ? "You tagged the job as completed."
                                                        : history[index] ==
                                                                "finished"
                                                            ? "The user has accepted & job is complete"
                                                            : history[index] ==
                                                                    "unfinished"
                                                                ? "User tagged the job is not complete."
                                                                : history[index] ==
                                                                        "paid"
                                                                    ? "The user has paid you."
                                                                    : history[index] ==
                                                                            "accepted"
                                                                        ? "The user has accepted your request."
                                                                        : "",
                                style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 61, 61, 61),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                timeStampConverter(
                                    documentData['dateRequested']),
                                style: TextStyle(
                                    color: Color.fromARGB(142, 61, 61, 61),
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12),
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
