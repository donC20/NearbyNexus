// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  final Future<List<Map<String, dynamic>>> Function(String query)
      searchPlaces; // Named parameter
  final Function(String) onItemSelected;
  CustomSearchDelegate(
      {required this.searchPlaces, required this.onItemSelected});
  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the search bar (e.g., clear text)
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the search bar (e.g., back button)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, "SelectedResult");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Build and display search results based on the query
    // You can replace this with your own search logic and UI
    return Center(
      child: Text('Search Results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: searchPlaces(query), // Call the searchPlaces function
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child:
                CircularProgressIndicator(), // Display a loading indicator while fetching suggestions
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final suggestions = snapshot.data!;
        if (query.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/vector/keyboard_typing.jpg",
                  width: 250,
                  height: 250,
                ),
                SizedBox(height: 15),
                Text(
                  "Please enter the location",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else if (suggestions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/vector/no_data.jpg",
                  width: 300,
                  height: 300,
                ),
                SizedBox(height: 15),
                Text(
                  "): Sorry, $query not found.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        } else {
          return ListView.separated(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              String name =
                  suggestions[index]["name"] ?? suggestions[index]["formatted"];
              String country = suggestions[index]["country"] as String;
              String state =
                  suggestions[index]["state"] ?? suggestions[index]["suburb"];
              String county = suggestions[index]["county"] ??
                  suggestions[index]["postcode"] ??
                  suggestions[index]["state_code"];

              return ListTile(
                title: Text(name),
                subtitle: Text("$state, $county, $country"),
                onTap: () {
                  final selectedName = suggestions[index]["name"] as String;
                  onItemSelected(selectedName);
                  close(context, selectedName);
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                color: Color.fromARGB(49, 18, 19, 19),
                thickness: 1.0,
                indent: 0,
                endIndent: 0,
              );
            },
          );
        }
      },
    );
  }
}
