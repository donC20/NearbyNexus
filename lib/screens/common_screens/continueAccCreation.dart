// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';

class ContinueAccCreation extends StatefulWidget {
  const ContinueAccCreation({Key? key}) : super(key: key);

  @override
  _ContinueAccCreationState createState() => _ContinueAccCreationState();
}

class _ContinueAccCreationState extends State<ContinueAccCreation> {
  Map<String, dynamic> currentUserData = {};
  bool isUserLoading = true;

  @override
  void initState() {
    super.initState();
    initializeUserData();
  }

  Future<void> initializeUserData() async {
    VendorCommonFn()
        .streamDocumentsData(
      colectionId: 'users',
      uidParam: ApiFunctions.user!.uid,
    )
        .listen((data) {
      if (data.isNotEmpty) {
        setState(() {
          currentUserData = data;
          isUserLoading = false;
        });
      } else {
        // Handle case where 'chats' is null or not present
        setState(() {
          currentUserData = data;
          isUserLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isUserLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.asset('assets/images/info.png'),
                      SizedBox(
                        height: 15,
                      ),
                      RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(
                                text: 'Hello, \n',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 22)),
                            TextSpan(
                                text: currentUserData['emailId']['id'],
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold))
                          ])),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'We need additional details of you, ',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      height: 50,
                      width: 300,
                      child: GFButton(
                        onPressed: () {
                          Map<String, dynamic> userData = {
                            'uid': ApiFunctions.user!.uid,
                            'email': currentUserData['emailId']['id'],
                            'userType': currentUserData['userType'],
                            'loginType': currentUserData['loginType']
                          };
                          currentUserData['userType'] == "general_user"
                              ? Navigator.popAndPushNamed(
                                  context, "/complete_registration_user",
                                  arguments: userData)
                              : currentUserData['userType'] == "vendor"
                                  ? Navigator.popAndPushNamed(
                                      context, "complete_registration_vendor",
                                      arguments: userData)
                                  : print("Cant register or navigate");
                        },
                        shape: GFButtonShape.pills,
                        text: 'Continue',
                        size: GFSize.LARGE,
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
