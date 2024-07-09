import 'dart:async'; // For asynchronous operations
import 'package:flutter/material.dart'; // Flutter core UI library
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Google Maps Flutter plugin
import 'package:location/location.dart'; // For getting device's current location
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding and decoding
import '../constants/constants.dart'; // Project constants
import '../services/location_service.dart'; // Location service
import '../services/dialog_service.dart'; // Dialog service
import '../services/polyline_service.dart'; // Polyline service

class MapPage extends StatefulWidget {
  final String source; // Source address
  final String destination; // Destination address
  const MapPage({super.key, required this.source, required this.destination});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location(); // Location controller
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>(); // Map controller

  LatLng? _currentP; // Current location
  LatLng? _sourceLocation; // Source location
  LatLng? _destinationLocation; // Destination location

  BitmapDescriptor? customIcon; // Custom icon for the marker
  Map<PolylineId, Polyline> polylines = {}; // Polyline collection

  @override
  void initState() {
    super.initState();
    _setCustomMarker(); // Set custom marker icon
    _getLatLngFromAddress(widget.source, true); // Get source location
    _getLatLngFromAddress(widget.destination, false); // Get destination location
  }

  // Set custom marker icon
  void _setCustomMarker() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/user_location.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null || _sourceLocation == null || _destinationLocation == null
          ? const Center(child: CircularProgressIndicator()) // Show progress indicator if locations are not yet available
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller); // Set map controller when the map is created
              },
              initialCameraPosition: CameraPosition(
                target: _sourceLocation!,
                zoom: 12.0, // Set initial camera position to the source location
              ),
              markers: {
                if (_currentP != null)
                  Marker(
                    markerId: const MarkerId('_currentLocation'),
                    position: _currentP!,
                    icon: customIcon ?? BitmapDescriptor.defaultMarker,
                    infoWindow: const InfoWindow(title: 'Current Location'),
                  ),
                if (_sourceLocation != null)
                  Marker(
                    markerId: const MarkerId('_sourceLocation'),
                    position: _sourceLocation!,
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: widget.source),
                  ),
                if (_destinationLocation != null)
                  Marker(
                    markerId: const MarkerId('_destinationLocation'),
                    position: _destinationLocation!,
                    icon: BitmapDescriptor.defaultMarker,
                    infoWindow: InfoWindow(title: widget.destination),
                  ),
              },
              polylines: Set<Polyline>.of(polylines.values), // Add polylines to the map
            ),
    );
  }

  // Move camera to the specified position
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13.0,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  // Get latitude and longitude from address
  Future<void> _getLatLngFromAddress(String address, bool isSource) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=${Constants.googleApiKey}';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);

    if (json['status'] == 'OK') {
      final lat = json['results'][0]['geometry']['location']['lat'];
      final lng = json['results'][0]['geometry']['location']['lng'];
      setState(() {
        if (isSource) {
          _sourceLocation = LatLng(lat, lng); // Set source latitude and longitude
        } else {
          _destinationLocation = LatLng(lat, lng); // Set destination latitude and longitude
        }
        getLocationUpdates().then(
          (_) => {
            getPolylinePoints().then((coordinates) => {
                  generatePolyLineFromPoints(coordinates), // Draw the polyline
                }),
          },
        );
      });
    } else {
      // ignore: use_build_context_synchronously
      DialogService.showErrorDialog(context, 'Error: ${json['error_message']}');
    }
  }

  // Get location updates
  Future<void> getLocationUpdates() async {
    LocationService.getLocationUpdates(_locationController, (LatLng position) {
      setState(() {
        _currentP = position; // Update current location
        //TODO: Uncomment the following line to move the camera to the current location
        _cameraToPosition(_currentP!);
      });
    });
  }

  // Get polyline points
  Future<List<LatLng>> getPolylinePoints() async {
    return await PolylineService.getPolylinePoints(
        _sourceLocation, _destinationLocation, Constants.googleApiKey, DialogService.showErrorDialog, context);
  }

  // Generate polyline from points
  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);

    setState(() {
      polylines[id] = polyline; // Add polyline to the collection
    });
  }
}
