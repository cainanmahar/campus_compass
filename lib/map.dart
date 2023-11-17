import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  // List of the names of the outdoor layers
  List<String> outdoorLayers = [
    'outdoors_all',
    'outdoors_ada',
  ];
  // List of the names of the indoor layers
  List<String> indoorLayers = [
    'level1',
    'level2',
  ];
  // List that contains the floor levels, and the corresponding boolean list,
  //Function bellow will iterate through them and change this based on index.
  List<String> floorLayers = ['G', 'L1', 'L2'];
  List<bool> selectedLayer = [true, false, false];
  //Tracks current layer index
  int currentLayerIndex = 0;
  //Tracks level layer, true or false
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    // initialize nodes and their neighbors
    initializeNodes();
    // load and parse endpoitn data from a_star.dart
    loadEndpoints();
  }

  // Method to perform a star search and draw the route
  void drawRoute(int startID, int endID) {
    // get the route with aStar
    var segmentedPaths = aStarSearch(startID, endID, isAdaFilterEnabled);
    if (segmentedPaths != null) {
      segmentedRouteCoordinates.clear();
      // Get the segmented route coordinates
      segmentedPaths.forEach((floor, nodes) {
        segmentedRouteCoordinates[floor] =
            nodes.map((node) => node.coords).toList();
      });
    }
    // changes the state to show route
    setState(() {});
  }

  void handleFilterChange(bool isAdaFilterEnabled) {
    setState(() {
      this.isAdaFilterEnabled = isAdaFilterEnabled;
      // Determine which layer based on ADA or non-ADA paths
      currentLayerIndex = isAdaFilterEnabled ? 1 : 0;
    });
  }

  // Method to reset the selection of start and end nodes and route
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

  // Function to show a dialog box
  // Allows the user to pick a start and end location to route to
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

  // handles the options for the auto complete dialog box
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

  // Function that handles the selections of the start and end nodes
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

  // Gets the layers to display based on ADA preferences and indoor layer selection
  List<String> getBothLayers() {
    // Determine the outdoor layer based on ADA filter
    String outdoorLayer = outdoorLayers[currentLayerIndex];
    // Determine the indoor layer based on selected floor
    String indoorLayer = '';
    if (selectedLayer[1]) {
      // If L1 is selected
      indoorLayer = indoorLayers[0];
    } else if (selectedLayer[2]) {
      // If L2 is selected
      indoorLayer = indoorLayers[1];
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
          // search icon
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => showSearchDialog(
                    context,
                  )),
          // refresh button that resets all route information
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
              // poly lines for route generation
              PolylineLayer(
                polylines: [
                  // Outdoor line layers
                  // line that creates a black 'border' around the route
                  if (selectedLayer[0] &&
                      segmentedRouteCoordinates.containsKey(0))
                    Polyline(
                      points: segmentedRouteCoordinates[0]!,
                      // increased width for border
                      strokeWidth: 8.0,
                      color: Colors.black,
                    ),
                  // orange route line
                  if (selectedLayer[0] &&
                      segmentedRouteCoordinates.containsKey(0))
                    Polyline(
                      points: segmentedRouteCoordinates[0]!,
                      strokeWidth: 4.0,
                      color: Colors.orange,
                    ),
                  // Indoor floor 1 line layers
                  // line that creates a black 'border' around the route
                  if (selectedLayer[1] &&
                      segmentedRouteCoordinates.containsKey(1))
                    Polyline(
                      points: segmentedRouteCoordinates[1]!,
                      strokeWidth: 8.0,
                      color: Colors.black,
                    ),
                  // orange route line
                  if (selectedLayer[1] &&
                      segmentedRouteCoordinates.containsKey(1))
                    Polyline(
                      points: segmentedRouteCoordinates[1]!,
                      strokeWidth: 4.0,
                      color: Colors.orange,
                    ),
                  // Indoor floor 2 line layers
                  // line thta creates a black 'border' around the route
                  if (selectedLayer[2] &&
                      segmentedRouteCoordinates.containsKey(2))
                    Polyline(
                      points: segmentedRouteCoordinates[2]!,
                      strokeWidth: 8.0,
                      color: Colors.black,
                    ),
                  // orange route line
                  if (selectedLayer[2] &&
                      segmentedRouteCoordinates.containsKey(2))
                    Polyline(
                      points: segmentedRouteCoordinates[2]!,
                      strokeWidth: 4.0,
                      color: Colors.orange,
                    ),
                ],
              ),
            ],
          ),
          // display for the start and end locations for routing
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
          // Buttons for the user to select the desired layer
          // Updates the map display based on what the layer the user selects
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
                    // Triggers a rebuild of FlutterMap with updated layers
                    setState(() {
                      for (int buttonIndex = 0;
                          buttonIndex < selectedLayer.length;
                          buttonIndex++) {
                        selectedLayer[buttonIndex] = buttonIndex == index;
                      }
                    });
                  },
                  children: floorLayers.map((floor) => Text(floor)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
