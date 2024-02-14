// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:NearbyNexus/functions/utiliity_functions.dart';

import 'package:NearbyNexus/models/message.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logger/logger.dart';

class ApiFunctions {
  List<Map<String, dynamic>> resultList = [];
  var logger = Logger();
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User? get user {
    if (auth.currentUser != null) {
      return auth.currentUser!;
    } else {
      // Handle the case where currentUser is null, such as by returning null or throwing an exception.
      // Example:
      // throw Exception('No user is currently signed in');
      return null;
    }
  }

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    var log = Logger();
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        UtilityFunctions().sharedPreferenceCreator("pushToken", t);
        print("my token $t");
      }
    });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log.f('Got a message whilst in the foreground!');
      log.f('Message data: ${message.data}');

      if (message.notification != null) {
        log.f('Message also contained a notification: ${message.notification}');
        UtilityFunctions.showNotification(
            'NearbyNexus', message.data['msg'], 'chats');
      }
    });
  }

// Search places api
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    const apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';

    final headers = {
      'X-RapidAPI-Host': 'geoapify-address-autocomplete.p.rapidapi.com',
      'X-RapidAPI-Key': apiKey,
    };
    final params = {'text': query};

    final uri = Uri.https(
      'geoapify-address-autocomplete.p.rapidapi.com',
      '/v1/geocode/autocomplete',
      params,
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data["features"] as List<dynamic>;
      resultList = features.map((feature) {
        final properties = feature["properties"] as Map<String, dynamic>;
        return properties;
      }).toList();

      return resultList;
    } else {
      // Handle errors here.
      logger.d('Error: ${response.statusCode}');
      return []; // Return an empty list in case of an error.
    }
  }

//
////////////////////////////////////////////////////////////////////////////////
/*------------------------Chat form apis--------------------------------------*/
////////////////////////////////////////////////////////////////////////////////
//

  // for sending push notification
  static Future<void> sendPushNotification(
      chatUserData, sendToUser, String msg) async {
    var logger = Logger();

    try {
      final body = {
        "to": chatUserData['pushToken'],
        "notification": {
          "title": chatUserData['name'], //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "userId": "User ID: $sendToUser",
          "msg": msg,
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAgTRiW7I:APA91bG-IvGm5BDzeHD0STBGHl_L75MTm5wnqv21AoHIStyKHKIWUL71B45ovT3bidjDJ4GuB9SgDDQjJ-gjoDpDXmiPuON7ADwMTK0KU3eVXqw0eKjOYcuBTl0IRlmOu78iXBVIXVIu'
          },
          body: jsonEncode(body));
      logger.e('Response status: ${res.statusCode}');
      logger.f('Response body: ${res.body}');
    } catch (e) {
      logger.i('\nsendPushNotificationE: $e');
    }
  }

// useful for getting conversation id
  static String getConversationID(String id) =>
      user!.uid.hashCode <= id.hashCode
          ? '${user?.uid}_$id'
          : '${id}_${user?.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(uid) {
    // print(getConversationID(user.uid));
    return firestore
        .collection('chats/${getConversationID(uid)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message

  static final Logger _logger = Logger();

  static Future<void> sendMessage(
      recepientData, sendToUser, String msg, Type type) async {
    try {
      // Message sending time (also used as id)
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      // Message to send
      final Message message = Message(
        toId: sendToUser,
        msg: msg,
        read: '',
        type: type,
        fromId: user!.uid,
        sent: time,
      );

      final ref = firestore
          .collection('chats/${getConversationID(sendToUser)}/messages/');
      await ref.doc(time).set(message.toJson()).then((value) =>
          sendPushNotification(
              recepientData, sendToUser, type == Type.text ? msg : 'image'));
    } catch (error, stackTrace) {
      // Log the error using a custom logger
      _logger.e('Error sending message: $error, $stackTrace');
    }
  }

//update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      lastMessagedUser) {
    return firestore
        .collection('chats/${getConversationID(lastMessagedUser)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(recepientData, chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'chatImages/${getConversationID(chatUser)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      // logger.f('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(recepientData, chatUser, imageUrl, Type.image);
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user?.uid).update({
      'online': isOnline,
      'last_seen': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken':
          await UtilityFunctions().fetchFromSharedPreference("pushToken"),
    }).then((value) => {});
    print(await UtilityFunctions().fetchFromSharedPreference("pushToken"));
  }

  // static initpushNotifications() async {
  //   final firebaseNotifications = FirebaseNotifications(); // Create an instance
  //   final pushToken = await firebaseNotifications.initNotifications();
  //   print('the tocken $pushToken');
  //   return pushToken;
  // }

//
////////////////////////////////////////////////////////////////////////////////
/*------------------------End of Chat forms-----------------------------------*/
////////////////////////////////////////////////////////////////////////////////
//
/*******************************************************************************
-*
-*
-*
-* 
*/
  /// end of the classs
}
