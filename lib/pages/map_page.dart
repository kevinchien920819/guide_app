import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';
import '../services/location_service.dart';
import '../services/dialog_service.dart';
import '../services/polyline_service.dart';

class MapPage extends StatefulWidget {
  final String source;
  final String destination;
  const MapPage({super.key, required this.source, required this.destination});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng? _currentP;
  LatLng? _sourceLocation;
  LatLng? _destinationLocation;

  BitmapDescriptor? customIcon;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _setCustomMarker();
    _getLatLngFromAddress(widget.source, true);
    _getLatLngFromAddress(widget.destination, false);
  }

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
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: CameraPosition(
                target: _sourceLocation!,
                zoom: 12.0,
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
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13.0,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
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
        _sourceLocation, _destinationLocation, Constants.googleApiKey, DialogService.showErrorDialog, context);
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
}
