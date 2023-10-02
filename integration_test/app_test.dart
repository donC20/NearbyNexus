// // ignore_for_file: prefer_const_constructors, avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:NearbyNexus/main.dart' as app;

// void main() {
//   group('App test', () {
//     IntegrationTestWidgetsFlutterBinding.ensureInitialized();
//     testWidgets("Full app test", (widgetTester) async {
//       app.main();

//       // Ensure the splash screen is shown.
//       await widgetTester.pumpAndSettle(
//           Duration(seconds: 2)); // Adjust the duration as needed.

//       // Assuming the splash screen automatically navigates to the login screen.
//       final getStartedBtn = find.byKey(Key('getStartedBtn'));
      
//       await widgetTester.tap(getStartedBtn);

//       await widgetTester.pumpAndSettle();

//       final loginEmailTester = find.byKey(Key('LoginEmail'));
//       final loginPasswordTester = find.byKey(Key('LoginPassword'));
//       final loginButtonTester = find.byKey(Key('LoginButton'));

//       await widgetTester.enterText(loginEmailTester, "donbenny916@gmail.com");
//       await widgetTester.enterText(loginPasswordTester, "123456");

//       await widgetTester.pumpAndSettle();

//       await widgetTester.tap(loginButtonTester);
//     });
//   });
// }
