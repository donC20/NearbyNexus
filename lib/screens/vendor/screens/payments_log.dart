// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
import 'package:NearbyNexus/components/pdf_api.dart';
import 'package:NearbyNexus/components/pdf_drawer.dart';
import 'package:NearbyNexus/components/user_circle_avatar.dart';
import 'package:NearbyNexus/models/invoice_model.dart';
import 'package:NearbyNexus/screens/user/components/vendor_review_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentVendorLogScreen extends StatefulWidget {
  const PaymentVendorLogScreen({super.key});

  @override
  State<PaymentVendorLogScreen> createState() => _PaymentVendorLogScreenState();
}

class _PaymentVendorLogScreenState extends State<PaymentVendorLogScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String imageLink = "https://icons8.com/icon/tZuAOUGm9AuS/user-default";
  String nameLoginned = "";
  bool isimageFetched = false;
  String uid = '';

  Color unselectedColor = Colors.blueGrey;
  Color selectedColor = Colors.black;
  var logger = Logger();
  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');

    setState(() {
      uid = initData['uid'];
    });
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        imageLink = fetchedData['image'] ??
            "https://firebasestorage.googleapis.com/v0/b/nearbynexus1.appspot.com/o/profile_images%2Ficons8-user-default-96.png?alt=media&token=0ffd4c8b-fc40-4f19-a457-1ef1e0ba6ae5";
        nameLoginned = fetchedData['name'];
        isimageFetched = false;
      });
    }
  }

  Future<Map<String, dynamic>> fetchAllPaymentData(
      DocumentReference jobId, DocumentReference payBy) async {
    DocumentSnapshot jobSnapshot = await jobId.get();
    DocumentSnapshot payBySnapshot = await payBy.get();
    Map<String, dynamic> jobDetails =
        jobSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> userDetails =
        payBySnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> data = {
      'userName': userDetails['name'],
      'userImage': userDetails['image'],
      'serviceName': jobDetails['service_name'],
    };
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "Payment logs",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: StreamBuilder(
          stream: _firestore.collection('users').doc(uid).snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                Map<String, dynamic>? vendorData =
                    snapshot.data?.data() as Map<String, dynamic>?;

                if (vendorData != null &&
                    vendorData.containsKey('paymentLogs')) {
                  List<dynamic> paymentList = vendorData['paymentLogs'];

                  return ListView.separated(
                    itemCount: paymentList.length,
                    itemBuilder: (context, index) {
                      String userId = paymentList[index].id;

                      return StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('payments')
                            .doc(userId)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.active) {
                            if (userSnapshot.hasData) {
                              Map<String, dynamic>? payData = userSnapshot.data
                                  ?.data() as Map<String, dynamic>?;
                              return FutureBuilder<Map<String, dynamic>>(
                                future: fetchAllPaymentData(
                                    payData?['jobId'], payData?['payedBy']),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Map<String, dynamic>>
                                        dataSnapshot) {
                                  if (dataSnapshot.connectionState ==
                                      ConnectionState.done) {
                                    Map<String, dynamic> data =
                                        dataSnapshot.data!;
                                    Timestamp time = payData?['paymentTime'];

                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                          boxShadow: Theme.of(context)
                                                      .brightness ==
                                                  Brightness.dark
                                              ? []
                                              : [
                                                  BoxShadow(
                                                    offset:
                                                        const Offset(12, 26),
                                                    blurRadius: 50,
                                                    spreadRadius: 0,
                                                    color: Colors.grey
                                                        .withOpacity(.1),
                                                  ),
                                                ],
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline),
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: ExpansionTile(
                                        childrenPadding:
                                            const EdgeInsets.all(15.0),
                                        leading: UserLoadingAvatar(
                                            userImage: data['userImage']),
                                        title: Text(
                                          data['serviceName'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(data['userName']),
                                        trailing: Text(
                                          "\u20B9${payData?['amountPaid']}",
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 21, 169, 26),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        children: [
                                          Column(
                                            children: [
                                              Divider(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                              ),
                                              detailsOfJob("Payed for",
                                                  data['serviceName']),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              detailsOfJob(
                                                  "Payed by", data['userName']),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              detailsOfJob("Payed on",
                                                  timeStampConverter(time)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              detailsOfJob(
                                                  "Payment id", userId),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton.icon(
                                                    icon: Icon(
                                                      Icons.print,
                                                      color: Colors.white,
                                                    ),
                                                    onPressed: () async {
                                                      try {
                                                        final invoice = Invoice(
                                                            userName: data[
                                                                'userName'],
                                                            vendorName:
                                                                vendorData[
                                                                    'name'],
                                                            invoiceId: userId,
                                                            jobName: data[
                                                                'serviceName'],
                                                            payDate:
                                                                timeStampConverter(
                                                                    time),
                                                            amount: payData?[
                                                                'amountPaid'],
                                                            description: '');
                                                        final pdfFile =
                                                            await PdfDrawer
                                                                .generate(
                                                                    invoice);

                                                        PdfApi.openFile(
                                                            pdfFile);
                                                      } catch (e) {
                                                        logger.e(e);
                                                      }
                                                    },
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(Colors
                                                                  .blue), // Set button color to green
                                                      shape: MaterialStateProperty
                                                          .all<OutlinedBorder>(
                                                        StadiumBorder(), // Use stadium border
                                                      ),
                                                    ),
                                                    label: Text("Invoice",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              );
                            }
                          }
                          return SizedBox();
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: Colors.grey,
                      );
                    },
                  );
                }
              }
            }

            return Center(
              child: Text(
                "You have no payment history",
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}

Widget detailsOfJob(String title, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      Text(
        value,
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    ],
  );
}
