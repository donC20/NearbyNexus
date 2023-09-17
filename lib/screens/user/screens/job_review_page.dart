// ignore_for_file: deprecated_member_use, prefer_const_constructors, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, use_build_context_synchronously, avoid_print

import 'dart:convert';

import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/screens/admin/screens/user_list_admin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

  bool isChecked = false;
  bool isPaymentClicked = false;
  String uid = '';
  String? formattedTimeAgo;
  var logger = Logger();
  Map<String, dynamic>? paymentIntent;
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
    var initData = json.decode(userLoginData!);
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
  Future<void> makePayment(String recipientName, String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'INR');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  // applePay: const PaymentSheetApplePay(merchantCountryCode: '+92',),
                  // googlePay: const PaymentSheetGooglePay(testEnv: true, currencyCode: "US", merchantCountryCode: "+92"),
                  style: ThemeMode.dark,
                  merchantDisplayName: recipientName))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Review job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore
              .collection('service_actions')
              .where('userReference',
                  isEqualTo:
                      FirebaseFirestore.instance.collection('users').doc(uid))
              .where('status', isEqualTo: 'completed')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error.toString()}'));
            } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              List<QueryDocumentSnapshot> documentList = snapshot.data!.docs;

              return ListView.separated(
                itemBuilder: (context, index) {
                  QueryDocumentSnapshot document = documentList[index];
                  Map<String, dynamic> documentData =
                      document.data() as Map<String, dynamic>;
                  final docId = documentList[index].id;
                  // Check if the document data is not empty
                  if (documentData.isNotEmpty) {
                    DocumentReference vendorReference =
                        documentData['referencePath'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: vendorReference
                          .get(), // Fetch user data asynchronously
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          // If user data is still loading, show a loading indicator
                          return Center(child: CircularProgressIndicator());
                        } else if (userSnapshot.hasError) {
                          // Handle errors if any
                          return Text(
                              'Error: ${userSnapshot.error.toString()}');
                        } else if (userSnapshot.hasData) {
                          // User data is available
                          Map<String, dynamic> userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          // Replace with actual field name
                          formattedTimeAgo =
                              formatTimestamp(documentData['dateRequested']);

                          return Column(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(10),
                                  width: MediaQuery.of(context).size.width - 30,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(43, 158, 158, 158)),
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
                                                path: 'donbenny916@gmail.com',
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
                                              backgroundColor: Color.fromARGB(
                                                  255, 251, 101, 8),
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
                                              final phoneNumber = userData[
                                                      'phone']['number']
                                                  .toString(); // Replace with the recipient's phone number
                                              const messageBody =
                                                  'Hello, there,';

                                              final Uri _smsLaunchUri = Uri(
                                                scheme: 'sms',
                                                path: phoneNumber,
                                                queryParameters: {
                                                  'body': messageBody,
                                                },
                                              );

                                              final url =
                                                  _smsLaunchUri.toString();

                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                throw 'Could not launch $url';
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 0, 173, 203),
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
                                              FlutterPhoneDirectCaller
                                                  .callNumber(userData['phone']
                                                          ['number']
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
                                              documentData['location']
                                                  .toString(),
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
                                      color: const Color.fromARGB(
                                          123, 158, 158, 158),
                                    ),
                                    serviceDetaisl("Service name",
                                        documentData['service_name']),
                                    serviceDetaisl(
                                        "Completed", formattedTimeAgo),
                                    serviceDetaisl(
                                        "Needed on",
                                        timeStampConverter(
                                            documentData['day'])),
                                    serviceDetaisl(
                                        "Location", documentData['location']),
                                    Text(
                                      "Description",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.white54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Divider(
                                      color: const Color.fromARGB(
                                          123, 158, 158, 158),
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
                                      color: const Color.fromARGB(
                                          123, 158, 158, 158),
                                    ),
                                    CheckboxListTile(
                                      title: Text(
                                        "Yes, I confirm that the above job is reviewed & stands completed.",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.white),
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
                                                      // _service_actions_collection
                                                      //     .doc(docId)
                                                      //     .update({
                                                      //   'clientStatus': 'finished',
                                                      //   'status': 'finished',
                                                      //   'dateRequested':
                                                      //       DateTime.now()
                                                      // });

                                                      setState(() {
                                                        isPaymentClicked = true;
                                                      });

                                                      await makePayment(
                                                          userData['name'],
                                                          documentData['wage']);
                                                    },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromARGB(
                                                    255, 0, 110, 255),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0), // Adjust the radius as needed
                                                ),
                                              ), // Rupee icon
                                              child: isPaymentClicked
                                                  ? CircularProgressIndicator(
                                                      color: Colors.white,
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Pay ", // ₹ is the Unicode character for the rupee symbol
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          )
                                        : ElevatedButton.icon(
                                            onPressed: () {
                                              _service_actions_collection
                                                  .doc(docId)
                                                  .update({
                                                'clientStatus': 'unfinished',
                                                'status': 'unfinished',
                                                'dateRequested': DateTime.now()
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 175, 76, 76),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    20.0), // Adjust the radius as needed
                                              ),
                                            ),
                                            icon: Icon(Icons.close),
                                            label: Text("Mark not completed"),
                                          )
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
                  } else {
                    return Center(
                      child: Text(
                        'No data available for the user.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
                itemCount: documentList.length,
              );
            } else {
              return Center(child: Text('No data available.'));
            }
          },
        ),
      ),
    );
  }
}

String timeStampConverter(Timestamp timeAndDate) {
  DateTime dateTime = timeAndDate.toDate();
  String formattedDateTime = DateFormat('MM/dd/yyyy hh:mm a').format(dateTime);
  return formattedDateTime;
}

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
