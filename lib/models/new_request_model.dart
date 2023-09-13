// ignore_for_file: non_constant_identifier_names

class NewRequestModal {
  final String? service_name;
  final String? description;
  final String? service_level;
  final String? location;
  final DateTime? dateRequested;
  final DateTime? day;
  // final DateTime time;
  final int? wage;
  NewRequestModal(
      {required this.description,
      required this.service_level,
      required this.location,
      required this.dateRequested,
      required this.day,
      required this.wage,
      required this.service_name});

  toJson() {
    return {
      'description': description,
      'service_level': service_level,
      'location': location,
      'dateRequested': dateRequested,
      'day': day,
      'wage': wage,
      'service_name': service_name,
    };
  }
}
