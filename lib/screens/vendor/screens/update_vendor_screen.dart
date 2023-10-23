// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new, avoid_print, sort_child_properties_last

import 'dart:convert';

import 'package:NearbyNexus/screens/vendor/components/bottom_sheet_services.dart';
import 'package:NearbyNexus/screens/vendor/components/days_mapper.dart';
import 'package:NearbyNexus/screens/vendor/components/search_services_screen.dart';
import 'package:NearbyNexus/screens/vendor/screens/set_languages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class UpdateVendorScreen extends StatefulWidget {
  const UpdateVendorScreen({super.key});

  @override
  State<UpdateVendorScreen> createState() => _UpdateVendorScreenState();
}

class _UpdateVendorScreenState extends State<UpdateVendorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _aboutController = TextEditingController();

  int maxLetters = 300;
  String uid = '';
  String aboutold = '';
  List<DateTime> selectedDates = [];
  DateTime _selectedDay = DateTime.now();
  var logger = Logger();
  // ////
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 0), () {
    //   setState(() {
    //     uid = Provider.of<UserProvider>(context, listen: false).uid!;
    //   });
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

    DocumentSnapshot userSnapshotData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userSnapshotData.exists) {
      Map<String, dynamic> userData =
          userSnapshotData.data() as Map<String, dynamic>;
      List<dynamic> rawData = userData['unavailableDays'];
      List<Timestamp> selectedTimestamps = [];

      selectedTimestamps = rawData.cast<Timestamp>();

      setState(() {
        for (var timestamp in selectedTimestamps) {
          DateTime date = timestamp.toDate();
          selectedDates.add(date);
        }
      });
      logger.e(selectedDates);
    }
  }

  Future<void> updateAbout(text) async {
    if (_aboutController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'about': text});
        _aboutController.clear();
      } catch (e) {
        print('Error removing service: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: MediaQuery.sizeOf(context).width,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10),
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.green
                ], // Adjust gradient colors as needed
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: Text(
              "Update profile",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              headings("About",
                  "Feel free to share details about your years of experience, your industry background. You can also discuss your accomplishments or past work experiences."),
              SizedBox(
                child: TextFormField(
                  controller: _aboutController,
                  maxLength: maxLetters,
                  maxLines: null,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tell us more about you',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                    counterText: "${_aboutController.text.length}/$maxLetters",
                    counterStyle: TextStyle(
                      color: Colors.white,
                    ), // Display remaining character count
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(74, 158, 158, 158),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(74, 158, 158, 158),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    // _formKey.currentState!.validate();
                  },
                  // validator: (value) {
                  //   if (value!.isEmpty) {
                  //     return "You left this field empty!";
                  //   }
                  //   return null;
                  // },
                ),
              ),
              headings("What you do?",
                  "Choose the services that are you really good at. This will help others to find you easily"),
              InkWell(
                onTap: () {
                  _openBottomSheet(context);
                },
                child: ListTile(
                  shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                  title: Text(
                    "Manage services",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                    backgroundColor: Colors.black,
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      return SearchScreenServices();
                    },
                  );
                },
                child: ListTile(
                  shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                  title: Text(
                    "Add more services",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              headings("Mark your unavailable days.",
                  "Mark out your unavailable days"),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.utc(2040, 10, 20),
                focusedDay: _selectedDay == '' ? DateTime.now() : _selectedDay,
                selectedDayPredicate: (day) {
                  // Check if this day is in the selected dates
                  return selectedDates
                      .any((selectedDate) => isSameDay(selectedDate, day));
                },
                daysOfWeekHeight: 25,
                headerVisible: true,
                daysOfWeekVisible: true,
                sixWeekMonthsEnforced: true,
                shouldFillViewport: false,
                headerStyle: HeaderStyle(
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: Colors.grey,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(87, 255, 255, 255),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  weekNumberTextStyle: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 8, 0, 255)),
                  disabledTextStyle:
                      const TextStyle(color: Color.fromARGB(66, 255, 255, 255)),
                  todayTextStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(
                        255, 235, 34, 8), // Adjust this color for visibility
                  ),
                  defaultTextStyle: TextStyle(
                    color: const Color.fromARGB(
                        255, 255, 255, 255), // Adjust this color for visibility
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.red, // Adjust this color for visibility
                  ),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  if (!selectedDates.contains(selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      selectedDates.add(selectedDay);
                    });
                  } else {
                    setState(() {
                      selectedDates.remove(selectedDay);
                    });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Selected Dates'),
                        // Use a column with mainAxisSize.min
                        content: selectedDates.isEmpty
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Card(
                                    child: Center(
                                      child: Text(
                                        "You have't selected any dates.",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Use a container with a fixed width
                                  SizedBox(
                                    height: 300,
                                    width: double.maxFinite,
                                    child: ListView(
                                      // Set shrinkWrap to true
                                      shrinkWrap: true,
                                      children: selectedDates.map((date) {
                                        // Wrap each item with a Dismissible widget
                                        return Dismissible(
                                          key: ValueKey(date),
                                          // Provide a background widget
                                          background: Container(
                                            color: Colors.red,
                                            alignment: Alignment.centerLeft,
                                            child: Icon(Icons.delete,
                                                color: Colors.white),
                                          ),
                                          // Provide an onDismissed callback
                                          onDismissed: (direction) {
                                            setState(() {
                                              selectedDates.remove(date);
                                            });
                                          },
                                          child: Card(
                                            color: Colors.green,
                                            child: ListTile(
                                              leading: Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.white),
                                              title: Text(
                                                "${date.day}-${date.month}-${date.year}",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                        actions: <Widget>[
                          selectedDates.isNotEmpty
                              ? ElevatedButton(
                                  child: Text('Update'),
                                  onPressed: () async {
                                    try {
                                      // Check if the document with uid exists
                                      DocumentSnapshot userSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(uid)
                                              .get();

                                      if (userSnapshot.exists) {
                                        // Attempt to update data
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(uid)
                                            .update({
                                          'unavailableDays': selectedDates
                                        });

                                        print(selectedDates);
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.white,
                                            content: Text(
                                              'Dates Saved',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ),
                                        );
                                      } else {
                                        print(
                                            'User document with uid $uid does not exist');
                                      }
                                    } catch (e) {
                                      print('Error: $e');
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.white,
                                          content: Text(
                                            'Failed to save dates. :)',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                )
                              : SizedBox(),
                          ElevatedButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                        // Use some properties to style the dialog
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 10.0,
                      );
                    },
                  );
                },
                child: Text('Save Selected Dates'),
              ),
              headings("Choose your working days.",
                  "This helps users to contact you on the days you specified. Provide the days you are available for services."),
              DaysMapper(),
              headings("Languages",
                  "This help us to connect right people at right place."),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                    backgroundColor: Colors.black,
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      return SetSpeakLanguages();
                    },
                  );
                },
                child: ListTile(
                  shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                  title: Text(
                    "Add more languages",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                    backgroundColor: Color.fromARGB(255, 32, 26, 47),
                    context: context,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      return BottomSheetVendor(
                        fieldName: "languages",
                      );
                    },
                  );
                },
                child: ListTile(
                  shape: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                  title: Text(
                    "Manage languages",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 14),
                  ),
                  trailing: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 30, bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                updateAbout(_aboutController.text);
              },
              child: Text("Update"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue), // Change the background color
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                  EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12), // Adjust padding
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(20.0), // Round the corners
                  ),
                ),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(
                    fontSize: 18, // Adjust the font size
                    fontWeight: FontWeight.bold, // Apply bold font weight
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// bottom bar
void _openBottomSheet(BuildContext context) {
  showModalBottomSheet<void>(
    backgroundColor: Color.fromARGB(255, 32, 26, 47),
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return BottomSheetVendor(
        fieldName: "services",
      );
    },
  );
}

Widget headings(String heading, String subheading) {
  return Column(
    children: [
      SizedBox(
        height: 15,
      ),
      RichText(
        textAlign: TextAlign.start,
        text: TextSpan(children: [
          TextSpan(
            text: "$heading\n",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          WidgetSpan(
              child: Divider(
            color: const Color.fromARGB(134, 158, 158, 158),
          )),
          TextSpan(
            text: subheading,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(151, 255, 255, 255),
            ),
          ),
        ]),
      ),
      SizedBox(
        height: 15,
      ),
    ],
  );
}

// Widget bottomNav(Function updateAbout) {
//   return ;
// }
