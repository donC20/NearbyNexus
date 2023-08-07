// ignore_for_file: avoid_print, use_build_context_synchronously

// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _fieldKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool showError = false;
  String? errorMessage = "Error";
  String userType = "general_user";
  Color borderColor = Colors.black26;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _repassController = TextEditingController();
  String? selectedValue;
// function for user Registration with email and password
  Future<void> registerUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user?.uid ?? "";

      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
      };

      Navigator.popAndPushNamed(context, "complete_registration",
          arguments: userData);
      // Registration and data storage successful
    } catch (e) {
      // Handle registration or data storage error
      print("the error that occured  ${e}");
    }
  }

  // register with google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        return await FirebaseAuth.instance.signInWithCredential(credential);
      }

      return null;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // check if the screen is opened from the user or vendor screen
    // String? argumentValue =
    //     ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _fieldKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const SizedBox(height: 80),
                Transform.translate(
                  offset: const Offset(
                      20, 40.0), // Adjust the vertical offset as needed
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.aBeeZee().fontFamily,
                      ),
                      children: const [
                        TextSpan(
                          text: "Hi there,\n",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "Join with us!",
                          style: TextStyle(color: Color(0xFFFD5301)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 70),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Whats your email?',
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      hintText: "example@example.com",
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }
                      bool emailRegex =
                          RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value);
                      if (!emailRegex) {
                        return "Email address is not valid 😕";
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _passController,
                    style: GoogleFonts.poppins(color: Colors.black),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Create a new password?',
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }
                      // bool passwordRegex = RegExp(
                      //         r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                      //     .hasMatch(value);
                      // if (!passwordRegex) {
                      //   return "Invalid password. Password must contain at least 1 letter, 1 digit, and be at least 8 characters long.";
                      // }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _repassController,
                    style: GoogleFonts.poppins(color: Colors.black),
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      labelText: 'Re-enter password?',
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      } else if (_passController.text != value) {
                        return "Passwords do not match!";
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_fieldKey.currentState!.validate()) {
                          registerUser(
                              _emailController.text, _passController.text);
                          _emailController.clear();
                          _passController.clear();
                          _repassController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        backgroundColor: const Color(0xFF25211E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Continue",
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
                ),

                const SizedBox(height: 10),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Or',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () async {
                        UserCredential? userCredential =
                            await signInWithGoogle();
                        if (userCredential != null) {
                          User googleuser = userCredential.user!;
                          Map<String, dynamic> userData = {
                            'uid': googleuser.uid,
                            'email': googleuser.email,
                          };

                          Navigator.popAndPushNamed(
                              context, "complete_registration",
                              arguments: userData);
                        } else {
                          print("failed to sign in with Google");
                        }
                        // Navigator.pushNamed(context, "");
                      },
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color.fromARGB(77, 0, 0, 0)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage("lib/icons/google.png"),
                          ),
                          SizedBox(width: 5),
                          Text("Signup with Google",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(context, "login_screen");
                      },
                      child: Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
