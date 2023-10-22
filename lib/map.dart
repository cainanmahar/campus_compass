import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:campus_compass/app_drawer.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      // Collapsible Menu
      drawer: const AppDrawer(),

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
              initialCenter:
                  const LatLng(30.309020846648558, -95.41179374141295),
            ),
            children: [
              TileLayer(
                wmsOptions: WMSTileLayerOptions(
                  baseUrl: "http://164.92.112.125:8080/geoserver/ne/wms/?",
                  layers: const ["ne:world"],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
