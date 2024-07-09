import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

class PolylineService {
  static Future<List<LatLng>> getPolylinePoints(
      LatLng? sourceLocation, LatLng? destinationLocation, String googleApiKey, Function(BuildContext, String) showErrorDialog, BuildContext context) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    if (sourceLocation == null || destinationLocation == null) {
      return polylineCoordinates;
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey:Constants.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        destination: PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
        mode: TravelMode.walking,
      ),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      showErrorDialog(context, 'error get polyline${result.errorMessage}');
    }
    return polylineCoordinates;
  }
}
