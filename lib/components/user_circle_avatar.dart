import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserLoadingAvatar extends StatelessWidget {
  final String userImage;
  const UserLoadingAvatar({super.key, required this.userImage});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor:
          Colors.transparent, // Set a transparent background for the avatar
      child: SizedBox(
        width: 50,
        child: ClipOval(
          // Clip the image to an oval (circle) shape
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
