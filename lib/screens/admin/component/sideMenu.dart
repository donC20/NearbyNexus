// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:NearbyNexus/screens/admin/config/size_config.dart';
import 'package:NearbyNexus/screens/admin/style/colors.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    return Drawer(
      elevation: 0,
      child: Container(
        width: double.infinity,
        height: SizeConfig.screenHeight,
        decoration: const BoxDecoration(color: AppColors.secondaryBg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
                alignment: Alignment.topCenter,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20),
                child: const SizedBox(
                  width: 70,
                  height: 70,
                  child: Image(
                    image: AssetImage("assets/images/nearbynexus(BL).png"),
                  ),
                ),
              ),
              IconButton(
                  iconSize: 20,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  icon: SvgPicture.asset(
                    'assets/images/vector/home.svg',
                    color: AppColors.iconGray,
                  ),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, "admin_screen");
                    print("buttonclicked");
                  }),
              IconButton(
                  iconSize: 20,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  icon: SvgPicture.asset(
                    'assets/images/vector/pie-chart.svg',
                    color: AppColors.iconGray,
                  ),
                  onPressed: () {
                    Navigator.popAndPushNamed(context, "list_users");
                    print("buttonclicked");
                  }),
              IconButton(
                  iconSize: 20,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  icon: SvgPicture.asset(
                    'assets/images/vector/clipboard.svg',
                    color: AppColors.iconGray,
                  ),
                  onPressed: () {}),
              IconButton(
                  iconSize: 20,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  icon: SvgPicture.asset(
                    'assets/images/vector/credit-card.svg',
                    color: AppColors.iconGray,
                  ),
                  onPressed: () {}),
              IconButton(
                  iconSize: 20,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  icon: SvgPicture.asset(
                    'assets/images/vector/trophy.svg',
                    color: AppColors.iconGray,
                  ),
                  onPressed: () {}),
              IconButton(
                iconSize: 30,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                icon: SvgPicture.asset(
                  'assets/images/vector/logout.svg',
                  color: AppColors.iconGray,
                ),
                onPressed: () async {
                  final SharedPreferences sharedpreferences =
                      await SharedPreferences.getInstance();
                  sharedpreferences.remove("userSessionData");
                  sharedpreferences.remove("uid");
                  Navigator.popAndPushNamed(context, "login_screen");
                  await _googleSignIn.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
