// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSheetVendor extends StatefulWidget {
  final String fieldName;
  const BottomSheetVendor({
    super.key,
    required this.fieldName,
  });

  @override
  _BottomSheetVendorState createState() => _BottomSheetVendorState();
}

class _BottomSheetVendorState extends State<BottomSheetVendor> {
  List<dynamic> serviceList = [];
  String? uid = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
    initUser();
  }

  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
    getTheVendor(uid);
  }

  Future<void> getTheVendor(uid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> vendorData =
            snapshot.data() as Map<String, dynamic>;
        setState(() {
          serviceList = vendorData[widget.fieldName];
        });
      }
    });
  }

  Future<void> removeService(String service) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        widget.fieldName: FieldValue.arrayRemove([service])
      });
    } catch (e) {
      print('Error removing service: $e');
    }
  }

  Future<void> confirmAndRemoveService(String service) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Removal"),
          content:
              Text("Are you sure you want to remove this ${widget.fieldName}?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Remove"),
              onPressed: () async {
                await removeService(service);
                setState(() {
                  serviceList.remove(service);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: serviceList.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fieldName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(
                  color: Theme.of(context).colorScheme.surface,
                ),
                SizedBox(height: 10),
                Column(
                  children: serviceList.map((item) {
                    return Wrap(
                      spacing: 5,
                      runSpacing: 2,
                      alignment: WrapAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                            confirmAndRemoveService(item);
                          },
                          child: Chip(
                            elevation: 1,
                            side: BorderSide(
                              color: Colors.grey,
                            ),
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors
                                        .red, // Change this to your desired button color
                                  ),
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors
                                        .white, // Change this to your desired icon color
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            )
          : Text(
              "No services added yet. Add your ${widget.fieldName}.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
    );
  }
}
