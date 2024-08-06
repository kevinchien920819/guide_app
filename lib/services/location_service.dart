import 'dart:async';
import 'dart:convert';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_guide_app/constants/constants.dart';

class LocationService {
  static StreamSubscription<LocationData>? _locationSubscription;
  static List<String>? instructions = [];
  static Future<void> getLocationUpdates(Location locationController, Function(LatLng) onUpdate) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationSubscription = locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        onUpdate(LatLng(currentLocation.latitude!, currentLocation.longitude!));
      }
    });
  }

  static void stopLocationUpdates() {
    _locationSubscription?.cancel();
  }

  static Future<LocationData> getCurrentLocation(Location locationController) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        return Future.error('Location service is disabled');
      }
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return Future.error('Location permission is denied');
      }
    }

    return await locationController.getLocation();
  }

  // TODO: get instruction from location using mapbox API
static Future<List<String>> getInstructions(LatLng origin, LatLng destination, String mode) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=${Constants.googleApiKey}';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List steps = data['routes'][0]['legs'][0]['steps'];
      return steps.map((step) => _removeHtmlTags(step['html_instructions'].toString())).toList();
    } else {
      throw Exception('Failed to load directions');
    }
  }

  static String _removeHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }
}
