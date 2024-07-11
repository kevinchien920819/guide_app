// import 'package:speech_to_text/speech_to_text.dart';
// class SpeechToTextService {
//   final SpeechToText _speechToText = SpeechToText();
//   // bool available = await speech.initialize( onStatus: statusListener, onError: errorListener );
//   // if ( available ) {
//   //   speech.listen( onResult: resultListener );
//   // }
//   // else {
//   //   print("The user has denied the use of speech recognition.");
//   // }

//   Future<void> initSpeechState() async {
//     await _speechToText.initialize(onStatus: statusListener, onError: errorListener );
//     var locales = await _speechToText.locales();

//    // Some UI or other code to select a locale from the list
//    // resulting in an index, selectedLocale

//     var selectedLocale = locales[selectedLocale];
//    _speechToText.listen(
//        onResult: resultListener,
//        localeId: selectedLocale.localeId,
//        );
//   }

//   void startListening(Function(String) onResult) {
//     _speechToText.listen(onResult: (result) {
//       onResult(result.recognizedWords);
//     });
//   }

//   void stopListening() {
//     _speechToText.stop();
//   }
// }
