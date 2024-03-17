// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

bool _isChecked = false;
String selectedBox = 'free';

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            priceContainer('0', 'Free', 'Free of cost',
                                Colors.white, Colors.transparent, 'free'),
                            SizedBox(
                              width: 15,
                            ),
                            priceContainer(
                                '499.0',
                                'Premium',
                                'Billed monthly',
                                Color(0xFFD2AF26),
                                Colors.transparent,
                                'premium_monthly'),
                            SizedBox(
                              width: 15,
                            ),
                            priceContainer(
                                '1999.0',
                                'Premium',
                                'Billed Yearly',
                                Color(0xFFD2AF26),
                                Colors.transparent,
                                'premium_yearly'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // price desc
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  width: MediaQuery.sizeOf(context).width - 10,
                  decoration: BoxDecoration(
                      color: Color.fromARGB(43, 158, 158, 158),
                      border: Border.all(
                          color: const Color.fromARGB(143, 255, 255, 255)),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.check_circle,
                          color: Colors.white,
                        ),
                        title: Text(
                          '2 job requests / month',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.close_outlined,
                          color: Colors.white,
                        ),
                        title: Text(
                          'Direct chat',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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

  Widget priceContainer(
      price, planType, pricedOn, backgroundColor, borderColor, selected) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedBox = selected;
        });
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width / 2,
        height: 190,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(15),
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
                    Text(
                      planType,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.black,
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.currency_rupee_sharp,
                      color: Colors.black,
                    ),
                    Text(
                      price,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              pricedOn,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
