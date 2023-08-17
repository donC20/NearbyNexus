// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../component/appBarActionItems.dart';
import '../component/header.dart';
import '../component/sideMenu.dart';
import '../config/responsive.dart';
import '../style/colors.dart';

class ListUsers extends StatefulWidget {
  const ListUsers({super.key});

  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  bool isDataFound = false;

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
                  length: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Header(
                          pageTitle: 'Manage Members',
                          subText:
                              'Manage the users and change their\nusability.',
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // Search bar
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 90,
                              child: TextField(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      const Color.fromARGB(255, 229, 226, 226),
                                  contentPadding: const EdgeInsets.only(
                                      left: 40.0, right: 5),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: AppColors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: const BorderSide(
                                        color: AppColors.white),
                                  ),
                                  prefixIcon: const Icon(Icons.search,
                                      color: AppColors.black),
                                  hintText: 'Search',
                                  hintStyle: const TextStyle(
                                      color: AppColors.secondary, fontSize: 14),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.filter_list)),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // Tab bar screens
                        TabBar(
                          onTap: (index) {
                            if (index == 0) {
                            } else if (index == 1) {
                            } else if (index == 2) {}
                          },
                          labelColor: const Color.fromARGB(255, 118, 115, 115),
                          tabs: [
                            const Tab(text: 'All'),
                            const Tab(text: 'Users'),
                            const Tab(text: 'Vendors'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildTab1Content(),
                              _buildTab2Content(),
                              _buildTab3Content(),
                            ],
                          ),
                        ),
                        // populate users
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

// ?User tile model

// ignore: must_be_immutable
class UserTile extends StatelessWidget {
  String name;
  String email;
  String imgUrl;
  String status;
  UserTile(
      {super.key,
      required this.name,
      required this.email,
      required this.imgUrl,
      required this.status});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 60,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(imgUrl), // Replace with the actual image URL
          ),
          title: Text(name),
          subtitle: Text(email),
          trailing: Container(
            width: 60,
            height: 30,
            decoration: BoxDecoration(
                color: status == "active" ? Colors.green[200] : Colors.red[200],
                borderRadius: BorderRadius.circular(25)),
            child: Align(
              alignment: Alignment.center,
              child: Text(convertToSentenceCase(status),
                  style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        ));
  }
}

// ?string convertot
String convertToSentenceCase(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

// ?model box
void _showModal(BuildContext context, String uid) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            // padding: const EdgeInsets.all(16.0),
            width: MediaQuery.sizeOf(context).width, // Custom width
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('Document does not exist.');
                  }
                  // Data is ready
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  var name = userData['name'] ?? '';
                  var email = userData['emailId'] ?? '';
                  var location = userData['geoLocation'] ?? '';
                  var imageUrl = userData['image'] ?? '';
                  var phone = userData['phone']?.toString() ?? '';
                  var status = userData['status'] ?? '';
                  return Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Positioned(
                              top: 0,
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 76, 76, 209),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 50,
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      imageUrl), // Replace with the actual image URL
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              color: Color.fromARGB(255, 116, 118, 120),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(24, 4, 24, 0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            ModalTextTiles(
                              titleIcon: Icons.email_outlined,
                              attribute: email,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ModalTextTiles(
                              titleIcon: Icons.location_on_outlined,
                              attribute: location,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ModalTextTiles(
                              titleIcon: Icons.call_outlined,
                              attribute: phone,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            ModalTextTiles(
                              titleIcon: Icons.flag_circle_outlined,
                              attribute: status,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            status == 'active'
                                ? SizedBox(
                                    width: 130,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Confirm Banning"),
                                              content: const Text(
                                                "This action will ban the user completely from the application. Do you want to continue?",
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'users') // Replace 'users' with your desired collection name
                                                        .doc(uid)
                                                        .update({
                                                      'status': 'disabled',
                                                    }).then((_) {
                                                      print(
                                                          "Document status updated successfully");
                                                    }).catchError((error) {
                                                      print(
                                                          "Error updating document status: $error");
                                                    });

                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Continue"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            // ignore: prefer_const_constructors
                                            Color.fromARGB(0, 241, 35, 3),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.not_interested,
                                            color: Colors.red,
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            "Ban",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 130,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Confirm Unbanning"),
                                              content: const Text(
                                                "This actio will unban user from banning. Do you want to continue?",
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: const Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    FirebaseFirestore.instance
                                                        .collection(
                                                            'users') // Replace 'users' with your desired collection name
                                                        .doc(uid)
                                                        .update({
                                                      'status': 'active',
                                                    }).then((_) {
                                                      print(
                                                          "Document status updated successfully");
                                                    }).catchError((error) {
                                                      print(
                                                          "Error updating document status: $error");
                                                    });

                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("Continue"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            // ignore: prefer_const_constructors
                                            Color.fromARGB(0, 241, 35, 3),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.done,
                                            color: Color.fromARGB(
                                                255, 67, 244, 54),
                                          ),
                                          SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            "Unban",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 67, 244, 54),
                                                fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ),
      ));
    },
  );
}
// ?modal box text tiles

class ModalTextTiles extends StatelessWidget {
  IconData titleIcon;
  String attribute;
  ModalTextTiles({super.key, required this.titleIcon, required this.attribute});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(titleIcon),
        Text(
          attribute,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF57636C),
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ! Firebase fetching all users
Widget _buildTab1Content() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .where('userType', isNotEqualTo: 'admin')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      final users = snapshot.data!.docs; // List of QueryDocumentSnapshot

      if (users.isEmpty) {
        return const Center(
          child: Text("No users found!"),
        );
      }

      return ListView.separated(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index].data() as Map<String, dynamic>;
          final documentId = users[index].id;

          return InkWell(
            onTap: () {
              _showModal(context, documentId);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserTile(
                name: user['name'],
                email: user['emailId'],
                imgUrl: user['image'],
                status: user['status'],
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

// ! Firebase fetching all normal users
Widget _buildTab2Content() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'general_user')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      // Data is ready
      final users = snapshot.data!.docs; // List of QueryDocumentSnapshot
      if (users.isEmpty) {
        return const Center(
          child: Text("No users found!"),
        );
      }

      return ListView.separated(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index].data() as Map<String, dynamic>;
          final documentId = users[index].id;

          return InkWell(
            onTap: () {
              _showModal(context, documentId);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserTile(
                name: user['name'],
                email: user['emailId'],
                imgUrl: user['image'],
                status: user['status'],
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

// ! Firebase fetching all vendors
Widget _buildTab3Content() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'vendor')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      // Data is ready
      final users = snapshot.data!.docs; // List of QueryDocumentSnapshot
      if (users.isEmpty) {
        return const Center(
          child: Text("No users found!"),
        );
      }

      return ListView.separated(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index].data() as Map<String, dynamic>;
          final documentId = users[index].id;

          return InkWell(
            onTap: () {
              _showModal(context, documentId);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: UserTile(
                name: user['name'],
                email: user['emailId'],
                imgUrl: user['image'],
                status: user['status'],
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
