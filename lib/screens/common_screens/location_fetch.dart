// ignore_for_file: avoid_print

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class FetchCurrentLocation {
  String yrCurrentLocation = "loading..";
  Position? _currentPosition;
  bool fetching = false;
  Future<void> fetchLocation() async {
    fetching = true;
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (_currentPosition != null) {
        String? address = await getAddressFromLocation(_currentPosition!);
        if (address != null) {
          yrCurrentLocation = address;
          fetching = false;
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String?> getAddressFromLocation(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        // Choose the desired fields to form the address
        String address = "${placemark.locality}";
        return address;
      }
      return null;
    } catch (e) {
      print("Error getting address: $e");
      return null;
    }
  }
}
