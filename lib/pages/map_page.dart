import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class MapScreen extends StatefulWidget {
//   final String destination;
//   const MapScreen({Key? key, required this.destination}) : super(key: key);

//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   late GoogleMapController mapController;
//   Set<Polyline> _polylines = Set<Polyline>();

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     _getRoute();
//   }

//   void _getRoute() async {
//     String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=你的起始位置&destination=${widget.destination}&key=你的API金鑰';
//     var response = await http.get(Uri.parse(url));
//     var json = jsonDecode(response.body);

//     var route = json['routes'][0]['overview_polyline']['points'];
//     var points = _convertToLatLng(_decodePoly(route));
//     setState(() {
//       _polylines.add(Polyline(
//         polylineId: PolylineId('route1'),
//         visible: true,
//         points: points,
//         width: 4,
//         color: Colors.blue,
//         startCap: Cap.roundCap,
//         endCap: Cap.roundCap,
//       ));
//     });
//   }

//   List<LatLng> _convertToLatLng(List points) {
//     List<LatLng> result = <LatLng>[];
//     for (int i = 0; i < points.length; i++) {
//       if (i % 2 != 0) {
//         result.add(LatLng(points[i - 1], points[i]));
//       }
//     }
//     return result;
//   }

//   List _decodePoly(String poly) {
//     var list = poly.codeUnits;
//     var lList = new List();
//     int index = 0;
//     int len = poly.length;
//     int c = 0;
//     // repeating until all attributes are decoded
//     do {
//       var shift = 0;
//       int result = 0;

//       // for decoding value of one attribute
//       do {
//         c = list[index] - 63;
//         result |= (c & 0x1F) << shift;
//         index++;
//         shift += 5;
//       } while (c >= 32);
//       // if value is negetive then bitwise not the value
//       if (result & 1 == 1) {
//         result = ~result;
//       }
//       var result1 = (result >> 1) * 0.00001;
//       lList.add(result1);
//     } while (index < len);

//     //adding latitude and longitude successively to the list
//     for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

//     return lList;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Map to ' + widget.destination)),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         polylines: _polylines,
//         initialCameraPosition: CameraPosition(
//           target: LatLng(25.0330, 121.5654), //預設位置，可以修改
//           zoom: 14.0,
//         ),
//       ),
//     );
//   }
// }
