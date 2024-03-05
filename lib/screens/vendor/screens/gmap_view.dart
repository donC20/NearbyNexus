import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class GmapView extends StatefulWidget {
  final String userLocation;
  const GmapView({Key? key, required this.userLocation}) : super(key: key);

  @override
  _GmapViewState createState() => _GmapViewState();
}

class _GmapViewState extends State<GmapView> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  bool _isLoading = true;
  Position? _currentPosition;
  var logger = Logger();
  LatLng userExtractedLocation = LatLng(0.0, 0.0);
  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    stringToLatLng(widget.userLocation);
    logger.f(widget.userLocation);

    getCurrentCoordinates();
  }

  Map<PolylineId, Polyline> polylines = {};

  void stringToLatLng(String latLngString) {
    setState(() {
      _isLoading = true;
    });
    String coordinates =
        latLngString.replaceAll("LatLng(", "").replaceAll(")", "");

    // Split the coordinates string by comma
    List<String> coordinatesList = coordinates.split(", ");

    // Extract latitude and longitude values
    double latitude = double.parse(coordinatesList[0]);
    double longitude = double.parse(coordinatesList[1]);

    // Update userExtractedLocation
    setState(() {
      userExtractedLocation = LatLng(latitude, longitude);
      _kGooglePlex = CameraPosition(
        target: userExtractedLocation,
        zoom: 14.4746,
      );
      _isLoading = false;
    });
  }

  Future<void> getCurrentCoordinates() async {
    setState(() {
      _isLoading = true;
    });
    try {
      dynamic positions = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _isLoading = false;
        _currentPosition = positions;
        _drawPolylines();
      });
      logger.e(_currentPosition);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error: $e");
    }
  }

  void _drawPolylines() {
    PolylineId id = PolylineId('poly');
    List<LatLng> polylineCoordinates = [
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      userExtractedLocation,
    ];

    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: _kGooglePlex,
              // ignore: null_argument_to_non_null_type
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              mapType: MapType.hybrid,
              markers: {
                Marker(
                  markerId: MarkerId("destination"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  position: userExtractedLocation,
                ),
                Marker(
                  markerId: MarkerId("start"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude),
                )
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }
}
