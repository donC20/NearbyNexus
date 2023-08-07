class GeneralUser {
  final String? id;
  final String? name;
  final String? emailId;
  final int? phone;
  final double? latitude;
  final double? longitude;
  final String? image;
  final String? currentGeoLocation;

  const GeneralUser(
      {this.id,
      required this.name,
      required this.emailId,
      required this.phone,
      required this.latitude,
      required this.longitude,
      required this.image,
      required this.currentGeoLocation});

  toJson() {
    return {
      "name": name,
      "emailId": emailId,
      "phone": phone,
      "latitude": latitude,
      "longitude": longitude,
      "image": image,
      "geoLocation": currentGeoLocation,
    };
  }
}
