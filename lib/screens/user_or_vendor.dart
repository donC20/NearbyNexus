import 'package:flutter/material.dart';

class UserOrVendor extends StatelessWidget {
  const UserOrVendor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 200,
                child: Image(
                    image: AssetImage("assets/images/nearbynexus(BL).png")),
              ),
              const Text(
                "What you need?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "registration_screen",
                        arguments: "Here for hire");
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    backgroundColor: const Color(0xFF25211E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("I need services"),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "registration_screen",
                        arguments: "Here for work");
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal),
                    backgroundColor: const Color(0xFF25211E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text("I need work"),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "--------------- Or ----------------",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 300,
                height: 70,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "login_screen");
                  },
                  style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color.fromARGB(77, 0, 0, 0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                  child: const Text("Login",
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
