import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_test/routing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: "Flutter Map")// ,
    );
  }
}







class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: content(),
    );
  }

  Widget content() {
  const LatLng firstMarkerLatLng = LatLng(35.90319388119893, 10.543855822746714);
  const LatLng secondMarkerLatLng = LatLng(35.85714535934493, 10.607729620383616);

  return FutureBuilder<List<LatLng>>(
    future: fetchRoutePoints(firstMarkerLatLng, secondMarkerLatLng),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        List<LatLng>? routePoints = snapshot.data;

        return FlutterMap(
          options: const MapOptions(
            initialCenter: firstMarkerLatLng,
            initialZoom: 13,
            interactionOptions: InteractionOptions(flags: ~InteractiveFlag.doubleTapDragZoom),
          ),
          children: [
            openStreetMapTileLayer,
            const MarkerLayer(
              markers: [
                Marker(
                  point: firstMarkerLatLng,
                  width: 50,
                  height: 50,
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.location_pin, size: 60, color: Colors.red),
                ),
                Marker(
                  point: secondMarkerLatLng,
                  width: 60,
                  height: 60,
                  alignment: Alignment.topCenter,
                  child: Icon(Icons.person_pin_circle_rounded, size: 55, color: Color.fromARGB(255, 74, 3, 206)),
                ),
              ],
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: routePoints!,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        );
      } else if (snapshot.hasError) {
        return Text("Error: ${snapshot.error}");
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}
}
TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.exemple',
);

Future<List<LatLng>> fetchRoutePoints(LatLng firstMarkerLatLng, LatLng secondMarkerLatLng) async {
  var v1 = firstMarkerLatLng.latitude;
  var v2 = firstMarkerLatLng.longitude;
  var v3 = secondMarkerLatLng.latitude;
  var v4 = secondMarkerLatLng.longitude;

  var url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
  var response = await http.get(url);
  var ruter = jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];

  List<LatLng> routpoints = [];
  for (int i = 0; i < ruter.length; i++) {
    var reep = ruter[i].toString();
    reep = reep.replaceAll("[", "");
    reep = reep.replaceAll("]", "");
    var lat1 = reep.split(',');
    var long1 = reep.split(",");
    routpoints.add(LatLng(double.parse(lat1[1]), double.parse(long1[0])));
  }

  return routpoints;
}