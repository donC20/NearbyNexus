// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/style/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarActionItems extends StatefulWidget {
  const AppBarActionItems({super.key});

  @override
  State<AppBarActionItems> createState() => _AppBarActionItemsState();
}

class _AppBarActionItemsState extends State<AppBarActionItems> {
  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  String name = "Jhon Doe";
  String imageLink =
      'https://cdn.shopify.com/s/files/1/0045/5104/9304/t/27/assets/AC_ECOM_SITE_2020_REFRESH_1_INDEX_M2_THUMBS-V2-1.jpg?v=8913815134086573859';

  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    String uid = initData['uid'];
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        imageLink = fetchedData['image'];
        name = fetchedData['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(children: [
          CircleAvatar(
            radius: 17,
            backgroundImage: NetworkImage(imageLink),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            name,
            style: TextStyle(
                color: Colors.black45,
                fontFamily: GoogleFonts.poppins().fontFamily),
          ),
          const SizedBox(
            width: 5,
          ),
          const Icon(Icons.arrow_drop_down_outlined, color: AppColors.black),
          const SizedBox(
            width: 10,
          ),
        ]),
      ],
    );
  }
}
