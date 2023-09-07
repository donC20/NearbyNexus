// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditNameLocation extends StatelessWidget {
  EditNameLocation({super.key});
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Form(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 226, 223, 223)),
                    decoration: InputDecoration(
                      labelText: 'Whats your name?',
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      hintText: "Eg : John Doe",
                      hintStyle:
                          const TextStyle(color: Color.fromARGB(255, 210, 210, 210), fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 255, 255, 255),
                          fontSize: 14),
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
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
                      bool nameRegex = RegExp(r'^[a-zA-Z]{3,}(?: [a-zA-Z]+)*$')
                          .hasMatch(value);
                      if (!nameRegex) {
                        return "Must contain atleast 3 characters & avoid any numbers.";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ))
          ],
        ));
  }
}
