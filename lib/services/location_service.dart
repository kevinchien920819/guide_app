import 'dart:async';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  static StreamSubscription<LocationData>? _locationSubscription;

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
}
