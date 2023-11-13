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
  // List of the names of the layers
  // TODO: Make this a 2-d array
  List<String> layerGeoserver = [
    'outdoors_all',
    'outdoors_ada',
  ];

  //Tracks current layer index
  int currentLayerIndex = 0;

  //Tracks level layer, true or false
  List<bool> isSelected = [true, false];

  @override
  void initState() {
    super.initState();
    initializeNodes(); // initialize nodes and their neighbors
    //drawRoute(); // initiatlize route drawing
  }

  List<LatLng> routeCoordinates = [];

  void drawRoute(Node start, Node goal) {
    // perform a* search
    var path = aStarSearch(start, goal);

    // convert the path to a list of LatLng
    if (path != null) {
      routeCoordinates = path.map((node) => node.coords).toList();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      // Collapsible Menu
      drawer: AppDrawer(),

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
