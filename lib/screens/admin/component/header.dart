import 'package:NearbyNexus/screens/admin/config/responsive.dart';
import 'package:NearbyNexus/screens/admin/style/colors.dart';
import 'package:NearbyNexus/screens/admin/style/style.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  String pageTitle;
  String subText;
  Header({Key? key, required this.pageTitle, required this.subText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PrimaryText(text: pageTitle, size: 30, fontWeight: FontWeight.w800),
            PrimaryText(
              text: subText,
              size: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.secondary,
            )
          ]),
      // const Spacer(
      //   flex: 1,
      // ),
      // Expanded(
      //   flex: Responsive.isDesktop(context) ? 1 : 3,
      //   child: TextField(
      //     decoration: InputDecoration(
      //         filled: true,
      //         fillColor: AppColors.white,
      //         contentPadding: const EdgeInsets.only(left: 40.0, right: 5),
      //         enabledBorder: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(30),
      //           borderSide: const BorderSide(color: AppColors.white),
      //         ),
      //         focusedBorder: OutlineInputBorder(
      //           borderRadius: BorderRadius.circular(30),
      //           borderSide: const BorderSide(color: AppColors.white),
      //         ),
      //         prefixIcon: const Icon(Icons.search, color: AppColors.black),
      //         hintText: 'Search',
      //         hintStyle:
      //             const TextStyle(color: AppColors.secondary, fontSize: 14)),
      //   ),
      // ),
    ]);
  }
}
