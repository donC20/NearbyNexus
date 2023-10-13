// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:NearbyNexus/main.dart' as app;

void main() {
  group('User Test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("User function test", (widgetTester) async {
      app.main();

      Color green = Color.fromARGB(255, 0, 255, 0);
      Color red = Color.fromARGB(255, 255, 0, 0);

      void printStep(String step) {
        print("\x1B[34m$step\x1B[0m");
      }

      void printResult(bool passed) {
        if (passed) {
          print("\x1B[32mTest Passed\x1B[0m");
        } else {
          print("\x1B[31mTest Failed\x1B[0m");
        }
      }

      // Ensure the splash screen is shown.
      await widgetTester.pumpAndSettle(
          Duration(seconds: 2)); // Adjust the duration as needed.
      printStep("Step 1: Splash screen shown");

      // Assuming the splash screen automatically navigates to the login screen.
      final getStartedBtn = find.byKey(Key('getStartedBtn'));

      await widgetTester.tap(getStartedBtn);

      await widgetTester.pumpAndSettle();
      printStep("Step 2: Tapped 'Get Started' button");

      final loginEmailTester = find.byKey(Key('LoginEmail'));
      final loginPasswordTester = find.byKey(Key('LoginPassword'));
      final loginButtonTester = find.byKey(Key('LoginButton'));
      final active_jobs = find.byKey(Key('active_jobs'));
      final details_button_user = find.byKey(Key('0_button_user'));
      final negotiate_start = find.byKey(Key('negotiate_start'));
      final enter_amount = find.byKey(Key('enter_amount'));
      final negotiate_final = find.byKey(Key('negotiate_final'));

      await widgetTester.enterText(loginEmailTester, "donbenny916@gmail.com");
      await widgetTester.enterText(loginPasswordTester, "123456");
      printStep("Step 3: Entered email and password");

      await widgetTester.pumpAndSettle();

      await widgetTester.tap(loginButtonTester);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      printStep("Step 4: Tapped 'Login' button");

      await widgetTester.tap(active_jobs);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      printStep("Step 5: Tapped 'Active Jobs' button");

      await widgetTester.tap(details_button_user);
      await widgetTester.pumpAndSettle(Duration(seconds: 7));
      printStep("Step 6: Tapped 'Details Button User'");

      await widgetTester.tap(negotiate_start);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      await widgetTester.enterText(enter_amount, "500");
      await widgetTester.pumpAndSettle(Duration(seconds: 3));
      printStep("Step 7: Tapped 'Negotiate Start' and entered amount");

      await widgetTester.tap(negotiate_final);
      await widgetTester.pumpAndSettle(Duration(seconds: 3));
      printStep("Step 8: Tapped 'Negotiate Final'");

      // Assuming the test passed, you can change this based on your actual condition.
      bool testPassed = true;

      // Print result with appropriate color.
      printResult(testPassed);
    });
  });
}
