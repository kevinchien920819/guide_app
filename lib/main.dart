import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'pages/login_page.dart'; // 导入 LoginScreen
import 'pages/map_page.dart'; // 导入 MapScreen
import 'services/speech_to_text_service.dart';

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
  // Flutter tts service 
  final FlutterTts flutterTts = FlutterTts();
  void _speak(String texts) async {
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(texts);
    await flutterTts.setVolume(1.0);
  }

  // login info and login sucess
  bool _isLoggedIn = false; // 檢查是否登入
  void _loginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  // Speech to text service
  final SpeechToTextService _speechToTextService = SpeechToTextService();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await _speechToTextService.initSpeechState();
    setState(() {});
  }

  void _toggleListening() {
    if (_isListening) {
      _speechToTextService.stopListening();
      _speak('你剛剛說$_lastWords');
    } else {
      _speechToTextService.startListening((result) {
        setState(() {
          _lastWords = result;
        });
      });
    }
    setState(() {
      _isListening = !_isListening;
    });
  }


  // void _onSpeechResult(String result) {
  //   setState(() {
  //     _lastWords = result;
  //     print(_lastWords);
  //   });
  // }

  // controller for source and destination
  final sourceController = TextEditingController();
  final destinationController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sourceController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.account_circle),
            iconSize: 50,
            onPressed: () {
              if (_isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Already logged in')));
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Center(
                  child: Text(
                    'Where do you want to go ?',
                    style: TextStyle(fontSize: 20),
                  ),
                )),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text("Source Location"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: Center(
                  child: TextField(
                    controller: sourceController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      hintText: 'Enter Source Location here',
                    ),
                  ),
                )),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text("Destination Location"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: TextField(
                      controller: destinationController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                        hintText: 'Enter Destination Location here',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: ElevatedButton(
                    child: const Text('Search'),
                    onPressed: () {
                      _speak('search');
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MapPage(
                                    source: sourceController.text,
                                    destination: destinationController.text,
                                  )));
                    },
                  ),
                ),
              ],
            ),
          ),
          OptionButton(
              label: 'Home',
              onTap: () {
                _speak('home');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapPage(
                              source: sourceController.text,
                              destination: destinationController.text,
                            )));
              }),
          OptionButton(
              label: 'Work place',
              onTap: () {
                _speak('work');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapPage(
                              source: sourceController.text,
                              destination: destinationController.text,
                            )));
              }),
          OptionButton(
              label: 'Saved place',
              onTap: () {
                _speak('save place');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapPage(
                              source: sourceController.text,
                              destination: destinationController.text,
                            )));
              }),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: FloatingActionButton(
              tooltip: '聆聽',
              onPressed: () {
                if(!_isListening){
                  _speak('Please say your destination');
                }

                _toggleListening();

                
              },
              backgroundColor: Colors.white,
              child: Icon(_isListening ? Icons.mic : Icons.mic_off),
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
