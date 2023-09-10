// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DaysMapper extends StatefulWidget {
  const DaysMapper({super.key});

  @override
  State<DaysMapper> createState() => _DaysMapperState();
}

class _DaysMapperState extends State<DaysMapper> {
  var logger = Logger();
  List<String> daysList = [];
  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 5.0,
      spacing: 5.0, // Adjust the spacing between containers
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var day in ['Mon', 'Tue', 'Wed', 'Thu'])
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  daysList.contains(day)
                      ? Column(
                          children: [
                            Container(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var day in ['Fri', 'Sat', 'Sun'])
              Row(
                children: [
                  daysList.contains(day)
                      ? Column(
                          children: [
                            Container(
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
                  SizedBox(
                    width: 30,
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
      ],
    );
  }
}
