// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, avoid_print

import 'dart:convert';

import 'package:NearbyNexus/components/avatar_of_user.dart';
import 'package:NearbyNexus/components/user_avatar_loader.dart';
import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/models/payment_modal.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:NearbyNexus/screens/vendor/functions/vendor_common_functions.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserActiveJobs extends StatefulWidget {
  const UserActiveJobs({super.key});

  @override
  State<UserActiveJobs> createState() => _UserActiveJobsState();
}

class _UserActiveJobsState extends State<UserActiveJobs> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = '';
  var logger = Logger();
  bool isPaymentClicked = false;
  String? formattedTimeAgo;
  Map<String, dynamic>? paymentIntent;
  final List<String> paymentLogs = [];
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
  }

  Future<void> fetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');

    setState(() {
      uid = initData['uid'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Active jobs"),
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: <Widget>[
                ButtonsTabBar(
                  backgroundColor: Color(0xFF2d4fff),
                  contentPadding: EdgeInsets.symmetric(horizontal: 15),
                  radius: 20,
                  unselectedBackgroundColor: Colors.grey[300],
                  unselectedLabelStyle: TextStyle(color: Colors.black),
                  labelStyle: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      icon: Icon(Icons.check_circle),
                      text: "Direct jobs",
                    ),
                    Tab(
                      icon: Icon(Icons.dangerous),
                      text: "My jobs",
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[directJobs(), getMyJobs()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget directJobs() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: uid.isNotEmpty
          ? _firestore
              .collection('service_actions')
              .where('userReference',
                  isEqualTo:
                      FirebaseFirestore.instance.collection('users').doc(uid))
              .where('status', whereNotIn: [
              'new',
              'completed',
              'user rejected'
            ]) // Add the statuses you want to include
              .snapshots()
          : Stream.empty(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List<QueryDocumentSnapshot> documentList = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: ListView.separated(
              itemBuilder: (context, index) {
                QueryDocumentSnapshot document = documentList[index];
                final docId = documentList[index].id;

                Map<String, dynamic> documentData =
                    document.data() as Map<String, dynamic>;
                return Container(
                  width: MediaQuery.sizeOf(context).width,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Color.fromARGB(43, 158, 158, 158)),
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    boxShadow: Theme.of(context).brightness == Brightness.dark
                        ? [] // Empty list for no shadow in dark theme
                        : [
                            BoxShadow(
                              color: Color.fromARGB(38, 67, 65, 65)
                                  .withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  documentData['service_name'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily:
                                          GoogleFonts.play().fontFamily),
                                ),
                                Chip(
                                  backgroundColor:
                                      documentData['service_level'] ==
                                              "Very urgent"
                                          ? Colors.red
                                          : documentData['service_level'] ==
                                                  "Urgent"
                                              ? Colors.amber
                                              : Colors.green,
                                  label: Text(
                                      documentData['service_level'] ??
                                          "loading..",
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  timeStampConverter(
                                      documentData['dateRequested']),
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      fontFamily:
                                          GoogleFonts.play().fontFamily),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  documentData['location'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily:
                                          GoogleFonts.play().fontFamily),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.currency_rupee,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  documentData['wage'],
                                  style: TextStyle(
                                      color: Color.fromARGB(230, 7, 211, 38),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      fontFamily:
                                          GoogleFonts.play().fontFamily),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                            bottom: 20,
                            right: 0,
                            child: OutlinedButton(
                                key: Key("${index.toString()}_button_user"),
                                onPressed: () {
                                  Map<String, dynamic> docInfo = {
                                    "dataReference": docId,
                                    "vendor": documentData['referencePath'],
                                  };
                                  Navigator.pushNamed(
                                      context, "job_review_page",
                                      arguments: docInfo);
                                },
                                child: Text(
                                  'Details',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary),
                                )))
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: 15,
                );
              },
              itemCount: documentList.length,
            ),
          );
        } else {
          return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SvgPicture.asset(
              "assets/images/vector/ship_wrek.svg",
              width: 300,
              height: 300,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "No active jobs found!",
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.blackHanSans().fontFamily),
            )
          ]);
        }
      },
    );
  }

  Widget getMyJobs() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('applications')
          .where('jobPostedBy',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(ApiFunctions.user!.uid))
          .where('status', isEqualTo: 'accepted')
          .where('log', isNotEqualTo: 'canceled')
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          // get application data
          List<DocumentSnapshot<Map<String, dynamic>>> documents =
              snapshot.data!.docs;
          return ListView.separated(
            itemBuilder: (BuildContext context, int index) {
              // single snapshot of application data
              var currentDoc = documents[index];
              return StreamBuilder<Map<String, dynamic>>(
                  stream: VendorCommonFn().streamUserData(
                      uidParam: FirebaseFirestore.instance
                          .collection('users')
                          .doc(documents[index]['applicant_id'])),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else {
                      // /get applicant data
                      //
                      Map<String, dynamic> postedUser =
                          snapshot.data as Map<String, dynamic>;
                      //
                      //
                      return StreamBuilder<Map<String, dynamic>>(
                          stream: VendorCommonFn().streamDocumentsData(
                              colectionId: 'job_posts',
                              uidParam: documents[index]['jobId']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else {
                              Map<String, dynamic> jobData =
                                  snapshot.data as Map<String, dynamic>;
                              logger.f(jobData);
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color:
                                            Color.fromARGB(43, 158, 158, 158)),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    boxShadow: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? [] // Empty list for no shadow in dark theme
                                        : [
                                            BoxShadow(
                                              color:
                                                  Color.fromARGB(38, 67, 65, 65)
                                                      .withOpacity(0.5),
                                              blurRadius: 20,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          UtilityFunctions.convertToSenenceCase(
                                            jobData['jobTitle'],
                                          ),
                                        ),
                                        trailing: Text(
                                            '${currentDoc['bid_amount']} / day'),
                                        titleTextStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondary),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 0,
                                            bottom: 10),
                                        child: Divider(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('Applicant'),
                                            Row(
                                              children: [
                                                AvatarOfUser(
                                                  imageLink:
                                                      postedUser['image'],
                                                  width: 25,
                                                  height: 25,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(postedUser['name']),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('Accepted on'),
                                            Text(UtilityFunctions()
                                                .convertTimestampToDateString(
                                                    currentDoc['acceptedOn']))
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text('Completion'),
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      50, // Adjust the size of the circular progress indicator as needed
                                                  height:
                                                      50, // Adjust the size of the circular progress indicator as needed
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: double.tryParse(
                                                            currentDoc[
                                                                'completion'])! /
                                                        100, // Value normalized to be between 0.0 and 1.0
                                                    strokeWidth:
                                                        4, // Adjust the stroke width as needed
                                                    backgroundColor: Colors
                                                            .grey[
                                                        300], // Adjust the background color as needed
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors
                                                          .blue, // Adjust the progress color as needed
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${currentDoc['completion']}%',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GFButton(
                                              onPressed: () async {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .dangerous_sharp,
                                                              size: 30,
                                                              color:
                                                                  Colors.amber,
                                                            ),
                                                            Text("Warning"),
                                                          ],
                                                        ),
                                                        SizedBox(height: 20),
                                                        Text(
                                                            "Are you sure you want to cancel? This action can't be undone."),
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          // Add functionality for the "Cancel" button here
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'applications')
                                                              .doc(documents[
                                                                      index]
                                                                  .id)
                                                              .update({
                                                            'canceledOn':
                                                                DateTime.now(),
                                                            'log': 'canceled'
                                                          });
                                                        },
                                                        child: Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              shape: GFButtonShape.pills,
                                              color: Colors.red,
                                              text: 'Cancel',
                                            ),
                                            SizedBox(
                                              width: 15,
                                            ),
                                            GFButton(
                                              onPressed: () {
                                                // var startDate =
                                                //     currentDoc['acceptedOn']
                                                //         .toDate();
                                                // var endDate = DateTime.now();

                                                // var differenceInDays = endDate
                                                //     .difference(startDate)
                                                //     .inDays;
                                                // var amountTopay =
                                                //     differenceInDays *
                                                //         int.parse(currentDoc[
                                                //             'bid_amount']);
                                                makePayment(
                                                    'vendor',
                                                    currentDoc['bid_amount'],
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(currentDoc[
                                                            'jobId']),
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(ApiFunctions
                                                            .user!.uid),
                                                    FirebaseFirestore.instance
                                                        .collection('users')
                                                        .doc(documents[index]
                                                            ['applicant_id']),
                                                    'Job posts');
                                              },
                                              shape: GFButtonShape.pills,
                                              color: Colors.blue,
                                              text: 'Pay user',
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                          });
                    }
                  });
            },
            itemCount: documents.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 15);
            },
          );
        }
      },
    );
  }

  // payments
  Future<void> makePayment(
      String recipientName,
      String amount,
      DocumentReference jobId,
      DocumentReference payedBy,
      DocumentReference payedTo,
      payType) async {
    try {
      setState(() {
        isPaymentClicked = true;
      });
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
      displayPaymentSheet(amount, jobId, payedBy, payedTo, payType);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(String amount, DocumentReference jobId,
      DocumentReference payedBy, DocumentReference payedTo, payType) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
// successful payment then update database
        try {
          PaymentModal payModal = PaymentModal(
              amountPaid: amount,
              jobId: jobId,
              payedBy: payedBy,
              payedTo: payedTo,
              paymentTime: DateTime.now(),
              payedFor: 'Premium service',
              applicationRevenue:
                  calculateApplicationRevenue(double.tryParse(amount))
                      .toString());

          Map<String, dynamic> paymentData = payModal.toJson();
          _firestore.collection('payments').add(paymentData).then((value) {
            DocumentReference paymentId =
                _firestore.collection('payments').doc(value.id);
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
          }).catchError((error) {
            // Handle any errors that occur when adding a document to the "payments" collection
            print('Error adding document to payments collection: $error');
          });
        } catch (e) {
          logger.e(e);
        }

        _firestore.collection('users').doc(payedBy.id).update({
          'subscription': {'last_payment': DateTime.now(), 'type': payType}
        });

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
        setState(() {
          isPaymentClicked = false;
        });
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      setState(() {
        isPaymentClicked = false;
      });
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

  double? calculateApplicationRevenue(double? amount) {
    return amount! / 3;
  }
}
