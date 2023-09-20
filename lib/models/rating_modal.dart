import 'package:cloud_firestore/cloud_firestore.dart';

class RateUser {
  final double rating;
  final String feedback;
  final bool forJobRating = true;
  final DocumentReference jobReference;
  final DocumentReference ratedBy;
  final DocumentReference ratedTo;
  final DateTime timeRated;

  RateUser({
    required this.rating,
    required this.feedback,
    required this.jobReference,
    required this.ratedBy,
    required this.ratedTo,
    required this.timeRated,
  });

  toJson() {
    return {
      "rating": rating,
      "feedback": feedback,
      "jobReference": jobReference,
      "ratedBy": ratedBy,
      "ratedTo": ratedTo,
      "timeRated": timeRated,
    };
  }
}
