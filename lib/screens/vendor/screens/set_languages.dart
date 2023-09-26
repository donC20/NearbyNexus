// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetSpeakLanguages extends StatefulWidget {
  const SetSpeakLanguages({super.key});

  @override
  State<SetSpeakLanguages> createState() => _SetSpeakLanguagesState();
}

class _SetSpeakLanguagesState extends State<SetSpeakLanguages> {
  var logger = Logger();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> resultList = [];
  List<dynamic> searchList = [];
  List<dynamic> selectedList = [];

  String uid = '';
  bool isFetchingList = true;

  bool isLoading = false;

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
    var initData = json.decode(userLoginData!);
    setState(() {
      uid = initData['uid'];
    });
    initLang(uid);
    fetchLanguages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> fetchLanguages() async {
    setState(() {
      isFetchingList = true;
    });
    const apiKey = '6451cd2838mshaa799c052193673p158fa6jsn14d05424a21d';

    final headers = {
      'X-RapidAPI-Host': 'aibit-translator.p.rapidapi.com',
      'X-RapidAPI-Key': apiKey,
    };

    final uri = Uri.https(
      'aibit-translator.p.rapidapi.com',
      '/api/v1/translator/support-languages',
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      for (var item in data) {
        final language = item["language"];
        setState(() {
          resultList.add(language);
          searchList = resultList;
          isFetchingList = false;
        });
      }
      logger.d(resultList);
    } else {
      // Handle errors here.
      logger.d('Error: ${response.statusCode}');
    }
  }

  // search

  void filterLanguages(String query) {
    setState(() {
      if (query.isNotEmpty) {
        setState(() {
          searchList = resultList
              .where((language) =>
                  language.toLowerCase().contains(query.toLowerCase()))
              .toList();
        });
      } else {
        setState(() {
          searchList = resultList;
        });
      }
    });
  }

  bool isSelected(String language) {
    return selectedList.contains(language);
  }

  void toggleSelection(String language) {
    setState(() {
      if (isSelected(language)) {
        selectedList.remove(language);
      } else {
        selectedList.add(language);
      }
    });
  }

  Future<void> initLang(uid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> vendorData =
            snapshot.data() as Map<String, dynamic>;
        setState(() {
          selectedList = vendorData['languages'];
        });
      }
    });
    logger.d(selectedList);
  }

  Future<void> updateLang(lists) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'languages': lists});
      setState(() {
        isLoading = false;
        selectedList.clear();
      });
    } catch (e) {
      logger.d('Error removing service: $e');
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
              "Choose your languages",
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            SizedBox(
              height: 55,
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: _searchController,
                style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 238, 238, 238)),
                decoration: InputDecoration(
                  hintText: "Search your relevant languages",
                  hintStyle: const TextStyle(
                      fontSize: 14, color: Color.fromARGB(114, 255, 255, 255)),
                  contentPadding: const EdgeInsets.only(left: 25, bottom: 35),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(74, 158, 158, 158),
                    ),
                  ),
                  suffixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: (value) {
                  filterLanguages(value);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: isFetchingList
                    ? Center(
                        child: LoadingAnimationWidget.waveDots(
                            color: Colors.white, size: 50),
                      )
                    : searchList.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/vector/curiosity.svg",
                                width: 300,
                                height: 300,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Sorry, ${_searchController.text} not found!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Expanded(
                            child: ListView.separated(
                              itemCount: searchList.length,
                              itemBuilder: (context, index) {
                                final language = searchList[index];
                                final firstLetter = language[0].toUpperCase() +
                                    language[1].toLowerCase();
                                final containerColor = isSelected(language)
                                    ? Colors.green
                                    : getRandomColor();
                                final bodyColor = isSelected(language)
                                    ? Color.fromARGB(40, 161, 250, 255)
                                    : Colors.black;

                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                      color: bodyColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: containerColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50)),
                                      ),
                                      child: isSelected(language)
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 30,
                                            )
                                          : Center(
                                              child: Text(
                                                firstLetter,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                    title: Text(
                                      language,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios_outlined,
                                      color: const Color.fromARGB(
                                          135, 255, 255, 255),
                                      size: 14,
                                    ),
                                    onTap: () {
                                      toggleSelection(language);
                                    },
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider(
                                  color:
                                      const Color.fromARGB(92, 158, 158, 158),
                                );
                              },
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(right: 25, bottom: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle, // You can adjust the shape as needed
              ),
              child: IconButton(
                onPressed: selectedList.isEmpty
                    ? null
                    : isLoading
                        ? null
                        : () {
                            setState(() {
                              isLoading = true;
                            });
                            updateLang(selectedList);
                          },
                icon: isLoading == true
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: const Color.fromARGB(255, 0, 0, 0), size: 20)
                    : Icon(
                        Icons.arrow_right_alt,
                        color: Colors.black,
                      ),
              ),
            ),
          ],
        ),
      ),
      
    );
  }
}

Color getRandomColor() {
  final Random random = Random();
  Color color;
  do {
    color = Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  } while (color == Colors.black);
  return color;
}
