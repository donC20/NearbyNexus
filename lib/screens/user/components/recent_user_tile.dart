// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RecentUserTile extends StatefulWidget {
  final BuildContext callerContext;
  final String vendorName;
  final String jobName;
  final String payment;
  final String vendorImage;
  final String location;
  const RecentUserTile(
      {super.key,
      required this.callerContext,
      required this.vendorName,
      required this.jobName,
      required this.payment,
      required this.location,
      required this.vendorImage});

  @override
  State<RecentUserTile> createState() => _RecentUserTileState();
}

class _RecentUserTileState extends State<RecentUserTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: MediaQuery.sizeOf(widget.callerContext).width - 30,
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
          borderRadius: BorderRadius.circular(10), // Add border radius
          color: Color.fromARGB(186, 42, 40, 40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.9),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          widget.vendorImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else if (loadingProgress.expectedTotalBytes !=
                                    null &&
                                loadingProgress.cumulativeBytesLoaded <
                                    loadingProgress.expectedTotalBytes!) {
                              return Center(
                                child: LoadingAnimationWidget.discreteCircle(
                                  color: Colors.grey,
                                  size: 15,
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 10), // Add some spacing
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vendorName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.work_history,
                                color: Colors.green,
                                size: 18,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                widget.jobName,
                                style: TextStyle(
                                  color: Colors
                                      .green, // Assuming online status is green
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee,
                                color: const Color.fromARGB(255, 180, 180, 180),
                                size: 18,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                widget.payment,
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 180, 180, 180),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.lock_clock,
                                color: const Color.fromARGB(255, 180, 180, 180),
                                size: 18,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "1 hour",
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 180, 180, 180),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: const Color.fromARGB(255, 180, 180, 180),
                                size: 18,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                widget.location,
                                style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 180, 180, 180),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10, // Adjust the top position as needed
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 19,
                      ),
                      SizedBox(height: 3),
                      Text(
                        "3.2",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
