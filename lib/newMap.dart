import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GetLocation extends StatefulWidget {
  const GetLocation({super.key});

  @override
  State<GetLocation> createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  late String lat, long;
  String locationMessage ="Current Location:";
  Future<Position> getCurrentLocation () async{
    bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
  return await Geolocator.getCurrentPosition();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          SizedBox(height: 50,),
          Text(locationMessage,textAlign: TextAlign.center,),
          ElevatedButton(onPressed: (){
            getCurrentLocation().then((value) {
              lat= '${value.latitude}';
              long= '${value.longitude}';
              setState(() {
                locationMessage= "Current Location: latitude: $lat ,longitude: $long";
              });
            });
          }, child: Text("press"))
        ],
      )),
    );
  }
}