// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Review {
  final String reviewerName;
  final String reviewText;
  final double rating;

  Review(this.reviewerName, this.reviewText, this.rating);
}

class UserReviewContainer extends StatelessWidget {
  final Review review;

  UserReviewContainer({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 6, 6, 6),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_circle,
                    color: Colors.blue,
                    size: 30,
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewerName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '10 Jul, 2023', // Example review date
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            review.reviewText,
            style: TextStyle(
              fontSize: 14.0,
              color: const Color.fromARGB(221, 150, 150, 150),
            ),
          ),
          SizedBox(height: 8),
          Divider(
            color: const Color.fromARGB(68, 158, 158, 158),
          ),
        ],
      ),
    );
  }
}
