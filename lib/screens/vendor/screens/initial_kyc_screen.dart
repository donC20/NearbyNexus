// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class KYCInstructionScreen extends StatelessWidget {
  const KYCInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Instructions",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Please read the instructions below",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              InstructionCard(
                icon: Icons.credit_card,
                text: 'Provide valid PAN card',
              ),
              InstructionCard(
                  icon: Icons.camera_alt,
                  text: 'Allow access for camera usage'),
              InstructionCard(
                  icon: Icons.assignment_ind,
                  text: 'Provide only your rightful PAN card'),
              InstructionCard(
                  icon: Icons.camera_alt,
                  text: 'Capture the image of the PAN card'),
              InstructionCard(
                  icon: Icons.camera_alt,
                  text: 'Capture the front side of the PAN card'),
              InstructionCard(
                  icon: Icons.lightbulb,
                  text: 'Ensure good lighting conditions'),
              InstructionCard(
                  icon: Icons.camera_alt,
                  text: 'Take a clear picture of the card'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 50, left: 20, right: 20),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              // Add functionality for the button here
            },
            child: Text(
              'Continue',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w200),
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionCard extends StatelessWidget {
  final IconData icon;
  final String text;

  InstructionCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Color.fromARGB(99, 46, 46, 46),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
