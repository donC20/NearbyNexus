// ignore_for_file: unnecessary_to_list_in_spreads, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/models/payment_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String selectedBox = 'free';
  String currentPlan = 'free';
  bool isChecked = false;
  bool isPaymentClicked = false;
  String uid = '';
  String? formattedTimeAgo;
  var logger = Logger();
  Map<String, dynamic>? paymentIntent;
  final List<String> paymentLogs = [];
  List<Map<String, dynamic>> infoOnFreeSub = [
    {
      'icon': Icons.check_circle,
      'text': 'Apply for 2 jobs / month',
    },
    {
      'icon': Icons.close,
      'text': 'Restriction in direct chat',
    },
    {
      'icon': Icons.check_circle,
      'text': 'One Service allowed',
    },
    {
      'icon': Icons.close,
      'text': 'Contact info disabled',
    },
  ];

  List<Map<String, dynamic>> infoOnPlatinumSub = [
    {
      'icon': Icons.check_circle,
      'text': 'Apply for 10 jobs / month',
    },
    {
      'icon': Icons.check_circle,
      'text': 'One time direct chat',
    },
    {
      'icon': Icons.check_circle,
      'text': 'Upto 5 services allowed',
    },
    {
      'icon': Icons.close,
      'text': 'Contact info disabled',
    },
  ];
  List<Map<String, dynamic>> infoOnGoldSub = [
    {
      'icon': Icons.check_circle,
      'text': 'Unlimited jobs requests.',
    },
    {
      'icon': Icons.check_circle,
      'text': 'Enabled direct chat',
    },
    {
      'icon': Icons.check_circle,
      'text': 'Upto 5 services',
    },
    {
      'icon': Icons.check_circle_sharp,
      'text': 'Contact info enabled',
    },
  ];

// payments
  Future<void> makePayment(
      String recipientName,
      String amount,
      DocumentReference jobId,
      DocumentReference payedBy,
      DocumentReference payedTo) async {
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
      displayPaymentSheet(amount, jobId, payedBy, payedTo);
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(String amount, DocumentReference jobId,
      DocumentReference payedBy, DocumentReference payedTo) async {
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
              payedFor: 'Premium service');

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Text(
                    "Upgrade to Premium",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      priceContainer(
                          '0',
                          'Free',
                          '',
                          'Free of cost',
                          Colors.white,
                          Colors.transparent,
                          'free',
                          Colors.black),
                      SizedBox(
                        width: 15,
                      ),
                      priceContainer(
                          '499.0',
                          'Premium',
                          'Platinum',
                          'Billed monthly',
                          Color(0xFF2E71DA),
                          Colors.transparent,
                          'premium_platinum',
                          Colors.white),
                      SizedBox(
                        width: 15,
                      ),
                      priceContainer(
                          '1999.0',
                          'Premium',
                          'Gold',
                          'Billed Yearly',
                          Color(0xFFD2AF26),
                          Colors.transparent,
                          'premium_gold',
                          Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget priceContainer(price, planType, subPlan, pricedOn, backgroundColor,
      borderColor, selected, baseColor) {
    return Container(
      width: MediaQuery.of(context).size.width - 80,
      constraints: BoxConstraints(minHeight: 450),
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '$planType\n',
                        style: TextStyle(
                            color: baseColor, fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: subPlan ?? '',
                        style: TextStyle(
                            color: baseColor,
                            fontSize: 25,
                            fontWeight: FontWeight.w900)),
                  ])),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Icon(
                    Icons.currency_rupee_sharp,
                    color: baseColor,
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: '$price',
                        style: TextStyle(
                            fontSize: 30,
                            color: baseColor,
                            fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '/ month',
                        style: TextStyle(
                            color: baseColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal)),
                  ])),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              selected == 'free'
                  ? offerPallete(infoOnFreeSub, baseColor, selected)
                  : selected == 'premium_platinum'
                      ? offerPallete(infoOnPlatinumSub, baseColor, selected)
                      : offerPallete(infoOnGoldSub, baseColor, selected),
              SizedBox(
                height: 15,
              ),
              currentPlan != selected
                  ? InkWell(
                      splashColor: const Color.fromARGB(143, 255, 255, 255),
                      onTap: () async {
                        await makePayment(
                            'Robert',
                            '499',
                            _firestore
                                .collection('users')
                                .doc(ApiFunctions.user!.uid),
                            _firestore
                                .collection('users')
                                .doc(ApiFunctions.user!.uid),
                            _firestore
                                .collection('users')
                                .doc(ApiFunctions.user!.uid));
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: baseColor),
                            color: Colors.transparent),
                        child: Column(
                          children: [
                            Text(
                              'CHOOSE THIS PLAN',      
                              style: TextStyle(
                                  fontSize: 12,
                                  color: baseColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.currency_rupee_sharp,
                                  size: 18,
                                  color: baseColor,
                                ),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: '$price',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: baseColor,
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: '/ month',
                                      style: TextStyle(
                                          color: baseColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal)),
                                ])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          currentPlan == selected
              ? Row(
                  children: [
                    Icon(
                      Icons.verified_sharp,
                      size: 20,
                      color: baseColor,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Current plan',
                      style: TextStyle(
                          color: baseColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget offerPallete(List<Map<String, dynamic>> info, baseColor, boxtype) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color.fromARGB(43, 158, 158, 158),
        border: Border.all(color: const Color.fromARGB(143, 255, 255, 255)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '${boxtype == 'free' ? 'Free' : boxtype == 'premium_platinum' ? 'Platinum' : 'Gold'} subscription includes,',
              style: TextStyle(
                  color: baseColor, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ...info.map((item) {
            return SizedBox(
              height: 30,
              child: Row(
                children: [
                  Icon(
                    item['icon'],
                    color: baseColor,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    item['text'],
                    style: TextStyle(color: baseColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
