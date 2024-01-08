// ignore_for_file: avoid_print, use_build_context_synchronously

// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _fieldKey = GlobalKey<FormState>();
  final GlobalKey<DropdownButton2State<String>> _dropdownKey = GlobalKey();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool showError = false;
  bool isLoading = false;
  bool isButtonDisabled = false;
  String? errorMessage = "Error";
  String userType = "general_user";
  Color borderColor = Colors.black26;
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _repassController = TextEditingController();
  Map<String, String>? selectedValue;
  String? selectedRadio;
  List<Map<String, String>> keyValuePairs = [
    {'key': 'Here for hire', 'value': 'general_user'},
    {'key': 'Here for work', 'value': 'vendor'},
  ];

  // snack bar
  void showSnackbar(String message, Color backgroundColor) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

// function for user Registration with email and password
  Future<void> registerUser(
      String email, String password, Map<String, String>? userType) async {
    try {
      final existingMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (existingMethods.isEmpty) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        String uid = userCredential.user?.uid ?? "";
        if (uid.isNotEmpty) {
          User? sendTo = userCredential.user;
          await sendVerificationEmail(sendTo!);
          showSnackbar("An verification mail has sent to your email address.",
              const Color.fromARGB(255, 244, 212, 54));
        }

        Map<String, dynamic> userData = {
          'uid': uid,
          'email': email,
          'userType': userType!['value'],
          'loginType': 'normal'
        };
        setState(() {
          isLoading = false;
        });
        userType['value'] == "general_user"
            ? Navigator.popAndPushNamed(context, "complete_registration_user",
                arguments: userData)
            : userType['value'] == "vendor"
                ? Navigator.popAndPushNamed(
                    context, "complete_registration_vendor",
                    arguments: userData)
                : print("Cant register or navigate");
        _emailController.clear();
        _passController.clear();
        _repassController.clear();
      } else {
        setState(() {
          isLoading = false;
        });
        showSnackbar("An account with this mail id already exists",
            const Color.fromARGB(255, 244, 54, 54));
      }
    } catch (e) {
      // Handle registration or data storage error
      setState(() {
        isLoading = false;
      });
      showSnackbar("$e", Colors.red);
    }
  }

//?Send user email verification
  Future<void> sendVerificationEmail(User user) async {
    await user.sendEmailVerification();
  }

  // register with google
  Future<void> signInWithGoogle() async {
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

        final existingMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(googleSignInAccount.email);
        if (existingMethods.isEmpty) {
          UserCredential? userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          if (userCredential != null) {
            User googleuser = userCredential.user!;
            Map<String, dynamic> userData = {
              'uid': googleuser.uid,
              'email': googleuser.email,
              'userType': selectedRadio,
              'name': googleuser.displayName,
              'loginType': 'google'
            };
            selectedRadio == "general_user"
                ? Navigator.popAndPushNamed(
                    context, "complete_registration_user", arguments: userData)
                : selectedRadio == "vendor"
                    ? Navigator.popAndPushNamed(
                        context, "complete_registration_vendor",
                        arguments: userData)
                    : print("Cant register or navigate");
          } else {
            print("Failed to sign in with Google");
          }
        } else {
          await _googleSignIn.signOut();
          showSnackbar("An account with this mail id already exists",
              const Color.fromARGB(255, 244, 54, 54));
        }
      }

      return null;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
                        fontFamily: GoogleFonts.poppins().fontFamily,
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
                        return "Email address is not valid";
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
                      bool passwordRegex = RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                          .hasMatch(value);
                      if (!passwordRegex) {
                        return "Invalid password. Password must contain at least 1 letter, 1 digit, and be at least 8 characters long.";
                      }
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
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<Map<String, String>>(
                          key: _dropdownKey,
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'What you are looking for?',
                                  style: TextStyle(
                                      color: Color.fromARGB(182, 0, 0, 0),
                                      fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          items: keyValuePairs
                              .map((Map<String, String> item) =>
                                  DropdownMenuItem<Map<String, String>>(
                                    value: item,
                                    child: Text(
                                      item['key']!,
                                      style: const TextStyle(
                                          color: Color.fromARGB(182, 0, 0, 0),
                                          fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          value: selectedValue,
                          buttonStyleData: ButtonStyleData(
                            height: 60,
                            padding: const EdgeInsets.only(left: 14, right: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: borderColor,
                              ),
                              color: Colors.white,
                            ),
                            elevation: 0,
                          ),
                          onChanged: (Map<String, String>? value) {
                            setState(
                              () {
                                selectedValue = value;
                              },
                            );
                          },
                          // ... other properties remain the same
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Visibility(
                          visible: showError,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // Check if drop-down value is empty using GlobalKey
                              if (selectedValue == null ||
                                  selectedValue!.isEmpty) {
                                // Show error message in TextFormField
                                setState(() {
                                  showError = true;
                                  borderColor = Colors.red;
                                  errorMessage = "You must select an option";
                                });
                              } else {
                                setState(() {
                                  showError = false;
                                  borderColor = Colors.black26;
                                });
                              }
                              if (_fieldKey.currentState!.validate() &&
                                  selectedValue!.isNotEmpty &&
                                  selectedValue != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                registerUser(_emailController.text,
                                    _passController.text, selectedValue);
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isLoading == true
                                    ? LoadingAnimationWidget.staggeredDotsWave(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        size: 50)
                                    : const Flexible(
                                        child: Text(
                                          "Continue",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_right),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SizedBox(
                    height: 60,
                    child: OutlinedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              title: const Text("What are you looking for?"),
                              content: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      RadioListTile(
                                        title: const Text('Here for hire'),
                                        value: 'general_user',
                                        groupValue: selectedRadio,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRadio = value;
                                          });
                                        },
                                      ),
                                      RadioListTile(
                                        title: const Text('Here for work'),
                                        value: 'vendor',
                                        groupValue: selectedRadio,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedRadio = value;
                                          });
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    signInWithGoogle();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Continue"),
                                ),
                              ],
                            );
                          },
                        );
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
