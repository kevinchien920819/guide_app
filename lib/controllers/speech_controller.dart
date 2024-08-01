import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';

class SpeechController extends GetxController {
  final stt.SpeechToText speechToText = stt.SpeechToText();
  var isListening = false.obs;
  var text = ''.obs;
  var selectedLocale = stt.LocaleName('en_US', 'English').obs;
  var locales = <stt.LocaleName>[].obs;

  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initSpeechToText();
  }

  void _initSpeechToText() async {
    bool available = await speechToText.initialize(
      onStatus: _statusListener,
      onError: _errorListener,
    );
    if (available) {
      locales.value = await speechToText.locales();
      selectedLocale.value = locales.firstWhere(
        (locale) => locale.name == 'Chinese, Traditional (Taiwan)',
        orElse: () => locales.first,
      );
    }
  }

  void _statusListener(String status) {
    isListening.value = speechToText.isListening;
  }

  void _errorListener(dynamic error) {
    // 处理错误的逻辑
    print('Error: $error');
  }

  void startListening() {
    speechToText.listen(
      onResult: (result) {
        text.value = result.recognizedWords;
      },
      localeId: selectedLocale.value.localeId,
    );
  }

  void stopListening() {
    speechToText.stop();
  }

  @override
  void onClose() {
    sourceController.dispose();
    destinationController.dispose();
    super.onClose();
  }
}
