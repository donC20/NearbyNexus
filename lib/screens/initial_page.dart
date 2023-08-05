import 'package:flutter/material.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({Key? key})
      : super(key: key); // Fix the constructor declaration.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                const Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(25, 50, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Find or work for the best services\nat one place.",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "We help you to connect with various services and people near to you.",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(200, 158, 158, 158)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: const Image(
                    image: AssetImage("lib/images/testimage.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                // Button Register
                SizedBox(
                  width: 300,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "user_or_vendor");
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      backgroundColor: const Color(0xFF25211E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Get Started"),
                        Icon(Icons.arrow_right),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
