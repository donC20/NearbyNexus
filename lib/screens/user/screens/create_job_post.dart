// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, unused_element, sized_box_for_whitespace, must_be_immutable

import 'dart:convert';

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:NearbyNexus/models/job_post_model.dart';
import 'package:NearbyNexus/providers/common_provider.dart';
import 'package:NearbyNexus/screens/common_screens/gmaps.dart';
import 'package:NearbyNexus/screens/vendor/components/bottom_sheet_quill.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateJobPost extends StatefulWidget {
  String openedFor;
  CreateJobPost({super.key, this.openedFor = 'create'});

  @override
  State<CreateJobPost> createState() => _CreateJobPostState();
}

class _CreateJobPostState extends State<CreateJobPost> {
// Firebase
  late final FirebaseFirestore _firestore;
  late final CollectionReference<Map<String, dynamic>> _jobPostCollection;
  late final CollectionReference<Map<String, dynamic>> _usersCollection;
  TextEditingController searchController = TextEditingController();
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
  dynamic prefferedLocations;
  List<Map<String, dynamic>> resultList = [];
  Map<String, dynamic> updateData = {};
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

  void broadcastPost(jobTitle, jobDescription, expiryDate, expiryTime, budget,
      jobPostedBy, skills, preferredLocation,
      {jobId = ''}) async {
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

    if (widget.openedFor == 'update') {
      // Assuming you have the document ID to update stored in some variable, let's call it jobIdToUpdate
      String jobIdToUpdate =
          jobId; // Replace 'your_document_id' with the actual document ID

      // Create a reference to the document to update
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('job_posts').doc(jobIdToUpdate);
      // Convert job post data to JSON
      Map<String, dynamic> updatedData = jobPostData.toJson();

      // Update the document in Firestore
      await docRef.update(updatedData).then((value) async {
        setState(() {
          isFormSubmitting = false;
          Navigator.pushReplacementNamed(context, "/success_screen",
              arguments: {
                "content": "Congrats 🎉, \nYour post is updated.",
                "navigation": "/view_my_job_post"
              });
        });
      }).catchError((error) {
        // Handle the error if needed
        print("Error updating data in Firebase: $error");
        setState(() {
          isFormSubmitting = false;
        });
      });
    } else {
      await _jobPostCollection.add(jobPostData.toJson()).then((value) async {
        // Get the document ID of the newly added document
        String newDocumentId = value.id;

        // Update app_config document with the new document ID
        await FirebaseFirestore.instance
            .collection('app_config')
            .doc('notifications')
            .update({
          'new_jobs': FieldValue.arrayUnion([newDocumentId])
        });

        setState(() {
          isFormSubmitting = false;
          Navigator.pushReplacementNamed(context, "/success_screen",
              arguments: {
                "content": "Congrats 🎉, \nYour post is published.",
                "navigation": "/view_my_job_post"
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
  }

  // Define a callback function to update the state

  LatLng locationFromMap = LatLng(0.0, 0.0);
  void updateLocation(locationSelected) {
    setState(() {
      locationFromMap = locationSelected;
      prefferedLocations = locationSelected.toString();
      UtilityFunctions()
          .showSnackbar("Location selected", Colors.green, context);
    }); // Trigger UI update
  }

  @override
  Widget build(BuildContext context) {
    final commonProvider = Provider.of<CommonProvider>(context);
    // logger.f("This is the location $prefferedLocations");
    if (widget.openedFor == 'update') {
      setState(() {
        updateData =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        // logger.e(updateData);
        titleController.text = updateData['jobData']['jobTitle'];
        budgetController.text = updateData['jobData']['budget'].toString();
        selectedSkillList = updateData['jobData']['skills'];
        selectedDate = updateData['jobData']['expiryDate'].toDate();
      });
    }

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
                      title: "Budget (per day)",
                      hintText: "What's your job budget?",
                      prefixIcon: Icons.currency_rupee,
                      controller: budgetController,
                      textInputType: TextInputType.number),
                  // Skills input field
                  // SizedBox(
                  //   height: 100,
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: [
                  //       Padding(
                  //         padding: EdgeInsets.all(8.0),
                  //         child: TextField(
                  //           controller: searchController,
                  //           onChanged: (value) async {
                  //             list = await ApiFunctions.fetchSkillsList(value);
                  //             logger.f(list);
                  //           },
                  //           decoration: InputDecoration(
                  //             hintText: 'Search for skills...',
                  //             hintStyle: TextStyle(color: Colors.white),
                  //             border: OutlineInputBorder(),
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: Card(
                  //           margin: EdgeInsets.all(8.0),
                  //           child: ListView.builder(
                  //             itemCount: list.length,
                  //             itemBuilder: (context, index) {
                  //               return ListTile(
                  //                 title: Text(list[index]),
                  //               );
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                        searchQueryBuilder: (query, list) async {
                          try {
                            final skills =
                                await ApiFunctions.fetchSkillsList(query);
                            return skills
                                .where((item) => item
                                    .toLowerCase()
                                    .contains(query.toLowerCase()))
                                .toList();
                          } catch (error) {
                            print('Error fetching skills: $error');
                            return []; // Return an empty list if there's an error
                          }
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
                      Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width - 10,
                        child: Wrap(
                          spacing: 8.0, // Spacing between chips
                          runSpacing: 4.0, // Spacing between lines of chips
                          children: selectedSkillList.map((e) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSkillList.remove(e);
                                });
                              },
                              child: Chip(
                                label: Text(
                                  e,
                                  style: TextStyle(
                                      color: Colors.white), // Text color
                                ),
                                padding: EdgeInsets.all(2),
                                deleteIcon: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    selectedSkillList.remove(e);
                                  });
                                },
                                backgroundColor: const Color.fromARGB(255, 59,
                                    59, 59), // Background color of the chip
                                shape: StadiumBorder(), // Stadium-shaped border
                              ),
                            );
                          }).toList(),
                        ),
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
                                    text: prefferedLocationAll
                                        ? "Remote / WFH"
                                        : "Custom",
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
                                        prefferedLocations != 'Remote/WFH') {
                                      prefferedLocations = "Remote/WFH";
                                    } else if (prefferedLocations ==
                                            'Remote/WFH' &&
                                        !prefferedLocationAll) {
                                      prefferedLocations = '';
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
                          ? Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: locationFromMap.latitude
                                              .isGreaterThan(0) &&
                                          locationFromMap.longitude
                                              .isGreaterThan(0)
                                      ? GFButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Gmaps(
                                                          updateLocation:
                                                              updateLocation,
                                                        )));
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/icons/svg/mapsIcon.svg',
                                            height: 30,
                                          ),
                                          text: "Change location",
                                          textStyle: TextStyle(fontSize: 12),
                                          size: GFSize.LARGE,
                                          fullWidthButton: true,
                                          shape: GFButtonShape.pills,
                                          color:
                                              Color.fromARGB(255, 0, 94, 157),
                                        )
                                      : GFButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Gmaps(
                                                          updateLocation:
                                                              updateLocation,
                                                        )));
                                          },
                                          icon: SvgPicture.asset(
                                            'assets/icons/svg/mapsIcon.svg',
                                            height: 30,
                                          ),
                                          text: "Choose from maps",
                                          textStyle: TextStyle(fontSize: 12),
                                          size: GFSize.LARGE,
                                          fullWidthButton: true,
                                          shape: GFButtonShape.pills,
                                          color: Color(0xFF1E1E1E),
                                        ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
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
                                Icon(
                                  Icons.calendar_today,
                                  color:
                                      const Color.fromARGB(115, 255, 255, 255),
                                ),
                                Text(
                                  'Selected Date: ${UtilityFunctions().formatDate(selectedDate)}',
                                  style: TextStyle(color: Colors.white),
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

                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, bottom: 5.0, top: 10),
                    child: widget.openedFor == 'update'
                        ? GFButton(
                            onPressed: () async {
                              // Navigator.pushNamed(context, "/quill_page");
                              await UtilityFunctions.updateSharedPreference(
                                  'descriptionController',
                                  updateData['jobData']['jobDescription']);
                              logger.e(
                                  'html value is ${updateData['jobData']['jobDescription']}');
                              showModalBottomSheet(
                                context: context,
                                enableDrag: false,
                                useSafeArea: true,
                                isDismissible: false,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return JobDescriptionEditor(
                                    isOpenforEdit: true,
                                  );
                                },
                              );
                            },
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            text: "Edit Description",
                            shape: GFButtonShape.pills,
                            fullWidthButton: true,
                            size: GFSize.LARGE,
                            color: Colors.green,
                          )
                        : commonProvider.isDescriptionAdded
                            ? GFButton(
                                onPressed: () {
                                  // Navigator.pushNamed(context, "/quill_page");
                                  showModalBottomSheet(
                                    context: context,
                                    enableDrag: false,
                                    useSafeArea: true,
                                    isDismissible: false,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return JobDescriptionEditor(
                                        isOpenforEdit: true,
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                text: "Edit Description",
                                shape: GFButtonShape.pills,
                                fullWidthButton: true,
                                size: GFSize.LARGE,
                                color: Colors.green,
                              )
                            : GFButton(
                                onPressed: () {
                                  // Navigator.pushNamed(context, "/quill_page");
                                  showModalBottomSheet(
                                    context: context,
                                    enableDrag: false,
                                    useSafeArea: true,
                                    isDismissible: false,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return JobDescriptionEditor(
                                        isOpenforEdit: false,
                                      );
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
                              : () async {
                                  if (selectedSkillList.isEmpty ||
                                      prefferedLocations == "") {
                                    SnackBar snackBar = UtilityFunctions()
                                        .snackBarOpener(
                                            "Missing Fields - skill list",
                                            "Some of the fields are empty!",
                                            ContentType.failure,
                                            Colors.red,
                                            SnackBarBehavior.floating);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    if (_formKey.currentState!.validate()) {
                                      String description =
                                          await UtilityFunctions()
                                              .fetchFromSharedPreference(
                                                  "descriptionController");

                                      if (widget.openedFor == 'update') {
                                        broadcastPost(
                                            titleController.text,
                                            description,
                                            selectedDate,
                                            selectedTime,
                                            budgetController.text,
                                            _usersCollection.doc(uid),
                                            selectedSkillList,
                                            prefferedLocations,
                                            jobId: updateData['jobData']
                                                ['documentId']);
                                      } else {
                                        broadcastPost(
                                          titleController.text,
                                          description,
                                          selectedDate,
                                          selectedTime,
                                          budgetController.text,
                                          _usersCollection.doc(uid),
                                          selectedSkillList,
                                          prefferedLocations,
                                        );
                                      }
                                      // remove the data after successfull insertion
                                      UtilityFunctions()
                                          .deleteFromSharedPreferences(
                                              "descriptionController");
                                      // set the button back
                                      commonProvider
                                          .changeDescriptionBtnState(false);
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
                                              widget.openedFor == 'update'
                                                  ? Icons.edit
                                                  : Icons
                                                      .emergency_share_rounded,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                                widget.openedFor == 'update'
                                                    ? 'Update'
                                                    : 'Broadcast',
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
