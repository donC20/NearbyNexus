import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? address;
  final Map<String, dynamic>? emailId;
  final Map<String, dynamic>? phone;
  final DocumentReference paymentLogs;
  final bool paymentVerified;
  final String? image;
  final String? currentGeoLocation;
  final String? userType;
  final String? status;
  final String? about;

  const UserModel(
      {this.id,
      required this.address,
      required this.paymentLogs,
      required this.paymentVerified,
      required this.about,
      required this.name,
      required this.emailId,
      required this.phone,
      required this.image,
      required this.userType,
      required this.status,
      required this.currentGeoLocation});

  toJson() {
    return {
      "name": name,
      "emailId": emailId,
      "phone": phone,
      "image": image,
      "userType": userType,
      "status": status,
      "geoLocation": currentGeoLocation,
      "address": address,
      "paymentLogs": paymentLogs,
      "paymentVerified": paymentVerified,
      "about": about,
    };
  }
}
