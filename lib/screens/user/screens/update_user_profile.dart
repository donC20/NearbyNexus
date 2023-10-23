// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:NearbyNexus/screens/user/components/enter_password_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({super.key});

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyName = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyPhone = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Timer? emailVerificationTimer;
// timer

  int maxLetters = 300;
  String uid = '';
  String aboutold = '';
  bool duplicateEmailId = false;
  bool isIdverified = false;
  String oldEmail = "";
  bool isFetchingDetails = false;
  bool isEmailVerified = false;
  bool initEmailStoreVal = false;
  bool isEmailOtpSend = true;
  bool otpSendProgress = false;
  String otpAuthCode = '';
  bool hidenOpenBtn = false;
  bool hidenOpenBtnName = false;
  bool hidenOpenBtnPhone = false;
  var logger = Logger();
  var user = FirebaseAuth.instance.currentUser;
  // ////
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        uid = Provider.of<UserProvider>(context, listen: false).uid;
        FetchUserData(uid);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  // Future<void> updateAbout(text) async {
  //   if (_aboutController.text.isNotEmpty) {
  //     try {
  //       await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(uid)
  //           .update({'about': text});
  //       _aboutController.clear();
  //     } catch (e) {
  //       logger.d('Error removing service: $e');
  //     }
  //   }
  // }

  Future<Map<String, dynamic>> sendOTP(String recipient) async {
    setState(() {
      otpSendProgress = true;
    });
    final apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';

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

  bool verifyOTP(String receivedOTP, String otpAuthCode) {
    final numericPart = md5.convert(utf8.encode(receivedOTP)).toString();
    return numericPart == otpAuthCode;
  }

// ----End of api calls ------------------------------------------------------

// imer function

// email verification checker

  Future<void> FetchUserData(uid) async {
    _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> fetchedData =
            snapshot.data() as Map<String, dynamic>;
        // Assing admin data to the UI
        setState(() {
          // _nameController.text = fetchedData['name'];
          // _locationController.text = fetchedData['geoLocation'];
          oldEmail = fetchedData['emailId']['id'];
          isFetchingDetails = false;
          isEmailVerified = fetchedData['emailId']['verified'];
          initEmailStoreVal = fetchedData['emailId']['verified'];
        });
        logger.d(isEmailVerified);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.green
                ], // Adjust gradient colors as needed
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              "Update profile",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            headings("Update Email",
                "You can update your email. But you need to verify its authenticity. "),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Whats your new email?',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 164, 162, 162), fontSize: 12),
                  // Display remaining character count
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: _emailController.text.isEmpty
                      ? SizedBox()
                      : duplicateEmailId
                          ? Icon(Icons.close, color: Colors.red)
                          : Icon(Icons.check, color: Colors.green),
                ),
                onChanged: (value) async {
                  try {
                    final existingMethods = await FirebaseAuth.instance
                        .fetchSignInMethodsForEmail(value);
                    if (existingMethods.isEmpty) {
                      setState(() {
                        duplicateEmailId = false;
                        hidenOpenBtn = true;
                      });
                    } else {
                      setState(() {
                        duplicateEmailId = true;
                        hidenOpenBtn = false;
                      });
                    }
                  } catch (e) {
                    logger.d(e);
                  }
                  _formKey.currentState!.validate();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    setState(() {
                      duplicateEmailId = true;
                      hidenOpenBtn = true;
                    });
                    return "You left this field empty!";
                  }
                  bool emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value);
                  if (!emailRegex) {
                    setState(() {
                      duplicateEmailId = true;
                      hidenOpenBtn = false;
                    });
                    return "Email address is not valid";
                  }
                  if (duplicateEmailId) {
                    return "This email id already exists!";
                  }
                  return null;
                },
              ),
            ),
            Visibility(
              visible: hidenOpenBtn,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ElevatedButton(
                  onPressed: duplicateEmailId
                      ? null
                      : () async {
                          logger.e(user);
                          _showDialog(context, oldEmail, _emailController.text,
                              _emailController, hidenOpenBtn);
                          setState(() {
                            hidenOpenBtn = false;
                            _emailController.clear();
                          });
                        },
                  child: Text("Update"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue), // Change the background color
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12), // Adjust padding
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5.0), // Round the corners
                      ),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                        fontSize: 18, // Adjust the font size
                        fontWeight: FontWeight.bold, // Apply bold font weight
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
            ),
            headings("Update name", "Here change your name. "),
            Form(
              key: _formKeyName,
              child: TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Whats your name?',
                  labelStyle: TextStyle(
                      color: Color.fromARGB(255, 164, 162, 162), fontSize: 12),
                  // Display remaining character count
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  // suffixIcon: _nameController.text.isEmpty
                  //     ? Icon(Icons.close, color: Colors.red)
                  //     : Icon(Icons.check, color: Colors.green),
                ),
                onChanged: (value) {
                  _formKeyName.currentState!.validate();
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    setState(() {
                      hidenOpenBtnName = false;
                    });
                    return "You left this field empty!";
                  }

                  // Define a regular expression for a valid name
                  RegExp nameRegExp = RegExp(r'^[A-Za-z ]{3,}$');

                  if (!nameRegExp.hasMatch(value)) {
                    setState(() {
                      hidenOpenBtnName = false;
                    });
                    return "Please enter a valid name";
                  }
                  setState(() {
                    hidenOpenBtnName = true;
                  });
                  return null;
                },
              ),
            ),
            Visibility(
              visible: hidenOpenBtnName,
              child: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ElevatedButton(
                  onPressed: duplicateEmailId
                      ? null
                      : () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Success"),
                                content: Text(
                                    "Confirm that you are updating the name."),
                                actions: [
                                  TextButton(
                                    child: Text("Yes i confirm"),
                                    onPressed: () {
                                      try {
                                        _firestore
                                            .collection('users')
                                            .doc(uid)
                                            .update(
                                                {'name': _nameController.text});
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
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } catch (e) {
                                        Navigator.pop(context);
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text("Success"),
                                              content:
                                                  Text("Can't update name"),
                                              actions: [
                                                TextButton(
                                                  child: Text("OK"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                  child: Text("Update"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue), // Change the background color
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12), // Adjust padding
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(5.0), // Round the corners
                      ),
                    ),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(
                        fontSize: 18, // Adjust the font size
                        fontWeight: FontWeight.bold, // Apply bold font weight
                        color: Colors.white, // Text color
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // headings("Update phone number", "Here change your phone number. "),
            // Form(
            //   key: _formKeyPhone,
            //   child: TextFormField(
            //     controller: _phoneController,
            //     keyboardType: TextInputType.emailAddress,
            //     style: GoogleFonts.poppins(
            //       color: Colors.white,
            //     ),
            //     decoration: InputDecoration(
            //       labelText: 'Whats your name?',
            //       labelStyle: TextStyle(
            //           color: Color.fromARGB(255, 164, 162, 162), fontSize: 12),
            //       // Display remaining character count
            //       enabledBorder: OutlineInputBorder(
            //         borderSide: BorderSide(
            //           color: Color.fromARGB(74, 158, 158, 158),
            //         ),
            //         borderRadius: BorderRadius.circular(8.0),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderSide: BorderSide(
            //           color: Color.fromARGB(74, 158, 158, 158),
            //         ),
            //         borderRadius: BorderRadius.circular(8.0),
            //       ),
            //       // suffixIcon: _nameController.text.isEmpty
            //       //     ? Icon(Icons.close, color: Colors.red)
            //       //     : Icon(Icons.check, color: Colors.green),
            //     ),
            //     onChanged: (value) {
            //       _formKeyPhone.currentState!.validate();
            //     },
            //     validator: (value) {
            //       if (value!.isEmpty) {
            //         setState(() {
            //           hidenOpenBtnPhone = false;
            //         });
            //         return "You left this field empty!";
            //       }

            //       // Define a regular expression for a valid name
            //       RegExp indianMobileNumber = RegExp(r'^[6789]\d{9}$');

            //       if (!indianMobileNumber.hasMatch(value)) {
            //         setState(() {
            //           hidenOpenBtnPhone = false;
            //         });
            //         return "Please enter a valid name";
            //       }
            //       setState(() {
            //         hidenOpenBtnPhone = true;
            //       });
            //       return null;
            //     },
            //   ),
            // ),
            // Visibility(
            //   visible: hidenOpenBtnPhone,
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 15),
            //     child: ElevatedButton(
            //       onPressed: duplicateEmailId
            //           ? null
            //           : () async {
            //               showDialog(
            //                 context: context,
            //                 builder: (BuildContext context) {
            //                   return AlertDialog(
            //                     title: Text("Success"),
            //                     content: Text(
            //                         "Confirm that you are updating the name."),
            //                     actions: [
            //                       TextButton(
            //                         child: Text("Yes i confirm"),
            //                         onPressed: () {
            //                           try {
            //                             _firestore
            //                                 .collection('users')
            //                                 .doc(uid)
            //                                 .update(
            //                                     {'name': _nameController.text});
            //                             Navigator.pop(context);
            //                             showDialog(
            //                               context: context,
            //                               builder: (BuildContext context) {
            //                                 return AlertDialog(
            //                                   title: Text("Success"),
            //                                   content: Text(
            //                                       "Email updated successfully!"),
            //                                   actions: [
            //                                     TextButton(
            //                                       child: Text("OK"),
            //                                       onPressed: () {
            //                                         Navigator.pop(context);
            //                                       },
            //                                     ),
            //                                   ],
            //                                 );
            //                               },
            //                             );
            //                           } catch (e) {
            //                             Navigator.pop(context);
            //                             showDialog(
            //                               context: context,
            //                               builder: (BuildContext context) {
            //                                 return AlertDialog(
            //                                   title: Text("Success"),
            //                                   content:
            //                                       Text("Can't update name"),
            //                                   actions: [
            //                                     TextButton(
            //                                       child: Text("OK"),
            //                                       onPressed: () {
            //                                         Navigator.pop(context);
            //                                       },
            //                                     ),
            //                                   ],
            //                                 );
            //                               },
            //                             );
            //                           }
            //                         },
            //                       ),
            //                     ],
            //                   );
            //                 },
            //               );
            //             },
            //       child: Text("Update"),
            //       style: ButtonStyle(
            //         backgroundColor: MaterialStateProperty.all<Color>(
            //             Colors.blue), // Change the background color
            //         padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            //           EdgeInsets.symmetric(
            //               horizontal: 24, vertical: 12), // Adjust padding
            //         ),
            //         shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //           RoundedRectangleBorder(
            //             borderRadius:
            //                 BorderRadius.circular(5.0), // Round the corners
            //           ),
            //         ),
            //         textStyle: MaterialStateProperty.all<TextStyle>(
            //           TextStyle(
            //             fontSize: 18, // Adjust the font size
            //             fontWeight: FontWeight.bold, // Apply bold font weight
            //             color: Colors.white, // Text color
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.only(right: 30, bottom: 30),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [
      //       ElevatedButton(
      //         onPressed: () {
      //           // updateAbout(_aboutController.text);
      //         },
      //         child: Text("Update"),
      //         style: ButtonStyle(
      //           backgroundColor: MaterialStateProperty.all<Color>(
      //               Colors.blue), // Change the background color
      //           padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
      //             EdgeInsets.symmetric(
      //                 horizontal: 24, vertical: 12), // Adjust padding
      //           ),
      //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      //             RoundedRectangleBorder(
      //               borderRadius:
      //                   BorderRadius.circular(20.0), // Round the corners
      //             ),
      //           ),
      //           textStyle: MaterialStateProperty.all<TextStyle>(
      //             TextStyle(
      //               fontSize: 18, // Adjust the font size
      //               fontWeight: FontWeight.bold, // Apply bold font weight
      //               color: Colors.white, // Text color
      //             ),
      //           ),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}

// bottom bar
// void _openBottomSheet(BuildContext context) {
//   showModalBottomSheet<void>(
//     backgroundColor: Color.fromARGB(255, 32, 26, 47),
//     context: context,
//     showDragHandle: true,
//     builder: (BuildContext context) {
//       return BottomSheetVendor(
//         fieldName: "services",
//       );
//     },
//   );
// }

Widget headings(String heading, String subheading) {
  return Column(
    children: [
      SizedBox(
        height: 15,
      ),
      RichText(
        textAlign: TextAlign.start,
        text: TextSpan(children: [
          TextSpan(
            text: "$heading\n",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          WidgetSpan(
              child: Divider(
            color: const Color.fromARGB(134, 158, 158, 158),
          )),
          TextSpan(
            text: subheading,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(151, 255, 255, 255),
            ),
          ),
        ]),
      ),
      SizedBox(
        height: 15,
      ),
    ],
  );
}

// Widget bottomNav(Function updateAbout) {
//   return ;
// }
void _showDialog(BuildContext context, email, newEmail, emailController,
    hidenOpenBtn) async {
  Completer<bool> completer = Completer<bool>(); // Create a Completer

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: AuthDoor(
          emailText: email,
          newEmail: newEmail,
          onAuthorizationComplete: (bool success) {
            if (success) {
              completer.complete(true); // Complete with success
            } else {
              completer.complete(false); // Complete with failure
            }
          },
          emailController: emailController,
          hidenOpenBtn: hidenOpenBtn,
        ),
      );
    },
  );

  await completer.future; // Wait for the Completer to complete
}
