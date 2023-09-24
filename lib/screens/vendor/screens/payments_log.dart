// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:NearbyNexus/components/bottom_g_nav.dart';
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
    var initData = json.decode(userLoginData!);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: _firestore.collection('users').doc(uid).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              Map<String, dynamic>? vendorData =
                  snapshot.data?.data() as Map<String, dynamic>?;

              if (vendorData != null && vendorData.containsKey('paymentLogs')) {
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

                            return SizedBox();
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
      bottomNavigationBar: BottomGNav(
        activePage: 3,
        isSelectable: false,
      ),
    );
  }
}
