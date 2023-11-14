import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:campus_compass/app_drawer.dart';
import 'package:campus_compass/a_star.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
 // State variables to track the selection of start and end nodes
  bool isSelectingStartNode = true;
  int? startId;
  int? endNodeId;

// State variables to store the names of the selected start and end locations
  String? startLocationName;
  String? endLocationName;

  // controls filter state
  bool isAdaFilterEnabled = false;

  // List of the names of the layers
  // TODO: Make this a 2-d array
  List<String> layerGeoserver = [
    'outdoors_hl_nonada',
    'outdoors_ada',
  ];

  //Tracks current layer index
  int currentLayerIndex = 0;

  //Tracks level layer, true or false
  List<bool> isSelected = [true, false];

  //List of rooms (just for testing purposes)
  List<String> roomNumbers = [
    'Room 202',
    'Room 204',
    'Room 206',
    'Room 101',
    'AB1 Entrance',
    // Add more rooms
  ];

  // int startId = 159942;
  // Controller for managing the text in the search field
  TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    initializeNodes(); // initialize nodes and their neighbors
    loadEndpoints(); // load and parse endpoitn data from a_star.dart
    //drawRoute(); // initiatlize route drawing
  }

  List<LatLng> routeCoordinates = [];

  // Method to draw the route on the map based on start and end IDs
  void drawRoute(int startID, int endID) {
    // perform a* search
    var path = aStarSearch(startID, endID, isAdaFilterEnabled);

    // convert the path to a list of LatLng
    if (path != null) {
      routeCoordinates = path.map((node) => node.coords).toList();
    }

    setState(() {});
  }

  void handleFilterChange(bool isAdaFilterEnabled) {
    setState(() {
      this.isAdaFilterEnabled = isAdaFilterEnabled;
      currentLayerIndex = isAdaFilterEnabled ? 1 : 0; // Ada or non-Ada path
    });
  }
  // Method to reset the selection of start and end nodes
  void resetSelections() {
    setState(() {
      startId = null;
      endNodeId = null;
      startLocationName = null;
      endLocationName = null;
      isSelectingStartNode = true;
      routeCoordinates.clear(); // clear the route
      searchController.clear(); // clear the search field
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return endpointLocations.keys;
            } else {
              // directly use endpointLocations from a_star.dart
              return endpointLocations.keys.where((location) {
                return location
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              });
            }
          },
          onSelected: (String selection) {
            int selectedNodeId = endpointLocations[selection] ?? 0;
            setState(() {
              if (isSelectingStartNode) {
                startId = selectedNodeId;
                startLocationName = selection; // Set start location name
                isSelectingStartNode = false;
              } else {
                endNodeId = selectedNodeId;
                endLocationName = selection; // Set end location name
                if (startId != null){
                  drawRoute(startId!, endNodeId!);
                }
                // Switch back to selecting start node for next selection
                isSelectingStartNode = true;
              }
              // Clear the search input
              searchController.clear();
            });
            print('Selected location: $selection, Node ID: $endNodeId');
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ), // Search icon
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: resetSelections,
          ),
        ],
      ),

      // Collapsible Menu
      drawer: AppDrawer(
        isAdaFilterEnabled: isAdaFilterEnabled,
        onFilterChanged: handleFilterChange,
      ),

      // Map part of the screen
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              initialCenter: LatLng(30.71475020, -95.54687941),
              initialZoom: 19.5,
              crs: Epsg4326(),
            ),
            children: [
              TileLayer(
                wmsOptions: WMSTileLayerOptions(
                  baseUrl: "http://144.126.221.0:8080/geoserver/wms/?",
                  layers: [layerGeoserver[currentLayerIndex]],
                  crs: const Epsg4326(),
                ),
                maxNativeZoom: 22,
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeCoordinates,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  )
                ],
              )
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Node: ${startLocationName ?? "Not selected"}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'End Node: ${endLocationName ?? "Not selected"}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                  color: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        currentLayerIndex++;
                        if (currentLayerIndex >= layerGeoserver.length) {
                          currentLayerIndex = 0;
                        }
                        printLayerName();
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                  color: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        currentLayerIndex--;
                        if (currentLayerIndex < 0) {
                          currentLayerIndex = layerGeoserver.length - 1;
                        }
                        printLayerName();
                      });
                    },
                    icon: const Icon(Icons.remove, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//Verifying output in Terminal: only purpose, Will be removed after all layers are added;
  void printLayerName() {
    print("Current Layer: ${layerGeoserver[currentLayerIndex]}");
  }
}
