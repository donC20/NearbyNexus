// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'dart:io';

import 'package:NearbyNexus/components/message_card.dart';
import 'package:NearbyNexus/components/my_date_util.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/models/message.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:NearbyNexus/screens/vendor/screens/subscription_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Size mq;

  var logger = Logger();

  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false, _isUploading = false, _isSending = false;
  Future<void> deleteCollection(String path) async {
    var collectionRef = FirebaseFirestore.instance.collection(path);
    var batchSize = 10;

    await collectionRef.get().then((querySnapshot) async {
      if (querySnapshot.size == 0) return;

      var batch = FirebaseFirestore.instance.batch();
      querySnapshot.docs.forEach((document) {
        batch.delete(document.reference);
      });

      await batch.commit();

      // Recursively call deleteCollection until the collection is empty
      await deleteCollection(path);
    });
  }

  Future<bool> _onBackPressed() async {
    // back pressed button event

    return (await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/svg/crown-svgrepo-com.svg',
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Upgrade to continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Your messages will be cleared after viewing, Upgrade to keep the message history.',
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 15),
                    GFButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SubscriptionScreen(),
                          ),
                        );
                      },
                      text: "Upgrade",
                      textColor: Colors.black,
                      color: Colors.amberAccent,
                      size: GFSize.LARGE,
                      shape: GFButtonShape.pills,
                      fullWidthButton: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GFButton(
                      onPressed: () async {
                        await deleteCollection(
                                'chats/${ApiFunctions.getConversationID(widget.userId)}/messages')
                            .then((value) => Navigator.of(context).pop(true));
//                         FirebaseFirestore.instance
//                             .collection('chats')
//                             .doc()
//                             .delete();
//                         DocumentReference documentReference = FirebaseFirestore
//                             .instance
//                             .collection('chats')
//                             .doc(ApiFunctions.getConversationID(widget.userId));

// // Call the delete method to remove the document
//                         documentReference.delete().then((_) {
//                           Navigator.of(context).pop(true);

//                           print('Document successfully deleted');
//                         }).catchError((error) {
//                           print('Error deleting document: $error');
//                         });
                      },
                      text: "Clear",
                      textColor: Colors.white,
                      color: Colors.red,
                      size: GFSize.LARGE,
                      shape: GFButtonShape.pills,
                      fullWidthButton: true,
                    )
                  ],
                ),
              ],
            ),
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(child: _appBar()),
        ),
        body: Builder(
          builder: (BuildContext context) {
            mq = MediaQuery.of(context).size;
            return Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: ApiFunctions.getAllMessages(widget.userId),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return SizedBox();
                        case ConnectionState.none:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          logger.e(data);
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: 10),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                  isSent: _isSending,
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'Say Hii! 👋',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 20,
                      ),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _appBar() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: VendorCommonFn().streamUserData(
        uidParam:
            FirebaseFirestore.instance.collection('users').doc(widget.userId),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          Map<String, dynamic>? userData = snapshot.data;
          String userName = userData?['name'] ?? 'Unknown';
          String img =
              userData?['image'] ?? "https://via.placeholder.com/350x150";
          bool isOnline = userData?['online'] ?? false;
          final last_seen = userData?['last_seen'];

          return InkWell(
            onTap: () {},
            child: Row(
              children: [
                // IconButton(
                //   onPressed: () => Navigator.pop(context),
                //   icon: Icon(
                //     CupertinoIcons.back,
                //   ),
                // ),
                SizedBox(
                  width: 20,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    imageUrl: img,
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      isOnline
                          ? 'Online'
                          : MyDateUtil.getLastActiveTime(
                              context: context, lastActive: last_seen),
                      style: TextStyle(
                        fontSize: 13,
                        color: isOnline
                            ? Colors.green
                            : Color.fromRGBO(220, 220, 220, 1),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }
      },
    );
  }

// bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          //input field & buttons
          Expanded(
            child: Card(
              color: KColors.backgroundDark,
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: const Color.fromARGB(46, 255, 255, 255)),
                  borderRadius: BorderRadius.circular(100)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: Color.fromARGB(255, 255, 255, 255), size: 25)),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(
                        color: Color.fromARGB(255, 205, 205, 205),
                        fontSize: 14),
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 205, 205, 205),
                            fontSize: 14),
                        border: InputBorder.none),
                  )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Picking multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        // uploading & sending image one by one
                        for (var i in images) {
                          // log('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          Map<String, dynamic>? recepientData =
                              await VendorCommonFn().fetchParticularDocument(
                                  'users', widget.userId);
                          await ApiFunctions.sendChatImage(
                              recepientData, widget.userId, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image,
                          color: Color.fromARGB(255, 255, 255, 255), size: 26)),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        // Pick an image
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          // log('Image Path: ${image.path}');
                          setState(() => _isUploading = true);
                          // recipent data
                          Map<String, dynamic>? recepientData =
                              await VendorCommonFn().fetchParticularDocument(
                                  'users', widget.userId);
                          await ApiFunctions.sendChatImage(
                              recepientData, widget.userId, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Color.fromARGB(255, 255, 255, 255), size: 26)),

                  //adding some space
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),

          //send message button
          MaterialButton(
            onPressed: () async {
              if (_textController.text.isNotEmpty) {
                setState(() => _isSending = true);
                Map<String, dynamic>? recepientData = await VendorCommonFn()
                    .fetchParticularDocument('users', widget.userId);
                ApiFunctions.sendMessage(recepientData, widget.userId,
                    _textController.text, Type.text);
                _textController.text = '';
                setState(() => _isSending = false);
              }
            },
            minWidth: 0,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(),
            color: KColors.primary,
            child: SvgPicture.asset(
              'assets/images/vector/send_icon.svg',
              color: Colors.white,
              height: 25,
              width: 25,
            ),
          )
        ],
      ),
    );
  }

  // end of classs
}
