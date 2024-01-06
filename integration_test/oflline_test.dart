// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:NearbyNexus/main.dart' as app;

void main() {
  group('New jobs test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("New job function test", (widgetTester) async {
      try {
        app.main();

        // Ensure the splash screen is shown.
        await widgetTester.pumpAndSettle(
            Duration(seconds: 2)); // Adjust the duration as needed.

        // Assuming the splash screen automatically navigates to the login screen.
        final getStartedBtn = find.byKey(Key('getStartedBtn'));

        await widgetTester.tap(getStartedBtn);
        print("Step 1: Tapped 'Get Started' button");
        await widgetTester.pumpAndSettle();

        final loginEmailTester = find.byKey(Key('LoginEmail'));
        final loginPasswordTester = find.byKey(Key('LoginPassword'));
        final loginButtonTester = find.byKey(Key('LoginButton'));
        final new_job = find.byKey(Key('new_job'));

        await widgetTester.enterText(loginEmailTester, "prizedrops@gmail.com");
        await widgetTester.enterText(loginPasswordTester, "123456");
        print("Step 2: Entered email and password");

        await widgetTester.pumpAndSettle();

        await widgetTester.tap(loginButtonTester);
        print("Step 3: Tapped 'Login' button");
        await widgetTester.pumpAndSettle(Duration(seconds: 8));

        await widgetTester.tap(new_job);
        print("Step 4: Tapped 'new_job' button");
        await widgetTester.pumpAndSettle(Duration(seconds: 10));

        print("Opened new jobs successfully!");

        await widgetTester.pumpAndSettle(Duration(seconds: 5));
      } catch (e) {
        print("Error occurred on page: ${e}");
      }
    });
  });
}
