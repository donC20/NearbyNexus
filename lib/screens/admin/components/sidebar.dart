import 'dart:developer';

import 'package:NearbyNexus/screens/admin/references/shared_components/project_card.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../references/constans/app_constants.dart';
import '../references/shared_components/selection_button.dart';
import '../references/shared_components/upgrade_premium_card.dart';

// ignore: unused_element
class Sidebar extends StatelessWidget {
  const Sidebar({
    Key? key,
  }) : super(key: key);

  // final ProjectCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.all(20.0)),
                const Divider(thickness: 1),
                SideBarButtons(context, EvaIcons.grid, "Dashboard"),
                SideBarButtons(context, EvaIcons.activity, "Manage users"),
                SideBarButtons(context, EvaIcons.eye, "View Services"),
                const SizedBox(height: kSpacing * 2),
                const SizedBox(height: kSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget SideBarButtons(BuildContext context, IconData icon, String name) {
  return Container(
    padding: const EdgeInsets.only(left: 15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    ),
    width: MediaQuery.of(context)
        .size
        .width, // Change MediaQuery.sizeOf(context) to MediaQuery.of(context).size
    height: 50,
    child: InkWell(
      onTap: () {
        // Handle onTap event
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(
            width: 10,
          ),
          Text(name),
        ],
      ),
    ),
  );
}
