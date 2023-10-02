// ignore_for_file: prefer_const_constructors

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserReviewContainer extends StatelessWidget {
  final String reviewerName;
  final String reviewText;
  final String image;
  final Timestamp timePosted;
  final double rating;

  const UserReviewContainer(
      {required this.reviewerName,
      required this.reviewText,
      required this.image,
      required this.rating,
      required this.timePosted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
        borderRadius: BorderRadius.circular(10),
        color: Color.fromARGB(186, 42, 40, 40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  UserLoadingAvatar(userImage: image),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        timeStampConverter(timePosted), // Example review date
                        style: TextStyle(
                          fontSize: 10.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          Divider(
            color: const Color.fromARGB(68, 158, 158, 158),
          ),
          SizedBox(height: 8),
          Text(
            reviewText,
            style: TextStyle(
              fontSize: 14.0,
              color: const Color.fromARGB(221, 150, 150, 150),
            ),
          ),
        ],
      ),
    );
  }
}

String timeStampConverter(Timestamp timeAndDate) {
  DateTime dateTime = timeAndDate.toDate();
  String formattedDateTime = DateFormat('MM-dd-yyyy hh:mm a').format(dateTime);
  return formattedDateTime;
}
