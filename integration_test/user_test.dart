// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:NearbyNexus/main.dart' as app;

void main() {
  group('Vendor Test', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("Vendor function test", (widgetTester) async {
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
      final active_jobs = find.byKey(Key('active_jobs'));
      final details_button_user = find.byKey(Key('0_button_user'));
      final negotiate_start = find.byKey(Key('negotiate_start'));
      final enter_amount = find.byKey(Key('enter_amount'));
      final negotiate_final = find.byKey(Key('negotiate_final'));

      await widgetTester.enterText(loginEmailTester, "donbenny916@gmail.com");
      await widgetTester.enterText(loginPasswordTester, "123456");

      await widgetTester.pumpAndSettle();

      await widgetTester.tap(loginButtonTester);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));

      await widgetTester.tap(active_jobs);

      await widgetTester.pumpAndSettle(Duration(seconds: 5));

      await widgetTester.tap(details_button_user);

      await widgetTester.pumpAndSettle(Duration(seconds: 7));

      await widgetTester.tap(negotiate_start);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
      await widgetTester.enterText(enter_amount, "500");
      await widgetTester.pumpAndSettle(Duration(seconds: 3));

      await widgetTester.tap(negotiate_final);

      await widgetTester.pumpAndSettle(Duration(seconds: 3));



      await widgetTester.pumpAndSettle(Duration(seconds: 5));
    });
  });
}
