import 'dart:convert';

import 'package:NearbyNexus/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiFunctions {
  List<Map<String, dynamic>> resultList = [];
  var logger = Logger();
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;

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

// useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

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

  static Future<void> sendMessage(sendToUser, String msg, Type type) async {
    try {
      // Message sending time (also used as id)
      final time = DateTime.now().millisecondsSinceEpoch.toString();

      // Message to send
      final Message message = Message(
        toId: sendToUser,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time,
      );

      final ref = firestore
          .collection('chats/${getConversationID(sendToUser)}/messages/');
      await ref.doc(time).set(message.toJson());
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
