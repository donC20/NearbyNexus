// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:NearbyNexus/config/sessions/user_session_init.dart';
import 'package:NearbyNexus/screens/vendor/components/bottom_sheet_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({super.key});

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  int maxLetters = 300;
  String uid = '';
  String aboutold = '';
  bool duplicateEmailId = false;
  var logger = Logger();
  // ////
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        uid = Provider.of<UserProvider>(context, listen: false).uid!;
      });
    });
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
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              headings("Update Email",
                  "You can update your email. But you need to verify its authenticity. "),
              TextFormField(
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
                  suffixIcon: duplicateEmailId
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
                      });
                      // if (initEmailStoreVal) {
                      //   if (value != email) {
                      //     setState(() {
                      //       isEmailVerified = false;
                      //     });
                      //   } else if (value == email) {
                      //     setState(() {
                      //       isEmailVerified = true;
                      //     });
                      //   }
                      // }
                    } else {
                      setState(() {
                        duplicateEmailId = true;
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
                    });
                    return "You left this field empty!";
                  }
                  bool emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value);
                  if (!emailRegex) {
                    setState(() {
                      duplicateEmailId = true;
                    });
                    return "Email address is not valid";
                  }
                  if (duplicateEmailId) {
                    return "This email id already exists!";
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: ElevatedButton(
                  onPressed: duplicateEmailId ? null : () {},
                  child: !duplicateEmailId ? Text("Verify") : Text("Update"),
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
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 30, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                // updateAbout(_aboutController.text);
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
                        BorderRadius.circular(20.0), // Round the corners
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
            )
          ],
        ),
      ),
    );
  }
}

// bottom bar
void _openBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    backgroundColor: Color.fromARGB(255, 32, 26, 47),
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return BottomSheetVendor(
        fieldName: "services",
      );
    },
  );
}

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
