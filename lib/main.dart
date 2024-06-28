import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Default Page')),
        body: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final FlutterTts flutterTts = FlutterTts();

  void _speak(texts) async {
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak("$texts");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Padding(
          padding:  EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  <Widget>[
              Expanded(
                child: Center(
                  child: Text(
                    'where you go ?',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: null,  // 需要添加功能
              ),
            ],
          ),
        ),
        OptionButton(label: 'Home', onTap: () {_speak('home');}),
        OptionButton(label: 'Work place', onTap: () {_speak('work');}),
        OptionButton(label: 'Saved place', onTap: () {_speak('save place');}),
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: FloatingActionButton(
            onPressed: () {
              _speak('Please say your destination');
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.mic),
          ),
        ),
      ],
    );
  }
}

class OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const OptionButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(label),
      ),
    );
  }
}
