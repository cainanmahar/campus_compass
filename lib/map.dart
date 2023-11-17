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
  // State variable to store route coords for route generation
  Map<int?, List<LatLng>> segmentedRouteCoordinates = {};

  // controls filter state
  bool isAdaFilterEnabled = false;

  // List of the names of the layers
  // TODO: Make this a 2-d array
  List<String> outdoorLayers = [
    'outdoors_all',
    'outdoors_ada',
  ];

  List<String> indoorLayers = [
    'level1',
    'level2',
  ];
  // List that contains the floor levels, and the corresponding boolean list, Function bellow will iterate true them and change this based on index.
  List<String> floorLayers = ['G', 'L1', 'L2'];
  List<bool> selectedLayer = [true, false, false];
  //Tracks current layer index
  int currentLayerIndex = 0;
  //Tracks level layer, true or false
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    initializeNodes(); // initialize nodes and their neighbors
    loadEndpoints(); // load and parse endpoitn data from a_star.dart
    //drawRoute(); // initiatlize route drawing
  }

  // Method to perform a star search and draw the route
  void drawRoute(int startID, int endID) {
    var segmentedPaths = aStarSearch(startID, endID, isAdaFilterEnabled);
    if (segmentedPaths != null) {
      segmentedRouteCoordinates.clear();
      segmentedPaths.forEach((floor, nodes) {
        segmentedRouteCoordinates[floor] =
            nodes.map((node) => node.coords).toList();
      });
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
      segmentedRouteCoordinates.clear(); // clear the route
    });
  }

  Future<void> showSearchDialog(BuildContext context) async {
    String? selectedStartLocation;
    String? selectedEndLocation;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Locations'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Start Location:'),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return _optionsBuilder(textEditingValue);
                  },
                  onSelected: (String selection) {
                    selectedStartLocation = selection;
                  },
                ),
                const SizedBox(height: 20),
                const Text('End Location:'),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    return _optionsBuilder(textEditingValue);
                  },
                  onSelected: (String selection) {
                    selectedEndLocation = selection;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleSelections(selectedStartLocation, selectedEndLocation);
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Iterable<String> _optionsBuilder(TextEditingValue textEditingValue) {
    if (textEditingValue.text.isEmpty) {
      return const Iterable<String>.empty();
    } else {
      return endpointLocations.keys.where((String option) {
        return option
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase());
      });
    }
  }

  void _handleSelections(String? start, String? end) {
    if (start != null && start.isNotEmpty) {
      int startNodeId = endpointLocations[start] ?? 0;
      setState(() {
        startId = startNodeId;
        startLocationName = start;
      });
    }

    if (end != null && end.isNotEmpty) {
      int endNodeId = endpointLocations[end] ?? 0;
      setState(() {
        endNodeId = endNodeId;
        endLocationName = end;
        if (startId != null) {
          drawRoute(startId!, endNodeId);
        }
      });
    }
  }

  List<String> getBothLayers() {
    // Determine the outdoor layer based on ADA filter
    String outdoorLayer = outdoorLayers[currentLayerIndex];

    // Determine the indoor layer based on selected floor
    String indoorLayer = '';
    if (selectedLayer[1]) {
      // If L1 is selected
      indoorLayer = 'Campus_Maps:ab1_level1';
    } else if (selectedLayer[2]) {
      // If L2 is selected
      indoorLayer = 'Campus_Maps:ab1_level2';
    }
    // For G, we only show the outdoor layer

    // Return the combined layers list based on the selected floor
    return indoorLayer.isEmpty ? [outdoorLayer] : [outdoorLayer, indoorLayer];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Campus Compass'),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => showSearchDialog(
                    context,
                  )),
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
              initialZoom: 18,
              crs: Epsg4326(),
            ),
            children: [
              TileLayer(
                wmsOptions: WMSTileLayerOptions(
                  baseUrl: "http://144.126.221.0:8080/geoserver/wms/?",
                  layers: getBothLayers(),
                  crs: const Epsg4326(),
                ),
                maxNativeZoom: 22,
              ),
              PolylineLayer(
                polylines: [
                  if (selectedLayer[0] &&
                      segmentedRouteCoordinates.containsKey(0)) // Outdoor Layer
                    Polyline(
                      points: segmentedRouteCoordinates[0]!,
                      strokeWidth: 8.0, // Increase the width for the border
                      color: Colors.black, // Use black color for the border
                    ),
                  if (selectedLayer[0] &&
                      segmentedRouteCoordinates.containsKey(0)) // Outdoor Layer
                    Polyline(
                      points: segmentedRouteCoordinates[0]!,
                      strokeWidth:
                          4.0, // Set the desired width for the main polyline
                      color: Colors.orange,
                    ),
                  if (selectedLayer[1] &&
                      segmentedRouteCoordinates.containsKey(1)) // Level 1
                    Polyline(
                      points: segmentedRouteCoordinates[1]!,
                      strokeWidth: 8.0, // Increase the width for the border
                      color: Colors.black, // Use black color for the border
                    ),
                  if (selectedLayer[1] &&
                      segmentedRouteCoordinates.containsKey(1)) // Level 1
                    Polyline(
                      points: segmentedRouteCoordinates[1]!,
                      strokeWidth:
                          4.0, // Set the desired width for the main polyline
                      color: Colors.orange,
                    ),
                  if (selectedLayer[2] &&
                      segmentedRouteCoordinates.containsKey(2)) // Level 2
                    Polyline(
                      points: segmentedRouteCoordinates[2]!,
                      strokeWidth: 8.0, // Increase the width for the border
                      color: Colors.black, // Use black color for the border
                    ),
                  if (selectedLayer[2] &&
                      segmentedRouteCoordinates.containsKey(2)) // Level 2
                    Polyline(
                      points: segmentedRouteCoordinates[2]!,
                      strokeWidth:
                          4.0, // Set the desired width for the main polyline
                      color: Colors.orange,
                    ),
                ],
              ),
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
                    'Start: ${startLocationName ?? ""}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'End: ${endLocationName ?? ""}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
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
                    'Start: ${startLocationName ?? ""}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'End: ${endLocationName ?? ""}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 16,
            child: IntrinsicWidth(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ToggleButtons(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.0),
                  fillColor: Colors.orangeAccent,
                  selectedColor: Colors.white,

                  direction: Axis.vertical,
                  isSelected: selectedLayer,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < selectedLayer.length;
                          buttonIndex++) {
                        selectedLayer[buttonIndex] = buttonIndex == index;
                      }
                      // Update map layers based on the new floor selection
                      // This will trigger a rebuild of the FlutterMap with updated layers
                    });
                  },
                  //constraints: const BoxConstraints(
                  // minHeight: 40.0, // Adjust the height as needed
                  //), // Adjust the width as needed)
                  children: floorLayers.map((floor) => Text(floor)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//Verifying output in Terminal: only purpose, Will be removed after all layers are added;
  void printLayerName() {
    print("Current Layer: ${outdoorLayers[currentLayerIndex]}");
  }
}
