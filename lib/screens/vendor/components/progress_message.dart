// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sort_child_properties_last

import 'package:NearbyNexus/screens/vendor/screens/job_details.dart';
import 'package:flutter/material.dart';

class CongratulatoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromARGB(43, 158, 158, 158)),
                  borderRadius: BorderRadius.circular(10),
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
                  children: [
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        color: Color.fromARGB(255, 203, 233, 8), // White text
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'You have accepted job. You can always  find the job details and the customer information in the next page. Press continue to view more information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the customer contact page
                        // Replace 'CustomerContactPage' with the actual page route.
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MyJobs()),
                        );
                      },
                      child: Text(
                        'Continue',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            255, 33, 82, 243), // Button color
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
