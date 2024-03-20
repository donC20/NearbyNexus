// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/screens/vendor/screens/subscription_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubscriptionDetails extends StatefulWidget {
  const SubscriptionDetails({Key? key}) : super(key: key);

  @override
  _SubscriptionDetailsState createState() => _SubscriptionDetailsState();
}

class _SubscriptionDetailsState extends State<SubscriptionDetails> {
  bool isLoading = true;
  List<Map<String, dynamic>> infoOnFreeSub = [
    {
      'icon': Icons.check_circle,
      'text': 'Apply for 2 jobs / month',
    },
    {
      'icon': Icons.close,
      'text': 'Restriction in direct chat',
    },
    {
      'icon': Icons.check_circle,
      'text': 'One Service allowed',
    },
    // {
    //   'icon': Icons.close,
    //   'text': 'Contact info disabled',
    // },
  ];

  List<Map<String, dynamic>> infoOnPlatinumSub = [
    {
      'icon': Icons.check_circle,
      'text': 'Apply for 10 jobs / month',
    },
    {
      'icon': Icons.check_circle,
      'text': 'One time direct chat',
    },
    {
      'icon': Icons.check_circle,
      'text': 'Upto 5 services allowed',
    },
    // {
    //   'icon': Icons.close,
    //   'text': 'Contact info disabled',
    // },
  ];
  List<Map<String, dynamic>> infoOnGoldSub = [
    {
      'icon': Icons.check_circle,
      'text': 'Unlimited jobs requests.',
    },
    {
      'icon': Icons.check_circle,
      'text': 'Enabled direct chat',
    },
    {
      'icon': Icons.check_circle,
      'text': 'Upto 5 services',
    },
    // {
    //   'icon': Icons.check_circle_sharp,
    //   'text': 'Contact info enabled',
    // },
  ];

  Map<String, dynamic> fetchedData = {};
  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  Future<void> FetchUserData() async {
    String uid = ApiFunctions.user!.uid;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      // Assign admin data to the UI
      setState(() {
        fetchedData = snapshot.data() as Map<String, dynamic>;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription Details'),
        backgroundColor: Colors.indigo, // Change app bar color
      ),
      body: !isLoading
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SizedBox(height: 20),
                  // Text(
                  //   'Subscription Details',
                  //   style: TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.indigo,
                  //   ),
                  // ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: fetchedData['subscription']['type'] == 'free'
                        ? _buildOfferPalette(infoOnFreeSub,
                            Theme.of(context).colorScheme.onSecondary, 'Free')
                        : fetchedData['subscription']['type'] ==
                                'premium_platinum'
                            ? _buildOfferPalette(
                                infoOnPlatinumSub,
                                Theme.of(context).colorScheme.onSecondary,
                                'Platinum')
                            : _buildOfferPalette(
                                infoOnGoldSub,
                                Theme.of(context).colorScheme.onSecondary,
                                'Gold'),
                  ),

                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: EdgeInsets.all(15),
                    width: MediaQuery.sizeOf(context).width,
                    decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer),
                    child: Column(
                      children: [
                        fetchedData['subscription']['type'] == 'free'
                            ? Column(
                                children: [
                                  Text(
                                    'Plan summary',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.build_rounded,
                                      size: 18,
                                    ),
                                    trailing: Text(
                                        '${2 - fetchedData['jobs_applied'].length} / 2'),
                                    title: Text(
                                      'Jobs left',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.room_service_outlined,
                                      size: 18,
                                    ),
                                    trailing: Text(
                                        '${1 - fetchedData['services'].length} / 1'),
                                    title: Text(
                                      'Services left',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              )
                            : fetchedData['subscription']['type'] ==
                                    'premium_platinum'
                                ? Column(
                                    children: [
                                      Text(
                                        'Plan summary',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.build_rounded,
                                          size: 18,
                                        ),
                                        trailing: Text(
                                            '${10 - fetchedData['jobs_applied'].length} / 10'),
                                        title: Text(
                                          'Jobs left',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.room_service_outlined,
                                          size: 18,
                                        ),
                                        trailing: Text(
                                            '${5 - fetchedData['services'].length} / 5'),
                                        title: Text(
                                          'Services left',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Your plan expires in',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        FutureBuilder<int>(
                          future: _calculateDaysLeft(
                              fetchedData['subscription']['last_payment']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Show loading indicator while calculating days left
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(
                                '${snapshot.data} days',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  fetchedData['subscription']['type'] != 'premium_gold'
                      ? InkWell(
                          splashColor: const Color.fromARGB(143, 255, 255, 255),
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SubscriptionScreen()));
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            width: MediaQuery.sizeOf(context).width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _calculateDaysLeft(fetchedData['subscription']
                                              ['last_payment']) ==
                                          0
                                      ? "EXTEND PLAN"
                                      : 'UPGRADE',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),
            )
          : Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
    );
  }

  Future<int> _calculateDaysLeft(time) async {
    // Get current date
    DateTime currentDate = DateTime.now();

    // Get last payment date from fetched data
    Timestamp lastPaymentDate = time;
    DateTime lastPaymentDateTime = lastPaymentDate.toDate();

    // Calculate next payment date (30 days from last payment date)
    DateTime nextPaymentDateTime = lastPaymentDateTime.add(Duration(days: 30));

    // Calculate difference in days between next payment date and current date
    Duration difference = nextPaymentDateTime.difference(currentDate);
    int daysLeft = difference.inDays;

    // Ensure days left is a positive value
    daysLeft = daysLeft < 0 ? 0 : daysLeft;

    return daysLeft;
  }

  Widget _buildOfferPalette(
      List<Map<String, dynamic>> info, Color baseColor, String boxtype) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .onSecondaryContainer, // Change palette background color
        border: Border.all(color: Colors.grey[400]!), // Change border color
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${boxtype} Subscription Includes:',
            style: TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: info.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        info[index]['icon'],
                        color: baseColor,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          info[index]['text'],
                          style: TextStyle(color: baseColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
