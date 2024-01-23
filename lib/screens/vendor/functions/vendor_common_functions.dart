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

//Fetching job_post data from firebase storage
  Future<List<Map<String, dynamic>>> fetchJobPostsForBroadcast() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('job_posts').get();

      if (snapshot.size > 0) {
        List<Map<String, dynamic>> fetchedData = [];

        // Iterate through documents in the snapshot and add them to the list
        snapshot.docs
            .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          fetchedData.add(doc.data());
        });

        return fetchedData;
      }

      return []; // Return an empty list if no data is found
    } catch (e) {
      print("Error fetching job posts: $e");
      return []; // Return an empty list if an error occurs
    }
  }
}
