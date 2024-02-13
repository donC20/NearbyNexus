// ignore_for_file: prefer_const_constructors

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/models/message.dart';
import 'package:NearbyNexus/screens/user/screens/chatScreen/chat_screen.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class UserInbox extends StatefulWidget {
  const UserInbox({super.key});

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> {
  var logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: KColors.backgroundDark,
        leading: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Card(
            color: const Color.fromARGB(255, 49, 49, 49),
            child: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          "Inbox",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: UserLoadingAvatar(
                userImage: "https://via.placeholder.com/350x150"),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: VendorCommonFn().streamDocuments('users'),
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.none:
                return Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                List<Map<String, dynamic>> listOfUsers =
                    snapshot.data as List<Map<String, dynamic>>;
                return ListView.separated(
                    itemBuilder: (context, index) {
                      return _customChatTile(listOfUsers[index]);
                    },
                    separatorBuilder: (context, index) => SizedBox(
                          height: 15,
                        ),
                    itemCount: listOfUsers.length);
            }
          }),
    );
  }

  Widget _customChatTile(chatUser) {
    //last message info (if null --> no message)
    Message? _message;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(
                'chats/${ApiFunctions.getConversationID('SXWjByatWxN7BI4sbOLuxeY1Cjq2_AMiTGam6EMOyB5Q8vpzn24SihQg2 ')}/messages/')
            .orderBy('sent', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          logger.e(data);
          final list =
              data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
          if (list.isNotEmpty) _message = list[0];
          return ListTile(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          userId: chatUser['documentId'],
                        ))),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: CircularProgressIndicator(
                    value: progress.progress,
                  ),
                ),
                imageUrl: chatUser['image'],
              ),
            ),
            title: Text(
              chatUser['name'],
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              _message != null ? _message!.msg : "Hey, there!",
              maxLines: 1,
            ),
            trailing: Text(
              "4:50 pm",
              style: TextStyle(color: Colors.white),
            ),
          );
        });
  }
}
