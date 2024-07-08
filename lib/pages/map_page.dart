import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_guide_app/constants/constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng _taipeistation = LatLng(25.0474, 121.5171);
  static const LatLng _taipei101 = LatLng(25.033671, 121.564427);
  LatLng? _currentP;
  // custom the position icon
  BitmapDescriptor? customIcon;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then(
      (_) => {
        getPolylinePoints().then((coordinates) => {
              generatePolyLineFromPoints(coordinates),
            }),
      },
    );
    _setCustomMarker();
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
      body: _currentP == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
              initialCameraPosition: const CameraPosition(
                target: _taipei101,
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
                const Marker(
                  markerId: MarkerId('_sourceLocation'),
                  position: _taipei101,
                  icon: BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(title: 'Taipei 101'),
                ),
                const Marker(
                  markerId: MarkerId('_destinationLocation'),
                  position: _taipeistation,
                  icon: BitmapDescriptor.defaultMarker,
                  infoWindow: InfoWindow(title: 'Taipei Station'),
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13.0,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Constants.googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(_taipei101.latitude, _taipei101.longitude),
        destination:
            PointLatLng(_taipeistation.latitude, _taipeistation.longitude),
        mode: TravelMode.walking,
        // wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")],
      ),
    );
    print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 8);

    setState(() {
      polylines[id] = polyline;
    });
  }
}
