// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/flutter_mapbox_navigation.dart';

class SampleNavigationApp extends StatefulWidget {
  final double sourceLocationlat;
  final double sourceLocationlon;
  final double destinationLocationlat;
  final double destinationLocationlon;

  const SampleNavigationApp(
      {super.key,
      required this.sourceLocationlat,
      required this.sourceLocationlon,
      required this.destinationLocationlat,
      required this.destinationLocationlon});

  @override
  State<SampleNavigationApp> createState() => _SampleNavigationAppState();
}

class _SampleNavigationAppState extends State<SampleNavigationApp> {
  final home =
      WayPoint(name: "Start", latitude: 0.0, longitude: 0.0, isSilent: false);

  final store =
      WayPoint(name: "End", latitude: 0.0, longitude: 0.0, isSilent: false);

  final bool _isMultipleStop = false;
  MapBoxNavigationViewController? _controller;

  bool _routeBuilt = false;
  bool _isNavigating = false;
  late MapBoxOptions _navigationOption;

  @override
  void initState() {
    super.initState();
    home.latitude = widget.sourceLocationlat;
    home.longitude = widget.sourceLocationlon;
    store.latitude = widget.destinationLocationlat;
    store.longitude = widget.destinationLocationlon;

    initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    if (!mounted) return;

    _navigationOption = MapBoxNavigation.instance.getDefaultOptions();
    _navigationOption.simulateRoute = true;
    _navigationOption.language = "zh-TW";

    // setState(() {
    //   var wayPoints = <WayPoint>[];
    //   wayPoints.add(home);
    //   wayPoints.add(store);
    //   // print(wayPoints);
    //   _isMultipleStop = wayPoints.length > 2;
    //   _controller?.buildRoute(wayPoints: wayPoints, options: _navigationOption);
    //   _controller?.startNavigation();
    // });
    MapBoxNavigation.instance.registerRouteEventListener(_onEmbeddedRouteEvent);

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              // Expanded(
              //   child: SingleChildScrollView(
              //     child: Column(
              //       children: [
              //         const SizedBox(height: 10),
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             ElevatedButton(
              //               onPressed:
              //               child: Text(_routeBuilt && !_isNavigating
              //                   ? "Clear Route"
              //                   : "Build Route"),
              //             ),
              //             const SizedBox(width: 10),
              //             ElevatedButton(
              //               onPressed:
              //               child: const Text('Start '),
              //             ),
              //             const SizedBox(width: 10),
              //             ElevatedButton(
              //               onPressed: _isNavigating
              //                   ? () {
              //                       _controller?.finishNavigation();
              //                     }
              //                   : null,
              //               child: const Text('Cancel '),
              //             )
              //           ],
              //         ),
              //         const Center(
              //           child: Padding(
              //             padding: EdgeInsets.all(10),
              //             child: Text(
              //               "Long-Press Embedded Map to Set Destination",
              //               textAlign: TextAlign.center,
              //             ),
              //           ),
              //         ),
              //         const Divider()
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 600,
                child: Container(
                  color: Colors.grey,
                  child: MapBoxNavigationView(
                      options: _navigationOption,
                      onRouteEvent: _onEmbeddedRouteEvent,
                      onCreated:
                          (MapBoxNavigationViewController controller) async {
                        _controller = controller;
                        _controller?.initialize();

                        var wayPoints = <WayPoint>[];
                        wayPoints.add(home);
                        wayPoints.add(store);
                        MapBoxNavigation.instance.startNavigation(
                                wayPoints: wayPoints,
                                options: MapBoxOptions(
                                    mode: MapBoxNavigationMode.driving,
                                    simulateRoute: false,
                                    language: "zh-TW",
                                    allowsUTurnAtWayPoints: true,
                                    units: VoiceUnits.metric));
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onEmbeddedRouteEvent(e) async {
    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        if (progressEvent.currentStepInstruction != null) {}
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        setState(() {
          _routeBuilt = true;
        });
        break;
      case MapBoxEvent.route_build_failed:
        setState(() {
          _routeBuilt = false;
        });
        break;
      case MapBoxEvent.navigation_running:
        setState(() {
          _isNavigating = true;
        });
        break;
      case MapBoxEvent.on_arrival:
        if (!_isMultipleStop) {
          await Future.delayed(const Duration(seconds: 3));
          await _controller?.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        setState(() {
          _routeBuilt = false;
          _isNavigating = false;

        });
        Navigator.pop(context);
        break;
      default:
        break;
    }
    setState(() {});
  }
}
