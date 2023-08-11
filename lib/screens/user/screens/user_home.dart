// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralUserHome extends StatefulWidget {
  const GeneralUserHome({super.key});

  @override
  State<GeneralUserHome> createState() => _GeneralUserHomeState();
}

class _GeneralUserHomeState extends State<GeneralUserHome> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text("User home"),
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
