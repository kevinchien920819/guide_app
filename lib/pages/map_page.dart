import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';
import '../services/location_service.dart';
import '../services/dialog_service.dart';
import '../services/polyline_service.dart';
import 'navigation_page.dart';
import 'route_page.dart';

class MapPage extends StatefulWidget {
  final String source;
  final String destination;

  const MapPage({super.key, required this.source, required this.destination});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  bool _isOnCurrentLocation = false;
  LatLng? _currentP;
  LatLng? _sourceLocation;
  LatLng? _destinationLocation;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    if (widget.source == '現在位置') {
      _isOnCurrentLocation = true;
      LocationService.getCurrentLocation(_locationController)
          .then((LocationData value) {
        _sourceLocation = LatLng(value.latitude!, value.longitude!);
      });
    } else {
      _getLatLngFromAddress(widget.source, true);
    }

    _getLatLngFromAddress(widget.destination, false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _currentP == null ||
              _sourceLocation == null ||
              _destinationLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _sourceLocation!,
                zoom: 12.0,
              ),
              myLocationEnabled: true,
              markers: _buildMarkers(),
              polylines: Set<Polyline>.of(polylines.values),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_sourceLocation != null && _destinationLocation != null) {
            LocationService.stopLocationUpdates();
            if (_isOnCurrentLocation) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NavigationPage(
                    sourceLocationlat: _sourceLocation!.latitude,
                    sourceLocationlon: _sourceLocation!.longitude,
                    destinationLocationlat: _destinationLocation!.latitude,
                    destinationLocationlon: _destinationLocation!.longitude,
                  ),
                ),
              );
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoutePage(
                      origin: _sourceLocation!,
                      destination: _destinationLocation!,
                      mode: 'driving',
                    ),
                  ));
            }
          }
        },
        label: const Text('Navigate'),
        icon: const Icon(Icons.navigation),
      ),
    );
  }

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
          _sourceLocation = LatLng(lat, lng);
        } else {
          _destinationLocation = LatLng(lat, lng);
        }
        getLocationUpdates().then(
          (_) => {
            getPolylinePoints().then((coordinates) => {
                  generatePolyLineFromPoints(coordinates),
                }),
          },
        );
      });
    } else {
      DialogService.showErrorDialog(context, 'Error: ${json['error_message']}');
    }
  }

  Future<void> getLocationUpdates() async {
    LocationService.getLocationUpdates(_locationController, (LatLng position) {
      setState(() {
        _currentP = position;
      });
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    return await PolylineService.getPolylinePoints(
        _sourceLocation!,
        _destinationLocation!,
        Constants.googleApiKey,
        DialogService.showErrorDialog,
        context);
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);

    setState(() {
      polylines[id] = polyline;
    });
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    if (_sourceLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('_sourceLocation'),
        position: _sourceLocation!,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: widget.source),
      ));
    }
    if (_destinationLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId('_destinationLocation'),
        position: _destinationLocation!,
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: widget.destination),
      ));
    }
    return markers;
  }
}
