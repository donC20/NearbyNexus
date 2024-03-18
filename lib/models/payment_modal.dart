import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModal {
  final String amountPaid;
  final DocumentReference jobId;
  final DocumentReference payedBy;
  final DocumentReference payedTo;
  final DateTime paymentTime;
  final String payedFor;

  PaymentModal(
      {required this.amountPaid,
      required this.jobId,
      required this.payedBy,
      required this.payedTo,
      required this.paymentTime,
      required this.payedFor});

  toJson() {
    return {
      "amountPaid": amountPaid,
      "jobId": jobId,
      "payedBy": payedBy,
      "payedTo": payedTo,
      "paymentTime": paymentTime,
      "payedFor": payedFor,
    };
  }
}
