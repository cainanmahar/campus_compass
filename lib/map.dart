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
            options: const MapOptions(),
            children: [
              TileLayer(
                wmsOptions: WMSTileLayerOptions(
                  baseUrl: "http://164.92.112.125:8080/geoserver/ne/wms",
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
