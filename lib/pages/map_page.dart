import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_guide_app/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  final String source;
  final String destination;
  const MapPage({super.key, required this.source, required this.destination});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location(); // 控制位置獲取
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>(); // 控制地圖

  LatLng? _currentP; // 當前位置
  LatLng? _sourceLocation; // 起點位置
  LatLng? _destinationLocation; // 終點位置

  BitmapDescriptor? customIcon; // 自定義圖標
  Map<PolylineId, Polyline> polylines = {}; // 多段線地圖

  @override
  void initState() {
    super.initState();
    _setCustomMarker(); // 設置自定義標記
    _getLatLngFromAddress(widget.source, true); // 獲取起點經緯度
    _getLatLngFromAddress(widget.destination, false); // 獲取終點經緯度
  }

  // 設置自定義標記圖標
  void _setCustomMarker() async {
    customIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(20, 20)),
      'assets/user_location.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null ||
              _sourceLocation == null ||
              _destinationLocation == null
          ? const Center(child: CircularProgressIndicator()) // 加載指示器
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller); // 地圖創建完成
              },
              initialCameraPosition: CameraPosition(
                target: _sourceLocation!, // 初始相機位置
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
              polylines: Set<Polyline>.of(polylines.values), // 設置路徑
            ),
    );
  }

  // 相機移動到指定位置
  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13.0,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPosition));
  }

  // 獲取位置更新
  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 檢查服務是否啟用
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // 檢查權限
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // 監聽位置變化
    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          // _cameraToPosition(_currentP!);
        });
      }
    });
  }

  // 根據地址獲取經緯度
  Future<void> _getLatLngFromAddress(String address, bool isSource) async {
    print(address);
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=${Constants.googleApiKey}';
    print(url);
    final response = await http.get(Uri.parse(url));
    // print(response.body);
    final json = jsonDecode(response.body);

    if (json['status'] == 'OK') {
      final lat = json['results'][0]['geometry']['location']['lat'];
      final lng = json['results'][0]['geometry']['location']['lng'];
      // print(lat);
      // print(lng);
      setState(() {
        if (isSource) {
          _sourceLocation = LatLng(lat, lng);
        } else {
          _destinationLocation = LatLng(lat, lng);
        }
        getLocationUpdates().then(
          (_) => {
            getPolylinePoints().then((coordinates) => {
                  generatePolyLineFromPoints(coordinates), // 獲取並生成路徑
                }),
          },
        );
      });
    } else {
      print('Error: ${json['error_message']}');
    }
  }

  // 獲取路徑點
  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    if (_sourceLocation == null || _destinationLocation == null)
      return polylineCoordinates;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: Constants.googleApiKey,
      request: PolylineRequest(
        origin:
            PointLatLng(_sourceLocation!.latitude, _sourceLocation!.longitude),
        destination: PointLatLng(
            _destinationLocation!.latitude, _destinationLocation!.longitude),
        mode: TravelMode.walking,
      ),
    );
    print(result.points);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print('error get polyline${result.errorMessage}');
    }
    return polylineCoordinates;
  }

  // 生成多段線
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
