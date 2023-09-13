// ignore_for_file: non_constant_identifier_names

class NewRequestModal {
  final String? service_name;
  final String? description;
  final String? service_level;
  final String? location;
  final DateTime? dateRequested;
  final DateTime? day;
  final int? wage;
  NewRequestModal(
      {this.description,
      this.service_level,
      this.location,
      this.dateRequested,
      this.day,
      this.wage,
      this.service_name});
}
