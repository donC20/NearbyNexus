import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainScreen();
  }

  _navigateToMainScreen() async {
    await Future.delayed(
      const Duration(seconds: 2),
    );
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, 'initial_page'); // Replace
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/nearbynexus(BL).png'),
      ),
    );
  }
}
