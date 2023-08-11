import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text("Vendor home"),
            ElevatedButton(
                onPressed: () async {
                  final SharedPreferences sharedpreferences =
                      await SharedPreferences.getInstance();
                  sharedpreferences.remove("userSessionData");
                  sharedpreferences.remove("uid");
                  Navigator.popAndPushNamed(context, "login_screen");
                  await _googleSignIn.signOut();
                },
                child: const Text("Logout"))
          ],
        ),
      ),
    );
  }
}
