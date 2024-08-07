import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class RoutePage extends StatelessWidget {
  final LatLng origin;
  final LatLng destination;
  final String mode;

  const RoutePage({super.key, required this.origin, required this.destination, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Page Component'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RouteForm(
        origin: origin,
        destination: destination,
        mode: mode,
      ),
    );
  }
}

class RouteForm extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final String mode;

  const RouteForm({super.key, required this.origin, required this.destination, required this.mode});

  @override
<<<<<<< HEAD
  RouteFormState createState() => RouteFormState();
}

class RouteFormState extends State<RouteForm> {
=======
  _RouteFormState createState() => _RouteFormState();
}

class _RouteFormState extends State<RouteForm> {
>>>>>>> main
  List<String> instructions = [];

  @override
  void initState() {
    super.initState();
    getRouteText();
  }

  Future<void> getRouteText() async {
    List<String> routeInstructions = await LocationService.getInstructions(widget.origin, widget.destination, widget.mode);
<<<<<<< HEAD
    if (mounted) {
      setState(() {
        instructions = routeInstructions;
      });
    }
=======
    setState(() {
      instructions = routeInstructions;
    });
>>>>>>> main
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: instructions.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.grey, // 設定底色
            border: Border.all(color: Colors.blueGrey, width: 2.0), // 設定邊界顏色和寬度
            borderRadius: BorderRadius.circular(10.0), // 設定圓角
          ),
          child: Text(
            instructions[index],
            style: const TextStyle(
              color: Colors.black, // 設定文字顏色
              fontSize: 16.0, // 設定文字大小
              fontWeight: FontWeight.bold, // 設定文字粗體
            ),
          ),
        );
      },
    );
  }
}
