// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateUserScreen extends StatefulWidget {
  const RateUserScreen({super.key});

  @override
  State<RateUserScreen> createState() => _RateUserScreenState();
}

class _RateUserScreenState extends State<RateUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');

  bool isChecked = false;
  bool isPaymentClicked = false;
  String uid = '';
  String? formattedTimeAgo;
  var logger = Logger();
  Map<String, dynamic>? paymentIntent;
  final List<String> paymentLogs = [];
  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Text(
              "Take a moment to review the user",
              style: TextStyle(color: Colors.white, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
