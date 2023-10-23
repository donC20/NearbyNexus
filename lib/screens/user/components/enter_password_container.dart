// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, unnecessary_new

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:NearbyNexus/screens/user/components/custom_otp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AuthDoor extends StatefulWidget {
  final String emailText;
  final String newEmail;
  bool hidenOpenBtn = true;
  final TextEditingController emailController;
  final Function(bool success) onAuthorizationComplete;
  AuthDoor(
      {super.key,
      required this.emailText,
      required this.newEmail,
      required this.onAuthorizationComplete,
      required this.emailController,
      required this.hidenOpenBtn});

  @override
  State<AuthDoor> createState() => _AuthDoorState();
}

class _AuthDoorState extends State<AuthDoor> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var logger = Logger();
  // timer
  int _seconds = 120;
  late Timer _timer;
// timer ends
  bool isLocationFetchingList = false;
  bool isListEmpty = false;
  bool isEmailVerified = false;
  bool initEmailStoreVal = false;
  bool duplicateEmailId = true;
  bool isFetchingDetails = false;
  bool emailRegex = false;
  bool isEmailOtpSend = false;
  bool otpSendProgress = false;
  bool trueOtp = false;
  bool isOtpvalid = true;
  bool isAuthorizing = false;
  String otpAuthCode = "";
  String otpValue = "";
  String selectedName = "";
  String yrCurrentLocation = "loading..";
  String nameLoginned = "Jhon Doe";
  String email = "";
  String? uid = "";
  List<Map<String, dynamic>> resultList = [];
  String? passwordError;
  @override
  void initState() {
    super.initState();
    sendOTP(widget.newEmail);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    uid = Provider.of<UserProvider>(context, listen: false).uid;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

// dialog

// Api calls
// Search places api

  // Send verify email otp

  Future<Map<String, dynamic>> sendOTP(String recipient) async {
    setState(() {
      otpSendProgress = true;
    });
    const apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';

    final headers = {
      'X-RapidAPI-Key': apiKey,
      'X-RapidAPI-Host': 'email-authentication-system.p.rapidapi.com',
    };

    final params = {
      'recipient': recipient,
      'app': 'NearbyNexus',
    };

    try {
      final uri = Uri.https(
        'email-authentication-system.p.rapidapi.com',
        '/',
        params,
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          isEmailOtpSend = true;
          otpSendProgress = false;
          otpAuthCode = data['authenticationCode'];
        });
        startTimer();

        return data;
      } else {
        setState(() {
          isEmailOtpSend = false;
          otpSendProgress = false;
        });
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Function to verify OTP
  bool verifyOTP(String receivedOTP, String otpAuthCode) {
    final numericPart = md5.convert(utf8.encode(receivedOTP)).toString();
    return numericPart == otpAuthCode;
  }

// ----End of api calls ------------------------------------------------------

// imer function
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (_seconds <= 0) {
            // Timer has reached 0, so cancel it
            timer.cancel();
            // You can perform actions here when the timer completes
          } else {
            _seconds--;
          }
        });
      },
    );
  }

// timer-ends--------------------------------------------------------------
  // Future<void> FetchUserData(uid) async {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .snapshots()
  //       .listen((DocumentSnapshot snapshot) {
  //     if (snapshot.exists) {
  //       Map<String, dynamic> fetchedData =
  //           snapshot.data() as Map<String, dynamic>;
  //       // Assing admin data to the UI
  //       setState(() {
  //         _nameController.text = fetchedData['name'];
  //         _locationController.text = fetchedData['geoLocation'];
  //         _emailController.text = fetchedData['emailId']['id'];
  //         email = fetchedData['emailId']['id'];
  //         isFetchingDetails = false;
  //         isEmailVerified = fetchedData['emailId']['verified'];
  //         initEmailStoreVal = fetchedData['emailId']['verified'];
  //       });
  //       logger.d(isEmailVerified);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
// timer styles
    TextStyle timerStyle = TextStyle(
      fontSize: 14,
      color: _seconds <= 60 ? Colors.red : Color.fromARGB(149, 255, 255, 255),
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
            borderRadius: BorderRadius.circular(10), // Add border radius
            color: Color.fromARGB(186, 42, 40, 40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.9),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Update details",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Divider(
                color: Color.fromARGB(89, 255, 255, 255),
                height: 30,
              ),
              Form(
                  key: _formKey,
                  child: trueOtp
                      ? Column(
                          children: [
                            Text(
                              "Please verify yourself to continue",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 73, 101, 203),
                                  fontSize: 12),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: TextFormField(
                                controller: _passwordController,
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.poppins(
                                    color: const Color.fromARGB(
                                        255, 226, 223, 223)),
                                decoration: new InputDecoration(
                                  labelStyle: TextStyle(
                                      color:
                                          Color.fromARGB(232, 255, 255, 255)),
                                  labelText: 'Enter your Password?',
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color.fromARGB(
                                          137, 255, 255, 255),
                                    ),
                                  ),
                                  errorText: passwordError,
                                ),
                                onChanged: (value) {
                                  _formKey.currentState!.validate();
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "You left this field empty!";
                                  }

                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            ElevatedButton(
                              onPressed: isAuthorizing
                                  ? null
                                  : () async {
                                      setState(() {
                                        isAuthorizing = true;
                                      });
                                      try {
                                        UserCredential userCredential =
                                            await _auth
                                                .signInWithEmailAndPassword(
                                          email: widget.emailText,
                                          password: _passwordController.text,
                                        );

                                        User? user = userCredential.user;

                                        if (user != null) {
                                          // Update the email address (if needed)
                                          if (widget.newEmail !=
                                              widget.emailText) {
                                            await user
                                                .updateEmail(widget.newEmail);
                                          }

                                          Map<String, dynamic> emaildata = {
                                            "id": widget.newEmail,
                                            "verified": true
                                          };

                                          // Update email in Firestore
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .update({'emailId': emaildata});

                                          setState(() {
                                            isEmailVerified = true;
                                            isEmailOtpSend = false;
                                            trueOtp = false;
                                            isAuthorizing = false;
                                          });

                                          Navigator.pop(context);
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Success"),
                                                content: Text(
                                                    "Email updated successfully!"),
                                                actions: [
                                                  TextButton(
                                                    child: Text("OK"),
                                                    onPressed: () {
                                                      widget.emailController
                                                          .clear();
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        widget.hidenOpenBtn =
                                                            false;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          setState(() {
                                            isAuthorizing = false;
                                          });
                                          logger
                                              .d('User is not authenticated.');
                                        }
                                      } catch (e) {
                                        setState(() {
                                          isAuthorizing = false;
                                        });

                                        if (e is FirebaseAuthException &&
                                            e.code == 'wrong-password') {
                                          setState(() {
                                            passwordError = 'Invalid password';
                                          });
                                        } else {
                                          logger.d(
                                              'Failed to login or update email: $e');
                                          setState(() {
                                            isEmailVerified = false;
                                            isEmailOtpSend = true;
                                            trueOtp = false;
                                          });
                                        }
                                      }
                                    },
                              child: isAuthorizing
                                  ? LoadingAnimationWidget.discreteCircle(
                                      color: Colors.white, size: 20)
                                  : Text(
                                      "Authorize",
                                      style: TextStyle(color: Colors.white),
                                    ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              child: Column(
                                children: [
                                  CustomOtpField(
                                    length: 6,
                                    height: 50,
                                    textColor: Colors.white,
                                    borderColor:
                                        Color.fromARGB(72, 158, 158, 158),
                                    onChanged: (otp) {
                                      logger.d("Changed: $otp");
                                    },
                                    onCompleted: (otp) {
                                      logger.d("Completed: $otp");
                                      setState(() {
                                        otpValue = otp;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  isOtpvalid
                                      ? SizedBox()
                                      : Text(
                                          "Invalid OTP",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _seconds <= 0
                                        ? Text(
                                            "OTP expired. please retry!",
                                            style: TextStyle(color: Colors.red),
                                          )
                                        : otpSendProgress == false
                                            ? Text(
                                                'Time Remaining: ${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                                                style:
                                                    timerStyle, // Apply the style here
                                              )
                                            : SizedBox(),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.email),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        label: Text("Change Email"),
                                      ),
                                      _seconds <= 0 || otpSendProgress == true
                                          ? ElevatedButton(
                                              style: ButtonStyle(),
                                              onPressed: otpSendProgress
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _seconds = 120;
                                                        trueOtp = !trueOtp;
                                                      });
                                                      sendOTP(widget.newEmail);
                                                    },
                                              child: otpSendProgress
                                                  ? LoadingAnimationWidget
                                                      .waveDots(
                                                          color: Colors.white,
                                                          size: 25)
                                                  : Text("Retry"))
                                          : ElevatedButton(
                                              style: ButtonStyle(),
                                              onPressed: () async {
                                                setState(() {
                                                  trueOtp = verifyOTP(
                                                      otpValue, otpAuthCode);
                                                  isOtpvalid = trueOtp;
                                                });
                                              },
                                              child: Text("Verify"))
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ))
            ],
          )),
    );
  }
}
