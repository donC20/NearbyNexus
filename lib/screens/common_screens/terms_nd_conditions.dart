// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '''\n1. Usage of the application implies acceptance of these terms.\n2. The application connects users with service providers based on location.\n3. Users are responsible for their interactions with service providers.\n4. The platform caters to individual providers and organizations.\n5. Contact information is kept confidential.\n6. Any misuse of the application will result in termination of account.\n7.Users are responsible for keeping their login credentials secure.\n8.The platform is not responsible for any disputes between users and service providers.\n9.Users should provide accurate and up-to-date information on their profiles.\n10.The application may use cookies for a better user experience.
              ''',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20.0),
            Text(
              'What we aim',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '''
              The project is a location-based service providing application that utilises the user's local location to connect them with available services, ranging from small-scale to large-scale providers. The application caters to users who are in a new town or city and need to contact service providers like taxi drivers, tailors, lawyers, labour and more, without having their contact information readily available. The platform accommodates both individual service providers and organizations.
              ''',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
