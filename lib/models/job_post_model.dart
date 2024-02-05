import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostModel {
  String? jobTitle;
  String? jobDescription;
  DateTime jobPostDate = DateTime.now();
  DateTime? expiryDate;
  String? expiryTime;
  double? budget;
  DocumentReference? jobPostedBy;
  List<dynamic>? applicants = [];
  List<dynamic>? skills;
  List<dynamic>? preferredLocation;
  bool isWithdrawn = false;

  JobPostModel(
      {required this.jobTitle,
      required this.jobDescription,
      DateTime? jobPostDate,
      required this.expiryDate,
      required this.expiryTime,
      required this.budget,
      required this.jobPostedBy,
      this.applicants,
      required this.skills,
      required this.preferredLocation,
      isWithdrawn = false});

  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'jobDescription': jobDescription,
      'jobPostDate': jobPostDate,
      'expiryDate': expiryDate,
      'expiryTime': expiryTime,
      'budget': budget,
      'jobPostedBy': jobPostedBy,
      'applicants': applicants,
      'skills': skills,
      'preferredLocation': preferredLocation,
      'isWithdrawn': isWithdrawn,
    };
  }
}
