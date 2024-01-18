// ignore_for_file: avoid_print, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, sort_child_properties_last

import 'dart:typed_data';

import 'package:NearbyNexus/screens/vendor/components/stage_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:azblob/azblob.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KYCScreen extends StatefulWidget {
  @override
  _KYCScreenState createState() => _KYCScreenState();
}

class _KYCScreenState extends State<KYCScreen> {
  bool isPredicting = false;
  String name = "";
  String gender = "";
  String dob = "";
  String id_number = "";
  String status = '';
  File? pickedImage;
  File? finalCroppedImage;
  String type = '';
  String api_ip = '0.0.0.0';

  String uid = '';

  var logger = Logger();

  @override
  void initState() {
    super.initState();
    FetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // setState(() {
    //   uid = Provider.of<UserProvider>(context, listen: false).uid;
    // });
  }

  Future<void> FetchUserData() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var userLoginData = sharedPreferences.getString("userSessionData");
    var initData = json.decode(userLoginData ?? '');

    setState(() {
      uid = initData['uid'];
    });

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('api_reference')
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> fetchedData =
          snapshot.data() as Map<String, dynamic>;

      // Assing admin data to the UI
      setState(() {
        api_ip = fetchedData['api_ip'];
      });
    }
  }

  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _cropImage(pickedFile.path);
    }
  }

  void _cropImage(String filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        finalCroppedImage = File(croppedImage.path);
      });
      logger.e(finalCroppedImage);
      _uploadImageToAzure(finalCroppedImage);
    }
  }

  Future<void> _uploadImageToAzure(pickedImage) async {
    setState(() {
      isPredicting = true;
    });
    if (pickedImage != null) {
      Uint8List content = await pickedImage!.readAsBytes();

      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=nearbynexusblob;AccountKey=B4N3BiiEq6HNqMSPytSCErkiu/bKjaHebesnbdXcPqCW1IYxRPv4zAmL3r+AdAJqTZtTXBTiGM5p+ASt4J5nVA==;EndpointSuffix=core.windows.net');

      String? contentType = lookupMimeType(pickedImage!.path);

      String blobName = 'nearbynexus-blobstore/testimg';

      await storage.putBlob(blobName,
          bodyBytes: content,
          contentType: contentType,
          type: BlobType.blockBlob);

      // Get the URL of the uploaded image
      Uri imageUrl = storage.uri(path: blobName);

      print(imageUrl);
      String imagePath = imageUrl.toString();
      _sendAPIRequest(imagePath);
      // setState(() {
      //   pickedImageUrl = imageUrl as String;
      // });
    }
  }

  Future<Map<String, dynamic>> _sendAPIRequest(imageUrl) async {
    if (imageUrl.isEmpty) {
      setState(() {
        isPredicting = false;
      });
      print('Please upload an image first.');
      return {'error': 'Image URL is empty.'};
    }

    try {
      setState(() {
        status = "Classifiying...";
      });
      final response = await http.post(
        Uri.parse(
            'https://don100.pythonanywhere.com/predict'), // Replace with your API URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'image_url': imageUrl}),
      );

      if (response.statusCode == 200) {
        // If server returns a 200 OK response
        print(response.body);
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          isPredicting = false;
          if (jsonResponse['data'] == 'Others') {
            String data = jsonResponse['data'] ?? "";
            print(data);
            setState(() {
              status = data;
              type = "not_pan";
            });
          } else {
            Map<String, dynamic> data = jsonResponse['data'];
            setState(() {
              id_number = data['Id'];
              dob = data['Dob'];
              isPredicting = false;
            });
            if (dob.isEmpty || id_number.isEmpty) {
              setState(() {
                type = "img_not_clear";
              });
            } else {
              setState(() {
                type = "PAN";
                openBottomSheet(context, id_number, dob, uid);
              });
            }
          }
        });
        print(type);
        return jsonDecode(response.body);
      } else {
        setState(() {
          isPredicting = false;
        });
        // If server returns an error response
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isPredicting = false;
      });
      print('Error: $e');
      return {'error': 'An error occurred while making the request.'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Get verified by\ncompleting your KYC",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: GoogleFonts.aBeeZee().fontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "Completing the KYC enables you for accepting new jobs & you earn an verified badge.",
                style: TextStyle(
                    color: const Color.fromARGB(100, 255, 255, 255),
                    fontSize: 12),
              ),
              SizedBox(
                height: 15,
              ),
              type == "not_pan" || type == "img_not_clear"
                  ? Center(
                      child: Image.asset(
                        "assets/images/invalid.png",
                        height: 350,
                      ),
                    )
                  : Center(
                      child: SvgPicture.asset(
                        "assets/images/vector/Verified-rafiki.svg",
                        height: 350,
                      ),
                    ),
              !isPredicting
                  ? type.isEmpty
                      ? Expanded(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            width: MediaQuery.sizeOf(context).width,
                            height: 100,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(81, 255, 255, 255)),
                                color: Color.fromARGB(44, 255, 255, 255),
                                borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Please note.',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily:
                                          GoogleFonts.aBeeZee().fontFamily,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_sharp,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'You must use PAN card for verification.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_sharp,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Other cards are not acceptable.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_sharp,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Only provide the card that is rightful\nto you.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_sharp,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      'Take a clear picture of the PAN card.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                      : type == 'not_pan'
                          ? Container(
                              padding: EdgeInsets.all(15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(81, 255, 0, 0)),
                                color: Color.fromARGB(44, 255, 0, 0),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Invalid PAN Card!',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontFamily:
                                          GoogleFonts.russoOne().fontFamily,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                    horizontalTitleGap: 8,
                                    title: Text(
                                      'We are unable to identify this card as a PAN card. Please ensure that you have provided a valid PAN card.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily:
                                            GoogleFonts.aBeeZee().fontFamily,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : type == 'img_not_clear'
                              ? Container(
                                  padding: EdgeInsets.all(15),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color.fromARGB(81, 255, 0, 0)),
                                    color: Color.fromARGB(44, 255, 0, 0),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Unclear card!',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 18,
                                          fontFamily:
                                              GoogleFonts.russoOne().fontFamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                          Icons.error,
                                          color: Colors.white,
                                        ),
                                        horizontalTitleGap: 8,
                                        title: Text(
                                          'We are unable to identify your card. Kindly provide a clear image of your PAN card. Please retry!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: GoogleFonts.aBeeZee()
                                                .fontFamily,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: Center(
                                    child: LoadingAnimationWidget
                                        .threeArchedCircle(
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                )
                  : Expanded(
                      child: Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 40),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, shape: StadiumBorder()),
            onPressed: isPredicting ? null : _captureImage,
            icon: Icon(
              Icons.document_scanner,
              color: Colors.black,
            ),
            label: isPredicting
                ? CircularProgressIndicator(
                    color: Colors.black,
                  )
                : Text(
                    type == "not_pan" || type == "img_not_clear"
                        ? 'Retry now'
                        : "Scan now",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }
}

// update query
void updateUserData(
    String uid, Map<String, dynamic> kycData, BuildContext context) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    await firestore.collection('users').doc(uid).update({
      'kyc': kycData,
    });
    print('Document updated successfully!');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Success!',
          message: 'Your KYC is successfully verified.',
        );
      },
    );
  } catch (e) {
    print('Error updating document: $e');
  }
}

openBottomSheet(BuildContext context, String panNumber, dob, uid) {
  final dobController = TextEditingController();
  final panController = TextEditingController();
  dobController.text = dob;
  panController.text = panNumber;
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) => SingleChildScrollView(
      child: Container(
        color: Colors.white,
        height:
            MediaQuery.of(context).size.height * 0.5, // Adjust the height here
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Center(
              child: Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    StageWidget(
                      color: Colors.green,
                      icon: Icons.check,
                      belowText: 'PAN identified',
                      isLast: false,
                    ),
                    StageWidget(
                      color: Colors.green,
                      icon: Icons.check,
                      belowText: 'Extracted',
                      isLast: false,
                    ),
                    StageWidget(
                      color: Colors.yellow,
                      icon: Icons.ac_unit,
                      belowText: 'Verify details',
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Verify your details",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: TextFormField(
                readOnly: true,
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime(1963),
                    firstDate: DateTime(1963),
                    lastDate: DateTime(2005),
                  );
                },
                controller: dobController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  labelText: "Date of Birth",
                  contentPadding: const EdgeInsets.only(left: 25, bottom: 35),
                  hintText: "Your date of birth",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  labelStyle: const TextStyle(
                      color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(166, 158, 158, 158),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromARGB(166, 158, 158, 158),
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: panController,
              keyboardType: TextInputType.text,
              readOnly: false,
              style: GoogleFonts.poppins(color: Colors.black),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.numbers),
                labelText: "PAN number",
                contentPadding: const EdgeInsets.only(left: 25, bottom: 35),
                hintText: "Your pan number",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                labelStyle: const TextStyle(
                    color: Color.fromARGB(182, 0, 0, 0), fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(166, 158, 158, 158),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color.fromARGB(166, 158, 158, 158),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 50,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> kycData = {
                    'dob': dobController.text, // Example date of birth
                    'pan_id': panController.text,
                    'verified': true, // Example PAN ID
                  };
                  updateUserData(uid, kycData, context);
                },
                child: Text('Complete'),
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// custom dialog
class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String message;

  CustomAlertDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(message),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, "vendor_dashboard");
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
