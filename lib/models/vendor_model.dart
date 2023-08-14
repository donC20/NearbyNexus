class VendorModel {
  final String? id;
  final String? name;
  final String? emailId;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? image;
  final String? currentGeoLocation;
  final String? userType;
  final String? status;
  final String? subscribers;
  final String? description;
  final List<String>? services;
  final List<String>? worksDone;
  final String govDocs;

  const VendorModel({
    this.id,
    required this.name,
    required this.emailId,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.userType,
    required this.status,
    required this.currentGeoLocation,
    this.subscribers,
    this.description,
    this.services,
    this.worksDone,
    required this.govDocs,
  });

  toJson() {
    return {
      "name": name,
      "emailId": emailId,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "image": image,
      "userType": userType,
      "status": status,
      "geoLocation": currentGeoLocation,
      "subscription": subscribers,
      "description": description,
      "services": services,
      "govDocs": govDocs,
      "worksDone": worksDone,
    };
  }
}
