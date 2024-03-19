// ignore_for_file: library_private_types_in_public_api

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AvatarOfUser extends StatefulWidget {
  final String imageLink;
  final double width;
  final double height;
  final String userPlan;
  const AvatarOfUser(
      {super.key,
      required this.imageLink,
      this.userPlan = 'free',
      this.width = 35.0,
      this.height = 35.0});

  @override
  _AvatarOfUserState createState() => _AvatarOfUserState();
}

class _AvatarOfUserState extends State<AvatarOfUser> {
  @override
  Widget build(BuildContext context) {
    return widget.userPlan != 'free'
        ? Stack(
            children: [
              Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 1.5),
                    borderRadius: BorderRadius.circular(100)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) =>
                        Center(
                      child:
                          CircularProgressIndicator(value: progress.progress),
                    ),
                    imageUrl: widget.imageLink,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: -2.5,
                child: Transform.rotate(
                  angle: 45 *
                      (3.1415926535 /
                          180), // Rotate 45 degrees clockwise (convert degrees to radians)
                  child: SvgPicture.asset(
                    'assets/icons/svg/crown-svgrepo-com.svg',
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
            ],
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: CachedNetworkImage(
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
              progressIndicatorBuilder: (context, url, progress) => Center(
                child: CircularProgressIndicator(value: progress.progress),
              ),
              imageUrl: widget.imageLink,
            ),
          );
  }
}
