// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class CreateJobPost extends StatefulWidget {
  const CreateJobPost({super.key});

  @override
  State<CreateJobPost> createState() => _CreateJobPostState();
}

class _CreateJobPostState extends State<CreateJobPost> {
  // controllers
  final titleController = TextEditingController();
  final budgetController = TextEditingController();

  //lists
  List list = [
    "Flutter",
    "React",
    "Ionic",
    "Xamarin",
  ];

  //Date time
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Functions

  // date picking
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // time picking
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1014),
      body: ListView(
        children: [
          Image.asset('assets/images/post_job_banner.png'),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              child: Column(
                children: [
                  // Title input field
                  customInput(
                      title: "Job title",
                      hintText: "What's your job title",
                      prefixIcon: Icons.title,
                      controller: titleController,
                      textInputType: TextInputType.name),
                  // Budget input field
                  customInput(
                      title: "Budget",
                      hintText: "What's your job budget?",
                      prefixIcon: Icons.currency_rupee,
                      controller: budgetController,
                      textInputType: TextInputType.number),
                  // Skills input field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Skills required",
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      GFSearchBar(
                        padding: EdgeInsets.all(0),
                        searchList: list,
                        searchQueryBuilder: (query, list) {
                          return list
                              .where((item) => item
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                              .toList();
                        },
                        overlaySearchListItemBuilder: (item) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item,
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        },
                        onItemSelected: (item) {
                          setState(() {
                            print('$item');
                          });
                        },
                        searchBoxInputDecoration: InputDecoration(
                          hintText: 'Skills required for this job ?',
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                          filled: true,
                          fillColor: Color(0xFF1E1E1E),
                          contentPadding: EdgeInsets.all(16),
                          prefixIcon: Icon(
                            Icons.search,
                            color: const Color.fromARGB(115, 255, 255, 255),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Date time input field
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Date Picker
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Date: ${selectedDate.toLocal()}'
                                      .split(' ')[0],
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),

                      // Time Picker
                      InkWell(
                        onTap: () => _selectTime(context),
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Selected Time: ${selectedTime.format(context)}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                  // Desc input field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          maxLines: null, // Set to null for multiline input
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter job description.',
                            hintStyle:
                                TextStyle(color: Colors.white24, fontSize: 14),
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget customInput(
    {required String title,
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    required TextInputType textInputType}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
      SizedBox(
        height: 5,
      ),
      Container(
        height: 55,
        decoration: BoxDecoration(
            color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
        child: TextField(
          controller: controller,
          keyboardType: textInputType,
          decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon,
                  color: const Color.fromARGB(115, 255, 255, 255)),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
              border: InputBorder.none),
        ),
      ),
      SizedBox(
        height: 15,
      ),
    ],
  );
}
