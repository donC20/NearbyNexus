// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeneralUserHome extends StatefulWidget {
  const GeneralUserHome({super.key});

  @override
  State<GeneralUserHome> createState() => _GeneralUserHomeState();
}

class _GeneralUserHomeState extends State<GeneralUserHome> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final vendorSearchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              SizedBox(
                  width: 20,
                  child: SvgPicture.asset(
                      "assets/images/vector/location_pin.svg")),
              SizedBox(width: 8.0),
              Text(
                "Location",
                style: TextStyle(
                  color: Color(0xFF838383),
                  fontWeight: FontWeight.normal,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontSize: 16.0,
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF838383),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://expertphotography.b-cdn.net/wp-content/uploads/2020/08/profile-photos-4.jpg"),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width - 80,
                    height: 50,
                    child: TextFormField(
                      controller: vendorSearchController,
                      style: GoogleFonts.poppins(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'What\'s service you need?',
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 14),
                        labelStyle: const TextStyle(
                            color: Color(0xFF838383), fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(166, 158, 158, 158),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(166, 158, 158, 158),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: Icon(Icons.search),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "You left this field empty!";
                        }
                        return null;
                      },
                    ),
                  ),
                  InkWell(
                    child: SizedBox(
                      width: 50,
                      height: 40,
                      child: SvgPicture.asset(
                          "assets/images/vector/equalizer.svg",
                          color: Color(0xFF838383)),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Suggested services",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Expanded(
                  child: ListView(
                children: [
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                  ServiceOnLocationContainer(),
                  SizedBox(
                    height: 15,
                  ),
                ],
              )),
              // ElevatedButton(
              //     onPressed: () async {
              //       final SharedPreferences sharedpreferences =
              //           await SharedPreferences.getInstance();
              //       sharedpreferences.remove("userSessionData");
              //       sharedpreferences.remove("uid");
              //       Navigator.popAndPushNamed(context, "login_screen");
              //       await _googleSignIn.signOut();
              //     },
              //     child: const Text("Logout"))
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceOnLocationContainer extends StatelessWidget {
  const ServiceOnLocationContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(81, 158, 158, 158)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
          ),
          // ?image of vendor
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 129,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://images.unsplash.com/photo-1568602471122-7832951cc4c5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80"),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  bottomLeft: Radius.circular(9),
                ),
              ),
            ),
          ),

          // ?Name
          Positioned(
            left: 145,
            top: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Jhon Doe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: SvgPicture.asset(
                          "assets/images/vector/spanner.svg",
                          color: Color(0xFF838383)),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Interior Designer',
                      style: TextStyle(
                        color: Color(0xFF7D7D7D),
                        fontSize: 12.5,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow,
                      size: 18.5,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '5.0 (123 reviews)',
                      style: TextStyle(
                        color: Color(0xFF7D7D7D),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: SvgPicture.asset(
                          "assets/images/vector/rupee-circle.svg",
                          color: Color(0xFF838383)),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '500 - 600/hr',
                      style: TextStyle(
                        color: Color(0xFF7D7D7D),
                        fontSize: 12.5,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: SizedBox(
              width: 100,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // Handle Hire button click
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF4000F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(9),
                    ),
                  ),
                ),
                child: Text(
                  'Hire',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
