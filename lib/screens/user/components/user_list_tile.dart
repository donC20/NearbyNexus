// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ServiceOnLocationContainer extends StatelessWidget {
  final String name;
  final String serviceNames;
  final String rating = "5.0";
  final String salary;
  final String image;
  const ServiceOnLocationContainer(
      {super.key,
      required this.name,
      required this.serviceNames,
      required this.salary,
      required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 15,
        ),
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(81, 158, 158, 158)),
            color: Color(0xFF343a40),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              ),
              // ?image of vendor
              Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 129,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                    ),
                    child: Image.network(
                      image,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else if (loadingProgress.expectedTotalBytes != null &&
                            loadingProgress.cumulativeBytesLoaded <
                                loadingProgress.expectedTotalBytes!) {
                          return Center(
                            child: LoadingAnimationWidget.discreteCircle(
                                color: Colors.grey, size: 30),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ),
                ),
              ),

              // ?Name
              Positioned(
                left: 145,
                top: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                              "assets/images/vector/spanner.svg",
                              color: Color(0xFF838383)),
                        ),
                        SizedBox(width: 5),
                        Text(
                          serviceNames,
                          style: TextStyle(
                            color: Color.fromARGB(255, 178, 176, 176),
                            fontSize: 12.5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 18.5,
                        ),
                        SizedBox(width: 3),
                        Text(
                          rating,
                          style: TextStyle(
                            color: Color.fromARGB(255, 178, 176, 176),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: SvgPicture.asset(
                              "assets/images/vector/rupee-circle.svg",
                              color: Color(0xFF838383)),
                        ),
                        SizedBox(width: 5),
                        Text(
                          salary,
                          style: TextStyle(
                            color: Color.fromARGB(255, 178, 176, 176),
                            fontSize: 12.5,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: SizedBox(
                  width: 100,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle Hire button click
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF4000F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(9),
                        ),
                      ),
                    ),
                    child: Text(
                      'Hire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
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
}
