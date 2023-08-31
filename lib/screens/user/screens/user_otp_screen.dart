// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:NearbyNexus/screens/admin/screens/add_data.dart';
import 'package:NearbyNexus/screens/user/screens/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/custom_otp.dart';

class UserOtpScreen extends StatefulWidget {
  const UserOtpScreen({super.key});

  @override
  State<UserOtpScreen> createState() => _UserOtpScreenState();
}

class _UserOtpScreenState extends State<UserOtpScreen> {
  OtpFieldController otpController = OtpFieldController();
  final _formKey = GlobalKey<FormState>();
  String otpValue = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: CustomOtpField(
                length: 6,
                onChanged: (otp) {
                  print("Changed: $otp");
                },
                onCompleted: (otp) {
                  print("Completed: $otp");
                  setState(() {
                    otpValue = otp;
                  });
                },
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: UserProfile.verifyPhone,
                            smsCode: otpValue);
                    FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((userCredential) async {
                      // Verification successful
                      showSnackbar(
                          "Phone number verified!", Colors.green, context);
                      final SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      var userLoginData =
                          sharedPreferences.getString("userSessionData");
                      var initData = json.decode(userLoginData!);
                      String uid = initData['uid'];
                      final userDocRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid);

                      // Get the current document snapshot
                      final userDocSnapshot = await userDocRef.get();

                      if (userDocSnapshot.exists) {
                        // Get the current phone map
                        final phoneMap =
                            userDocSnapshot['phone'] as Map<String, dynamic>;

                        // Update the 'verified' field within the phone map
                        phoneMap['verified'] = true;

                        // Update the entire 'phone' map within the document
                        await userDocRef.update({'phone': phoneMap});

                        print('Phone verification status updated.');
                        Navigator.popAndPushNamed(context, "user_profile");
                      } else {
                        print('Document does not exist.');
                      }
                    }).catchError((error) {
                      // Verification failed
                      showSnackbar(
                          "Verification failed: $error", Colors.red, context);
                    });
                  } catch (e) {
                    print("wrong otp");
                    showSnackbar(e.toString(), Colors.red, context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: const Color(0xFF25211E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.numbers),
                          SizedBox(
                            width: 5,
                          ),
                          Flexible(
                            child: Text(
                              "Verify my number",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
