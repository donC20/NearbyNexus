// ignore_for_file: avoid_print, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables

import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:azblob/azblob.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';

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
  String type = '';
  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      pickedImage = File(pickedFile.path);
      _uploadImageToAzure(pickedImage);
    }
  }

  Future<void> _uploadImageToAzure(pickedImage) async {
    setState(() {
      isPredicting = true;
    });
    if (pickedImage != null) {
      Uint8List content = await pickedImage!.readAsBytes();

      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=nearbystorage;AccountKey=K2Vtgfs2CapuWIYzFMxXtELXRiJtyRAQ4lSo1sr9ElVHJGNuSISr6P1R8yeRwnnEtfF+5QJDt8rE+AStmaAn8A==;EndpointSuffix=core.windows.net');

      String? contentType = lookupMimeType(pickedImage!.path);

      String blobName = 'nearbyblob/testimg';

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
        Uri.parse('http://52.90.42.210/predict'), // Replace with your API URL
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
            });
            if (dob.isEmpty || id_number.isEmpty) {
              setState(() {
                type = "img_not_clear";
              });
            } else {
              setState(() {
                type = "PAN";
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
