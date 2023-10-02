// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalNotifications {
  var log = Logger();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      vendorStreamSubscription;

  void requestMonitor() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    String uid = '';
    var initData;
    if (userLoginData != null && userLoginData.isNotEmpty) {
      initData = json.decode(userLoginData);
      uid = initData['uid'] ??
          ''; // Add ?? '' to provide an empty string if 'uid' is null.
      if (initData['userType'] == "vendor") {
        vendorStreamSubscription = FirebaseFirestore.instance
            .collection('service_actions')
            .where('referencePath',
                isEqualTo:
                    FirebaseFirestore.instance.collection('users').doc(uid))
            .snapshots()
            .listen((querySnapshot) async {
          for (var document in querySnapshot.docs) {
            var status = document['status'];
            DocumentReference userRef = document['userReference'];
            DocumentSnapshot userDoc =
                await userRef.get(); // Use await to get the document

            if (userDoc.exists) {
              var userName = userDoc['name'];

              switch (status) {
                case "new":
                  _showNotification("$userName requested a new service!",
                      "Hello there,\n I need a service on ${document['service_name']}");
                case "user negotiated":
                  _showNotification("$userName updated the price. take a look.",
                      "The new price is \u{20B9}${document['wage']}");
                case "user canceled":
                  _showNotification("$userName has canceled the request",
                      "Sorry to hear that, $userName has canceled the request.");
                case "user accepted":
                  _showNotification("$userName has accepted the new price.",
                      "Congrats on your new job, Please follow the guide lines of the job.");
              }
            }
          }
        });
      } else if (initData['userType'] == "general_user") {
        vendorStreamSubscription = FirebaseFirestore.instance
            .collection('service_actions')
            .where('userReference',
                isEqualTo:
                    FirebaseFirestore.instance.collection('users').doc(uid))
            .snapshots()
            .listen((querySnapshot) async {
          for (var document in querySnapshot.docs) {
            var status = document['status'];
            DocumentReference userRef = document['referencePath'];
            DocumentSnapshot userDoc = await userRef.get();

            if (userDoc.exists) {
              var userName = userDoc['name'];

              switch (status) {
                case "accepted":
                  _showNotification("$userName has accepted your request!",
                      "$userName has accepted for your${document['service_name']}");
                case "negotiate":
                  _showNotification(
                      "$userName requested for the price change. Take a look.",
                      "The new price requested is \u{20B9}${document['wage']}");
                case "completed":
                  _showNotification("$userName has completed the job",
                      "We are happy to inform you that $userName has completed his work review.");
                case "rejected":
                  _showNotification("$userName has declined your request.",
                      "Sorry, $userName can't accept your request right now.");
              }
            }
          }
        });
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'job_notifications',
      'Job notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

// background
  // Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  //   final SharedPreferences sharedPreferences =
  //       await SharedPreferences.getInstance();
  //   var userLoginData = sharedPreferences.getString("userSessionData");
  //   var initData = json.decode(userLoginData ??'');
  //   String uid = initData['uid'];
  //   log.d("Handling a background message: ${message.messageId}");
  //   vendorStreamSubscription = FirebaseFirestore.instance
  //       .collection('service_actions')
  //       .where('referencePath',
  //           isEqualTo: FirebaseFirestore.instance.collection('users').doc(uid))
  //       .snapshots()
  //       .listen((querySnapshot) {
  //     for (var document in querySnapshot.docs) {
  //       var status = document['status'];
  //       if (status == "new") {
  //         _showNotification(
  //             "Hello there from background,", "You may have new requests");
  //       }
  //     }
  //   });
  // }
}
