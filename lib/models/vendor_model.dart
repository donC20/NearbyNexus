// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String? id;
  final String? name;
  final Map<String, dynamic>? emailId;
  final Map<String, dynamic>? phone;
  final Map<String, dynamic>? kyc;
  final String? image;
  final String? currentGeoLocation;
  final String? userType;
  final String? status;
  final String? description;
  final List<String>? services;
  final String govDocs;
  final String? languages;
  final String? activityStatus;
  final double actualRating;
  final double totalRating;
  final List? jobs_applied;
  final List? jobs_applied_list;
  final List? saved_jobs;
  final List<DocumentReference> paymentLogs;

  final List<DocumentReference> allRatings;
  final List<String> userFavourites;
  List<String> working_days = [];
  List<String> unavailableDays = [];
  VendorModel( 
      {this.id,
      required this.name,
      required this.emailId,
      required this.kyc,
      required this.phone,
      required this.image,
      required this.userType,
      required this.status,
      required this.unavailableDays,
      required this.currentGeoLocation,
      this.description,
      this.services,
      required this.govDocs,
      required this.allRatings,
      required this.actualRating,
      required this.totalRating,
      required this.jobs_applied,
      this.jobs_applied_list,
      required this.saved_jobs,
      this.languages,
      required this.paymentLogs,
      required this.activityStatus,
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
      "allRatings": allRatings,
      "actualRating": actualRating,
      "totalRating": totalRating,
      "jobs_applied": jobs_applied,
      "jobs_applied_list":jobs_applied_list,
      "saved_jobs": saved_jobs,
      "activityStatus": activityStatus,
      "kyc": kyc,
      "unavailableDays": unavailableDays,
    };
  }
}
