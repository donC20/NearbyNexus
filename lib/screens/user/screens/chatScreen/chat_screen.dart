// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:NearbyNexus/components/message_card.dart';
import 'package:NearbyNexus/components/my_date_util.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/models/message.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  const ChatScreen({super.key, required this.userId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Size mq;

  var logger = Logger();

  //for storing all messages
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  //showEmoji -- for storing value of showing or hiding emoji
  //isUploading -- for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(child: _appBar()),
      ),
      body: Builder(
        builder: (BuildContext context) {
          // Initialize mq within the Builder widget
          mq = MediaQuery.of(context).size;
          return Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: ApiFunctions.getAllMessages(widget.userId),
                  builder: (context, snapshot) {
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
                                return MessageCard(message: _list[index]);
                              });
                        } else {
                          return const Center(
                            child: Text('Say Hii! 👋',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20)),
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
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                        child: CircularProgressIndicator(strokeWidth: 2))),
              _chatInput(),
              //show emojis on keyboard emoji button click & vice versa
              if (_showEmoji)
                SizedBox(
                  height: mq.height * .35,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                      height: 256,
                      checkPlatformCompatibility: true,
                      emojiViewConfig: EmojiViewConfig(
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0)),
                    ),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

// app bar
  Widget _appBar() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: VendorCommonFn().streamUserData(
        uidParam:
            FirebaseFirestore.instance.collection('users').doc(widget.userId),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
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
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.black54),
                ),
                // User profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    imageUrl: img,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),

                // Add some space
                const SizedBox(width: 10),

                // User name & online status
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User name
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Add some space

                    // Online status
                    Text(
                      isOnline
                          ? 'Online'
                          : MyDateUtil.getLastActiveTime(
                              context: context, lastActive: last_seen),
                      style: TextStyle(
                          fontSize: 13,
                          color: isOnline
                              ? Colors.green
                              : Color.fromARGB(255, 51, 51, 51)),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 25)),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
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
                          color: Colors.blueAccent, size: 26)),

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
                          color: Colors.blueAccent, size: 26)),

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
                Map<String, dynamic>? recepientData = await VendorCommonFn()
                    .fetchParticularDocument('users', widget.userId);
                ApiFunctions.sendMessage(recepientData, widget.userId,
                    _textController.text, Type.text);
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white, size: 28),
          )
        ],
      ),
    );
  }

  // end of classs
}
