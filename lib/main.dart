import 'package:flutter/material.dart';
// import 'package:flutter_guide_app/services/test.dart';
import 'package:flutter_guide_app/pages/main_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  const MainPage(),
    );
  }
}
