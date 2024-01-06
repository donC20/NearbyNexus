// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:NearbyNexus/main.dart' as app;

void main() {
  group('Login  Test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("Login Scenarios", (widgetTester) async {
      app.main();

      // Ensure the splash screen is shown.
      await widgetTester.pumpAndSettle(
          Duration(seconds: 2)); // Adjust the duration as needed.

      // Assuming the splash screen automatically navigates to the login screen.
      final getStartedBtn = find.byKey(Key('getStartedBtn'));

      await widgetTester.tap(getStartedBtn);

      await widgetTester.pumpAndSettle();

      final loginEmailTester = find.byKey(Key('LoginEmail'));
      final loginPasswordTester = find.byKey(Key('LoginPassword'));
      final loginButtonTester = find.byKey(Key('LoginButton'));

      // Scenario 1: Press login button without entering anything
      print(
          "\x1B[34mScenario 1:\x1B[0m Press login button without entering anything");
      await widgetTester.tap(loginButtonTester);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text("Test Pass"),
          findsNothing); // Expecting no "Test` Pass" indicator

      // Scenario 2: Enter wrong password and press login
      print("\x1B[34mScenario 2:\x1B[0m Enter wrong  password and press login");
      await widgetTester.enterText(loginEmailTester, "don@gmail.com");
      await widgetTester.enterText(loginPasswordTester, "wrong_password");
      await widgetTester.tap(loginButtonTester);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text("Test Pass"),
          findsNothing); // Expecting no "Test Pass" indicator

      // Scenario 3: Enter correct email and password
      print("\x1B[34mScenario 3:\x1B[0m Enter correct email and password");
      await widgetTester.enterText(loginEmailTester, "donbenny916@gmail.com");
      await widgetTester.enterText(loginPasswordTester, "123456");
      await widgetTester.tap(loginButtonTester);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      expect(find.text("Test Pass"),
          findsNothing); // Expecting no "Test Pass" indicator

      print("\x1B[32mAll scenarios passed!\x1B[0m");
    });
  });
}
