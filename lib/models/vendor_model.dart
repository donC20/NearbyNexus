// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String? id;
  final String? name;
  final Map<String, dynamic>? emailId;
  final Map<String, dynamic>? phone;
  final String? image;
  final String? currentGeoLocation;
  final String? userType;
  final String? status;
  final String? description;
  final List<String>? services;
  final String govDocs;
  final String? languages;
  DocumentReference? paymentLogs =
      FirebaseFirestore.instance.collection('payments').doc('someDocs');
  final List<String> userFavourites;
  List<String> working_days = [];
  VendorModel( 
      {this.id,
      required this.name,
      required this.emailId,
      required this.phone,
      required this.image,
      required this.userType,
      required this.status,
      required this.currentGeoLocation,
      this.description,
      this.services,
      required this.govDocs,
      this.languages,
      this.paymentLogs,
      required this.userFavourites,
      required this.working_days});

  toJson() {
    return {
      
      "name": name,
      "emailId": emailId,
      "phone": phone,
      "image": image,
      "userType": userType,
      "status": status,
      "geoLocation": currentGeoLocation,
      "about": description,
      "services": services,
      "govDocs": govDocs,
      "paymentLogs": paymentLogs,
      "userFavourites": userFavourites,
      "working_days": working_days,
    };
  }
}
