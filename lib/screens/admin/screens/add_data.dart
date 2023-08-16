// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../vendor/screens/registration_vendor_two.dart';
import '../component/appBarActionItems.dart';
import '../component/header.dart';
import '../component/sideMenu.dart';
import '../config/responsive.dart';
import '../style/colors.dart';

class DataEntry extends StatefulWidget {
  const DataEntry({super.key});

  @override
  State<DataEntry> createState() => DataEntryState();
}

class DataEntryState extends State<DataEntry> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  // ?----------------------------Snack bar (Reusable)------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawer: const SizedBox(width: 100, child: SideMenu()),
      appBar: !Responsive.isDesktop(context)
          ? AppBar(
              elevation: 0,
              backgroundColor: AppColors.white,
              leading: IconButton(
                  onPressed: () {
                    _drawerKey.currentState!.openDrawer();
                  },
                  icon: const Icon(Icons.menu, color: AppColors.black)),
              actions: const [
                AppBarActionItems(),
              ],
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SideMenu(),
              ),
            Expanded(
              flex: 10,
              child: SafeArea(
                child: DefaultTabController(
                  length: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(
                          pageTitle: 'Data Entry',
                          subText:
                              'Add and modfiy different services\nto the application',
                        ),
                        // add services formatted
                        Expanded(
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 25,
                                ),
                                const TabBar(
                                  labelColor:
                                      Color.fromARGB(255, 118, 115, 115),
                                  tabs: [
                                    Tab(text: 'Add services'),
                                    Tab(text: 'All services'),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      const AddServices(),
                                      _buildTab2Content(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddServices extends StatefulWidget {
  const AddServices({super.key});

  @override
  State<AddServices> createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices> {
  final serviceController = TextEditingController();
  List<String>? newServices = [];
  bool isTextFieldEmpty = true;
  bool textHind = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(),
            const Text(
              "You can add services from here make sure you add relevant services.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Provide new service name.",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 65,
                  child: TextFormField(
                    controller: serviceController,
                    onChanged: (value) {
                      setState(() {
                        isTextFieldEmpty = value.isEmpty;
                      });
                    },
                    style: GoogleFonts.poppins(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: 'Name the service',
                      contentPadding:
                          const EdgeInsets.only(left: 25, bottom: 35),
                      hintStyle:
                          const TextStyle(color: Colors.grey, fontSize: 14),
                      labelStyle: const TextStyle(
                          color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromARGB(166, 158, 158, 158),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffix: IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: isTextFieldEmpty == false
                            ? () {
                                setState(() {
                                  newServices?.add(serviceController.text);
                                  serviceController.clear();
                                  isTextFieldEmpty = true;
                                });
                              }
                            : null,
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "You left this field empty!";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            const Text(
              "Tap to remove items from the collection",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 5,
                children: newServices!.map((item) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        newServices!.remove(item);
                      });
                    },
                    child: Chip(
                      elevation: 1,
                      side: const BorderSide(
                        color: Colors.grey,
                      ),
                      label: Text(
                        convertToSentenceCase(item),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 143, 143, 143),
                        ),
                      ),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 130,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      DocumentReference documentRef = FirebaseFirestore.instance
                          .collection('services')
                          .doc('service_list');

                      await documentRef.update({
                        'service': FieldValue.arrayUnion(newServices!),
                      });

                      // Clear the text field
                      serviceController.clear();
                      showSnackbar("Services updated successfully!",
                          const Color.fromARGB(255, 9, 237, 25), context);
                      setState(() {
                        newServices!.clear();
                      });
                    } catch (e) {
                      showSnackbar(e.toString(),
                          const Color.fromARGB(255, 175, 76, 76), context);
                    }
                  },
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text("Update"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTab2Content() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance
        .collection('services')
        .doc('service_list')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      final data = snapshot.data!.data() as Map<String, dynamic>;
      if (data == null || !data.containsKey('service')) {
        return const Center(
          child: Text("No services found!"),
        );
      }

      final services = List<String>.from(data['service']);

      return ListView.separated(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final serviceName = services[index];

          return InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(serviceName),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          color: Color.fromARGB(150, 158, 158, 158),
        ),
      );
    },
  );
}

void showSnackbar(String message, Color backgroundColor, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

  // ?----------------------------Snack bar (ends)------------------------------------