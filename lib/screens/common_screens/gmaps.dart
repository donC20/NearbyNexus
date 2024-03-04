import 'package:NearbyNexus/functions/api_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:logger/logger.dart';

class Gmaps extends StatefulWidget {
  const Gmaps({Key? key}) : super(key: key);

  @override
  _GmapsState createState() => _GmapsState();
}

class _GmapsState extends State<Gmaps> {
  late GoogleMapController _mapController;
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.4279613388664, -122.085749655962),
    zoom: 14.4746,
  );

  late LatLng _selectedLocation;
  bool _locationSelected = false;

  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlaceSearch(
                  mapController: _mapController,
                  markers: _markers,
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
            mapType: MapType.satellite,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
                _locationSelected = true;
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
            child: ElevatedButton(
              onPressed: _locationSelected
                  ? () {
                      // Save the selected location
                      print('Selected Location: $_selectedLocation');
                    }
                  : null,
              child: Text('Save this location as text'),
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceSearch extends SearchDelegate<Map<String, dynamic>> {
  final GoogleMapController mapController;
  final Set<Marker> markers;

  PlaceSearch({required this.mapController, required this.markers});

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
