// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserLoadingAvatar extends StatelessWidget {
  final String userImage;
  double height;
  double width;
  UserLoadingAvatar(
      {super.key, required this.userImage, this.height = 50, this.width = 50});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor:
          Colors.transparent, // Set a transparent background for the avatar
      child: SizedBox(
        height: height,
        width: width,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          child: Image.network(
            userImage,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) {
                return child;
              } else if (loadingProgress.expectedTotalBytes != null &&
                  loadingProgress.cumulativeBytesLoaded <
                      loadingProgress.expectedTotalBytes!) {
                return Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.grey,
                    size: 15,
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
