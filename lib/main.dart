import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request location permission
  var status = await Permission.location.request();
  if (status.isGranted) {
    runApp(const MyApp());
  } else {
    // Handle if permission is denied
    print("Location permission is required to use the app.");
    // Optionally, you can inform the user about the necessity of location permission and guide them to enable it
  }
}

// MyHomePage and other classes remain the same

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
        home: const MyHomePage(title: "Flutter Map") // ,
        );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<LatLng>> routePointsFuture;
  late Future<void> tilesFuture;
  late LatLng userPosition;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    tilesFuture = Future.value(); // You can add tile fetching here if needed
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userPosition = LatLng(position.latitude, position.longitude);
        routePointsFuture = fetchRoutePoints(
          userPosition,
          const LatLng(35.85714535934493,
              10.607729620383616), // Replace with shop position
        ).whenComplete(() => setState(() {
              isLoading = false;
            }));
      });
    } catch (e) {
      print("Error getting user location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: Future.wait([routePointsFuture, tilesFuture]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  List<LatLng> routePoints = snapshot.data![0];
                  // You can access tile data using snapshot.data![1]
                  return FlutterMap(
                    options: MapOptions(
                      center: userPosition,
                      initialZoom: 13,
                      interactionOptions: const InteractionOptions(
                          flags: ~InteractiveFlag.doubleTapDragZoom),
                    ),
                    children: [
                      openStreetMapTileLayer,
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: userPosition,
                            width: 50,
                            height: 50,
                            child: const Icon(Icons.location_pin,
                                size: 60, color: Colors.red),
                          ),
                          Marker(
                            point: routePoints.first,
                            width: 60,
                            height: 60,
                            child: const Icon(Icons.person_pin_circle_rounded,
                                size: 55,
                                color: Color.fromARGB(255, 74, 3, 206)),
                          ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'dev.fleaflet.flutter_map.exemple',
      );

  Future<List<LatLng>> fetchRoutePoints(LatLng start, LatLng end) async {
    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?steps=true&annotations=true&geometries=geojson&overview=full');
    final response = await http.get(url);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = decoded['routes'] as List<dynamic>;
    if (routes.isEmpty) {
      throw Exception('No routes found');
    }
    final geometry = routes[0]['geometry']['coordinates'] as List<dynamic>;
    return geometry
        .map<LatLng>((coord) => LatLng(coord[1] as double, coord[0] as double))
        .toList();
  }
}
