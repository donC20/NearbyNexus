// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:NearbyNexus/screens/admin/screens/add_data.dart';
import 'package:NearbyNexus/screens/vendor/components/edit_name_location_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ContentBox extends StatefulWidget {
  final String? uid;
  final Function(bool) onImageUploading;
  final BuildContext parentContext;
  const ContentBox(
      {super.key,
      this.uid,
      required this.onImageUploading,
      required this.parentContext});

  @override
  State<ContentBox> createState() => _ContentBoxState();
}

class _ContentBoxState extends State<ContentBox> {
  File? profileImage;
  String? imageUrl;
  var logger = Logger();

  // shoe dialog
  void _showDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: EditNameLocation(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
        borderRadius: BorderRadius.circular(10), // Add border radius
        color: Theme.of(context).colorScheme.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.image,
              size: 22,
            ),
            title: Text(
              "Change photo",
              style: TextStyle(fontSize: 14),
            ),
            onTap: () async {
              final pickedFile =
                  await ImagePicker().pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                profileImage = File(pickedFile.path);
              }
              if (profileImage != null) {
                try {
                  widget.onImageUploading(true);
                  Navigator.pop(context);
                  Reference ref = FirebaseStorage.instance.ref().child(
                      'profile_images/vendor/dp-vendor-${widget.uid}.jpg');
                  UploadTask uploadTask = ref.putFile(profileImage!);
                  TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
                  String downloadUrl = await snapshot.ref.getDownloadURL();
                  imageUrl = downloadUrl;
                  logger.d('Image uploaded: $imageUrl');
                  if (imageUrl!.isNotEmpty) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .update({'image': imageUrl}).then((value) {
                      // insert success
                      widget.onImageUploading(false);
                      showSnackbar(
                          "Your profile photo updated!",
                          const Color.fromARGB(255, 9, 237, 25),
                          widget.parentContext);
                    }).catchError((error) {
                      widget.onImageUploading(false);
                      showSnackbar(
                          "): Sorry we cant't proccess the request right now. Try again after few minutes",
                          const Color.fromARGB(255, 175, 76, 76),
                          widget.parentContext);
                    });
                  }
                } catch (error) {
                  logger.d('Image upload error: $error');
                }
              }
            },
          ),
          Divider(
            color: Theme.of(context).colorScheme.surface,
          ),
          ListTile(
            leading: Icon(
              Icons.edit_outlined,
              size: 22,
            ),
            title: Text(
              "Change details",
              style: TextStyle(fontSize: 14),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDialog(context);
            },
          ),
        ],
      ),
    );
  }
}
