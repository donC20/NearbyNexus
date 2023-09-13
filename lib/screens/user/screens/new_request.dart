// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names, library_private_types_in_public_api, use_key_in_widget_constructors, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewServiceRequest extends StatefulWidget {
  @override
  _NewServiceRequestState createState() => _NewServiceRequestState();
}

class _NewServiceRequestState extends State<NewServiceRequest> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? service_name;
  String? description;
  String? service_level;
  String? location;
  DateTime? day;
  int? wage;
  final _aboutController = TextEditingController();
  int maxLetters = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Service Request'),
        backgroundColor: Colors.black, // Set a dark app bar background color
      ),
      backgroundColor: Colors.black, // Set a dark background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              headings("What service do you need?",
                  "Provide the service that you need. Be specific about the service name this will help providers to review the request."),
              TextFormField(
                maxLength: maxLetters,
                maxLines: null,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Service name',
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
                onSaved: (value) => service_name = value,
              ),
              headings("Describe your need.",
                  "Describe your project in detail so the the providers can understand your project."),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Describe your need',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  hintText: 'E',
                  hintStyle: TextStyle(
                      color: const Color.fromARGB(134, 255, 255, 255),
                      fontSize: 12),
                  // Display remaining character count
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
                maxLines: null, // Allow multiple lines for description
                keyboardType: TextInputType.multiline,
                controller: _aboutController,
              ),
              headings("Choose the level of need.",
                  "This will help the providers to understand the urgency of the service."),
              Theme(
                data: ThemeData.dark(), // Set dark theme for the dropdown
                child: DropdownButtonFormField<String>(
                  value: service_level,
                  decoration: InputDecoration(
                    labelText: 'Choose the service level',
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),

                    // Display remaining character count
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
                  items: <String>['Very urgent', 'Urgent', 'Normal']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      service_level = value;
                    });
                  },
                ),
              ),
              headings("Location", "Provide the place where to be serviced."),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Provide location',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),

                  // Display remaining character count
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
                onSaved: (value) => location = value,
              ),
              headings("Day & Time", "Date that the service is expected"),
              Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Color.fromARGB(74, 158, 158, 158)),
                ),
                child: ListTile(
                  title: Text(
                    day == null
                        ? 'Select Day'
                        : '${day.toString().substring(0, 16)}',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          day = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ),
              headings("Budget", "What is the proposed wage of this project"),
              TextFormField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefix: Icon(Icons.currency_rupee, color: Colors.white),
                  labelText: 'Provide budget',
                  labelStyle: TextStyle(color: Colors.white, fontSize: 12),

                  // Display remaining character count
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
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  wage = int.tryParse(value ?? '');
                },
              ),
              SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Now, you can submit the form data to your backend or process it as needed.
                    // Remember to handle date and wage conversions.
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Set text color to white
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }
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
