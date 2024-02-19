// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:NearbyNexus/components/message_card.dart';
import 'package:NearbyNexus/components/my_date_util.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/models/message.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
  bool _showEmoji = false, _isUploading = false, _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 23, 24, 28),
        elevation: 1,
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
                        return SizedBox(); // Return an empty widget while waiting for data
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
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.back,
                      color: Color.fromARGB(212, 255, 255, 255)),
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
                        color: Color.fromARGB(221, 255, 255, 255),
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
                              : Color.fromRGBO(220, 220, 220, 1)),
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
