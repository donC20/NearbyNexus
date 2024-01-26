// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_element, sized_box_for_whitespace

import 'dart:convert';

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/models/job_post_model.dart';
import 'package:NearbyNexus/screens/vendor/components/bottom_sheet_quill.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateJobPost extends StatefulWidget {
  const CreateJobPost({super.key});

  @override
  State<CreateJobPost> createState() => _CreateJobPostState();
}

class _CreateJobPostState extends State<CreateJobPost> {
// Firebase
  late final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _jobPostCollection;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;

  // init
  @override
  void initState() {
    super.initState();
    initUser();
    _firestore = FirebaseFirestore.instance;
    _jobPostCollection = _firestore.collection('job_posts');
    _usersCollection = _firestore.collection('users');
  }

  // controllers
  final titleController = TextEditingController();
  final budgetController = TextEditingController();
  final _locationController = TextEditingController();
  final descriptionController = TextEditingController();

  // formkeys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // variables
  // bool
  bool prefferedLocationAll = true;
  bool isLocationFetchingList = false;
  bool isListEmpty = false;
  bool isFormSubmitting = false;

  // String
  String selectedName = "";
  String inputValue = "";
  String? uid = "";
  // others
  var logger = Logger();

  //lists
  List list = [
    "Flutter",
    "React",
    "Ionic",
    "Xamarin",
  ];
  List<dynamic> selectedSkillList = [];
  List prefferedLocations = ["All"];
  List<Map<String, dynamic>> resultList = [];

  //Date time
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // Functions

  // user init
  void initUser() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');
    setState(() {
      uid = initData['uid'];
    });
  }

  // date picking
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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

  // search places //
  void handleInputChange(String value) {
    setState(() {
      inputValue = value;
      isLocationFetchingList = true;
    });

    ApiFunctions().searchPlaces(value).then((result) {
      setState(() {
        isLocationFetchingList = false;
        resultList = result;
        isListEmpty = resultList.isEmpty;
      });
    }).catchError((error) {
      setState(() {
        isLocationFetchingList = false;
      });
      print('Error searching places: $error');
    });
  }

  void broadcastPost(
    jobTitle,
    jobDescription,
    expiryDate,
    expiryTime,
    budget,
    jobPostedBy,
    skills,
    preferredLocation,
  ) async {
    setState(() {
      isFormSubmitting = true;
    });

    // Convert expiryTime to a string if not null
    String formattedExpiryTime =
        expiryTime != null ? expiryTime.toString() : '';

    // Validate and convert budget to double
    double parsedBudget = double.tryParse(budget) ?? 0.0;

    // job post model
    JobPostModel jobPostData = JobPostModel(
      jobTitle: jobTitle,
      jobDescription: jobDescription,
      expiryDate: expiryDate,
      expiryTime: formattedExpiryTime,
      budget: parsedBudget,
      jobPostedBy: jobPostedBy,
      skills: skills,
      preferredLocation: preferredLocation,
    );

    // firebase actions
    await _jobPostCollection.add(jobPostData.toJson()).then((_) {
      // Data added successfully, set isFormSubmitting to false
      setState(() {
        isFormSubmitting = false;
        Navigator.pushReplacementNamed(context, "/success_screen", arguments: {
          "content": "Congrats 🎉, \nYour post is published.",
          "navigation": "/view_my_posts"
        });
      });
    }).catchError((error) {
      // Handle the error if needed
      print("Error adding data to Firebase: $error");
      setState(() {
        isFormSubmitting = false;
      });
    });
  }

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
              key: _formKey,
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
                      title: "Budget (in months)",
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
                          return ListTile(
                            trailing: selectedSkillList.contains(item)
                                ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : SizedBox(),
                            title: Text(
                              item,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 0, 0, 0)),
                            ),
                          );
                        },
                        onItemSelected: (item) {
                          setState(() {
                            selectedSkillList.contains(item)
                                ? selectedSkillList.remove(item)
                                : selectedSkillList.add(item);
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
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  // Preffered location
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                              text: TextSpan(
                                  text: "Preffered location - ",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white54),
                                  children: [
                                TextSpan(
                                    text:
                                        prefferedLocationAll ? "All" : "Custom",
                                    style: TextStyle(color: Colors.red))
                              ])),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GFToggle(
                                onChanged: (val) {
                                  setState(() {
                                    prefferedLocationAll = val!;
                                    if (prefferedLocationAll &&
                                        !prefferedLocations.contains('All')) {
                                      prefferedLocations.clear();
                                      prefferedLocations.add("All");
                                    } else if (prefferedLocations
                                            .contains('All') &&
                                        !prefferedLocationAll) {
                                      prefferedLocations.remove('All');
                                    }
                                  });
                                },
                                value: true,
                                enabledTrackColor: Colors.blueAccent,
                                enabledThumbColor: Colors.amber,
                                type: GFToggleType.ios,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      !prefferedLocationAll
                          ? Container(
                              height: 55,
                              decoration: BoxDecoration(
                                  color: Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextField(
                                controller: _locationController,
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.poppins(
                                  color:
                                      const Color.fromARGB(255, 226, 223, 223),
                                ),
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.location_pin,
                                      color: Colors.white54),
                                  suffixIcon:
                                      _locationController.text.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(
                                                Icons.clear,
                                                color: Colors.white54,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _locationController.clear();
                                                  resultList.clear();
                                                  isListEmpty = false;
                                                  selectedName = "";
                                                });
                                              },
                                            )
                                          : Icon(
                                              Icons.my_location_sharp,
                                              color: Colors.white54,
                                            ),
                                  hintStyle: TextStyle(color: Colors.white38),
                                  hintText: 'Eg : California',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) => handleInputChange(value),
                              ),
                            )
                          : SizedBox(),
                      !prefferedLocationAll
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: isLocationFetchingList == false
                                  ? isListEmpty
                                      ? Center(
                                          child: Text(
                                            "Sorry, Location not found",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 227, 8, 8)),
                                          ),
                                        )
                                      : LayoutBuilder(
                                          builder: (BuildContext context,
                                              BoxConstraints constraints) {
                                            double containerHeight =
                                                resultList.length * 90.0;
                                            containerHeight =
                                                containerHeight.clamp(0, 170);
                                            return Container(
                                              height: containerHeight,
                                              decoration: BoxDecoration(
                                                color: Color.fromARGB(
                                                    138, 53, 52, 52),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: ListView.separated(
                                                itemCount: resultList.length,
                                                itemBuilder: (context, index) {
                                                  String name =
                                                      resultList[index]
                                                              ["name"] ??
                                                          resultList[index]
                                                              ["formatted"] ??
                                                          "";
                                                  String country =
                                                      resultList[index]
                                                              ["country"] ??
                                                          "";
                                                  String state =
                                                      resultList[index]
                                                              ["state"] ??
                                                          resultList[index]
                                                              ["suburb"] ??
                                                          "";
                                                  String county =
                                                      resultList[index]
                                                              ["county"] ??
                                                          resultList[index]
                                                              ["postcode"] ??
                                                          resultList[index]
                                                              ["state_code"] ??
                                                          "";
                                                  return ListTile(
                                                    title: Text(
                                                      name,
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white60),
                                                    ),
                                                    subtitle: Text(
                                                        "$state, $county, $country",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white60)),
                                                    onTap: () {
                                                      setState(() {});
                                                      selectedName = resultList[
                                                              index]["name"] ??
                                                          resultList[index]
                                                              ["formatted"] ??
                                                          "";
                                                      // _locationController.text =
                                                      //     selectedName;
                                                      setState(() {
                                                        prefferedLocations
                                                                .contains(
                                                                    selectedName)
                                                            ? prefferedLocations
                                                                .remove(
                                                                    selectedName)
                                                            : prefferedLocations
                                                                .add(
                                                                    selectedName);
                                                        resultList.clear();
                                                      });
                                                      // Handle the selection logic here
                                                    },
                                                  );
                                                },
                                                separatorBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  return Divider(
                                                    color: Color.fromARGB(
                                                        48, 189, 189, 189),
                                                    thickness: 1.0,
                                                    indent: 0,
                                                    endIndent: 0,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        )
                                  : Center(
                                      child: LoadingAnimationWidget
                                          .horizontalRotatingDots(
                                              color: Colors.white, size: 20),
                                    ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  // Date time input field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expiry date",
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                                  color:
                                      const Color.fromARGB(115, 255, 255, 255),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  // Time Picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expiry time",
                        style: TextStyle(color: Colors.white54),
                      ),
                      SizedBox(
                        height: 5,
                      ),
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
                                  color:
                                      const Color.fromARGB(115, 255, 255, 255),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  // Desc input field
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       "Description",
                  //       style: TextStyle(color: Colors.white54),
                  //     ),
                  //     SizedBox(
                  //       height: 5,
                  //     ),
                  //     Container(
                  //       height: 150,
                  //       decoration: BoxDecoration(
                  //         color: Color(0xFF1E1E1E),
                  //         borderRadius: BorderRadius.circular(20),
                  //       ),
                  //       child: TextFormField(
                  //         maxLines: null, // Set to null for multiline input
                  //         keyboardType: TextInputType.multiline,
                  //         controller: descriptionController,
                  //         style: TextStyle(color: Colors.white),
                  //         decoration: InputDecoration(
                  //           hintText: 'Enter job description.',
                  //           hintStyle:
                  //               TextStyle(color: Colors.white24, fontSize: 14),
                  //           contentPadding: EdgeInsets.all(16),
                  //           border: InputBorder.none,
                  //         ),
                  //         validator: (value) {
                  //           if (value!.isEmpty) {
                  //             return "You left this field empty!";
                  //           }
                  //           return null;
                  //         },
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       height: 10,
                  //     ),
                  //   ],
                  // ),
                  // button
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 5.0, right: 5.0, bottom: 5.0, top: 10),
                    child: GFButton(
                      onPressed: () {
                        // Navigator.pushNamed(context, "/quill_page");
                        showModalBottomSheet(
                          context: context,
                          enableDrag: false,
                          useSafeArea: true,
                          isDismissible: false,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return JobDescriptionEditor();
                          },
                        );
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      text: "Add description",
                      shape: GFButtonShape.pills,
                      fullWidthButton: true,
                      size: GFSize.LARGE,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(10),
                    width: MediaQuery.sizeOf(context).width - 10,
                    height: 50,
                    child: AspectRatio(
                      aspectRatio: 208 / 71,
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              offset: Offset(0, 4),
                              color: Color(0xFF4960F9).withOpacity(.2),
                              spreadRadius: 4,
                              blurRadius: 50)
                        ]),
                        child: MaterialButton(
                          onPressed: isFormSubmitting
                              ? null
                              : () {
                                  if (selectedSkillList.isEmpty ||
                                      prefferedLocations.isEmpty) {
                                    SnackBar snackBar = UtilityFunctions()
                                        .snackBarOpener(
                                            "Missing Fields",
                                            "Some of the fields are empty!",
                                            ContentType.failure,
                                            Colors.red,
                                            SnackBarBehavior.floating);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    if (_formKey.currentState!.validate()) {
                                      broadcastPost(
                                          titleController.text,
                                          descriptionController.text,
                                          selectedDate,
                                          selectedTime,
                                          budgetController.text,
                                          _usersCollection.doc(uid),
                                          selectedSkillList,
                                          prefferedLocations);
                                    } else {
                                      SnackBar snackBar = UtilityFunctions()
                                          .snackBarOpener(
                                              "Missing Fields",
                                              "Some of the fields are empty!",
                                              ContentType.failure,
                                              Colors.red,
                                              SnackBarBehavior.floating);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  }
                                },
                          splashColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(36)),
                          padding: const EdgeInsets.all(0.0),
                          child: Ink(
                              decoration: BoxDecoration(
                                //gradient:
                                image: DecorationImage(
                                  image: NetworkImage(
                                      "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/finance_app_2%2FbuttonBackgroundSmall.png?alt=media&token=fa2f9bba-120a-4a94-8bc2-f3adc2b58a73"),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 88.0,
                                      minHeight:
                                          36.0), // min sizes for Material buttons
                                  alignment: Alignment.center,
                                  child: isFormSubmitting
                                      ? SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.emergency_share_rounded,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Broadcast',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w300)),
                                          ],
                                        ))),
                        ),
                      ),
                    ),
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
        child: TextFormField(
          controller: controller,
          keyboardType: textInputType,
          style: TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
              prefixIcon: Icon(prefixIcon,
                  color: const Color.fromARGB(115, 255, 255, 255)),
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
              border: InputBorder.none),
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
    ],
  );
}
