import 'package:text_to_speech/text_to_speech.dart';

class TextToSpeechState{
  final TextToSpeech _tts = TextToSpeech();
  var languages = [];
  String? language;
  String? languageCode;
  List<String> languageCodes = [];
  String? voice;


  void initTextToSpeech() async{
    languageCodes = await _tts.getLanguages();
    // get default language
    final String? defaultLangCode = await _tts.getDefaultLanguage();
    if (defaultLangCode != null && languageCodes.contains(defaultLangCode)) {
      languageCode = defaultLangCode;
    } else {
      languageCode = languages.first.code;
    }
    // get voice
    voice = await getVoiceByLang(languageCode!);
  }

  void start(String message) {
    if (languageCode != null) {
      _tts.setLanguage(languageCode!);
    }
    _tts.setVolume(1.0);
    _tts.speak(message);
  }

  void stop(){
    _tts.stop();
  }

  Future<String?> getVoiceByLang(String lang) async {
    List<String> voices = await _tts.getVoiceByLang(languageCode!);
    if (voices.isNotEmpty) {
      return voices.first;
    }
    return null;
  }
}