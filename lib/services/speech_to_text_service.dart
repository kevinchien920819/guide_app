import 'dart:async';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class SpeechToTextService {
  // ignore: unused_field
  bool _hasSpeech = false;
  // bool _logEvents = false;
  final bool _onDevice = false;
  double level = 100.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  Future<void> initSpeechState() async {
    // _logEvent('Initialize');
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        // debugLogging: _logEvents,
      );
      // 這邊設定語言依據系統設定
      if (hasSpeech) {
        _localeNames = await speech.locales();
        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      _hasSpeech = hasSpeech;
    } catch (e) {
      lastError = 'Speech recognition failed: ${e.toString()}';
      _hasSpeech = false;
    }
  }

  void startListening(Function(String) onResult) {
    // _logEvent('start listening');
    lastWords = '';
    lastError = '';
    final options = SpeechListenOptions(
      onDevice: _onDevice,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      autoPunctuation: true,
      enableHapticFeedback: true,
    );
    speech.listen(
      onResult: (SpeechRecognitionResult result) {
        onResult(result.recognizedWords);
      },
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      listenOptions: options,
    );
  }

  void stopListening() {
    // _logEvent('stop');
    speech.stop();
    level = 0.0;
  }

  void cancelListening() {
    // _logEvent('cancel');
    speech.cancel();
    level = 0.0;
  }

  void resultListener(SpeechRecognitionResult result) {
    // _logEvent('Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    lastWords = '${result.recognizedWords} - ${result.finalResult}';
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    this.level = level;
  }

  void errorListener(SpeechRecognitionError error) {
    // _logEvent('Received error status: $error, listening: ${speech.isListening}');
    lastError = '${error.errorMsg} - ${error.permanent}';
  }

  void statusListener(String status) {
    // _logEvent('Received listener status: $status, listening: ${speech.isListening}');
    lastStatus = status;
  }

  // void _switchLang(selectedVal) {
  //   _currentLocaleId = selectedVal;
  // }

  // void _logEvent(String eventDescription) {
  //   if (_logEvents) {
  //     var eventTime = DateTime.now().toIso8601String();
  //     // debugPrint('$eventTime $eventDescription');
  //   }
  }

  // void _switchLogging(bool? val) {
  //   _logEvents = val ?? false;
  // }

  // void _switchOnDevice(bool? val) {
  //   _onDevice = val ?? false;
  // }
// }
