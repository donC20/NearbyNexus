import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralUserHome extends StatefulWidget {
  const GeneralUserHome({super.key});

  @override
  State<GeneralUserHome> createState() => _GeneralUserHomeState();
}

class _GeneralUserHomeState extends State<GeneralUserHome> {
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
                },
                child: const Text("Logout"))
          ],
        ),
      ),
    );
  }
}
