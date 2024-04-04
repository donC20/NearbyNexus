// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:convert';

import 'package:NearbyNexus/functions/utiliity_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:NearbyNexus/functions/api_functions.dart';

class FilterContainer extends StatefulWidget {
  final Function(int filtecount) filterCount;
  const FilterContainer({required this.filterCount});
  @override
  _FilterContainerState createState() => _FilterContainerState();
}

class _FilterContainerState extends State<FilterContainer> {
  bool fixedCostSelected = false;
  bool hourlyCostSelected = false;
  List list = [
    "Flutter",
    "React",
    "Ionic",
    "Xamarin",
  ];
  var logger = Logger();
  List<dynamic> selectedSkillList = [];
  final minValueController = TextEditingController();
  final maxValueController = TextEditingController();

  @override
  void initState() {
    initFilterList();
    super.initState();
  }

  Map<String, dynamic> filterListFromSharedPref = {};
  void initFilterList() async {
    final data =
        await UtilityFunctions().fetchFromSharedPreference('filterList');

    Map<String, dynamic>? filterData;
    filterData = json.decode(data);
    logger.f('frommshare pref $filterData');
    if (filterData != null) {
      setState(() {
        minValueController.text = filterData!['minValue'].toString();
        maxValueController.text = filterData['maxValue'].toString();
        selectedSkillList = List<dynamic>.from(filterData['skillList']);
      });
      if (filterData['minValue'].toString().isNotEmpty &&
          filterData['maxValue'].toString().isNotEmpty) {
        setState(() {
          fixedCostSelected = true;
        });
      }
      // Get minValue, maxValue, and skillList from the parsedData map
      String minValue = filterData['minValue'].toString();
      String maxValue = filterData['maxValue'].toString();
      List<dynamic> skillList = List<dynamic>.from(filterData['skillList']);

      logger.f('minValue: $minValue');
      logger.f('maxValue: $maxValue');
      logger.f('skillList: $skillList');
    } else {
      logger.e('frommshare pref has no data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.0),
      child: ListView(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list_alt),
                  Text(
                    "Filter",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              Row(
                children: [
                  GFButton(
                    onPressed: () async {
                      Map<String, dynamic> filterList = {
                        'skillList': selectedSkillList,
                        'minValue': minValueController.text,
                        'maxValue': maxValueController.text,
                      };
                      final SharedPreferences sharedpreferences =
                          await SharedPreferences.getInstance();
                      sharedpreferences.setString(
                          "filterList", json.encode(filterList));
                      Navigator.pop(context);
                      // Calculate the count of enabled filters
                      int filterCount = 0;
                      if (fixedCostSelected) filterCount += 1;
                      if (hourlyCostSelected) filterCount += 1;
                      // Add the count of selected skills
                      filterCount += selectedSkillList.length;
                      // Pass the filter count to the callback function
                      widget.filterCount(filterCount);
                    },
                    type: GFButtonType.outline,
                    text: 'Done',
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GFButton(
                    onPressed: () async {
                      await UtilityFunctions()
                          .deleteFromSharedPreferences('filterList');
                      Navigator.pop(context);
                      widget.filterCount(0);
                    },
                    type: GFButtonType.outline,
                    color: Colors.red,
                    text: 'Clear',
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            'Project Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Checkbox(
                value: fixedCostSelected,
                onChanged: (bool? value) {
                  setState(() {
                    fixedCostSelected = value ?? false;
                    hourlyCostSelected = false;
                  });
                },
              ),
              Text('Daily Cost'),
            ],
          ),
          if (fixedCostSelected || hourlyCostSelected) ...[
            SizedBox(height: 16.0),
            Text(
              'Enter Daily Cost Range',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: minValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Min Value',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: maxValueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Max Value',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          SizedBox(height: 16.0),
          Text(
            'Search Skills',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
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
                    final skills = await ApiFunctions.fetchSkillsList(query);
                    return skills
                        .where((item) =>
                            item.toLowerCase().contains(query.toLowerCase()))
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
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
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
                          style: TextStyle(color: Colors.white), // Text color
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
                        backgroundColor: const Color.fromARGB(
                            255, 59, 59, 59), // Background color of the chip
                        shape: StadiumBorder(), // Stadium-shaped border
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
