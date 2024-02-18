import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserAvatarLoader extends StatefulWidget {
  const UserAvatarLoader({Key? key}) : super(key: key);

  @override
  State<UserAvatarLoader> createState() => _UserAvatarLoaderState();
}

class _UserAvatarLoaderState extends State<UserAvatarLoader> {
  String imageLink = '';

  @override
  void initState() {
    initializeUserData();
    super.initState();
  }

  Future<void> initializeUserData() async {
    VendorCommonFn().streamUserData().listen((userData) {
      if (userData.isNotEmpty) {
        setState(() {
          setState(() {
            imageLink = userData['image'];
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "vendor_profile_one"),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: CachedNetworkImage(
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          progressIndicatorBuilder: (context, url, progress) => Center(
            child: CircularProgressIndicator(value: progress.progress),
          ),
          imageUrl: imageLink,
        ),
      ),
    );
  }
}
