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
      final job_logs_btn = find.byKey(Key('job_logs_btn'));
      final view_requests_btn = find.byKey(Key('0_button'));
      final accept_job_btn = find.byKey(Key('accept_btn'));

      await widgetTester.enterText(loginEmailTester, "prizedrops@gmail.com");
      await widgetTester.enterText(loginPasswordTester, "123456");

      await widgetTester.pumpAndSettle();

      await widgetTester.tap(loginButtonTester);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));

      await widgetTester.tap(job_logs_btn);

      await widgetTester.pumpAndSettle(Duration(seconds: 10));

      await widgetTester.tap(view_requests_btn);

      await widgetTester.pumpAndSettle(Duration(seconds: 5));

      await widgetTester.tap(accept_job_btn);
      await widgetTester.pumpAndSettle(Duration(seconds: 5));
    });
  });
}
