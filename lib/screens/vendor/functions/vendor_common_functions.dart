// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorCommonFn {
  String uid = '';

//Fetching user's image from firebase storage
  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var userLoginData = sharedPreferences.getString("userSessionData");
      var initData = json.decode(userLoginData ?? '');

      uid = initData['uid'];
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;

        return fetchedData;
      }
      return {}; // Return an empty map if no data is found
    } catch (e) {
      print("Error fetching user data: $e");
      return {}; // Return an empty map if an error occurs
    }
  }
}
