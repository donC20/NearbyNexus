// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class NewRequestModal {
  final String? service_name;
  final String? description;
  final String? service_level;
  final String? location;
  final String? status;
  final String? clientStatus;
  final String? paymentStatus;
  final DateTime? day;
  final DateTime? dateRequested;
  final DocumentReference? vendor_reference;
  final DocumentReference? user_reference;
  final DocumentReference paymentLog;
  final List<dynamic> jobLogs;

  // final DateTime time;
  final String? wage;
  NewRequestModal(
      {required this.clientStatus,
      required this.paymentStatus,
      required this.paymentLog,
      required this.vendor_reference,
      required this.user_reference,
      required this.status,
      required this.description,
      required this.service_level,
      required this.location,
      required this.dateRequested,
      required this.day,
      required this.wage,
      required this.service_name,
      required this.jobLogs});

  toJson() {
    return {
      'description': description,
      'service_level': service_level,
      'location': location,
      'dateRequested': dateRequested,
      'day': day,
      'wage': wage,
      'service_name': service_name,
      'referencePath': vendor_reference,
      'userReference': user_reference,
      'status': status,
      'clientStatus': clientStatus,
      'paymentStatus': paymentStatus,
      'paymentLog': paymentLog,
      'jobLogs': jobLogs
    };
  }
}
