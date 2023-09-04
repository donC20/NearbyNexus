// ignore_for_file: prefer_const_constructors

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.off(NetworErrorScreen());
    } else {
      Navigator.of(Get.context!).popAndPushNamed("user_home");
    }
  }
}

class NetworErrorScreen extends StatelessWidget {
  const NetworErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Please connect to the internet",
          style: TextStyle(
              color: const Color.fromARGB(255, 12, 1, 1), fontSize: 16),
        ),
      ),
    );
  }
}
