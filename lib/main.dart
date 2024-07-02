import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'pages/login_page.dart'; // 导入 LoginScreen
import 'pages/map_page.dart'; // 导入 MapScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
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
  bool _isLoggedIn = false; // 檢查是否登入

// 語音合成
  void _speak(String texts) async {
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(texts);
  }

// 登入成功
  void _loginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  // void _navigateTo(String destination) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => MapScreen(destination: destination),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Default Page'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              if (_isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Already logged in'))
                );
                _speak('you have already logged in');
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(
                      onLoginSuccess: _loginSuccess,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Expanded(
                  child: Center(
                    child: Text(
                      'where you go ?',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _speak('search');
                  },
                ),
              ],
            ),
          ),
          OptionButton(label: 'Home', onTap: () {_speak('home'); Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));}),
          OptionButton(label: 'Work place', onTap: () {_speak('work'); Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));}),
          OptionButton(label: 'Saved place', onTap: () {_speak('save place'); Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));}),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: FloatingActionButton(
              onPressed: () {
                _speak('Please say your destination');
                // 在这里，你应该集成你的语音识别功能以获取地址。
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.mic),
            ),
          ),
        ],
      ),
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
