import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

class SampleNavigationApp extends StatefulWidget {
  final double sourceLocationlat;
  final double sourceLocationlon;
  final double destinationLocationlat;
  final double destinationLocationlon;

  const SampleNavigationApp({
    super.key,
    required this.sourceLocationlat,
    required this.sourceLocationlon,
    required this.destinationLocationlat,
    required this.destinationLocationlon,
  });

  @override
  State<SampleNavigationApp> createState() => _SampleNavigationAppState();
}

class _SampleNavigationAppState extends State<SampleNavigationApp> {
  final WayPoint home = WayPoint(name: "Start", latitude: 0.0, longitude: 0.0, isSilent: false);
  final WayPoint store = WayPoint(name: "End", latitude: 0.0, longitude: 0.0, isSilent: false);

  MapBoxNavigationViewController? _controller;
  late MapBoxOptions _navigationOption;

  @override
  void initState() {
    super.initState();
    _setupNavigation();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _setupNavigation() {
    home.latitude = widget.sourceLocationlat;
    home.longitude = widget.sourceLocationlon;
    store.latitude = widget.destinationLocationlat;
    store.longitude = widget.destinationLocationlon;

    _navigationOption = MapBoxOptions(
      mode: MapBoxNavigationMode.driving,
      simulateRoute: true,
      language: "en",
      allowsUTurnAtWayPoints: true,
      units: VoiceUnits.metric,
    );

    MapBoxNavigation.instance.registerRouteEventListener(_onRouteEvent);
    _startNavigation();
  }

  void _startNavigation() {
    var wayPoints = <WayPoint>[home, store];
    MapBoxNavigation.instance.startNavigation(
      wayPoints: wayPoints,
      options: _navigationOption,
    );
  }

  Future<void> _onRouteEvent(RouteEvent e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        // 處理進度變更事件
        break;
      case MapBoxEvent.route_building:
        // 處理路線構建事件
        break;
      case MapBoxEvent.route_built:
        // 處理路線已構建事件
        break;
      case MapBoxEvent.route_build_failed:
        // 處理路線構建失敗事件
        break;
      case MapBoxEvent.navigation_running:
        // 處理導航進行中事件
        break;
      case MapBoxEvent.on_arrival:
        // 處理到達事件
        await Future.delayed(const Duration(seconds: 3));
        await MapBoxNavigation.instance.finishNavigation();
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        // 處理導航完成或取消事件
        await MapBoxNavigation.instance.finishNavigation();
        Navigator.pop(context);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // 如果需要顯示 UI，可以在這裡構建視圖
    );
  }
}
