// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorCommonFn {
  var logger = Logger();

//Fetching user's data
  Future<Map<String, dynamic>> fetchUserData(
      {DocumentReference? uidParam}) async {
    try {
      String uid = uidParam?.path.isNotEmpty == true
          ? uidParam!.id
          : await getUserUIDFromSharedPreferences();

      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return snapshot.data() ?? {};
      }

      return {}; // Return an empty map if no data is found
    } catch (e) {
      print("Error fetching user data: $e");
      return {}; // Return an empty map if an error occurs
    }
  }

  Future<String> getUserUIDFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    return initData['uid'] ?? '';
  }

//Fetching documents data from firebase storage
  Future<List<Map<String, dynamic>>> fetchDouments(String collectionId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection(collectionId).get();

      if (snapshot.size > 0) {
        List<Map<String, dynamic>> fetchedData = [];

        // Iterate through documents in the snapshot and add both document ID and data to the list
        snapshot.docs
            .forEach((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          Map<String, dynamic> documentData = doc.data();
          documentData['documentId'] = doc.id;
          fetchedData.add(documentData);
        });

        return fetchedData;
      }

      return []; // Return an empty list if no data is found
    } catch (e) {
      print("Error fetching job posts: $e");
      return []; // Return an empty list if an error occurs
    }
  }

// -----------------------------------------------------------------------------------
// End of class
}
