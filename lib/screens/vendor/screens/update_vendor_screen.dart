// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'package:NearbyNexus/screens/vendor/components/bottom_sheet_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpdateVendorScreen extends StatefulWidget {
  const UpdateVendorScreen({super.key});

  @override
  State<UpdateVendorScreen> createState() => _UpdateVendorScreenState();
}

class _UpdateVendorScreenState extends State<UpdateVendorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _aboutController = TextEditingController();
  int maxLetters = 300;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ShaderMask(
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
              SizedBox(
                height: 15,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "About\n",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text:
                        "Feel free to share details about your years of experience, your industry background. You can also discuss your accomplishments or past work experiences.",
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
              SizedBox(
                child: TextFormField(
                  controller: _aboutController,
                  maxLength: maxLetters,
                  maxLines: null,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tell us about you',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                    counterText: "${_aboutController.text.length}/$maxLetters",
                    counterStyle: TextStyle(
                      color: Colors.white,
                    ), // Display remaining character count
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
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // _formKey.currentState!.validate();
                  },
                  // validator: (value) {
                  //   if (value!.isEmpty) {
                  //     return "You left this field empty!";
                  //   }
                  //   return null;
                  // },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "What you do?\n",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text:
                        "Choose the services that are you really good at. This will help others to find you easily",
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
              InkWell(
                onTap: () {
                  _openBottomSheet(context);
                },
                child: ListTile(
                  shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                  title: Text(
                    "Manage services",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {},
                child: ListTile(
                  shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                  title: Text(
                    "Add services",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
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
    builder: (BuildContext context) {
      return BottomSheetVendorServices();
    },
  );
}
