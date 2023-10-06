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
  File? _image;
  String _imageUrl = '';
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
      print('Please upload an image first.');
      return {'error': 'Image URL is empty.'};
    }

    try {
      final response = await http.post(
        Uri.parse('http://3.85.39.225/predict'), // Replace with your API URL
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
          String predicted = jsonResponse['predicted_class'];
          Map<String, dynamic> data = jsonResponse['data'];
          String name = data['name'] ?? "";
          String gender = data['gender'] ?? "";
          String dob = data['dob'] ?? "";
          String id_number = data['id_number'] ?? "";

          if (predicted == "Aadhaar") {
            if (name.isEmpty ||
                gender.isEmpty ||
                dob.isEmpty ||
                id_number.isEmpty) {
              type = "Not an Aadhaar";
            } else {
              type = "Aadhaar";
            }
          } else {
            type = "Not an Aadhaar";
          }
        });
        return jsonDecode(response.body);
      } else {
        // If server returns an error response
        throw Exception('Failed to load data');
      }
    } catch (e) {
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
              child: Text(
                type,
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
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
              onPressed: _uploadImageToAzure,
              child: Text('Upload Image to Firebase'),
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
