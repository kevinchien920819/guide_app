import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../controllers/login_controller.dart';
import '../controllers/speech_controller.dart';
import 'login_page.dart';
import 'map_page.dart';
import '../components/optionbutton.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final loginController = Get.put(LoginController());
  final speechController = Get.put(SpeechController());
  final FlutterTts flutterTts = FlutterTts();

  void _speak(String text) async {
    try {
      await flutterTts.setLanguage('zh-TW');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
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
              if (loginController.isLoggedIn.value) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Already logged in')));
                _speak('你已經登入了');
              } else {
                Get.to(() => LoginScreen());
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
            child: Text(
              'Where do you want to go?',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text("Source Location"),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: speechController.sourceController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                hintText: 'Enter Source Location here',
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Text("Destination Location"),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: speechController.destinationController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                hintText: 'Enter Destination Location here',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: const Text('Search'),
              onPressed: () {
                Get.to(() => MapPage(
                  source: speechController.sourceController.text,
                  destination: speechController.destinationController.text,
                ));
              },
            ),
          ),
          OptionButton(
            label: 'Home',
            onTap: () {
              _speak('home');
              Get.to(() => MapPage(
                source: speechController.sourceController.text,
                destination: speechController.destinationController.text,
              ));
            },
          ),
          OptionButton(
            label: 'Work place',
            onTap: () {
              _speak('work');
              Get.to(() => MapPage(
                source: speechController.sourceController.text,
                destination: speechController.destinationController.text,
              ));
            },
          ),
          OptionButton(
            label: 'Saved place',
            onTap: () {
              _speak('save place');
              Get.to(() => MapPage(
                source: speechController.sourceController.text,
                destination: speechController.destinationController.text,
              ));
            },
          ),
          Obx(() => DropdownButton<stt.LocaleName>(
            value: speechController.selectedLocale.value,
            onChanged: (stt.LocaleName? newValue) {
              speechController.selectedLocale.value = newValue!;
            },
            items: speechController.locales
                .map<DropdownMenuItem<stt.LocaleName>>(
                    (stt.LocaleName locale) {
                  return DropdownMenuItem<stt.LocaleName>(
                    value: locale,
                    child: Text(locale.name),
                  );
                }).toList(),
          )),
          Obx(() => Text(
            speechController.isListening.value
                ? 'Listening...'
                : speechController.text.value,
            textAlign: TextAlign.center,
          )),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton(
              tooltip: 'microphone',
              onPressed: () {
                if (speechController.isListening.value) {
                  speechController.stopListening();
                } else {
                  speechController.startListening();
                }
              },
              backgroundColor: Colors.white,
              child: Icon(speechController.isListening.value
                  ? Icons.mic
                  : Icons.mic_off),
            ),
          ),
        ],
      ),
    );
  }
}
