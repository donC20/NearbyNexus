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

// stream user fetchong
  Stream<Map<String, dynamic>> streamUserData(
      {DocumentReference? uidParam}) async* {
    try {
      String uid = uidParam?.path.isNotEmpty == true
          ? uidParam!.id
          : await getUserUIDFromSharedPreferences();

      Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

      await for (DocumentSnapshot<Map<String, dynamic>> snapshot in snapshots) {
        if (snapshot.exists) {
          yield snapshot.data() ?? {};
        } else {
          yield {}; // Return an empty map if no data is found
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      yield {}; // Return an empty map if an error occurs
    }
  }

  Future<String> getUserUIDFromSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    return initData['uid'] ?? '';
  }

// fetch documents using streamed data
// stream user fetchong
  Stream<Map<String, dynamic>> streamDocumentsData(
      {required String colectionId, required String uidParam}) async* {
    try {
      Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
          FirebaseFirestore.instance
              .collection(colectionId)
              .doc(uidParam)
              .snapshots();

      await for (DocumentSnapshot<Map<String, dynamic>> snapshot in snapshots) {
        if (snapshot.exists) {
          yield snapshot.data() ?? {};
        } else {
          yield {}; // Return an empty map if no data is found
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      yield {}; // Return an empty map if an error occurs
    }
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

  // Streamed Documents
  Stream<List<Map<String, dynamic>>> streamDocuments(String collectionId) {
    try {
      return FirebaseFirestore.instance
          .collection(collectionId)
          .snapshots()
          .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
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
      });
    } catch (e) {
      print("Error fetching job posts: $e");
      return Stream.value([]); // Return an empty stream if an error occurs
    }
  }

//Fetching particulaar documents data from firebase storage
  Future<Map<String, dynamic>?> fetchParticularDocument(
      String collectionId, String docId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection(collectionId)
          .doc(docId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> fetchedData = snapshot.data() ?? {};
        return fetchedData;
      }

      return null; // Return null if the document doesn't exist
    } catch (e) {
      print("Error fetching document: $e");
      return null; // Return null if an error occurs
    }
  }


// -----------------------------------------------------------------------------------
// End of class
}
