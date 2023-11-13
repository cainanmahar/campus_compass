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

  int startId = 159942;

  @override
  void initState() {
    super.initState();
    initializeNodes(); // initialize nodes and their neighbors
    loadEndpoints(); // load and parse endpoitn data from a_star.dart
    //drawRoute(); // initiatlize route drawing
  }

  List<LatLng> routeCoordinates = [];

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
            // Implement a star routing to that room
            // hardcoded endgoal is front of AB1 till I get endpoint json
            int endNodeId = endpointLocations[selection] ??
                0; // default to 0 or handle appropriately
            drawRoute(startId, endNodeId);
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
