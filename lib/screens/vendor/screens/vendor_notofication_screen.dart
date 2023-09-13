// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

class VendorNotificationScreen extends StatefulWidget {
  const VendorNotificationScreen({super.key});

  @override
  State<VendorNotificationScreen> createState() =>
      _VendorNotificationScreenState();
}

class _VendorNotificationScreenState extends State<VendorNotificationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  String uid = '';
  var logger = Logger();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to a topic (optional)
    _firebaseMessaging.subscribeToTopic('your_topic_name');

    // Initialize Firebase Cloud Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle incoming messages when the app is in the foreground
      print("onMessage: $message");

      // You can show a local notification here if needed
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle opening the app from a terminated state or background state
      print("onMessageOpenedApp: $message");

      // You can navigate to a specific screen or perform an action here
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    initUser();
  }

  // Add a method to send notifications
  // void sendNotification() async {
  //   // Use Firebase Cloud Messaging to send notifications
  //   await _firebaseMessaging.subscribeToTopic('your_topic_name');
  //   final response = await _firebaseMessaging.subscribeToTopic('your_topic_name', <String, dynamic>{
  //     'notification': <String, dynamic>{
  //       'title': 'New Document Added',
  //       'body': 'A new document has been added to the collection.',
  //     },
  //     'data': <String, dynamic>{
  //       // You can include additional data if needed
  //     },
  //   });

  //   print('Notification sent: $response');
  // }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Handle background messages here
    print("Handling background message: $message");
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });
  }

  Stream<List<Map<String, dynamic>>> getDocumentStream() {
    // Reference to the "service_logs" collection
    CollectionReference serviceLogsCollection =
        _firestore.collection('service_logs');

    // Stream to listen to changes in the "service_logs" collection
    return serviceLogsCollection.snapshots().asyncMap((querySnapshot) async {
      List<Map<String, dynamic>> documentDataList = [];

      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        // Reference to the "new_requests" subcollection within the current document
        CollectionReference newRequestsCollection =
            docSnapshot.reference.collection('new_requests');

        // Query to check if a document with the specific ID exists in "new_requests"
        QuerySnapshot subcollectionSnapshot = await newRequestsCollection
            .where(FieldPath.documentId, isEqualTo: uid)
            .get();

        if (subcollectionSnapshot.docs.isNotEmpty) {
          // Document with the specific ID exists in the current subcollection
          DocumentSnapshot targetDocument = subcollectionSnapshot.docs.first;
          Map<String, dynamic> documentData =
              targetDocument.data() as Map<String, dynamic>;
          documentDataList.add(documentData);
        }
      }

      return documentDataList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Notifications",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          // Update the type parameter here
          stream: getDocumentStream(),
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            // Update the type parameter here
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else if (snapshot.data != null) {
              // Document with the specific ID exists
              List<Map<String, dynamic>>? documentDataList =
                  snapshot.data; // Update the variable type here
              logger.e(documentDataList);
              // Build the ListView
              return ListView.separated(
                itemBuilder: (context, index) {
                  Map<String, dynamic> documentData = documentDataList[index];
                  return ListTile(
                    title: Text(
                      'Service Name: ${documentData['service_name']}',
                      style:
                          TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    subtitle: Text(
                      'Wage: ${documentData['wage'].toString()}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    trailing: Text(
                      'Location: ${documentData['location']}',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
                itemCount:
                    documentDataList!.length, // Update the item count here
              );
            } else {
              // Document does not exist
              return Center(
                  child: Text('Document with ID $uid does not exist.'));
            }
          },
        ),
      ),
    );
  }
}
