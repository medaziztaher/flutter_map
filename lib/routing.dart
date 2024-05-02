import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;

class Routing extends StatefulWidget {
  const Routing({super.key});

  @override
  State<Routing> createState() => _RoutingState();
}

class _RoutingState extends State<Routing> {
  bool isVisible = false;
  List<LatLng> routpoints = [LatLng(52.05884, -1.345583)];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Routing"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    const LatLng firstMarkerLatLng =
                        LatLng(35.90319388119893, 10.543855822746714);
                    const LatLng secondMarkerLatLng =
                        LatLng(35.85714535934493, 10.607729620383616);
                    var v1 = firstMarkerLatLng.latitude;
                    var v2 = firstMarkerLatLng.longitude;
                    var v3 = secondMarkerLatLng.latitude;
                    var v4 = secondMarkerLatLng.longitude;
                    var url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
                      var response = await http.get(url);
                      print(response.body);
                      setState(() {
                        routpoints = [];
                        var ruter = jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
                        for(int i=0; i< ruter.length; i++){
                          var reep = ruter[i].toString();
                          reep = reep.replaceAll("[","");
                          reep = reep.replaceAll("]","");
                          var lat1 = reep.split(',');
                          var long1 = reep.split(",");
                          routpoints.add(LatLng( double.parse(lat1[1]), double.parse(long1[0])));
                        }
                        isVisible = !isVisible;
                        print(routpoints);
                      });
                  },
                  child: Text("Press")),
                  SizedBox(height: 10,),
                  SizedBox(
                  height: 500,
                  width: 400,
                  child: Visibility(
                    visible: isVisible,
                    child: FlutterMap(options:
                        MapOptions(
                          initialCenter: routpoints[0],
                          initialZoom: 13,
                          interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapDragZoom),
                        ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        const MarkerLayer(
        markers: [
           Marker(
            point: LatLng(35.90319388119893, 10.543855822746714),
            width: 50,
            height: 50,
            alignment: Alignment.topCenter,
            child: Icon(Icons.location_pin, size: 60, color: Colors.red),
          ),
          Marker(
            point: LatLng(35.85714535934493, 10.607729620383616),
            width: 60,
            height: 60,
            alignment: Alignment.topCenter,
            child: Icon(Icons.person_pin_circle_rounded, size: 55, color: Color.fromARGB(255, 74, 3, 206)),
          ),
        ],
      ),
                        PolylineLayer(
                          polylineCulling: false,
                          polylines: [
                            Polyline(points: routpoints, color: Colors.blue, strokeWidth: 4)
                          ],
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      )),
    );
  }
}
