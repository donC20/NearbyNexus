// ignore_for_file: prefer_const_constructors

import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class GeneralUserTiles extends StatefulWidget {
  final String userName;
  final String userImage;
  final String userLocation;
  final int jobsOffered;
  final bool paymentVerified;
  final bool emailVerified;
  final double ratings;
  final String docId;

  const GeneralUserTiles({
    Key? key,
    required this.userName,
    required this.userImage,
    required this.userLocation,
    required this.jobsOffered,
    required this.paymentVerified,
    required this.ratings,
    required this.emailVerified,
    required this.docId,
  }) : super(key: key);

  @override
  _GeneralUserTilesState createState() => _GeneralUserTilesState();
}

class _GeneralUserTilesState extends State<GeneralUserTiles> {
  var logger = Logger();
  List<dynamic> userFavourites = [];
  bool isFavorite = false;
  @override
  Widget build(BuildContext context) {
    String? uid = Provider.of<UserProvider>(context).uid;

    return SizedBox(
      width: 250,
      height: 110,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(18, 158, 158, 158)),
          borderRadius: BorderRadius.circular(10), // Add border radius
          color: Color.fromARGB(89, 42, 40, 40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          // Wrap the content with a Stack
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 19,
                  ),
                  SizedBox(width: 3),
                  Text(
                    widget.ratings.toStringAsFixed(1),
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
            Positioned(
              right: 5, // Adjust the right position for the favorite button
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(); // Loading indicator while fetching data
                  }

                  final userFavourites = List<String>.from(
                      snapshot.data!.get('userFavourites') ?? []);

                  return IconButton(
                    icon: Icon(
                      userFavourites.contains(widget.docId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      try {
                        if (userFavourites.contains(widget.docId)) {
                          userFavourites.remove(widget.docId);
                        } else {
                          userFavourites.add(widget.docId);
                        }

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({'userFavourites': userFavourites});

                        logger.d('Document updated successfully');
                      } catch (e) {
                        logger.d('Error updating document: $e');
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.userImage,
                      width: 80,
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
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  detailsRow(widget.jobsOffered, Icons.work, Colors.grey, ""),
                  SizedBox(
                    height: 5,
                  ),
                  detailsRow(widget.userLocation, Icons.location_on,
                      const Color.fromARGB(255, 158, 158, 158), ""),
                  SizedBox(
                    height: 5,
                  ),
                  detailsRow(
                      widget.emailVerified,
                      widget.emailVerified ? Icons.check_circle : Icons.close,
                      widget.emailVerified
                          ? Color.fromARGB(214, 27, 102, 232)
                          : Colors.red,
                      "Email"),
                  SizedBox(
                    height: 5,
                  ),
                  detailsRow(
                      widget.paymentVerified,
                      widget.paymentVerified ? Icons.check_circle : Icons.close,
                      widget.paymentVerified
                          ? Color.fromARGB(214, 27, 102, 232)
                          : Colors.red,
                      "Payment"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget detailsRow(value, IconData icon, Color icColor, addon) {
  return Row(
    children: [
      Icon(
        icon,
        color: icColor,
        size: 20,
      ),
      SizedBox(width: 10),
      value.runtimeType == bool
          ? value
              ? Text(
                  "$addon verified",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                )
              : Text(
                  "$addon unverified",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                )
          : Text(
              value.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
    ],
  );
}
