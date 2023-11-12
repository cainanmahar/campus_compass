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
  List<String> layerGeoserver = [
    'outdoors',
    '',
  ];

 

  //Tracks current layer index
  int currentLayerIndex = 0;

  //Tracks level layer, true or false
  List<bool> isSelected = [true, false];

  @override
 void initState() {
    super.initState();
    initializeNodes(); // initialize nodes and their neighbors
    drawRoute(); // initiatlize route drawing
  }


  @override
  
  List<LatLng> routeCoordinates = [];

  void drawRoute(){
    // perform a* search
    var path = aStarSearch(lib, ab1);

    // convert the path to a list of LatLng
    if (path != null) {
      routeCoordinates = path.map((node) => LatLng(node.x, node.y)).toList();
    }
  
  setState(() {
    
  });
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
            options: MapOptions(
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(30.926847, -96.762604),
                  const LatLng(29.066889, -93.930492),
                ),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              initialCenter:
                  const LatLng(30.714786150948303, -95.54705543100049),
              initialZoom: 19.5,
            ),
            children: [
              TileLayer(
                wmsOptions: WMSTileLayerOptions(
                  baseUrl: "http://144.126.221.0:8080/geoserver/wms/?",
                  layers: [layerGeoserver[currentLayerIndex]],
                ),
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
