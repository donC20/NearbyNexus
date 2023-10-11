// ignore_for_file: avoid_print, prefer_const_constructors, use_key_in_widget_constructors

import 'dart:typed_data';

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:azblob/azblob.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
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
  File? _image;
  String type = '';
  Future<void> _captureImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImageToAzure() async {
    setState(() {
      isPredicting = true;
      status = "Uploading to Cloud";
    });
    if (_image != null) {
      Uint8List content = await _image!.readAsBytes();

      var storage = AzureStorage.parse(
          'DefaultEndpointsProtocol=https;AccountName=nearbystorage;AccountKey=K2Vtgfs2CapuWIYzFMxXtELXRiJtyRAQ4lSo1sr9ElVHJGNuSISr6P1R8yeRwnnEtfF+5QJDt8rE+AStmaAn8A==;EndpointSuffix=core.windows.net');

      String? contentType = lookupMimeType(_image!.path);

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
      //   _imageUrl = imageUrl as String;
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
        Uri.parse('http://54.159.158.131/predict'), // Replace with your API URL
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
          String predicted = jsonResponse['predicted_class'];
          print(predicted);
          if (jsonResponse['data'] == 'unavailable') {
            String data = jsonResponse['data'] ?? "";
            print(data);
            setState(() {
              status = jsonResponse['data'];
              type = "Not an Aadhaar";
            });
          } else {
            Map<String, dynamic> data = jsonResponse['data'];

            setState(() {
              name = data['name'] ?? "";
              gender = data['gender'] ?? "";
              dob = data['dob'] ?? "";
              id_number = data['id_number'];
            });
            if (predicted == "Aadhaar") {
              if (name.isEmpty ||
                  gender.isEmpty ||
                  dob.isEmpty ||
                  id_number.isEmpty) {
                setState(() {
                  type = "Not an Aadhaar";
                });
              } else {
                setState(() {
                  type = "Aadhaar";
                });
              }
            } else {
              setState(() {
                type = "Not an Aadhaar";
              });
            }
          }
        });
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
      appBar: AppBar(
        title: Text('KYC Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        "Status : ",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                            color: Color.fromARGB(255, 15, 209, 1),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        "Name : ",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                            color: Color.fromARGB(255, 15, 209, 1),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        "Gender : ",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16),
                      ),
                      Text(
                        gender,
                        style: TextStyle(
                            color: Color.fromARGB(255, 15, 209, 1),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        "DOB : ",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16),
                      ),
                      Text(
                        dob,
                        style: TextStyle(
                            color: Color.fromARGB(255, 15, 209, 1),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Text(
                        "Number : ",
                        style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16),
                      ),
                      Text(
                        id_number,
                        style: TextStyle(
                            color: Color.fromARGB(255, 15, 209, 1),
                            fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                type,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            _image != null
                ? Image.file(_image!, height: 200)
                : Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureImage,
              child: Text('Capture Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isPredicting ? () {} : _uploadImageToAzure,
              child:
                  isPredicting ? CircularProgressIndicator() : Text('Verify'),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _sendAPIRequest,
            //   child: Text('Send API Request'),
            // ),
          ],
        ),
      ),
    );
  }
}
