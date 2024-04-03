// ignore_for_file: use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';

class ReportUser extends StatefulWidget {
  final userTobeReported;
  const ReportUser({Key? key, this.userTobeReported}) : super(key: key);

  @override
  _ReportUserState createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSubmitting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report user'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: Text(
                      'If you encounter any issues with a user, please utilize the reporting option to bring it to our attention. We carefully review reports to ensure compliance with our platforms Terms and Conditions. Thank you for helping us maintain a safe and welcoming environment for all users.'),
                ),
                SizedBox(
                  height: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe your issue',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 200,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                          borderRadius: BorderRadius.circular(5)),
                      child: TextFormField(
                        controller: controller,
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                            hintText: 'Please enter something.',
                            hintStyle:
                                TextStyle(color: Colors.white24, fontSize: 14),
                            border: InputBorder.none),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "You left this field empty!";
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 50),
        child: isSubmitting
            ? GFButton(
                onPressed: null,
                fullWidthButton: true,
                color: Colors.red,
                size: 50,
                shape: GFButtonShape.pills,
                child: Center(
                  child: GFLoader(
                    type: GFLoaderType.android,
                  ),
                ),
              )
            : GFButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isSubmitting = true;
                    });
                    try {
                      FirebaseFirestore.instance.collection('reports').add({
                        'reportedBy': ApiFunctions.user!.uid,
                        'reportedAbout': widget.userTobeReported,
                        'reportedOn': DateTime.now(),
                        'description': controller.text,
                        'status': 'received',
                      }).then((value) => Navigator.pushReplacementNamed(
                              context, "/success_screen",
                              arguments: {
                                "content":
                                    "Your report has been successfully submitted.",
                                "navigation": "user_dashboard"
                              }));
                      setState(() {
                        isSubmitting = false;
                      });
                    } catch (e) {
                      setState(() {
                        isSubmitting = false;
                      });
                      print(e);
                    }
                  }
                },
                icon: Icon(Icons.flag),
                text: 'Report',
                textStyle: TextStyle(fontSize: 16),
                fullWidthButton: true,
                color: Colors.red,
                size: 50,
                shape: GFButtonShape.pills,
              ),
      ),
    );
  }
}
