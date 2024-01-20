import 'package:cloud_firestore/cloud_firestore.dart';

class JobPostModel {
  String? jobTitle;
  String? jobDescription;
  DateTime jobPostDate = DateTime.now();
  DateTime? expiryDateTime;
  int? budget;
  DocumentReference? jobPostedBy;
  List<Map<DocumentReference, dynamic>>? applicants;
  List<String>? skills;
  List<String>? prefferedLocation;

  JobPostModel(
      {required jobTitle,
      required jobDescription,
      jobPostDate,
      required expiryDateTime,
      required budget,
      required jobPostedBy,
      applicants,
      required skills,
      required prefferedLocation});

  toJson() {
    return {
      jobTitle: 'jobTitle',
      jobDescription: 'jobDescription',
      jobPostDate: 'jobPostDate',
      expiryDateTime: 'expiryDateTime',
      budget: 'budget',
      jobPostedBy: 'jobPostedBy',
      applicants: 'applicants',
      skills: 'skills',
      prefferedLocation: 'prefferedLocation'
    };
  }
}
