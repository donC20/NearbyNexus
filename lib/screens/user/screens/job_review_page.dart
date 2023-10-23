// ignore_for_file: deprecated_member_use, prefer_const_constructors, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, use_build_context_synchronously, avoid_print, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/functions_utils.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/models/payment_modal.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class JobReviewPage extends StatefulWidget {
  const JobReviewPage({super.key});

  @override
  State<JobReviewPage> createState() => _JobReviewPageState();
}

class _JobReviewPageState extends State<JobReviewPage> {
  // Sample job and customer information
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _service_actions_collection =
      FirebaseFirestore.instance.collection('service_actions');
  FunctionInvoker functionInvoker = FunctionInvoker();

  bool isChecked = false;
  bool isPaymentClicked = false;
  String uid = '';
  String? formattedTimeAgo;
  var logger = Logger();
  Map<String, dynamic>? paymentIntent;
  final List<String> paymentLogs = [];
  @override
  void initState() {
    super.initState();
    initUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime currentTime = DateTime.now();
    DateTime postTime = timestamp.toDate();
    Duration difference = currentTime.difference(postTime);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}d ago";
    } else {
      return DateFormat('MMM dd, yyyy').format(postTime);
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails(
      DocumentReference userReference) async {
    try {
      DocumentSnapshot userDetailsSnapshot = await userReference.get();
      return userDetailsSnapshot.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching user details: $e');
      return null; // Handle the error as needed
    }
  }

// payments
  Future<void> makePayment(
      String recipientName,
      String amount,
      DocumentReference jobId,
      DocumentReference payedBy,
      DocumentReference payedTo,
      List<dynamic> jobLogs) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  googlePay: const PaymentSheetGooglePay(
                      testEnv: true,
                      currencyCode: "INR",
                      merchantCountryCode: "IN"),
                  style: ThemeMode.dark,
                  merchantDisplayName: recipientName))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet(amount, jobId, payedBy, payedTo, jobLogs);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(
      String amount,
      DocumentReference jobId,
      DocumentReference payedBy,
      DocumentReference payedTo,
      List<dynamic> jobLogs) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
// successful payment then update database
        try {
          PaymentModal payModal = PaymentModal(
              amountPaid: amount,
              jobId: jobId,
              payedBy: payedBy,
              payedTo: payedTo,
              paymentTime: DateTime.now());
          setState(() {
            jobLogs.add("paid");
          });
          Map<String, dynamic> paymentData = payModal.toJson();
          _firestore.collection('payments').add(paymentData).then((value) {
            DocumentReference paymentId =
                _firestore.collection('payments').doc(value.id);
            jobId.update({
              'paymentStatus': 'paid',
              'paymentLog': paymentId,
              'jobLogs': jobLogs
            });
// update user
            payedBy.get().then((userDoc) {
              if (userDoc.exists) {
                Map<String, dynamic> paymentLogs =
                    userDoc.data() as Map<String, dynamic>;
                List<dynamic> payLogs = paymentLogs['paymentLogs'];
                payLogs.add(paymentId);

                payedBy.update({'paymentLogs': payLogs}).then((_) {
                  print('Payment ID added to paymentLogs: $paymentId');
                }).catchError((error) {
                  print('Error updating user document: $error');
                });
              } else {
                // Handle the case where the user document doesn't exist
                print('User document does not exist');
              }
            }).catchError((error) {
              // Handle any errors that occur when retrieving the user document
              print('Error retrieving user document: $error');
            });

            // update vendor

            payedTo.get().then((userDoc) {
              if (userDoc.exists) {
                Map<String, dynamic> paymentToLogs =
                    userDoc.data() as Map<String, dynamic>;
                List<dynamic> payToLogs = paymentToLogs['paymentLogs'];
                payToLogs.add(paymentId);

                payedTo.update({'paymentLogs': payToLogs}).then((_) {
                  print('Payment ID added to paymentLogs: $paymentId');
                }).catchError((error) {
                  print('Error updating user document: $error');
                });
              } else {
                // Handle the case where the user document doesn't exist
                print('User document does not exist');
              }
            }).catchError((error) {
              // Handle any errors that occur when retrieving the user document
              print('Error retrieving user document: $error');
            });
          }).catchError((error) {
            // Handle any errors that occur when adding a document to the "payments" collection
            print('Error adding document to payments collection: $error');
          });

          jobId.update({
            'clientStatus': 'finished',
            'status': 'finished',
            'dateRequested': DateTime.now()
          });
          // Navigator.popAndPushNamed(context, "rate_user_screen");
          Navigator.popAndPushNamed(context, "rate_user_screen",
              arguments: {"uid": payedTo.id, "jobId": jobId.id});
        } catch (e) {
          logger.e(e);
        }

        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 30,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));
        paymentIntent = null;
        setState(() {
          isPaymentClicked = false;
        });
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      String SECRET_KEY =
          "sk_test_51NpN8rSJaMBnAdU7Rwr9dgYxVZ4yk3J8lQNazKj0hBv3Vn98yphDtEZ1rNY9hR6I6D4mDpcJKjoO2XbZE0Y5u5Se00Fey7EJwx";
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $SECRET_KEY',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Review job'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _firestore
                .collection('service_actions')
                .doc(arguments['dataReference'])
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error.toString()}'));
              } else if (!snapshot.hasData || snapshot.data!.data() == null) {
                return Center(child: Text('No data available'));
              } else {
                Map<String, dynamic> documentData =
                    snapshot.data!.data()! as Map<String, dynamic>;
                // Access data here
                DocumentReference vendorReference =
                    documentData['referencePath'];
                return FutureBuilder<DocumentSnapshot>(
                  future:
                      vendorReference.get(), // Fetch user data asynchronously
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      // If user data is still loading, show a loading indicator
                      return Center(child: CircularProgressIndicator());
                    } else if (userSnapshot.hasError) {
                      // Handle errors if any
                      return Text('Error: ${userSnapshot.error.toString()}');
                    } else if (userSnapshot.hasData) {
                      // User data is available

                      Map<String, dynamic> userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;

                      // Replace with actual field name
                      formattedTimeAgo =
                          formatTimestamp(documentData['dateRequested']);

                      return ListView(
                        children: [
                          Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width - 30,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(43, 158, 158, 158)),
                                borderRadius: BorderRadius.circular(10),
                                color: Color.fromARGB(186, 42, 40, 40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.9),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  UserLoadingAvatar(
                                      userImage: userData['image']),
                                  Text(
                                    convertToSentenceCase(userData['name']),
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final Uri _emailLaunchUri = Uri(
                                            scheme: 'mailto',
                                            path: userData['emailId']['id'],
                                            // queryParameters: {
                                            //   'subject':
                                            //       Uri.encodeComponent(subject),
                                            //   'body': Uri.encodeComponent(body),
                                            // },
                                          );

                                          final url =
                                              _emailLaunchUri.toString();
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 251, 101, 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                20.0), // Adjust the radius as needed
                                          ),
                                        ),
                                        icon: Icon(Icons.mail),
                                        label: Text("Mail"),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          final phoneNumber = userData['phone']
                                                  ['number']
                                              .toString(); // Replace with the recipient's phone number
                                          const messageBody = 'Hello, there,';

                                          final Uri _smsLaunchUri = Uri(
                                            scheme: 'sms',
                                            path: phoneNumber,
                                            queryParameters: {
                                              'body': messageBody,
                                            },
                                          );

                                          final url = _smsLaunchUri.toString();

                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 0, 173, 203),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                20.0), // Adjust the radius as needed
                                          ),
                                        ),
                                        icon: Icon(Icons.sms),
                                        label: Text("SMS"),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          FlutterPhoneDirectCaller.callNumber(
                                              userData['phone']['number']
                                                  .toString());
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                20.0), // Adjust the radius as needed
                                          ),
                                        ),
                                        icon: Icon(Icons.call),
                                        label: Text("Call"),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 15,
                                        top: 10,
                                        bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.email,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          userData['emailId']['id'],
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 15,
                                        top: 10,
                                        bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "+91 ${userData['phone']['number'].toString()}",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 15,
                                        top: 10,
                                        bottom: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          documentData['location'].toString(),
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width - 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromARGB(43, 158, 158, 158)),
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromARGB(186, 42, 40, 40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.9),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Service details",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Divider(
                                  color:
                                      const Color.fromARGB(123, 158, 158, 158),
                                ),
                                serviceDetaisl("Service name",
                                    documentData['service_name']),
                                serviceDetaisl("Completed", formattedTimeAgo),
                                serviceDetaisl("Needed on",
                                    timeStampConverter(documentData['day'])),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Budjet",
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        documentData['wage'],
                                        style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Divider(
                                  color:
                                      const Color.fromARGB(123, 158, 158, 158),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  convertToSentenceCase(
                                      documentData['description']),
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white54,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  color:
                                      const Color.fromARGB(123, 158, 158, 158),
                                ),

                                // if job completed
                                documentData['status'] == 'completed' &&
                                        documentData['status'] != 'unfinished'
                                    ? reviewAndPay(vendorReference, userData,
                                        arguments, documentData)
                                    : documentData['status'] == 'negotiate'
                                        ? negotiateAmount(
                                            context,
                                            documentData,
                                            arguments['dataReference'],
                                            "Negotiate")
                                        : documentData['status'] ==
                                                'user negotiated'
                                            ? negotiateAmount(
                                                context,
                                                documentData,
                                                arguments['dataReference'],
                                                "Change amount")
                                            : ElevatedButton.icon(
                                                onPressed: () {
                                                  Map<String, dynamic> logData =
                                                      {
                                                    "docId": arguments[
                                                        'dataReference'],
                                                    "from": "user"
                                                  };

                                                  Navigator.pushNamed(context,
                                                      "job_log_timeline",
                                                      arguments: logData);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape: StadiumBorder()),
                                                icon: Icon(
                                                  Icons.donut_large_rounded,
                                                  color: Colors.black,
                                                ),
                                                label: Text(
                                                  "View log",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                )),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No data available for the user.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                );
              }
            },
          )),
    );
  }

// if user amount negotiated then show this
  Widget negotiateAmount(
      BuildContext context, documentData, docId, String text) {
    final TextEditingController _amountController = TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
            key: Key("negotiate_start"),
            onPressed: () {
              showDialog(
                // barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "Negotiate the price",
                                style: TextStyle(
                                    color: Color.fromARGB(170, 0, 0, 0),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              "Enter amount",
                              style: TextStyle(
                                  color: Color.fromARGB(170, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              child: TextFormField(
                                key: Key("enter_amount"),
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.poppins(
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Enter amount',
                                  labelStyle: TextStyle(
                                      color:
                                          const Color.fromARGB(255, 22, 0, 0),
                                      fontSize: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(73, 0, 0, 0),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(73, 0, 0, 0),
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "You left this field empty!";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                key: Key("negotiate_final"),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final List<dynamic> jobLogs =
                                        documentData['jobLogs'];
                                    jobLogs.add('user negotiated');

                                    _service_actions_collection
                                        .doc(docId)
                                        .update({
                                      'status': 'user negotiated',
                                      'wage': _amountController.text,
                                      'dateRequested': DateTime.now(),
                                      'jobLogs': jobLogs
                                    });
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  text,
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 252, 252, 252),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 83, 41, 255),
                shape: StadiumBorder()),
            icon: Icon(Icons.new_label),
            label: Text(text)),
        SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, shape: StadiumBorder()),
            onPressed: () {
              declineFunction() {
                print("finc called");
                final List<dynamic> jobLogs = documentData['jobLogs'];
                jobLogs.add('user rejected');
                _service_actions_collection.doc(docId).update({
                  'status': 'user rejected',
                  'clientStatus': 'canceled',
                  'dateRequested': DateTime.now(),
                  'jobLogs': jobLogs
                }).then((value) => functionInvoker.showAwesomeSnackbar(
                    context,
                    "The service is rejected",
                    Colors.green,
                    Colors.white,
                    Icons.check,
                    Colors.amber));
              }

              functionInvoker.showCancelDialog(context, declineFunction,
                  "Do you want to cancel this service request?");
            },
            icon: Icon(Icons.close),
            label: Text("Revoke")),
        ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, shape: StadiumBorder()),
            onPressed: () {
              declineFunction() {
                print("finc called");
                final List<dynamic> jobLogs = documentData['jobLogs'];
                jobLogs.add('user accepted');
                _service_actions_collection.doc(docId).update({
                  'status': 'user accepted',
                  'dateRequested': DateTime.now(),
                  'jobLogs': jobLogs
                }).then((value) => functionInvoker.showAwesomeSnackbar(
                    context,
                    "The service is accepted",
                    Colors.green,
                    Colors.white,
                    Icons.check,
                    Colors.amber));
              }

              functionInvoker.showCancelDialog(context, declineFunction,
                  "Do you want to accept this service request?");
            },
            icon: Icon(Icons.check),
            label: Text("Accept")),
      ],
    );
  }

// payment verify function
  Widget reviewAndPay(vendorReference, userData, arguments, documentData) {
    return Column(
      children: [
        CheckboxListTile(
          title: Text(
            "Yes, I confirm that the above job is reviewed & stands completed.",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          checkColor: Colors.black,
          activeColor: Colors.white,
          value: isChecked,
          onChanged: (newValue) {
            setState(() {
              isChecked = newValue!;
            });
          },
        ),
        SizedBox(
          height: 10,
        ),
        isChecked
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: isPaymentClicked
                      ? null
                      : () async {
                          setState(() {
                            isPaymentClicked = true;
                          });

                          final DocumentReference jobId = _firestore
                              .collection('service_actions')
                              .doc(arguments['dataReference']);
                          final DocumentReference payedBy =
                              _firestore.collection('users').doc(uid);
                          final DocumentReference payedTo = vendorReference;
                          logger.d(payedTo.id);
                          await makePayment(
                              userData['name'],
                              documentData['wage'],
                              jobId,
                              payedBy,
                              payedTo,
                              documentData['jobLogs']);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 110, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          20.0), // Adjust the radius as needed
                    ),
                  ), // Rupee icon
                  child: isPaymentClicked
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Pay ", // ₹ is the Unicode character for the rupee symbol
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.currency_rupee,
                              size: 18,
                            ),
                            Text(
                              "${documentData['wage']}", // ₹ is the Unicode character for the rupee symbol
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: () {
                  List<dynamic> jobLog = documentData['jobLogs'];
                  setState(() {
                    jobLog.add('unfinished');
                  });
                  _service_actions_collection
                      .doc(arguments['dataReference'])
                      .update({
                    'clientStatus': 'unfinished',
                    'status': 'unfinished',
                    'dateRequested': DateTime.now(),
                    'jobLogs': jobLog
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 175, 76, 76),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        20.0), // Adjust the radius as needed
                  ),
                ),
                icon: Icon(Icons.close),
                label: Text("Mark not completed"),
              )
      ],
    );
  }
}

// time stamp converter
String timeStampConverter(Timestamp timeAndDate) {
  DateTime dateTime = timeAndDate.toDate();
  String formattedDateTime = DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
  return formattedDateTime;
}

// servcce boc
Widget serviceDetaisl(serviceTitle, serviceName) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          serviceTitle,
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          convertToSentenceCase(serviceName),
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white54,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}
