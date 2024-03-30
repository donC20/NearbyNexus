// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_super_parameters, prefer_final_fields

import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';

class Gmaps extends StatefulWidget {
  final void Function(LatLng location) updateLocation;
  const Gmaps({Key? key, required this.updateLocation}) : super(key: key);

  @override
  _GmapsState createState() => _GmapsState();
}

class _GmapsState extends State<Gmaps> {
  late GoogleMapController _mapController;

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.4279613388664, -122.085749655962),
    zoom: 14.4746,
  );

  late LatLng _selectedLocation;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get the current location and set the initial camera position
  Future<void> _getCurrentLocation() async {
    try {
      // Get the current location
      LocationData locationData =
          (await ApiFunctions.getCurrentLocation()) as LocationData;
      double lat = locationData.latitude!;
      double lon = locationData.longitude!;

      // Set the initial camera position to the current location
      setState(() {
        _kGooglePlex = CameraPosition(target: LatLng(lat, lon), zoom: 14.4746);
      });

      print('Current Location: $lat, $lon');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  // Define a callback function to update the state
  void updateState(locationSelected) {
    setState(() {
      _selectedLocation = locationSelected;
    }); // Trigger UI update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Choose your location'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlaceSearch(
                  mapController: _mapController,
                  markers: _markers,
                  updateParentState: updateState, // Pass the callback function
                ),
              );
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            mapType: MapType.hybrid,
            trafficEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
                _markers.clear();
                _markers.add(
                  Marker(
                    markerId: MarkerId('selected-location'),
                    position: _selectedLocation,
                  ),
                );
              });
            },
            markers: _markers,
          ),
          Positioned(
              bottom: 16.0,
              left: 16.0,
              child: GFButton(
                onPressed: _markers.isNotEmpty
                    ? () {
                        // Save the selected location
                        // print('Selected Location: $_selectedLocation');
                        widget.updateLocation(_selectedLocation);
                        Navigator.pop(context);
                      }
                    : null,
                text: "Save this location",
                icon: Icon(Icons.check_circle_rounded),
                textStyle: TextStyle(color: Colors.black),
                shape: GFButtonShape.pills,
                color: Colors.white,
              )),
        ],
      ),
    );
  }
}

class PlaceSearch extends SearchDelegate<Map<String, dynamic>> {
  final GoogleMapController mapController;
  final Set<Marker> markers;
  final void Function(LatLng selectedLocation)
      updateParentState; // Callback function

  PlaceSearch({
    required this.mapController,
    required this.markers,
    required this.updateParentState,
  });

  @override
  String get searchFieldLabel => 'Search for a location';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(onPressed: () => query = '', icon: Icon(Icons.clear))];
  }

  var logger = Logger();
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, {}),
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('Search results for $query');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ApiFunctions().searchPlaces(query),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final locations = snapshot.data!;
          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                title: Text(location['name'] ?? location['formatted']),
                onTap: () {
                  String latString = location['lat'].toString();
                  String lonString = location['lon'].toString();
                  double lat = double.parse(latString);
                  double lon = double.parse(lonString);
                  LatLng selectedLocation = LatLng(lat, lon);
                  mapController.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: selectedLocation,
                        zoom: 14.0,
                      ),
                    ),
                  );
                  markers.clear();
                  markers.add(
                    Marker(
                      markerId: MarkerId('selected-location'),
                      position: selectedLocation,
                    ),
                  );
                  updateParentState(
                      selectedLocation); // Trigger parent widget's state update
                  close(context, location);
                },
              );
            },
          );
        }
      },
    );
  }
}
