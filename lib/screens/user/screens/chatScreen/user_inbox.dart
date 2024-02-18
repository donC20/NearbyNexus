// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers, prefer_const_literals_to_create_immutables

import 'package:NearbyNexus/components/my_date_util.dart';
import 'package:NearbyNexus/components/user_avatar_loader.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/models/message.dart';
import 'package:NearbyNexus/screens/user/screens/chatScreen/chat_screen.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

class UserInbox extends StatefulWidget {
  const UserInbox({super.key});

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> with WidgetsBindingObserver {
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
        titleSpacing: 125,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: UserAvatarLoader(),
          )
        ],
      ),
      body: StreamBuilder<Map<String, dynamic>>(
          stream: VendorCommonFn().streamDocumentsData(
              colectionId: 'users', uidParam: ApiFunctions.user!.uid),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.hasData) {
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
                  List<dynamic> listOfUsers = snapshot.data?['chats'] ?? [];
                  if (listOfUsers.isNotEmpty) {
                    return ListView.separated(
                        itemBuilder: (context, index) {
                          logger.e(listOfUsers[index]);

                          return _customChatTile(listOfUsers[index]);
                        },
                        separatorBuilder: (context, index) => SizedBox(
                              height: 15,
                            ),
                        itemCount: listOfUsers.length);
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no-messages.png',
                            height: 250,
                            width: 250,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "No messages till now!.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    );
                  }
              }
            } else {
              return Center(
                child: Image.asset('assets/images/no-messages.png'),
              );
            }
          }),
    );
  }

  Widget _customChatTile(chatUser) {
    return StreamBuilder(
      stream: VendorCommonFn().streamDocumentsData(
        colectionId: 'users',
        uidParam: chatUser,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Text(
              'Please wait...',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final data = snapshot.data as Map<String, dynamic>?;

        if (data == null || !snapshot.hasData) {
          return Center(
            child: Text(
              'No data available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(
                  'chats/${ApiFunctions.getConversationID(chatUser)}/messages/')
              .orderBy('sent', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final msgData = snapshot.data?.docs
                as List<QueryDocumentSnapshot<Map<String, dynamic>>>?;
            final list =
                msgData?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            Message? _message;
            if (list.isNotEmpty) {
              _message = list[0];
            }

            return ListTile(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    userId: chatUser,
                  ),
                ),
              ),
              leading: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, progress) =>
                          Center(
                        child:
                            CircularProgressIndicator(value: progress.progress),
                      ),
                      imageUrl: data['image'] ?? '',
                    ),
                  ),
                  if (data['online'] == true)
                    Positioned(
                      bottom: 0,
                      right: 1,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(100)),
                        child: Badge(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                data['name'] ?? '',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: _message?.type == Type.image
                  ? Row(
                      children: [
                        Icon(
                          CupertinoIcons.photo,
                          size: 16,
                          color: Colors.white,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Image",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        )
                      ],
                    )
                  : RichText(
                      maxLines: 1,
                      text: TextSpan(children: [
                        if (_message?.fromId == ApiFunctions.user?.uid)
                          TextSpan(text: 'You ~ '),
                        TextSpan(
                            text: UtilityFunctions()
                                    .truncateText(_message!.msg, 30) ??
                                "Hey, there!"),
                      ]),
                    ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    _message != null
                        ? MyDateUtil.getFormattedTime(
                            context: context, time: _message.sent)
                        : '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(137, 255, 255, 255),
                    ),
                  ),
                  StreamBuilder<int>(
                    stream: ApiFunctions.getUnreadMessagesCount(chatUser),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        int pendingMessageCount = snapshot.data!;
                        return pendingMessageCount <= 0
                            ? SizedBox()
                            : Badge(
                                backgroundColor: KColors.primary,
                                smallSize: 20,
                                largeSize: 20,
                                label: Text(
                                  pendingMessageCount.toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
