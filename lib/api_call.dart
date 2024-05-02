import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CallApi {
  Future<void> pathPoints(double v1, double v2, double v3, double v4, List<LatLng> routpoints ) async{
    var url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
    var response = await http.get(url);
    print(response.body);
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
    print(routpoints);
  }
}