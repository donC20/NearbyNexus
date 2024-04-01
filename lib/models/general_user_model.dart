import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String? name;
  final String? address;
  final Map<String, dynamic>? emailId;
  final Map<String, dynamic>? phone;
  final List<DocumentReference> paymentLogs;
  final List<DocumentReference> iamRated;
  final bool paymentVerified;
  final String? image;
  final String? currentGeoLocation;
  final String? userType;
  final String? status;
  final String? about;
  final String? pushToken;
  final last_seen;
  final bool online;
  final String registrationStatus;
  final List<String>? userFavourites;

  UserModel(
      {this.id,
      required this.address,
      required this.paymentLogs,
      required this.paymentVerified,
      required this.iamRated,
      required this.about,
      required this.name,
      required this.emailId,
      required this.phone,
      required this.registrationStatus,
      required this.image,
      required this.userType,
      required this.userFavourites,
      required this.status,
      required this.currentGeoLocation,
      this.last_seen,
      this.online = true,
      this.pushToken = ''});

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
      "userFavourites": userFavourites,
      "iamRated": iamRated,
      "online": online,
      "last_seen": last_seen,
      "pushToken": pushToken,
      'registrationStatus': registrationStatus
    };
  }
}
