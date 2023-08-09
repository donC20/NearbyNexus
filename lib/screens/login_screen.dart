// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formField = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  // snack bar
  void showSnackbar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

// !Normal login

  Future<void> signInWithEmailAndPasswordAndCheckEmailVerification() async {
    try {
      UserCredential loginEpCredentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passController.text);

      User user = loginEpCredentials.user!;
      if (user.emailVerified) {
        // User is verified, proceed with login
        // ?check user type
        String uid = loginEpCredentials.user?.uid ?? "";

        DocumentSnapshot snapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (snapshot.exists) {
          // Check if the document exists
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

          if (data != null && data.containsKey('userType')) {
            String userType = data['userType'];
            // ?share preferences instance creation
            final SharedPreferences sharedpreferences =
                await SharedPreferences.getInstance();
            Map<String, dynamic> userSessionData = {
              'uid': uid,
              'userType': userType,
            };
            sharedpreferences.setString(
                "userSessionData", json.encode(userSessionData));
            // ?End of SharedPreferences
            if (userType == "admin") {
              Navigator.popAndPushNamed(context, "admin_screen");
            } else if (userType == "vendor") {
              Navigator.popAndPushNamed(context, "vendor_home");
            } else if (userType == "general_user") {
              Navigator.popAndPushNamed(context, "user_home");
            } else {
              showSnackbar(":) Sorry we are unable to proccess your request! ",
                  Colors.red);
            }
          } else {
            print('User Type not found in the document');
          }
        } else {
          print('Document does not exist');
        }
        showSnackbar("Login successful", Colors.green);
        emailController.clear();
        passController.clear();
      } else {
        // User is not verified, show appropriate message
        showSnackbar(
            "Email not verified. Please check your inbox for a verification email.",
            Colors.orange);
      }
    } catch (error) {
      // Login error
      String errorMessage;
      if (error.toString().contains(
          "The password is invalid or the user does not have a password.")) {
        errorMessage =
            "The password is invalid or the user does not have a password.";
      } else {
        errorMessage = "Error: ${error.toString()}";
      }
      showSnackbar(errorMessage, Colors.red);
    }
  }

// !Normal login ends

// !Login with google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) return;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: (await googleSignInAccount.authentication).accessToken,
        idToken: (await googleSignInAccount.authentication).idToken,
      );

      final email = googleSignInAccount.email;
      checkEmailExists(email, credential);
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  Future<void> checkEmailExists(String email, AuthCredential credential) async {
    try {
      List<String> signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (signInMethods.isEmpty) {
        showSnackbar("Sorry, this mail id is not associated with any account.",
            Colors.red);
      } else {
        UserCredential userCredentialGoogle =
            await FirebaseAuth.instance.signInWithCredential(credential);

        User user = userCredentialGoogle.user!;
        if (user.emailVerified) {
          // User is verified, proceed with login
          // ?check user type
          String uid = userCredentialGoogle.user?.uid ?? "";

          DocumentSnapshot snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (snapshot.exists) {
            // Check if the document exists
            Map<String, dynamic>? data =
                snapshot.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('userType')) {
              String userType = data['userType'];
              // ?share preferences instance creation
              final SharedPreferences sharedpreferences =
                  await SharedPreferences.getInstance();
              Map<String, dynamic> userSessionData = {
                'uid': uid,
                'userType': userType,
              };
              sharedpreferences.setString(
                  "userSessionData", json.encode(userSessionData));
              // ?End of SharedPreferences
              if (userType == "admin") {
                Navigator.popAndPushNamed(context, "admin_screen");
              } else if (userType == "vendor") {
                Navigator.popAndPushNamed(context, "vendor_home");
              } else if (userType == "general_user") {
                Navigator.popAndPushNamed(context, "user_home");
              } else {
                showSnackbar(
                    ":) Sorry we are unable to proccess your request! ",
                    Colors.red);
              }
            } else {
              print('User Type not found in the document');
            }
          } else {
            print('Document does not exist');
          }
          showSnackbar("Login successful", Colors.green);
          emailController.clear();
          passController.clear();
        } else {
          // User is not verified, show appropriate message
          showSnackbar(
              "Email not verified. Please check your inbox for a verification email.",
              Colors.orange);
        }

        showSnackbar("Login successful", Colors.green);
      }
    } catch (e) {
      print("Error checking email existence: $e");
    }
  }

// !| ------------------------

  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formField,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // const SizedBox(height: 80),
                Transform.translate(
                  offset: const Offset(
                      20, 40.0), // Adjust the vertical offset as needed
                  child: Text(
                    "Welcome\nback!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: GoogleFonts.aBeeZee().fontFamily,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/nearbynexus(BL).png', // Replace with your SVG logo path
                    height: 200,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Whats your email?',
                      hintText: "example@example.com",
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
                      bool emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value);
                      if (!emailRegex) {
                        return "Email address is not valid 😕";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: passController,
                    style: GoogleFonts.poppins(color: Colors.black),
                    obscureText: _isObscure, // Use the state variable here
                    decoration: InputDecoration(
                      labelText: 'What\'s your password?',
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
                      // Add the eye icon button to toggle the password visibility
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
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
                        // Navigator.pushNamed(context, "user_or_vendor");
                        if (_formField.currentState!.validate()) {
                          // user logion validation
                          signInWithEmailAndPasswordAndCheckEmailVerification();
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
                TextButton(
                  onPressed: () {
                    // Implement forgot password logic here
                    Map<String, String> dummyMail = {
                      "email": emailController.text
                    };
                    Navigator.pushNamed(context, "forgot_password_screen",
                        arguments: dummyMail);
                  },
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
                        await signInWithGoogle();
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
                            image: AssetImage("assets/icons/google.png"),
                          ),
                          SizedBox(width: 5),
                          Text("Login with Google",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0))),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "admin_screen");
                    },
                    child: const Text("Administrator")),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.popAndPushNamed(
                            context, "registration_screen");
                      },
                      child: Text(
                        'Sign Up',
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
