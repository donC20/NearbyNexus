// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/misc/colors.dart';
import 'package:NearbyNexus/models/application_model.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:logger/logger.dart';

class BidForJob extends StatefulWidget {
  const BidForJob({Key? key}) : super(key: key);

  @override
  _BidForJobState createState() => _BidForJobState();
}

class _BidForJobState extends State<BidForJob> {
  late final CollectionReference<Map<String, dynamic>> _applicationsCollection;
  final _formKey = GlobalKey<FormState>();

  // bool
  bool isSubmitting = false;

// logger
  var logger = Logger();
  //Date time
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // controllers
  final bidAmountController = TextEditingController();
  final descriptionController = TextEditingController();

// String

  // fn()
  // date picking
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  void initState() {
    _applicationsCollection =
        FirebaseFirestore.instance.collection('applications');
    fetchCurrentUser();
    super.initState();
  }

  String currentUser = '';
  Future<void> fetchCurrentUser() async {
    final userUID = await VendorCommonFn().getUserUIDFromSharedPreferences();

    setState(() {
      currentUser = userUID;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> argument =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    logger.d(argument);
    return Scaffold(
        backgroundColor: KColors.backgroundDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Job Proposal',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 5.0,
                              color: Colors.black,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      "Show your interest for the job post.",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      customInput(
                        title: "Your bid amount",
                        hintText: "What's your bid amount",
                        prefixIcon: Icons.attach_money,
                        controller: bidAmountController,
                        textInputType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Bid amount can't be empty!";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      customInput(
                        title: "Describe your proposal",
                        hintText: "What makes you fit for this job?",
                        prefixIcon: Icons.description,
                        controller: descriptionController,
                        textInputType: TextInputType.multiline,
                        maxLines: null,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 10) {
                            return "Please provide a detailed proposal (min 100 characters)!";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                GFButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() {
                            isSubmitting = true;
                          });

                          ApplicationModel myApplication = ApplicationModel(
                            applicantId: await VendorCommonFn()
                                .getUserUIDFromSharedPreferences(),
                            proposalDescription: descriptionController.text,
                            applicationPostedTime: DateTime.now(),
                            bidAmount: bidAmountController.text,
                            jobId: argument['post_id'],
                          );

                          if (_formKey.currentState!.validate()) {
                            try {
                              // Convert ApplicationModel to JSON format
                              Map<String, dynamic> applicationData =
                                  myApplication.toJson();

                              // Add application document to _applicationsCollection
                              DocumentReference applicationDocRef =
                                  await _applicationsCollection
                                      .add(applicationData);

                              // Get the document ID of the newly added application
                              String applicationId = applicationDocRef.id;

                              // Show snackbar to indicate successful addition
                              UtilityFunctions().showSnackbar(
                                "Application added successfully",
                                Colors.green,
                                context,
                              );

                              // Update the job_post document with the application ID
                              await FirebaseFirestore.instance
                                  .collection('job_posts')
                                  .doc(argument[
                                      'post_id']) // Use the appropriate document ID
                                  .update({
                                'applications':
                                    FieldValue.arrayUnion([applicationId])
                              });
                              // Update the users document with the application ID
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser)
                                  .update({
                                'jobs_applied':
                                    FieldValue.arrayUnion([applicationId])
                              });
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser)
                                  .update({
                                'jobs_applied_list':
                                    FieldValue.arrayUnion([argument['post_id']])
                              });
                            } catch (e) {
                              UtilityFunctions().showSnackbar(
                                "Error: $e",
                                const Color.fromARGB(255, 175, 76, 76),
                                context,
                              );
                            } finally {
                              setState(() {
                                isSubmitting = false;
                              });
                            }
                          } else {
                            logger.f('errr');
                            setState(() {
                              isSubmitting = false;
                            });
                          }
                        },
                  shape: GFButtonShape.pills,
                  text: "Submit",
                  size: GFSize.LARGE,
                  fullWidthButton: true,
                ),
              ],
            ),
          ),
        ));
  }

  Widget customInput({
    required String title,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    required TextInputType textInputType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextFormField(
            maxLines: maxLines,
            keyboardType: textInputType,
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(prefixIcon, color: Colors.white),
              border: InputBorder.none,
            ),
            validator: validator,
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
