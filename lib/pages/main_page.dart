import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/dialog_service.dart';
import '../controllers/login_controller.dart';
import '../controllers/speech_controller.dart';
import '../components/optionbutton.dart';
import '../databases/db_helper.dart';
import 'login_page.dart';
import 'map_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final loginController = Get.put(LoginController());
  final speechController = Get.put(SpeechController());
  final FlutterTts flutterTts = FlutterTts();
  final RxList<String> favoritePlaces = <String>[].obs; // 喜愛地點的列表

  @override
  void initState() {
    super.initState();
    if(loginController.isLoggedIn.value){
      _loadFavoritePlaces(); // 在初始化時加載喜愛地點
    }
  }

  void _loadFavoritePlaces() async {
    try {
      final dbHelper = DbHelper();
      final places = await dbHelper.getFavoritePlaces(loginController.emailController.text); // 從資料庫中讀取喜愛地點
      favoritePlaces.assignAll(places.map((place) => "${place['place']},${place['lat']}, ${place['lng']}").toList());
      print(favoritePlaces);
    } catch (e) {
      // 處理可能發生的錯誤
      DialogService.showErrorDialog(Get.overlayContext!, e.toString());
    }
  }

  void _speak(String text) async {
    try {
      await flutterTts.setLanguage('zh-TW');
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
      // TODO: Check this is available 
      await flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker]);
    } catch (e) {
      // prindit("TTS Error: $e");
      DialogService.showErrorDialog(Get.overlayContext!, e.toString());
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
                Get.to(() => const LoginScreen());
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
          // 動態生成 OptionButton 列表
          Obx(() {
            return Column(
              children: favoritePlaces.map((place) {
                return OptionButton(
                  label: place.split(',')[0],
                  onTap: () {
                    _speak(place.split(',')[0]);
                    Get.to(() => MapPage(
                          source: speechController.sourceController.text,
                          destination: place.split(',')[0],
                        ));
                  },
                );
              }).toList(),
            );
          }),
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
