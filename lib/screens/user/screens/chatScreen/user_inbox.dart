// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_cast

import 'package:NearbyNexus/components/my_date_util.dart';
import 'package:NearbyNexus/components/user_avatar_loader.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/models/message.dart';
import 'package:NearbyNexus/screens/user/screens/chatScreen/chat_screen.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:NearbyNexus/screens/vendor/screens/subscription_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:logger/logger.dart';

class UserInbox extends StatefulWidget {
  const UserInbox({Key? key}) : super(key: key);

  @override
  State<UserInbox> createState() => _UserInboxState();
}

class _UserInboxState extends State<UserInbox> with WidgetsBindingObserver {
  var logger = Logger();
  final searchController = TextEditingController();
  List<dynamic> userChatData = [];
  Map<String, dynamic> currentUserData = {};
  bool isUserLoading = true;

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  Future<void> initializeUserData() async {
    VendorCommonFn()
        .streamDocumentsData(
      colectionId: 'users',
      uidParam: ApiFunctions.user!.uid,
    )
        .listen((data) {
      if (data.isNotEmpty && data['chats'] != null) {
        setState(() {
          userChatData = List.from(data['chats']);
          currentUserData = data;
          isUserLoading = false;
        });
      } else {
        // Handle case where 'chats' is null or not present
        setState(() {
          userChatData = [];
          currentUserData = data;
          isUserLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Inbox",
          style: TextStyle(fontSize: 16),
        ),
        titleSpacing: 125,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: UserAvatarLoader(),
          )
        ],
      ),
      body: isUserLoading
          ? Center(child: CircularProgressIndicator())
          : buildInboxBody(),
    );
  }

  Widget buildInboxBody() {
    if (currentUserData['userType'] == 'vendor' &&
        currentUserData['subscription']['type'] == 'free') {
      return buildSubscriptionUpgradeUI();
    } else if (userChatData.isEmpty) {
      return buildNoMessagesUI();
    } else {
      return buildChatList();
    }
  }

  Widget buildSubscriptionUpgradeUI() {
    // Your subscription upgrade UI here.
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/svg/crown-svgrepo-com.svg',
            height: 50,
            width: 50,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Upgrade to continue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'With current plan you cant\'t send direct messages please upgrade your plan to continue.',
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: 15,
          ),
          GFButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SubscriptionScreen()));
            },
            text: "Upgrade",
            textColor: Colors.black,
            color: Colors.amberAccent,
            size: GFSize.LARGE,
            shape: GFButtonShape.pills,
            fullWidthButton: true,
          )
        ],
      ),
    );
  }

  Widget buildNoMessagesUI() {
    return Center(
      child: Text(
        "No chats available.",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget buildChatList() {
    return ListView.builder(
      itemCount: userChatData.length,
      itemBuilder: (context, index) {
        // Your chat list item UI here.
        if (userChatData.isNotEmpty) {
          return Column(
            children: [
              _customChatTile(userChatData[index]),
            ],
          );
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
                SizedBox(height: 15),
                Text(
                  "No messages till now!",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontSize: 18),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Your other methods and widget builders like _customChatTile and UserCircleAvatar...

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
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
            ),
          );
        }

        final data = snapshot.data as Map<String, dynamic>?;
        if (data == null || !snapshot.hasData) {
          return Center(
            child: Text(
              'No data available',
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
                msgData?.map((e) => Message.fromJson(e.data())).toList();
            Message? message;
            if (list != null && list.isNotEmpty) {
              message = list[0];
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
              leading: UserCircleAvatar(
                imageUrl: data['image'] ?? '',
                online: data['online'] == true,
                size: 40,
              ),
              title: Text(
                data['name'] ?? '',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              subtitle: message?.type == Type.image
                  ? Row(
                      children: [
                        Icon(
                          CupertinoIcons.photo,
                          size: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Image",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 12),
                        ),
                      ],
                    )
                  : RichText(
                      maxLines: 1,
                      text: TextSpan(children: [
                        if (message?.fromId == ApiFunctions.user?.uid)
                          TextSpan(
                            text: 'You ~ ',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiary,
                                fontSize: 12),
                          ),
                        TextSpan(
                          text: UtilityFunctions()
                              .truncateText(message?.msg ?? "Hey, there!", 30),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 12),
                        ),
                      ]),
                    ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    message != null
                        ? MyDateUtil.getFormattedTime(
                            context: context, time: message.sent)
                        : '',
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSecondary),
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

class UserCircleAvatar extends StatelessWidget {
  final String imageUrl;
  final bool online;
  final double size;

  const UserCircleAvatar({
    required this.imageUrl,
    required this.online,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey,
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        ),
        online
            ? Positioned(
                bottom: 0,
                right: 1,
                child: Container(
                  padding: EdgeInsets.all(2),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              )
            : SizedBox(),
      ],
    );
  }
}
