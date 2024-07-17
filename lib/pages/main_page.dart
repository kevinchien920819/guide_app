import 'package:flutter/material.dart';
import 'package:flutter_guide_app/services/dialog_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../pages/login_page.dart';
import '../pages/map_page.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../components/optionbutton.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  // Flutter tts service 
  final FlutterTts flutterTts = FlutterTts();
  void _speak(String texts) async {
    await flutterTts.setLanguage("zh-TW");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(texts);
    // await flutterTts.setVolume(1.0);
  }

  // login info and login success
  bool _isLoggedIn = false; // 檢查是否登入
  void _loginSuccess() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  List<stt.LocaleName> _locales = [];
  stt.LocaleName? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
  }

  void _initSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: _statusListener,
      onError: _errorListener,
    );
    if (available) {
      var locales = await _speechToText.locales();
      setState(() {
        _locales = locales;
        // 設定預設值為中文
        _selectedLocale = _locales.firstWhere(
          (locale) => locale.name.contains('Chinese, Traditional (Taiwan)'),
          orElse: () => _locales.first,
        );
      });
    }
  }

  void _statusListener(String status) {
    setState(() {
      _isListening = _speechToText.isListening;
    });
  }

  void _errorListener(SpeechRecognitionError error) {
    DialogService.showErrorDialog(context,'Error: $error');
  }

  void _resultListener(SpeechRecognitionResult result) {
    setState(() {
      _text = result.recognizedWords;
    });
  }

  void _startListening() {
    _speechToText.listen(
      onResult: _resultListener,
      localeId: _selectedLocale!.localeId,
    );
  }

  void _stopListening() {
    _speechToText.stop();
  }

  // controller for source and destination
  final sourceController = TextEditingController(text: '現在位置');
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
            padding: EdgeInsets.all(12.0),
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
            padding: const EdgeInsets.all(10.0),
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
            padding: const EdgeInsets.all(10.0),
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
                      // _speak('search');
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
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<stt.LocaleName>(
              value: _selectedLocale,
              onChanged: (stt.LocaleName? newValue) {
                setState(() {
                  _selectedLocale = newValue;
                });
              },
              items: _locales.map<DropdownMenuItem<stt.LocaleName>>((stt.LocaleName locale) {
                return DropdownMenuItem<stt.LocaleName>(
                  value: locale,
                  child: Text(locale.name),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Expanded(
              child: Center(
                child: Text(
                  _isListening ? 'Listening...' : _text,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              tooltip: 'microphone',
              onPressed: () {
                if (_isListening) {
                  _stopListening();
                } else {
                  _startListening();
                }
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
