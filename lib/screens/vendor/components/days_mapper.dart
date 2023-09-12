// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_full_hex_values_for_flutter_colors

import 'dart:convert';

import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaysMapper extends StatefulWidget {
  const DaysMapper({super.key});

  @override
  State<DaysMapper> createState() => _DaysMapperState();
}

class _DaysMapperState extends State<DaysMapper> {
  var logger = Logger();
  String? uid = '';
  List<dynamic> daysList = [];
  List<dynamic> realList = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 0), () {
    //   setState(() {
    //     uid = Provider.of<UserProvider>(context, listen: false).uid;
    //     fetchDays(uid);
    //   });
    // });
    initUser();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });
    fetchDays(uid);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> fetchDays(uid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> vendorData =
            snapshot.data() as Map<String, dynamic>;
        setState(() {
          daysList = vendorData['working_days'];
        });
      }
    });
    logger.d(daysList);
  }

  Future<void> updateWorkingDays(lists) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'working_days': lists});
    } catch (e) {
      logger.d('Error removing service: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 5.0,
      spacing: 5.0, // Adjust the spacing between containers
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var day in ['Mon', 'Tue', 'Wed', 'Thu'])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  daysList.contains(day)
                      ? Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50),

                                shape: BoxShape
                                    .circle, // You can adjust the shape as needed
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    if (daysList.contains(day)) {
                                      setState(() {
                                        daysList.remove(day);
                                        updateWorkingDays(daysList);
                                      });
                                    }
                                    logger.d(daysList);
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              day,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFF44336),
                                shape: BoxShape
                                    .circle, // You can adjust the shape as needed
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    if (!daysList.contains(day)) {
                                      setState(() {
                                        daysList.add(day);
                                        updateWorkingDays(daysList);
                                      });
                                    }
                                    logger.d(daysList);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              day,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                  // if (day != 'Thu')
                  //   Container(
                  //     width: 40.0, // Adjust the width of the connecting line
                  //     height: 2.0, // Adjust the height of the connecting line
                  //     color: Colors.grey, // Color of the connecting line
                  //   ),
                ],
              ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var day in ['Fri', 'Sat', 'Sun'])
              Row(
                children: [
                  daysList.contains(day)
                      ? Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50),

                                shape: BoxShape
                                    .circle, // You can adjust the shape as needed
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    if (daysList.contains(day)) {
                                      setState(() {
                                        daysList.remove(day);
                                        updateWorkingDays(daysList);
                                      });
                                    }
                                    logger.d(daysList);
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              day,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFF44336),
                                shape: BoxShape
                                    .circle, // You can adjust the shape as needed
                              ),
                              child: IconButton(
                                  onPressed: () {
                                    if (!daysList.contains(day)) {
                                      setState(() {
                                        daysList.add(day);
                                        updateWorkingDays(daysList);
                                      });
                                    }
                                    logger.d(daysList);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  )),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              day,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                  // if (day != 'Thu')
                  //   Container(
                  //     width: 40.0, // Adjust the width of the connecting line
                  //     height: 2.0, // Adjust the height of the connecting line
                  //     color: Colors.grey, // Color of the connecting line
                  //   ),
                ],
              ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF2196F3),
                    shape:
                        BoxShape.circle, // You can adjust the shape as needed
                  ),
                  child: IconButton(
                      onPressed: () {
                        if (daysList.isNotEmpty) {
                          setState(() {
                            daysList.clear();
                            updateWorkingDays(daysList);
                          });
                        } else {
                          setState(() {
                            daysList.addAll(realList);
                            updateWorkingDays(daysList);
                          });
                        }
                        logger.d(daysList);
                      },
                      icon: Icon(
                        daysList.isNotEmpty ? Icons.close : Icons.add,
                        color: Colors.white,
                      )),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  daysList.isNotEmpty ? "Clear all" : "Add all",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
