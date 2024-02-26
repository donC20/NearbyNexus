// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyFavourites extends StatefulWidget {
  const MyFavourites({super.key});

  @override
  State<MyFavourites> createState() => _MyFavouritesState();
}

class _MyFavouritesState extends State<MyFavourites> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String imageLink = "";
  String nameLoginned = "";
  bool isimageFetched = false;
  String uid = '';

  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  // ignore: non_constant_identifier_names
  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');

    setState(() {
      uid = initData['uid'];
    });
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        imageLink = fetchedData['image'];
        nameLoginned = fetchedData['name'];
        isimageFetched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text(
            "My favorites",
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection('users').doc(uid).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  decoration: BoxDecoration(color: Colors.black),
                  child: Center(
                    child: LoadingAnimationWidget.prograssiveDots(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        size: 80),
                  ),
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.exists) {
              var data = snapshot.data!.data() as Map<String, dynamic>;
              List<String> userFavourites =
                  List<String>.from(data['userFavourites']);

              if (userFavourites.isEmpty) {
                return Center(
                  child: Text(
                    "No favorites found",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              return ListView.separated(
                itemCount: userFavourites.length,
                itemBuilder: (BuildContext context, int index) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(userFavourites[index])
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (userSnapshot.hasData &&
                          userSnapshot.data!.exists) {
                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        String userName = userData['name'];
                        String userImage = userData['image'];
                        String userLocation = userData['geoLocation'];

                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: userTileModel(userName, userImage,
                              userLocation, context, userFavourites[index]),
                        );
                      } else {
                        return SizedBox(); // You can return a placeholder or handle the case when no data is found
                      }
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    height: 15,
                  );
                },
              );
            } else {
              return CircularProgressIndicator();
            }
          },
        ));
  }
}

Widget userTileModel(name, image, location, BuildContext context, docId) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? [] // Empty list for no shadow in dark theme
              : [
                  BoxShadow(
                    color: Color.fromARGB(38, 67, 65, 65).withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: ListTile(
          leading: UserLoadingAvatar(userImage: image),
          title: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            location,
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "vendor_profile_opposite",
                    arguments: docId);
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF2d4fff),
                shape: StadiumBorder(),
              ),
              child: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
