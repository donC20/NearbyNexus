// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    // Access individual arguments
    String content = arguments['content'] ?? '';
    String navigation = arguments['navigation'] ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFF0F1014),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Lottie.network(
                    'https://lottie.host/016774e7-942a-4e62-9264-09139a4ed80f/iPC3sP2jKh.json',
                    fit: BoxFit.contain,
                    width: 300,
                    height: 300,
                    animate: true,
                    filterQuality: FilterQuality.high,
                    repeat: false),
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ],
            ),
            // SizedBox(
            //   height: 20,
            // ),
            FutureBuilder<bool>(
                future: Future.delayed(Duration(seconds: 1), () => true),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // Delay is over, show the button
                    return DecoratedBox(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                                tileMode: TileMode.mirror,
                                colors: [
                                  Color.fromARGB(188, 83, 232, 140),
                                  Color.fromARGB(177, 21, 190, 120)
                                ])),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                alignment: Alignment.center,
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.only(
                                        right: 75,
                                        left: 75,
                                        top: 15,
                                        bottom: 15)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25)),
                                )),
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, navigation);
                            },
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )));
                  } else {
                    // Still waiting for the delay to complete, you can show a loading indicator or something else
                    return SizedBox();
                  }
                })
          ],
        ),
      ),
    );
  }
}
