import 'package:speech_to_text/speech_to_text.dart';

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  Future<void> initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void startListening(Function(String) onResultCallback) async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: (result) {
        onResultCallback(result.recognizedWords);
      });
    }
  }

  void stopListening() async {
    await _speechToText.stop();
  }
}
